class ExpenseSplitMember {
  const ExpenseSplitMember({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.amount,
    required this.subtitle,
    required this.statusLabel,
    this.statusColorHex,
  });

  final String userId;
  final String displayName;
  final String? avatarUrl;
  final double amount;
  final String subtitle;
  final String statusLabel;
  final int? statusColorHex;
}
