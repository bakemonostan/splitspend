import 'package:flutter/material.dart';
import 'package:split_spend/src/core/ui/app_toast.dart';
import 'package:split_spend/src/features/expenses/data/expenses_repository.dart';
import 'package:split_spend/src/features/expenses/models/expense_item.dart';
import 'package:split_spend/src/features/groups/screens/create_group_screen.dart';
import 'package:split_spend/src/features/groups/screens/join_group_screen.dart';
import 'package:split_spend/src/features/groups/widgets/start_something_new_card.dart';
import 'package:split_spend/src/features/home/widgets/home_header.dart';
import 'package:split_spend/src/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.groupsRefreshSignal});

  /// When create/join succeeds from Home, bump so the Groups tab reloads.
  final ValueNotifier<int>? groupsRefreshSignal;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ExpensesRepository _repo;
  List<ExpenseItem>? _expenses;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _repo = ExpensesRepository(Supabase.instance.client);
    widget.groupsRefreshSignal?.addListener(_onRefreshSignal);
    _load();
  }

  @override
  void dispose() {
    widget.groupsRefreshSignal?.removeListener(_onRefreshSignal);
    super.dispose();
  }

  void _onRefreshSignal() => _load();

  Future<void> _load() async {
    setState(() {
      _expenses = null;
      _loadError = null;
    });
    try {
      final list = await _repo.fetchMyExpenses();
      if (mounted) {
        setState(() => _expenses = list);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadError = e);
      }
    }
  }

  Future<void> _openCreate(BuildContext context) async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
    );
    if (ok == true) {
      widget.groupsRefreshSignal?.value++;
    }
  }

  Future<void> _openJoin(BuildContext context) async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const JoinGroupScreen()),
    );
    if (ok == true) {
      widget.groupsRefreshSignal?.value++;
      await AppToast.success('Joined group');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _load,
          color: AppPalette.primary500,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const HomeHeader(),
                  const SizedBox(height: 24),
                  _buildBody(context),
                  const SizedBox(height: 8),
                  StartSomethingNewCard(
                    onCreateGroup: () => _openCreate(context),
                    onJoinWithCode: () => _openJoin(context),
                  ),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loadError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Could not load expenses',
            style: TextStyle(color: AppPalette.neutral700),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: _load, child: const Text('Retry')),
        ],
      );
    }
    if (_expenses == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 36),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final expenses = _expenses!;
    if (expenses.isEmpty) {
      return Container(
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppPalette.neutral100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 40,
              color: AppPalette.neutral400,
            ),
            const SizedBox(height: 12),
            const Text(
              'No expenses yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppPalette.neutral900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Your created expenses will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppPalette.neutral500, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Column(
      children: expenses
          .map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ExpenseRow(expense: e),
            ),
          )
          .toList(),
    );
  }
}

class _ExpenseRow extends StatelessWidget {
  const _ExpenseRow({required this.expense});

  final ExpenseItem expense;

  @override
  Widget build(BuildContext context) {
    final amount = expense.amount.toStringAsFixed(2);
    final date = '${expense.spentAt.day.toString().padLeft(2, '0')}/'
        '${expense.spentAt.month.toString().padLeft(2, '0')}/'
        '${expense.spentAt.year}';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppPalette.neutral900.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: AppPalette.primary50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                color: AppPalette.primary600,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppPalette.neutral900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${expense.groupName} • ${expense.category} • $date',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppPalette.neutral500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '\$ $amount',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppPalette.primary600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
