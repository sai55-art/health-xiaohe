import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:health_xiaohe/core/constants/app_colors.dart';

enum VoiceAvatarMode {
  /// 连接中 — 旋转光环
  connecting,

  /// 待机 — 缓慢呼吸
  idle,

  /// 用户说话 — 内聚脉冲
  listening,

  /// AI 处理中 — 快速旋转环
  processing,

  /// AI 说话 — 多层向外涟漪
  speaking,
}

class VoiceAvatar extends StatefulWidget {
  final VoiceAvatarMode mode;
  final double size;

  const VoiceAvatar({
    super.key,
    required this.mode,
    this.size = 140,
  });

  @override
  State<VoiceAvatar> createState() => _VoiceAvatarState();
}

class _VoiceAvatarState extends State<VoiceAvatar>
    with TickerProviderStateMixin {
  late final AnimationController _breath;
  late final AnimationController _ripple;
  late final AnimationController _pulse;
  late final AnimationController _rotation;

  @override
  void initState() {
    super.initState();
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _ripple = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _rotation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _applyMode();
  }

  @override
  void didUpdateWidget(covariant VoiceAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode != widget.mode) {
      _applyMode();
    }
  }

  void _applyMode() {
    switch (widget.mode) {
      case VoiceAvatarMode.speaking:
        _ripple.repeat();
        _pulse.stop();
        _rotation.stop();
        break;
      case VoiceAvatarMode.listening:
        _pulse.repeat(reverse: true);
        _ripple.stop();
        _rotation.stop();
        break;
      case VoiceAvatarMode.processing:
        _rotation.repeat();
        _ripple.stop();
        _pulse.stop();
        break;
      case VoiceAvatarMode.connecting:
        _rotation.repeat();
        _ripple.stop();
        _pulse.stop();
        break;
      case VoiceAvatarMode.idle:
        _ripple.stop();
        _pulse.stop();
        _rotation.stop();
        break;
    }
  }

  @override
  void dispose() {
    _breath.dispose();
    _ripple.dispose();
    _pulse.dispose();
    _rotation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canvasSize = widget.size * 2.2; // 给涟漪留空间
    return SizedBox(
      width: canvasSize,
      height: canvasSize,
      child: AnimatedBuilder(
        animation: Listenable.merge([_breath, _ripple, _pulse, _rotation]),
        builder: (context, _) {
          return CustomPaint(
            painter: _AvatarPainter(
              mode: widget.mode,
              breath: _breath.value,
              ripple: _ripple.value,
              pulse: _pulse.value,
              rotation: _rotation.value,
              coreSize: widget.size,
            ),
            child: Center(
              child: _buildCore(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCore() {
    final scale = 1.0 + (_breath.value - 0.5) * 0.08; // 0.96 ~ 1.04
    return Transform.scale(
      scale: scale,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.45),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Text(
            '🌿',
            style: TextStyle(fontSize: widget.size * 0.42),
          ),
        ),
      ),
    );
  }
}

class _AvatarPainter extends CustomPainter {
  final VoiceAvatarMode mode;
  final double breath;
  final double ripple;
  final double pulse;
  final double rotation;
  final double coreSize;

  _AvatarPainter({
    required this.mode,
    required this.breath,
    required this.ripple,
    required this.pulse,
    required this.rotation,
    required this.coreSize,
  });

  // 预缓存 — 避免每帧 new Paint / new SweepGradient / createShader()
  final _fillPaint = Paint()..style = PaintingStyle.fill;
  final _strokePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4
    ..strokeCap = StrokeCap.round;

  // SweepGradient 本体不随旋转变化，只创建一次；旋转用 canvas.rotate 实现
  static final _arcGradient = SweepGradient(
    startAngle: 0,
    endAngle: math.pi * 2,
    colors: [
      AppColors.primary.withOpacity(0.0),
      AppColors.primary.withOpacity(0.0),
      AppColors.primary.withOpacity(0.6),
      AppColors.primaryDark.withOpacity(0.9),
    ],
    stops: [0.0, 0.5, 0.85, 1.0],
  );

  Shader? _cachedShader;
  Rect? _cachedRect;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final coreRadius = coreSize / 2;

    switch (mode) {
      case VoiceAvatarMode.speaking:
        _drawRipples(canvas, center, coreRadius);
        break;
      case VoiceAvatarMode.listening:
        _drawPulse(canvas, center, coreRadius);
        break;
      case VoiceAvatarMode.processing:
      case VoiceAvatarMode.connecting:
        _drawRotatingArc(canvas, center, coreRadius, size);
        break;
      case VoiceAvatarMode.idle:
        _drawIdleHalo(canvas, center, coreRadius);
        break;
    }
  }

  void _drawIdleHalo(Canvas canvas, Offset center, double r) {
    _fillPaint.color = AppColors.primary.withOpacity(0.12 + breath * 0.05);
    canvas.drawCircle(center, r * (1.18 + breath * 0.04), _fillPaint);
  }

  void _drawRipples(Canvas canvas, Offset center, double r) {
    for (int i = 0; i < 3; i++) {
      final progress = (ripple + i / 3) % 1.0;
      _strokePaint.color = AppColors.primary.withOpacity((1.0 - progress) * 0.55);
      _strokePaint.strokeWidth = 3.0 - progress * 2.0;
      canvas.drawCircle(center, r * (1.0 + progress * 1.15), _strokePaint);
    }
  }

  void _drawPulse(Canvas canvas, Offset center, double r) {
    _fillPaint.color = AppColors.primary.withOpacity(0.18 + pulse * 0.18);
    canvas.drawCircle(center, r * (1.35 - pulse * 0.1), _fillPaint);

    _fillPaint.color = AppColors.primaryLight.withOpacity(0.35 + pulse * 0.25);
    canvas.drawCircle(center, r * (1.15 - pulse * 0.05), _fillPaint);
  }

  void _drawRotatingArc(Canvas canvas, Offset center, double r, Size size) {
    final radius = r * 1.22;
    final rect = Rect.fromCircle(center: center, radius: radius);
    // 只在画布尺寸变化时重建 shader（旋转通过 canvas.rotate 实现，不重建）
    if (_cachedShader == null || _cachedRect != rect) {
      _cachedRect = rect;
      _cachedShader = _arcGradient.createShader(rect);
    }
    _strokePaint.shader = _cachedShader;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation * math.pi * 2);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawArc(rect, 0, math.pi * 2, false, _strokePaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AvatarPainter old) =>
      old.mode != mode ||
      old.breath != breath ||
      old.ripple != ripple ||
      old.pulse != pulse ||
      old.rotation != rotation;
}
