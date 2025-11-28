import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'spaces.dart';

class CurrencyTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final Function(String value)? onChanged;
  final TextInputAction? textInputAction;
  final bool showLabel;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool readOnly;
  final int maxDigits;

  const CurrencyTextField({
    super.key,
    required this.controller,
    required this.label,
    this.onChanged,
    this.textInputAction,
    this.showLabel = true,
    this.prefixIcon,
    this.suffixIcon,
    this.readOnly = false,
    this.maxDigits = 18,
  });

  @override
  State<CurrencyTextField> createState() => _CurrencyTextFieldState();
}

class _CurrencyTextFieldState extends State<CurrencyTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
    // Listen to controller changes to update prefix visibility
    widget.controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  String _formatCurrency(String value) {
    if (value.isEmpty) return '';
    // Remove non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) return '';
    // Format with thousand separators
    final number = int.tryParse(digitsOnly) ?? 0;
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showLabel) ...[
          Text(
            widget.label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SpaceHeight(12.0),
        ],
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          onChanged: (value) {
            // Remove "Rp." prefix and format
            String cleanedValue = value.replaceAll('Rp.', '').trim();
            cleanedValue = cleanedValue.replaceAll('.', '');

            // Validasi maksimal digit
            if (cleanedValue.length > widget.maxDigits) {
              // Potong ke maxDigits
              cleanedValue = cleanedValue.substring(0, widget.maxDigits);
              setState(() {
                _errorMessage = 'Maksimal ${widget.maxDigits} digit';
              });
            } else {
              setState(() {
                _errorMessage = null;
              });
            }

            // Format the value
            final formatted = _formatCurrency(cleanedValue);

            // Update controller without triggering listener
            widget.controller.value = TextEditingValue(
              text: formatted,
              selection: TextSelection.collapsed(
                offset: formatted.length,
              ),
            );

            if (widget.onChanged != null) {
              widget.onChanged!(cleanedValue);
            }
          },
          keyboardType: TextInputType.number,
          textInputAction: widget.textInputAction,
          readOnly: widget.readOnly,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(
                widget.maxDigits + 10), // Allow extra for formatting characters
          ],
          decoration: InputDecoration(
            prefixText: (_isFocused || widget.controller.text.isNotEmpty)
                ? 'Rp. '
                : null,
            prefixStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: BorderSide(
                color: _errorMessage != null ? Colors.red : Colors.grey,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: BorderSide(
                color: _errorMessage != null ? Colors.red : Colors.grey,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: BorderSide(
                color: _errorMessage != null ? Colors.red : Colors.blue,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            hintText: widget.label,
            errorText: _errorMessage,
            errorMaxLines: 2,
          ),
        ),
      ],
    );
  }
}
