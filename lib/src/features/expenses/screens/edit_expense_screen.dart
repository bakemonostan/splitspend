import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:split_spend/src/core/storage/avatar_storage_service.dart';
import 'package:split_spend/src/core/ui/app_toast.dart';
import 'package:split_spend/src/core/utils/number_formatters.dart';
import 'package:split_spend/src/features/expenses/data/expenses_repository.dart';
import 'package:split_spend/src/features/expenses/models/expense_item.dart';
import 'package:split_spend/src/features/expenses/widgets/add_category_dialog.dart';
import 'package:split_spend/src/features/expenses/widgets/receipt_action_tile.dart';
import 'package:split_spend/src/features/groups/data/groups_repository.dart';
import 'package:split_spend/src/features/home/models/group_summary.dart';
import 'package:split_spend/src/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditExpenseScreen extends StatefulWidget {
  const EditExpenseScreen({super.key, required this.expense});

  final ExpenseItem expense;

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  late final ExpensesRepository _expensesRepo;
  late final GroupsRepository _groupsRepo;

  List<GroupSummary> _groups = const [];
  bool _loadingGroups = true;
  bool _saving = false;
  String? _selectedGroupId;
  String _selectedCategory = 'Other';
  DateTime _selectedDate = DateTime.now();
  XFile? _newReceipt;
  String? _existingReceiptPath;

  final List<String> _categories = [
    'Dining',
    'Shopping',
    'Transport',
    'Rent',
    'Groceries',
    'Utilities',
    'Other',
  ];

  bool get _canSave {
    final amount = NumberFormatters.parseCurrencyInput(_amountController.text);
    return !_saving &&
        amount != null &&
        amount > 0 &&
        _noteController.text.trim().isNotEmpty &&
        _selectedGroupId != null &&
        _selectedGroupId!.isNotEmpty &&
        _selectedCategory.trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    final client = Supabase.instance.client;
    _expensesRepo = ExpensesRepository(client);
    _groupsRepo = GroupsRepository(client);

    _selectedGroupId = widget.expense.groupId;
    _selectedCategory = widget.expense.category;
    _selectedDate = widget.expense.spentAt;
    _existingReceiptPath = widget.expense.receiptStoragePath;
    _amountController.text = NumberFormatters.formatCurrency(
      widget.expense.amount,
      symbol: '',
      decimals: 2,
    ).trim();
    _noteController.text = widget.expense.note ?? '';
    _amountController.addListener(_onFieldChanged);
    _noteController.addListener(_onFieldChanged);
    _loadGroups();
  }

  @override
  void dispose() {
    _amountController.removeListener(_onFieldChanged);
    _noteController.removeListener(_onFieldChanged);
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onFieldChanged() => setState(() {});

  Future<void> _loadGroups() async {
    try {
      final list = await _groupsRepo.fetchMyGroups();
      if (!mounted) return;
      setState(() {
        _groups = list;
        _loadingGroups = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingGroups = false);
      await AppToast.error('Could not load groups');
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null && mounted) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _addCustomCategory() async {
    final value = await showDialog<String>(
      context: context,
      builder: (_) => const AddCategoryDialog(),
    );
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return;
    setState(() {
      if (!_categories.contains(trimmed)) _categories.add(trimmed);
      _selectedCategory = trimmed;
    });
  }

  Future<void> _pickReceipt(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1800,
      imageQuality: 88,
    );
    if (picked == null || !mounted) return;
    setState(() => _newReceipt = picked);
    await AppToast.success('Receipt updated');
  }

  Future<void> _save() async {
    if (!_canSave) return;
    final amount = NumberFormatters.parseCurrencyInput(_amountController.text);
    final groupId = _selectedGroupId;
    if (amount == null || groupId == null) return;

    setState(() => _saving = true);
    try {
      String? receiptStoragePath = _existingReceiptPath;
      if (_newReceipt != null) {
        receiptStoragePath = await _expensesRepo.uploadExpenseReceipt(
          groupId: groupId,
          file: _newReceipt!,
        );
      }
      await _expensesRepo.updateExpense(
        expenseId: widget.expense.id,
        groupId: groupId,
        amount: amount,
        category: _selectedCategory,
        note: _noteController.text,
        spentAt: _selectedDate,
        receiptStoragePath: receiptStoragePath,
      );
      if (!mounted) return;
      await AppToast.success('Expense updated');
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        await AppToast.error('Could not update expense');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = '${_selectedDate.day.toString().padLeft(2, '0')}/'
        '${_selectedDate.month.toString().padLeft(2, '0')}/'
        '${_selectedDate.year}';
    final existingReceiptUrl = _existingReceiptPath == null || _existingReceiptPath!.isEmpty
        ? null
        : Supabase.instance.client.storage
              .from(AvatarStorageService.bucketId)
              .getPublicUrl(_existingReceiptPath!);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text('Edit Expense'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        children: [
          _label('Amount'),
          const SizedBox(height: 8),
          _amountField(),
          const SizedBox(height: 16),
          _label('What was it for?'),
          const SizedBox(height: 8),
          TextField(controller: _noteController, decoration: _inputDecoration('Note')),
          const SizedBox(height: 16),
          _label('Date'),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickDate,
            child: InputDecorator(
              decoration: _inputDecoration('').copyWith(
                suffixIcon: const Icon(Icons.calendar_month_outlined),
              ),
              child: Text(dateText),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _label('Category'),
              const Spacer(),
              TextButton(
                onPressed: _addCustomCategory,
                style: TextButton.styleFrom(foregroundColor: AppPalette.primary500),
                child: const Text('Custom'),
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
                      color: _selectedCategory == c ? Colors.white : AppPalette.neutral900,
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          _label('Split with group'),
          const SizedBox(height: 8),
          if (_loadingGroups)
            const Center(child: CircularProgressIndicator())
          else
            DropdownButtonFormField<String>(
              initialValue: _selectedGroupId,
              items: _groups
                  .where((g) => g.id != null)
                  .map((g) => DropdownMenuItem(value: g.id!, child: Text(g.name)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedGroupId = v),
              decoration: _inputDecoration('Pick group'),
            ),
          const SizedBox(height: 16),
          _label('Attach Receipt'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ReceiptActionTile(
                  icon: Icons.photo_camera_outlined,
                  label: 'Take Photo',
                  onTap: () => _pickReceipt(ImageSource.camera),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ReceiptActionTile(
                  icon: Icons.image_outlined,
                  label: 'Gallery',
                  onTap: () => _pickReceipt(ImageSource.gallery),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _receiptPreview(existingReceiptUrl: existingReceiptUrl),
          const SizedBox(height: 22),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: _canSave ? _save : null,
              style: FilledButton.styleFrom(backgroundColor: AppPalette.primary500),
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_saving ? 'Saving...' : 'Save changes'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _receiptPreview({String? existingReceiptUrl}) {
    if (_newReceipt != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: Image.file(File(_newReceipt!.path), fit: BoxFit.cover),
        ),
      );
    }
    if (existingReceiptUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: Image.network(existingReceiptUrl, fit: BoxFit.cover),
        ),
      );
    }
    return Text(
      'No receipt attached',
      style: TextStyle(color: AppPalette.neutral500),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppPalette.neutral700,
        ),
      );

  Widget _amountField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppPalette.neutral200),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const Text(
            r'$',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: AppPalette.neutral500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _amountController,
              inputFormatters: [CurrencyTextInputFormatter()],
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: AppPalette.neutral500,
              ),
              decoration: const InputDecoration(
                hintText: '0.00',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
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
