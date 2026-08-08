import 'package:flutter/material.dart';
import 'package:field_service_app/models/work_order.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:field_service_app/models/inspection.dart';
import 'package:field_service_app/services/database_service.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';

class InspectionFormScreen extends StatefulWidget {
  final WorkOrder workOrder;
  const InspectionFormScreen({super.key, required this.workOrder});

  @override
  State<InspectionFormScreen> createState() => _InspectionFormScreenState();
}

class _InspectionFormScreenState extends State<InspectionFormScreen> {
  bool _isSaving = false;
  final DatabaseService _databaseService = DatabaseService();
  final Uuid _uuid = const Uuid();
  Position? _currentPosition;
  bool _isGettingLocation = false;
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _selectedImage;
  final TextEditingController _observationController = TextEditingController();
  String? _selectedCondition;

  Future<String> _saveImagePermanently(XFile image) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = '${_uuid.v4()}.jpg';
    final savedImage = await File(
      image.path,
    ).copy('${directory.path}/$fileName');
    return savedImage.path;
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (mounted) {
          _showMessage('Ative a localização do dispositivo');
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        if (mounted) {
          _showMessage('Permissão de localização necessária');
        }
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          _showMessage('Permissão de localização bloqueada nas configurações');
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition();

      if (!mounted) {
        return;
      }

      setState(() {
        _currentPosition = position;
      });

      _showMessage('Localização capturada');
    } catch (error) {
      if (mounted) {
        _showMessage('Não foi possível obter a localização');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
        });
      }
    }
  }

  Future<void> _takePhoto() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
    );
    if (image == null || !mounted) {
      return;
    }
    setState(() {
      _selectedImage = image;
    });
  }

  @override
  void dispose() {
    _observationController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _validateInspection() async {
    if (_isSaving) {
      return;
    }

    if (_observationController.text.trim().isEmpty) {
      _showMessage('Preencha a observação!');
      return;
    }

    if (_selectedCondition == null) {
      _showMessage('Selecione a condição!');
      return;
    }

    if (_selectedImage == null) {
      _showMessage('Adicione uma foto!');
      return;
    }

    if (_currentPosition == null) {
      _showMessage('Capture a localização!');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final photoPath = await _saveImagePermanently(_selectedImage!);

      final inspection = Inspection(
        clientId: _uuid.v4(),
        workOrderId: widget.workOrder.id,
        observation: _observationController.text.trim(),
        condition: _selectedCondition,
        photoPath: photoPath,
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        capturedAt: DateTime.now(),
        status: 'pending',
      );
      await _databaseService.insertInspection(inspection);

      if (!mounted) {
        return;
      }

      _showMessage('Inspeção salva no dispositivo');

      await Future.delayed(const Duration(milliseconds: 700));

      if (!mounted) {
        return;
      }

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage('Não foi possível salvar a inspeção');

      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova inspeção')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.workOrder.code,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(widget.workOrder.title),

            const SizedBox(height: 24),

            TextField(
              controller: _observationController,

              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Observação',
                hintText: 'Descreva o serviço realizado',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedCondition,
              decoration: const InputDecoration(
                labelText: 'Condição',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'bom', child: Text('Bom')),
                DropdownMenuItem(value: 'regular', child: Text('Regular')),
                DropdownMenuItem(value: 'ruim', child: Text('Ruim')),
                DropdownMenuItem(value: 'critico', child: Text('Crítico')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCondition = value;
                });
              },
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _takePhoto,
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Adicionar foto'),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isGettingLocation ? null : _getCurrentLocation,
                icon: const Icon(Icons.location_on_outlined),
                label: Text(
                  _isGettingLocation
                      ? 'Obtendo localização...'
                      : 'Capturar localização',
                ),
              ),
            ),

            if (_currentPosition != null) ...[
              const SizedBox(height: 8),
              Text('Latitude: ${_currentPosition!.latitude}'),
              Text('Longitude: ${_currentPosition!.longitude}'),
            ],

            if (_selectedImage != null) ...[
              const SizedBox(height: 16),

              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(_selectedImage!.path),
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ],

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _validateInspection,
                child: Text(_isSaving ? 'Salvando...' : 'Concluir inspeção'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
