import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final ImagePicker _picker = ImagePicker();

  late final ExpensesRepository _expensesRepo;
  late final GroupsRepository _groupsRepo;

  List<GroupSummary> _groups = const [];
  bool _loadingGroups = true;
  bool _saving = false;

  String? _selectedGroupId;
  String _selectedCategory = 'Dining';
  DateTime _selectedDate = DateTime.now();
  XFile? _receipt;
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
    _amountController.addListener(_onFieldChanged);
    _noteController.addListener(_onFieldChanged);
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

  bool get _canSave {
    final amount = double.tryParse(_amountController.text.trim());
    final hasAmount = amount != null && amount > 0;
    final hasNote = _noteController.text.trim().isNotEmpty;
    final hasGroup = _selectedGroupId != null && _selectedGroupId!.isNotEmpty;
    final hasCategory = _selectedCategory.trim().isNotEmpty;
    return !_saving && hasAmount && hasNote && hasGroup && hasCategory;
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
    final value = await showDialog<String>(
      context: context,
      builder: (context) => const _AddCategoryDialog(),
    );

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

  Future<void> _pickReceipt(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1800,
      imageQuality: 88,
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() => _receipt = picked);
    await AppToast.success('Receipt attached');
  }

  Future<void> _save() async {
    if (_saving) {
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
      String? receiptStoragePath;
      if (_receipt != null) {
        receiptStoragePath = await _expensesRepo.uploadExpenseReceipt(
          groupId: groupId,
          file: _receipt!,
        );
      }
      await _expensesRepo.createExpense(
        groupId: groupId,
        amount: amount,
        category: _selectedCategory,
        note: _noteController.text,
        spentAt: _selectedDate,
        receiptStoragePath: receiptStoragePath,
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

  Future<void> _showAllCategories() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Pick category',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._categories.map(
                      (c) => ActionChip(
                        label: Text(c),
                        onPressed: () => Navigator.pop(context, c),
                      ),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.add, size: 16),
                      label: const Text('Custom'),
                      onPressed: () async {
                        Navigator.pop(context);
                        await _addCustomCategory();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    if (selected != null && mounted) {
      setState(() => _selectedCategory = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = '${_selectedDate.day.toString().padLeft(2, '0')}/'
        '${_selectedDate.month.toString().padLeft(2, '0')}/'
        '${_selectedDate.year}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Add Expense',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        children: [
            Text(
              'Amount',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppPalette.neutral700,
              ),
            ),
            const SizedBox(height: 8),
            Container(
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
                      fontSize: 38,
                      fontWeight: FontWeight.w700,
                      color: AppPalette.neutral500,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(
                        fontSize: 42,
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
            Text(
              'Date',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppPalette.neutral700,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: _inputDecoration('').copyWith(
                  suffixIcon: const Icon(Icons.calendar_month_outlined, size: 20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: AppPalette.secondary500,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      dateText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
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
                TextButton(
                  onPressed: _showAllCategories,
                  style: TextButton.styleFrom(
                    foregroundColor: AppPalette.primary500,
                  ),
                  child: const Text('View All'),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.take(4)
                  .map(
                    (c) => ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_categoryIcon(c) != null) ...[
                            Icon(
                              _categoryIcon(c),
                              size: 14,
                              color: _selectedCategory == c
                                  ? Colors.white
                                  : AppPalette.neutral700,
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            c,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _selectedCategory == c
                                  ? Colors.white
                                  : AppPalette.neutral900,
                            ),
                          ),
                        ],
                      ),
                      selected: _selectedCategory == c,
                      onSelected: (_) => setState(() => _selectedCategory = c),
                      selectedColor: AppPalette.primary500,
                      backgroundColor: Colors.white,
                      side: BorderSide(color: AppPalette.neutral200),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  )
                  .toList()
                ..add(
                  ChoiceChip(
                    label: const Icon(Icons.add, size: 18),
                    selected: false,
                    onSelected: (_) => _addCustomCategory(),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: AppPalette.neutral200),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
            ),
            const SizedBox(height: 22),
            Text(
              'Attach Receipt',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppPalette.neutral700,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _ReceiptActionTile(
                    icon: Icons.photo_camera_outlined,
                    label: 'Take Photo',
                    onTap: () => _pickReceipt(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ReceiptActionTile(
                    icon: Icons.image_outlined,
                    label: 'Gallery',
                    onTap: () => _pickReceipt(ImageSource.gallery),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _receipt == null
                  ? Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppPalette.neutral100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.receipt_long_outlined,
                            size: 18,
                            color: AppPalette.neutral500,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'No receipt attached',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: AppPalette.neutral900,
                                ),
                              ),
                              Text(
                                'Keep your paper trails digital.',
                                style: TextStyle(
                                  color: AppPalette.neutral500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await showDialog<void>(
                              context: context,
                              builder: (ctx) => Dialog(
                                insetPadding: const EdgeInsets.all(16),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(File(_receipt!.path)),
                                ),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: AspectRatio(
                              aspectRatio: 4 / 3,
                              child: Image.file(
                                File(_receipt!.path),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 18,
                              color: AppPalette.primary500,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Receipt attached',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: AppPalette.neutral900,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () async {
                                await showDialog<void>(
                                  context: context,
                                  builder: (ctx) => Dialog(
                                    insetPadding: const EdgeInsets.all(16),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(File(_receipt!.path)),
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Preview'),
                            ),
                          ],
                        ),
                        Text(
                          _receipt!.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppPalette.neutral500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF0F8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD5E0EE)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.group_outlined, color: AppPalette.primary600),
                      SizedBox(width: 8),
                      Text(
                        'Split with group',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      Spacer(),
                      Text(
                        'Equally',
                        style: TextStyle(
                          color: AppPalette.primary600,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (_loadingGroups)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  else
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppPalette.neutral200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedGroupId,
                            hint: const Text('Pick group'),
                            onChanged: (v) => setState(() => _selectedGroupId = v),
                            items: _groups
                                .where((g) => g.id != null)
                                .map(
                                  (g) => DropdownMenuItem<String>(
                                    value: g.id!,
                                    child: Text(g.name),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _canSave ? _save : null,
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
    );
  }

  InputDecoration _inputDecoration(
    String hint, {
    EdgeInsets? contentPadding,
  }) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          contentPadding ??
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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

  IconData? _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'dining':
        return Icons.restaurant_rounded;
      case 'shopping':
        return Icons.shopping_bag_outlined;
      case 'transport':
        return Icons.directions_car_outlined;
      case 'rent':
        return Icons.home_outlined;
      default:
        return null;
    }
  }
}

class _ReceiptActionTile extends StatelessWidget {
  const _ReceiptActionTile({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 94,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppPalette.neutral200,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppPalette.secondary500),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: AppPalette.secondary600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddCategoryDialog extends StatefulWidget {
  const _AddCategoryDialog();

  @override
  State<_AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<_AddCategoryDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New category'),
      content: TextField(
        controller: _controller,
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
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Add'),
        ),
      ],
    );
  }
}
