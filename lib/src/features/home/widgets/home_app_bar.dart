import 'package:flutter/material.dart';
import 'package:split_spend/src/theme/theme.dart';
import 'package:split_spend/src/widgets/profile_toolbar_avatar.dart';

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
        child: ProfileToolbarAvatar(
          radius: 18,
          onPressed: () {},
        ),
      ),
      title: Image.asset(
        'assets/img/general/logo_filled.png',
        fit: BoxFit.contain,
        alignment: Alignment.center,
        width: 40,
        height: 40,
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
