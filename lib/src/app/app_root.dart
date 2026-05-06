import 'package:flutter/material.dart';
import 'package:split_spend/src/app/app_flow_controller.dart';
import 'package:split_spend/src/app/auth_gate.dart';
import 'package:split_spend/src/features/onboarding/widgets/pageview_builder.dart';

/// Onboarding first, then [AuthGate] (sign-in vs main shell).
class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppFlowController.instance,
      builder: (context, _) {
        final flow = AppFlowController.instance;
        if (flow.showOnboarding) {
          return PageViewBuilder(
            onFinished: flow.completeOnboarding,
          );
        }
        return const AuthGate();
      },
    );
  }
}
