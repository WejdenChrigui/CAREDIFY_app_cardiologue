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
}
