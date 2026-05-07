import 'package:flutter/material.dart';
import 'package:split_spend/src/core/storage/avatar_storage_service.dart';
import 'package:split_spend/src/features/expenses/data/expenses_repository.dart';
import 'package:split_spend/src/features/expenses/models/expense_item.dart';
import 'package:split_spend/src/features/expenses/models/expense_split_member.dart';
import 'package:split_spend/src/features/expenses/widgets/details/expense_paid_by_card.dart';
import 'package:split_spend/src/features/expenses/widgets/details/expense_receipt_card.dart';
import 'package:split_spend/src/features/expenses/widgets/details/expense_split_breakdown_card.dart';
import 'package:split_spend/src/features/expenses/widgets/details/expense_summary_card.dart';
import 'package:split_spend/src/features/groups/data/groups_repository.dart';
import 'package:split_spend/src/features/groups/models/group_member_display.dart';
import 'package:split_spend/src/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExpenseDetailsScreen extends StatefulWidget {
  const ExpenseDetailsScreen({
    super.key,
    required this.expenseId,
  });

  final String expenseId;

  @override
  State<ExpenseDetailsScreen> createState() => _ExpenseDetailsScreenState();
}

class _ExpenseDetailsScreenState extends State<ExpenseDetailsScreen> {
  late final ExpensesRepository _expensesRepo;
  late final GroupsRepository _groupsRepo;

  ExpenseItem? _expense;
  List<GroupMemberDisplay>? _members;
  Object? _error;

  String get _currentUserId => Supabase.instance.client.auth.currentUser?.id ?? '';

  @override
  void initState() {
    super.initState();
    final client = Supabase.instance.client;
    _expensesRepo = ExpensesRepository(client);
    _groupsRepo = GroupsRepository(client);
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _error = null;
      _expense = null;
      _members = null;
    });
    try {
      final expense = await _expensesRepo.fetchExpenseById(widget.expenseId);
      if (expense == null) {
        throw StateError('Expense not found');
      }
      final members = await _groupsRepo.fetchGroupMembers(expense.groupId);
      if (!mounted) {
        return;
      }
      setState(() {
        _expense = expense;
        _members = members;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _error = e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Expense Details',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Could not load expense details'),
            const SizedBox(height: 10),
            FilledButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }

    final expense = _expense;
    final members = _members;
    if (expense == null || members == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final creator = members.where((m) => m.userId == expense.createdBy).firstOrNull;
    final creatorName = _displayNameForMember(creator, fallback: 'Member');
    final splitRows = _buildSplitRows(expense, members);
    final receiptPath = expense.receiptStoragePath;
    final receiptUrl = (receiptPath == null || receiptPath.isEmpty)
        ? null
        : Supabase.instance.client.storage
              .from(AvatarStorageService.bucketId)
              .getPublicUrl(receiptPath);

    return RefreshIndicator(
      onRefresh: _load,
      color: AppPalette.primary500,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 26),
        children: [
          ExpenseSummaryCard(expense: expense),
          const SizedBox(height: 12),
          ExpensePaidByCard(
            label: 'Created by',
            payerName: creatorName,
            spentAt: expense.spentAt,
          ),
          const SizedBox(height: 12),
          ExpenseSplitBreakdownCard(members: splitRows),
          if (receiptUrl != null) ...[
            const SizedBox(height: 18),
            ExpenseReceiptCard(receiptUrl: receiptUrl),
          ],
        ],
      ),
    );
  }

  List<ExpenseSplitMember> _buildSplitRows(
    ExpenseItem expense,
    List<GroupMemberDisplay> members,
  ) {
    if (members.isEmpty) {
      return const [];
    }
    if (members.length == 1) {
      final m = members.first;
      return [
        ExpenseSplitMember(
          userId: m.userId,
          displayName: m.userId == _currentUserId
              ? 'You'
              : _displayNameForMember(m, fallback: 'Member ${m.shortIdTail}'),
          avatarUrl: m.avatarUrl,
          amount: expense.amount,
          subtitle: 'Only member in this group',
          statusLabel: 'No split needed',
          statusColorHex: 0xFF16A34A,
        ),
      ];
    }
    final share = expense.amount / members.length;

    return members.map((m) {
      final isCurrent = m.userId == _currentUserId;
      final displayName = isCurrent
          ? 'You'
          : _displayNameForMember(m, fallback: 'Member ${m.shortIdTail}');
      final isCreator = m.userId == expense.createdBy;
      final subtitle = isCreator
          ? 'Created this expense • split (1/${members.length})'
          : 'Equally split (1/${members.length})';

      return ExpenseSplitMember(
        userId: m.userId,
        displayName: displayName,
        avatarUrl: m.avatarUrl,
        amount: share,
        subtitle: subtitle,
        statusLabel: isCurrent ? 'Payment due' : 'Pending payment',
        statusColorHex: isCurrent ? 0xFFDC2626 : 0xFF6B7280,
      );
    }).toList();
  }

  String _displayNameForMember(GroupMemberDisplay? member, {required String fallback}) {
    final raw = member?.displayName?.trim();
    if (raw == null || raw.isEmpty) {
      return fallback;
    }
    return raw;
  }
}

extension _FirstWhereOrNullExt<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
