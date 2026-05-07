import 'package:image_picker/image_picker.dart';
import 'package:split_spend/src/core/storage/avatar_storage_service.dart';
import 'package:split_spend/src/features/expenses/models/expense_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExpensesRepository {
  ExpensesRepository(this._client);

  final SupabaseClient _client;

  String? get _userId => _client.auth.currentUser?.id;

  Future<List<ExpenseItem>> fetchMyExpenses({int limit = 40}) async {
    final uid = _userId;
    if (uid == null) {
      return [];
    }

    final rows = await _client
        .from('expenses')
        .select(
          'id, group_id, created_by, amount, currency, category, note, spent_at, receipt_storage_path, groups(name)',
        )
        .eq('created_by', uid)
        .order('spent_at', ascending: false)
        .limit(limit);

    final out = <ExpenseItem>[];
    for (final row in rows as List<dynamic>) {
      final m = Map<String, dynamic>.from(row as Map);
      final group = m['groups'];
      final amountRaw = m['amount'];
      final amount = amountRaw is num
          ? amountRaw.toDouble()
          : double.tryParse(amountRaw?.toString() ?? '') ?? 0;
      final spentAtRaw = m['spent_at']?.toString();
      final spentAt = spentAtRaw == null
          ? DateTime.now()
          : DateTime.tryParse(spentAtRaw)?.toLocal() ?? DateTime.now();

      out.add(
        ExpenseItem(
          id: m['id']?.toString() ?? '',
          groupId: m['group_id']?.toString() ?? '',
          createdBy: m['created_by']?.toString() ?? '',
          groupName: group is Map<String, dynamic>
              ? (group['name'] as String? ?? 'Group')
              : 'Group',
          amount: amount,
          currency: m['currency'] as String? ?? 'USD',
          category: m['category'] as String? ?? 'Other',
          note: m['note'] as String?,
          spentAt: spentAt,
          receiptStoragePath: m['receipt_storage_path'] as String?,
        ),
      );
    }
    return out;
  }

  Future<ExpenseItem?> fetchExpenseById(String expenseId) async {
    final row = await _client
        .from('expenses')
        .select(
          'id, group_id, created_by, amount, currency, category, note, spent_at, receipt_storage_path, groups(name)',
        )
        .eq('id', expenseId)
        .maybeSingle();
    if (row == null) {
      return null;
    }
    final m = Map<String, dynamic>.from(row);
    final group = m['groups'];
    final amountRaw = m['amount'];
    final amount = amountRaw is num
        ? amountRaw.toDouble()
        : double.tryParse(amountRaw?.toString() ?? '') ?? 0;
    final spentAtRaw = m['spent_at']?.toString();
    final spentAt = spentAtRaw == null
        ? DateTime.now()
        : DateTime.tryParse(spentAtRaw)?.toLocal() ?? DateTime.now();

    return ExpenseItem(
      id: m['id']?.toString() ?? '',
      groupId: m['group_id']?.toString() ?? '',
      createdBy: m['created_by']?.toString() ?? '',
      groupName: group is Map<String, dynamic>
          ? (group['name'] as String? ?? 'Group')
          : 'Group',
      amount: amount,
      currency: m['currency'] as String? ?? 'USD',
      category: m['category'] as String? ?? 'Other',
      note: m['note'] as String?,
      spentAt: spentAt,
      receiptStoragePath: m['receipt_storage_path'] as String?,
    );
  }

  Future<void> createExpense({
    required String groupId,
    required double amount,
    required String category,
    String? note,
    DateTime? spentAt,
    String? receiptStoragePath,
  }) async {
    final uid = _userId;
    if (uid == null) {
      throw StateError('Sign in to create expense.');
    }
    if (groupId.isEmpty) {
      throw ArgumentError('Pick a group.');
    }
    if (amount <= 0) {
      throw ArgumentError('Amount must be positive.');
    }

    final user = _client.auth.currentUser;
    final currency = (user?.userMetadata?['currency'] as String?)?.trim();

    await _client.from('expenses').insert({
      'group_id': groupId,
      'created_by': uid,
      'amount': amount,
      'currency': (currency == null || currency.isEmpty) ? 'USD' : currency,
      'category': category.trim().isEmpty ? 'Other' : category.trim(),
      'note': note?.trim().isEmpty == true ? null : note?.trim(),
      'spent_at': (spentAt ?? DateTime.now()).toUtc().toIso8601String(),
      'receipt_storage_path': receiptStoragePath,
    });
  }

  Future<String> uploadExpenseReceipt({
    required String groupId,
    required XFile file,
  }) async {
    final uid = _userId;
    if (uid == null) {
      throw StateError('Sign in to upload a receipt.');
    }
    final ext = _extensionForMime(file.mimeType);
    final millis = DateTime.now().millisecondsSinceEpoch;
    final path = '$uid/expense-receipts/$groupId/$millis.$ext';
    final bytes = await file.readAsBytes();
    final contentType = file.mimeType ??
        (ext == 'png' ? 'image/png' : 'image/jpeg');

    await _client.storage.from(AvatarStorageService.bucketId).uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(
        upsert: false,
        contentType: contentType,
      ),
    );

    return path;
  }

  static String _extensionForMime(String? mime) {
    if (mime != null && mime.toLowerCase().contains('png')) {
      return 'png';
    }
    return 'jpg';
  }
}
