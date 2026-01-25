enum ErrandStatus { pending, inProgress, completed, cancelled }

class ErrandModel {
  final String id;
  final String customerId;
  final String? runnerId;
  final String description;
  final double price;
  final ErrandStatus status;
  final String location;

  ErrandModel({
    required this.id,
    required this.customerId,
    this.runnerId,
    required this.description,
    required this.price,
    required this.status,
    required this.location,
  });
}
