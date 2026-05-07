import 'package:flutter/material.dart';
import 'package:split_spend/src/features/activity/data/activity_repository.dart';
import 'package:split_spend/src/features/activity/models/activity_item.dart';
import 'package:split_spend/src/features/activity/widgets/activity_event_tile.dart';
import 'package:split_spend/src/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  late final ActivityRepository _repo;
  List<ActivityItem>? _items;
  Object? _error;

  String get _currentUserId => Supabase.instance.client.auth.currentUser?.id ?? '';

  @override
  void initState() {
    super.initState();
    _repo = ActivityRepository(Supabase.instance.client);
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _items = null;
      _error = null;
    });
    try {
      final list = await _repo.fetchActivity();
      if (mounted) {
        setState(() => _items = list);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _load,
          color: AppPalette.primary500,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 88),
            children: [
              Text(
                'Everything that happened in your groups.',
                style: TextStyle(
                  fontSize: 15,
                  color: AppPalette.neutral500,
                ),
              ),
              const SizedBox(height: 14),
              if (_error != null)
                Column(
                  children: [
                    Text(
                      'Could not load activity.',
                      style: TextStyle(color: AppPalette.neutral700),
                    ),
                    const SizedBox(height: 8),
                    TextButton(onPressed: _load, child: const Text('Retry')),
                  ],
                )
              else if (_items == null)
                const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_items!.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Column(
                    children: [
                      Icon(
                        Icons.timeline_outlined,
                        size: 58,
                        color: AppPalette.neutral300,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'No activity yet',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ..._items!.map(
                  (a) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ActivityEventTile(
                      item: a,
                      currentUserId: _currentUserId,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
