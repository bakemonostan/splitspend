class ExpenseItem {
  const ExpenseItem({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.createdBy,
    required this.amount,
    required this.currency,
    required this.category,
    required this.spentAt,
    this.note,
    this.receiptStoragePath,
  });

  final String id;
  final String groupId;
  final String groupName;
  final String createdBy;
  final double amount;
  final String currency;
  final String category;
  final DateTime spentAt;
  final String? note;
  final String? receiptStoragePath;

  String get title => note?.trim().isNotEmpty == true ? note!.trim() : category;
}
