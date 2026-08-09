class Inspection {
  final String clientId;
  final String workOrderId;
  final String observation;
  final String? condition;
  final String? photoPath;
  final double? latitude;
  final double? longitude;
  final DateTime capturedAt;
  final String status;
  final String? serverId;
  final String? errorMessage;

  Inspection({
    required this.clientId,
    required this.workOrderId,
    required this.observation,
    this.condition,
    this.photoPath,
    this.latitude,
    this.longitude,
    required this.capturedAt,
    required this.status,
    this.serverId,
    this.errorMessage,
  });

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'workOrderId': workOrderId,
      'observation': observation,
      'condition': condition,
      'photoPath': photoPath,
      'latitude': latitude,
      'longitude': longitude,
      'capturedAt': capturedAt.toIso8601String(),
      'status': status,
      'serverId': serverId,
      'errorMessage': errorMessage,
    };
  }

  factory Inspection.fromMap(Map<String, dynamic> map) {
    return Inspection(
      clientId: map['clientId'] as String,
      workOrderId: map['workOrderId'] as String,
      observation: map['observation'] as String,
      condition: map['condition'] as String?,
      photoPath: map['photoPath'] as String?,
      latitude: map['latitude'] != null
          ? (map['latitude'] as num).toDouble()
          : null,
      longitude: map['longitude'] != null
          ? (map['longitude'] as num).toDouble()
          : null,
      capturedAt: DateTime.parse(map['capturedAt'] as String),
      status: map['status'] as String,
      serverId: map['serverId'] as String?,
      errorMessage: map['errorMessage'] as String?,
    );
  }
}
