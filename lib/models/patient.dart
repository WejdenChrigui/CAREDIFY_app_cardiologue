class Patient {
  final String id;
  final String name;
  final String email;
  final String dateCreated;
  final String status;
  final int recordsCount;
  final String imageUrl;

  Patient({
    required this.id,
    required this.name,
    required this.email,
    required this.dateCreated,
    required this.status,
    required this.recordsCount,
    required this.imageUrl,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? 'N/A',
      email: json['email'] ?? '',
      dateCreated: json['dateCreated'] ?? 'N/A',
      status: json['status'] ?? 'Stable',
      recordsCount: json['recordsCount'] ?? 0,
      imageUrl: json['imageUrl'] ?? "https://i.pravatar.cc/150?u=${json['_id']}",
    );
  }
}

