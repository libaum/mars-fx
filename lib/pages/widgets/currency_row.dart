import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mars_fx/theme/theme_constants.dart';

/// A single currency row that can be either active (editable) or inactive (display-only).
class CurrencyRow extends StatefulWidget {
  final String code;
  final String value;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final ValueChanged<String> onValueChanged;
  final VoidCallback onDismissed;

  const CurrencyRow({
    super.key,
    required this.code,
    required this.value,
    required this.isActive,
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

  /// Track whether we're currently editing to avoid feedback loops
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(CurrencyRow oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update text only if this is an inactive row or if the value changed externally
    if (!_isEditing) {
      if (_controller.text != widget.value) {
        _controller.text = widget.value;
      }
    }

    // Handle focus changes when active state changes
    if (widget.isActive && !oldWidget.isActive) {
      // Becoming active — request focus
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _focusNode.requestFocus();
          // Place cursor at end
          _controller.selection = TextSelection.collapsed(
            offset: _controller.text.length,
          );
        }
      });
    } else if (!widget.isActive && oldWidget.isActive) {
      // Becoming inactive — release focus
      _isEditing = false;
      _focusNode.unfocus();
    }
  }

  void _onTextChanged() {
    if (widget.isActive && _focusNode.hasFocus) {
      _isEditing = true;
      widget.onValueChanged(_controller.text);
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

    return Dismissible(
      key: ValueKey('dismiss_${widget.code}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => widget.onDismissed(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: Icon(
          Icons.delete_outline,
          color: primary.withValues(alpha: 0.3),
          size: 20,
        ),
      ),
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
                  widget.code,
                  style: TEXT_STYLE_CURRENCY_CODE.copyWith(color: primary),
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
    );
  }

  Widget _buildActiveInput(Color color) {
    return TextField(
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
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
      ],
      onEditingComplete: () {},
    );
  }

  Widget _buildInactiveValue(Color color) {
    return SizedBox(
      // Match the height of the TextField to prevent layout jumps
      height: TEXT_STYLE_CURRENCY_VALUE.fontSize! * (TEXT_STYLE_CURRENCY_VALUE.height ?? 1.2) + 4,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          widget.value.isEmpty ? '0' : widget.value,
          style: TEXT_STYLE_CURRENCY_VALUE.copyWith(
            color: widget.value.isEmpty
                ? color.withValues(alpha: 0.2)
                : color,
          ),
        ),
      ),
    );
  }
}
