import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:split_spend/src/features/onboarding/widgets/pageview_one.dart';
import 'package:split_spend/src/features/onboarding/widgets/pageview_two.dart';
import 'package:split_spend/src/features/onboarding/widgets/pageview_three.dart';
import 'package:split_spend/src/theme/theme.dart';

class PageViewBuilder extends StatefulWidget {
  const PageViewBuilder({super.key, required this.onFinished});

  /// Called after the last onboarding page (e.g. navigate to auth).
  final VoidCallback onFinished;

  static const int _pageCount = 3;

  @override
  State<PageViewBuilder> createState() => _PageViewBuilderState();
}

class _PageViewBuilderState extends State<PageViewBuilder> {
  final PageController _pageController = PageController();

  /// Use a [double] so [DotsIndicator] can animate between pages while swiping.
  double _page = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onPageScroll);
  }

  void _onPageScroll() {
    final page = _pageController.page;
    if (page != null && page != _page) {
      setState(() => _page = page);
    }
  }

  void _onPrimaryButton() {
    final current = _pageController.page?.round() ?? 0;
    if (current < PageViewBuilder._pageCount - 1) {
      _pageController.animateToPage(
        current + 1,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      widget.onFinished();
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.primary10,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            children: [
              PageViewOne(onPrimary: _onPrimaryButton),
              PageViewTwo(onPrimary: _onPrimaryButton),
              PageViewThree(onPrimary: _onPrimaryButton),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 200,
            child: Center(
              child: DotsIndicator(
                dotsCount: PageViewBuilder._pageCount,
                position: _page,
                decorator: DotsDecorator(
                  color: AppPalette.primary300,
                  activeColor: AppPalette.primary500,
                  size: const Size.square(8),
                  activeSize: const Size(20, 8),
                  activeShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  spacing: const EdgeInsets.symmetric(horizontal: 4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
