import 'package:flutter/foundation.dart';

/// Demo flow: always start on onboarding; after logout return to onboarding.
class AppFlowController extends ChangeNotifier {
  AppFlowController._();
  static final AppFlowController instance = AppFlowController._();

  bool showOnboarding = true;

  void completeOnboarding() {
    if (!showOnboarding) return;
    showOnboarding = false;
    notifyListeners();
  }

  void returnToOnboarding() {
    if (showOnboarding) return;
    showOnboarding = true;
    notifyListeners();
  }
}
