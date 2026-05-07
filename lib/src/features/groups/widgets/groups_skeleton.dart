import 'package:flutter/material.dart';
import 'package:split_spend/src/core/ui/skeleton.dart';

class GroupsSkeleton extends StatelessWidget {
  const GroupsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Skeleton(
      child: Column(
        children: [
          _GroupCardSkeleton(),
          SizedBox(height: 12),
          _GroupCardSkeleton(),
          SizedBox(height: 12),
          _GroupCardSkeleton(),
        ],
      ),
    );
  }
}

class _GroupCardSkeleton extends StatelessWidget {
  const _GroupCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: const [
          SkeletonBox(height: 42, width: 42, radius: 12),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(height: 14, width: 120),
                SizedBox(height: 8),
                SkeletonBox(height: 10, width: 80),
              ],
            ),
          ),
          SizedBox(width: 12),
          SkeletonBox(height: 12, width: 48),
        ],
      ),
    );
  }
}

