import 'package:flutter/material.dart';
import 'package:split_spend/src/theme/theme.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 12,
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppPalette.primary100,
            child: Icon(
              Icons.person_outline,
              color: AppPalette.primary600,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'SplitSpend',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppPalette.primary500,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.notifications_outlined,
            color: AppPalette.primary500,
            size: 26,
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}
