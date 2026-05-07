import 'package:flutter/material.dart';
import 'package:split_spend/src/core/ui/app_toast.dart';
import 'package:split_spend/src/features/expenses/data/expenses_repository.dart';
import 'package:split_spend/src/features/groups/data/groups_repository.dart';
import 'package:split_spend/src/features/home/models/group_summary.dart';
import 'package:split_spend/src/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateExpenseScreen extends StatefulWidget {
  const CreateExpenseScreen({super.key});

  @override
  State<CreateExpenseScreen> createState() => _CreateExpenseScreenState();
}

class _CreateExpenseScreenState extends State<CreateExpenseScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late final ExpensesRepository _expensesRepo;
  late final GroupsRepository _groupsRepo;

  List<GroupSummary> _groups = const [];
  bool _loadingGroups = true;
  bool _saving = false;

  String? _selectedGroupId;
  String _selectedCategory = 'Dining';
  final List<String> _categories = [
    'Dining',
    'Shopping',
    'Transport',
    'Rent',
    'Groceries',
    'Utilities',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final client = Supabase.instance.client;
    _expensesRepo = ExpensesRepository(client);
    _groupsRepo = GroupsRepository(client);
    _loadGroups();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadGroups() async {
    try {
      final list = await _groupsRepo.fetchMyGroups();
      if (!mounted) {
        return;
      }
      setState(() {
        _groups = list;
        _selectedGroupId = list.isNotEmpty ? list.first.id : null;
        _loadingGroups = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _loadingGroups = false);
      await AppToast.error('Could not load your groups');
    }
  }

  Future<void> _addCustomCategory() async {
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New category'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. Fuel',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    controller.dispose();

    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return;
    }
    setState(() {
      if (!_categories.contains(trimmed)) {
        _categories.add(trimmed);
      }
      _selectedCategory = trimmed;
    });
  }

  Future<void> _save() async {
    if (_saving) {
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final groupId = _selectedGroupId;
    if (groupId == null || groupId.isEmpty) {
      await AppToast.error('Select a group first');
      return;
    }
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      await AppToast.error('Enter a valid amount');
      return;
    }

    setState(() => _saving = true);
    try {
      await _expensesRepo.createExpense(
        groupId: groupId,
        amount: amount,
        category: _selectedCategory,
        note: _noteController.text,
      );
      if (!mounted) {
        return;
      }
      await AppToast.success('Expense created');
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        await AppToast.error('Could not create expense');
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
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
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Add Expense',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          children: [
            Text(
              'Group',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppPalette.neutral700,
              ),
            ),
            const SizedBox(height: 8),
            if (_loadingGroups)
              const SizedBox(
                height: 48,
                child: Center(child: CircularProgressIndicator()),
              )
            else
              DropdownButtonFormField<String>(
                initialValue: _selectedGroupId,
                items: _groups
                    .where((g) => g.id != null)
                    .map(
                      (g) => DropdownMenuItem<String>(
                        value: g.id!,
                        child: Text(g.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedGroupId = value),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Pick a group' : null,
                decoration: _inputDecoration('Select group'),
              ),
            const SizedBox(height: 18),
            Text(
              'Amount',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppPalette.neutral700,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: _inputDecoration('0.00', prefix: '\$ '),
              validator: (v) {
                final value = double.tryParse((v ?? '').trim());
                if (value == null || value <= 0) {
                  return 'Enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            Text(
              'What was it for?',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppPalette.neutral700,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _noteController,
              decoration: _inputDecoration('e.g. Dinner with team'),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Text(
                  'Category',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppPalette.neutral700,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _addCustomCategory,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Custom'),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories
                  .map(
                    (c) => ChoiceChip(
                      label: Text(c),
                      selected: _selectedCategory == c,
                      onSelected: (_) => setState(() => _selectedCategory = c),
                      selectedColor: AppPalette.primary500,
                      labelStyle: TextStyle(
                        color: _selectedCategory == c
                            ? Colors.white
                            : AppPalette.neutral800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppPalette.primary500,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline_rounded),
                label: Text(_saving ? 'Saving...' : 'Save Expense'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, {String? prefix}) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppPalette.neutral200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppPalette.neutral200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppPalette.primary400, width: 2),
      ),
    );
  }
}
