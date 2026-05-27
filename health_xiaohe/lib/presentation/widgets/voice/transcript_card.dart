import 'package:flutter/material.dart';
import 'package:health_xiaohe/core/constants/app_colors.dart';

enum TranscriptRole { user, ai }

class TranscriptCard extends StatelessWidget {
  final TranscriptRole role;
  final String text;

  const TranscriptCard({
    super.key,
    required this.role,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = role == TranscriptRole.user;
    final bg = isUser
        ? AppColors.primary.withOpacity(0.18)
        : Colors.white.withOpacity(0.08);
    final border = isUser
        ? AppColors.primary.withOpacity(0.4)
        : Colors.white.withOpacity(0.15);
    final labelColor =
        isUser ? AppColors.primaryLight : Colors.white.withOpacity(0.7);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        final slide = Tween<Offset>(
          begin: Offset(0, isUser ? 0.15 : -0.15),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: slide, child: child),
        );
      },
      child: Container(
        // 仅用 role 做 key：卡片只在首次出现时播放入场动画；
        // 流式文字更新不再触发 AnimatedSwitcher 的 slide+fade
        key: ValueKey(role),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primary.withOpacity(0.35)
                    : Colors.white.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isUser
                    ? const Icon(Icons.person, color: Colors.white, size: 16)
                    : const Text('🌿', style: TextStyle(fontSize: 14)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isUser ? '你说' : '小云',
                    style: TextStyle(color: labelColor, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    text,
                    style: TextStyle(
                      color: Colors.white.withOpacity(isUser ? 0.95 : 0.85),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
