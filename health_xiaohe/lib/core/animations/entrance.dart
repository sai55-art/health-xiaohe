import 'package:flutter/material.dart';
import 'package:health_xiaohe/core/constants/app_motion.dart';

/// 挂载时执行"淡入 + 上浮"入场(静润曲线,单次)。
///
/// 用法:`Entrance(index: i, child: ...)`。index 用于 stagger:
/// 实际延迟 = min(index, AppMotion.staggerMaxIndex) * staggerStep。
/// 仅在首次构建跑一次,适合问候区/标签等少量首屏元素。
class Entrance extends StatefulWidget {
  final Widget child;
  final int index;

  const Entrance({super.key, required this.child, this.index = 0});

  @override
  State<Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<Entrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.base,
  );
  late final Animation<double> _anim =
      CurvedAnimation(parent: _controller, curve: AppMotion.calm);

  @override
  void initState() {
    super.initState();
    final clamped = widget.index.clamp(0, AppMotion.staggerMaxIndex);
    final delay = AppMotion.staggerStep * clamped;
    Future.delayed(delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        return Opacity(
          opacity: _anim.value,
          child: Transform.translate(
            offset: Offset(0, (1 - _anim.value) * AppMotion.entranceOffset),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
