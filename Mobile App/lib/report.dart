class Report {
  final String id;
  final String type;
  final String carNumber;
  final String? imageName;
  final String details;
  String status;
  final DateTime date;
  final String? adminResponse;

  Report({
    required this.id,
    required this.type,
    required this.carNumber,
    this.imageName,
    required this.details,
    required this.status,
    required this.date,
    this.adminResponse,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      carNumber: json['car_number'] ?? '',
      imageName: json['image_name'],
      details: json['details'] ?? '',
      status: json['status'] ?? 'قيد المراجعة',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      adminResponse: json['admin_response'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'car_number': carNumber,
      'image_name': imageName,
      'details': details,
      'status': status,
      'date': date.toIso8601String(),
      'admin_response': adminResponse,
    };
  }

  Report copyWith({
    String? id,
    String? type,
    String? carNumber,
    String? imageName,
    String? details,
    String? status,
    DateTime? date,
    String? adminResponse,
  }) {
    return Report(
      id: id ?? this.id,
      type: type ?? this.type,
      carNumber: carNumber ?? this.carNumber,
      imageName: imageName ?? this.imageName,
      details: details ?? this.details,
      status: status ?? this.status,
      date: date ?? this.date,
      adminResponse: adminResponse ?? this.adminResponse,
    );
  }

  @override
  String toString() {
    return 'Report{id: $id, type: $type, carNumber: $carNumber, status: $status}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Report &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}