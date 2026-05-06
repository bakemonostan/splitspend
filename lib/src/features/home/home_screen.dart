import 'package:flutter/material.dart';
import 'package:split_spend/src/features/home/widgets/group_summary_card.dart';
import 'package:split_spend/src/theme/theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final List<GroupSummary> _demoGroups = [
    GroupSummary(
      name: 'Flatmates 2024',
      memberCount: 4,
      statusLabel: 'You owe',
      amountLabel: '\$42.50',
      amountColor: const Color(0xFFDC2626),
      icon: Icons.apartment_rounded,
      iconBackground: AppPalette.primary500,
    ),
    GroupSummary(
      name: 'Tokyo Trip',
      memberCount: 4,
      statusLabel: 'Settled',
      amountLabel: '\$0.00',
      amountColor: const Color(0xFF16A34A),
      icon: Icons.flight_rounded,
      iconBackground: const Color(0xFF2563EB),
    ),
    GroupSummary(
      name: 'Dinner Club',
      memberCount: 4,
      statusLabel: 'Owes you',
      amountLabel: '\$115.20',
      amountColor: const Color(0xFF16A34A),
      icon: Icons.restaurant_rounded,
      iconBackground: const Color(0xFF9C573A),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Text(
                    'Home',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppPalette.neutral900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Keep track of shared expenses with friends and family.',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.35,
                      color: AppPalette.neutral500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ..._demoGroups.map(
                    (g) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GroupSummaryCard(
                        summary: g,
                        onTap: () {},
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _StartSomethingNewCard(onTap: () {}),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StartSomethingNewCard extends StatelessWidget {
  const _StartSomethingNewCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppPalette.primary50,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppPalette.primary300, width: 1.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.add_reaction_outlined,
                size: 28,
                color: AppPalette.primary500,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start something new?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppPalette.primary600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Create a group to easily split bills with friends on your next outing.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.35,
                        color: AppPalette.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
