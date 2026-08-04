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

class _CurrencyRowState extends State<CurrencyRow> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isEditing = false;

  /// How far a row may travel, as a fraction of its width — same reveal
  /// mechanic as the thought list: swipe left deletes, swipe right copies.
  static const _maxRevealFraction = 1 / 3;
  static const _iconSize = 20.0;

  /// Set from the LayoutBuilder below — the travel limit is width-relative.
  double _maxReveal = 0;

  Offset? _pointerStart;
  double _drag = 0;

  /// True once the row is pulled all the way to the stop. Only then does
  /// releasing it do anything — a half-hearted swipe is always a no-op.
  /// Hitting the stop ticks once so you can feel the action is loaded.
  bool _armed = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _controller.addListener(_onTextChanged);
  }

  void _onPointerDown(PointerDownEvent e) {
    _pointerStart = e.localPosition;
  }

  void _onPointerMove(PointerMoveEvent e) {
    if (_pointerStart == null) return;
    final dx = e.localPosition.dx - _pointerStart!.dx;
    final drag = dx.clamp(-_maxReveal, _maxReveal);
    final armed = _maxReveal > 0 && drag.abs() >= _maxReveal - 0.5;
    if (armed && !_armed) HapticFeedback.mediumImpact();
    setState(() {
      _drag = drag;
      _armed = armed;
    });
  }

  void _onPointerUp(PointerUpEvent e) {
    final delete = _armed && _drag < 0;
    final copy = _armed && _drag > 0 && widget.value.isNotEmpty;
    setState(() {
      _pointerStart = null;
      _drag = 0;
      _armed = false;
    });
    if (delete) widget.onDismissed();
    if (copy) Clipboard.setData(ClipboardData(text: widget.value));
  }

  void _onPointerCancel(PointerCancelEvent e) {
    setState(() {
      _pointerStart = null;
      _drag = 0;
      _armed = false;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final opacity = widget.isActive ? 1.0 : 0.5;

    // The row reads as a tile in the background colour. Swiping it aside
    // uncovers an inverted tile filling exactly the strip it vacated —
    // delete (left) tints red, copy (right) stays in the neutral primary
    // colour. Same mechanic and look as ThoughtRow's swipe actions.
    final tile = Theme.of(context).scaffoldBackgroundColor;
    final reveal = _drag < 0 ? COLOR_DELETE : primary;

    return LayoutBuilder(
      builder: (context, constraints) {
        _maxReveal = constraints.maxWidth * _maxRevealFraction;
        return Listener(
          onPointerDown: _onPointerDown,
          onPointerMove: _onPointerMove,
          onPointerUp: _onPointerUp,
          onPointerCancel: _onPointerCancel,
          child: Stack(
            children: [
              if (_drag != 0)
                Positioned(
                  // Flush with the edge the row started at, so the two
                  // tiles meet without a seam.
                  left: _drag > 0 ? 0 : null,
                  right: _drag < 0 ? 0 : null,
                  top: 0,
                  bottom: 0,
                  width: _drag.abs(),
                  child: ClipRect(
                    child: ColoredBox(
                      color: reveal,
                      // OverflowBox keeps the icon at full size and centred
                      // in the strip, so early in a swipe it is cut off by
                      // the strip's edges rather than squeezed into it.
                      child: OverflowBox(
                        minWidth: 0,
                        maxWidth: double.infinity,
                        child: Icon(
                          _drag < 0
                              ? Icons.delete_outline
                              : Icons.copy_outlined,
                          size: _iconSize,
                          color: tile,
                        ),
                      ),
                    ),
                  ),
                ),
              Transform.translate(
                offset: Offset(_drag, 0),
                child: ColoredBox(
                  color: tile,
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
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
              ),
            ],
          ),
        );
      },
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
