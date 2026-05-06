import 'package:flutter/material.dart';
import 'package:split_spend/src/features/home/models/group_summary.dart';
import 'package:split_spend/src/features/home/widgets/create_group_placeholder.dart';
import 'package:split_spend/src/features/home/widgets/group_summary_card.dart';
import 'package:split_spend/src/features/home/widgets/home_header.dart';
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
      iconColor: AppPalette.primary600,
      iconTileBackground: AppPalette.primary100,
    ),
    GroupSummary(
      name: 'Tokyo Trip',
      memberCount: 4,
      statusLabel: 'Settled',
      amountLabel: '\$0.00',
      amountColor: const Color(0xFF16A34A),
      icon: Icons.flight_rounded,
      iconColor: const Color(0xFF2563EB),
      iconTileBackground: const Color(0xFFDBEAFE),
    ),
    GroupSummary(
      name: 'Dinner Club',
      memberCount: 4,
      statusLabel: 'Owes you',
      amountLabel: '\$115.20',
      amountColor: const Color(0xFF16A34A),
      icon: Icons.restaurant_rounded,
      iconColor: AppPalette.tertiary600,
      iconTileBackground: AppPalette.tertiary100,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF8F9F9),
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const HomeHeader(),
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
                  CreateGroupPlaceholder(onTap: () {}),
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
