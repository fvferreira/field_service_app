import 'package:field_service_app/services/work_order_service.dart';
import 'package:field_service_app/models/work_order.dart';
import 'package:flutter/material.dart';

class WorkOrderProvider extends ChangeNotifier {
  final WorkOrderService _workOrderService;

  WorkOrderProvider(this._workOrderService);

  List<WorkOrder> _workOrders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<WorkOrder> get workOrders => _workOrders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadWorkOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _workOrders = await _workOrderService.getWorkOrders();
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
