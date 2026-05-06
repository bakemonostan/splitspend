import 'package:flutter/material.dart';
import 'package:split_spend/src/theme/theme.dart';

/// Home tab app bar: avatar (leading), centered **SplitSpend**, bell action.
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: IconButton(
          onPressed: () {},
          icon: CircleAvatar(
            radius: 18,
            backgroundColor: AppPalette.primary100,
            child: Icon(
              Icons.person_rounded,
              color: AppPalette.primary600,
              size: 22,
            ),
          ),
        ),
      ),
      title: Text(
        'SplitSpend',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppPalette.primary500,
        ),
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
      ],
    );
  }
}
