import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mars_fx/domain/currency_data.dart';
import 'package:mars_fx/theme/theme_constants.dart';

class CurrencyRow extends StatefulWidget {
  final String code;
  final String value;
  final bool isActive;
  final bool showLongName;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final ValueChanged<String> onValueChanged;
  final VoidCallback onDismissed;

  const CurrencyRow({
    super.key,
    required this.code,
    required this.value,
    required this.isActive,
    this.showLongName = false,
    required this.onTap,
    required this.onLongPress,
    required this.onValueChanged,
    required this.onDismissed,
  });

  @override
  State<CurrencyRow> createState() => _CurrencyRowState();
}

enum _DragDir { copy, delete }

class _CurrencyRowState extends State<CurrencyRow>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isEditing = false;

  // Right-swipe copy
  double _copyOffset = 0.0;
  static const double _copyMax = 72.0;
  static const double _copyThreshold = 52.0;

  // Left-swipe delete
  double _deleteOffset = 0.0;
  static const double _deleteMax = 80.0;
  static const double _deleteThreshold = 60.0;

  // Shared drag state
  Offset? _pointerStart;
  _DragDir? _dragDir;
  bool _isAnimating = false;

  // Snap-back / dismiss animation
  late final AnimationController _snapAnim;
  late CurvedAnimation _snapCurve;
  double _snapFrom = 0;
  double _snapTo = 0;
  bool _willDismiss = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _controller.addListener(_onTextChanged);

    _snapAnim = AnimationController(vsync: this);
    _snapCurve = CurvedAnimation(parent: _snapAnim, curve: Curves.easeOut);
    _snapAnim.addListener(_onSnapTick);
    _snapAnim.addStatusListener(_onSnapStatus);
  }

  void _onSnapTick() {
    if (!mounted) return;
    setState(() {
      _deleteOffset = _snapFrom + (_snapTo - _snapFrom) * _snapCurve.value;
    });
  }

  void _onSnapStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    _isAnimating = false;
    if (_willDismiss) {
      widget.onDismissed();
    } else {
      setState(() => _deleteOffset = 0);
    }
  }

  void _animateTo(double end, {required bool dismiss}) {
    _snapFrom = _deleteOffset;
    _snapTo = end;
    _willDismiss = dismiss;
    _isAnimating = true;
    _snapCurve = CurvedAnimation(
      parent: _snapAnim,
      curve: dismiss ? Curves.easeIn : Curves.elasticOut,
    );
    _snapAnim.duration = dismiss
        ? const Duration(milliseconds: 160)
        : const Duration(milliseconds: 500);
    _snapAnim.forward(from: 0);
  }

  void _onPointerDown(PointerDownEvent e) {
    if (_isAnimating) return;
    _pointerStart = e.localPosition;
    _dragDir = null;
  }

  void _onPointerMove(PointerMoveEvent e) {
    if (_pointerStart == null || _isAnimating) return;
    final dx = e.localPosition.dx - _pointerStart!.dx;

    if (_dragDir == null) {
      if (dx.abs() < 8) return;
      _dragDir = dx > 0 ? _DragDir.copy : _DragDir.delete;
    }

    if (_dragDir == _DragDir.copy) {
      setState(() => _copyOffset = dx.clamp(0.0, _copyMax));
    } else {
      setState(() => _deleteOffset = (-dx).clamp(0.0, _deleteMax));
    }
  }

  void _onPointerUp(PointerUpEvent e) {
    if (_dragDir == _DragDir.copy) {
      if (_copyOffset >= _copyThreshold && widget.value.isNotEmpty) {
        Clipboard.setData(ClipboardData(text: widget.value));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.code} · ${widget.value}'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      _resetDrag();
    } else if (_dragDir == _DragDir.delete) {
      if (_deleteOffset >= _deleteThreshold) {
        _animateTo(MediaQuery.of(context).size.width, dismiss: true);
      } else {
        _animateTo(0.0, dismiss: false);
      }
      _pointerStart = null;
      _dragDir = null;
    } else {
      _resetDrag();
    }
  }

  void _onPointerCancel(PointerCancelEvent e) {
    if (_deleteOffset > 0) {
      _animateTo(0.0, dismiss: false);
      _pointerStart = null;
      _dragDir = null;
    } else {
      _resetDrag();
    }
  }

  void _resetDrag() {
    if (!mounted) return;
    setState(() {
      _copyOffset = 0.0;
      _pointerStart = null;
      _dragDir = null;
    });
  }

  @override
  void didUpdateWidget(CurrencyRow oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!_isEditing) {
      final raw = widget.value;
      if (_controller.text.replaceAll(' ', '') != raw) {
        _controller.text = widget.isActive ? _formatDisplay(raw) : raw;
        if (widget.isActive) {
          _controller.selection = TextSelection.collapsed(
            offset: _controller.text.length,
          );
        }
      }
    }

    if (widget.isActive && !oldWidget.isActive) {
      final formatted = _formatDisplay(widget.value);
      _controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    } else if (!widget.isActive && oldWidget.isActive) {
      _isEditing = false;
      _focusNode.unfocus();
    }
  }

  String _formatDisplay(String value) {
    if (value.isEmpty) return value;
    final parts = value.split('.');
    final intPart = parts[0];
    final decPart = parts.length > 1 ? '.${parts[1]}' : '';
    final buf = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(' ');
      buf.write(intPart[i]);
    }
    return buf.toString() + decPart;
  }

  void _onTextChanged() {
    if (widget.isActive && _focusNode.hasFocus) {
      _isEditing = true;
      widget.onValueChanged(_controller.text.replaceAll(' ', ''));
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    _snapAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final opacity = widget.isActive ? 1.0 : 0.5;
    final copyProgress = (_copyOffset / _copyMax).clamp(0.0, 1.0);
    final deleteProgress = (_deleteOffset / _deleteMax).clamp(0.0, 1.0);

    return Listener(
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          if (_copyOffset > 0)
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: Icon(
                    Icons.copy_outlined,
                    size: 20,
                    color: primary.withValues(alpha: copyProgress * 0.5),
                  ),
                ),
              ),
            ),
          if (_deleteOffset > 0)
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: primary.withValues(
                      alpha: (deleteProgress * 0.8).clamp(0.0, 0.6),
                    ),
                  ),
                ),
              ),
            ),
          Transform.translate(
            offset: Offset(_copyOffset - _deleteOffset, 0),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                widget.onTap();
                _focusNode.requestFocus();
                _controller.selection = TextSelection.collapsed(
                  offset: _controller.text.length,
                );
              },
              onLongPress: widget.onLongPress,
              child: Opacity(
                opacity: opacity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.showLongName
                            ? (CurrencyData.currencies[widget.code] ??
                                  widget.code)
                            : widget.code,
                        style: TEXT_STYLE_CURRENCY_CODE.copyWith(
                          color: primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      widget.isActive
                          ? _buildActiveInput(primary)
                          : _buildInactiveValue(primary),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveInput(Color color) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              style: TEXT_STYLE_CURRENCY_VALUE_ACTIVE.copyWith(color: color),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                hintText: '0',
                hintStyle: TEXT_STYLE_CURRENCY_VALUE.copyWith(
                  color: color.withValues(alpha: 0.2),
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                _ThousandsSeparatorFormatter(),
              ],
              onEditingComplete: () {},
            ),
          ),
          if (_controller.text.isNotEmpty)
            GestureDetector(
              onTap: () => _controller.clear(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 4, 14),
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: color.withValues(alpha: 0.3),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInactiveValue(Color color) {
    final display = widget.value.isEmpty ? '' : _formatDisplay(widget.value);
    return SizedBox(
      height:
          TEXT_STYLE_CURRENCY_VALUE.fontSize! *
              (TEXT_STYLE_CURRENCY_VALUE.height ?? 1.2) +
          4,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          display.isEmpty ? '0' : display,
          style: TEXT_STYLE_CURRENCY_VALUE.copyWith(
            color: widget.value.isEmpty ? color.withValues(alpha: 0.2) : color,
          ),
        ),
      ),
    );
  }
}

class _ThousandsSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text;
    if (raw.isEmpty) return newValue;

    final parts = raw.split('.');
    final intPart = parts[0];
    final decPart = parts.length > 1 ? '.${parts[1]}' : '';

    final buf = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(' ');
      buf.write(intPart[i]);
    }
    final formatted = buf.toString() + decPart;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
