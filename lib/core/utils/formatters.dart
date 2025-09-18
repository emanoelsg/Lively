// core/utils/formatters.dart
import 'package:flutter/services.dart';
import 'package:lively/core/constants.dart';

/// Text input formatter that only allows numbers with up to 2 decimal places
class DecimalTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow empty string or minus sign
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Allow only numbers and one decimal point
    final regExp = RegExp(r'^\d*\.?\d{0,2}$');
    if (!regExp.hasMatch(newValue.text)) {
      return oldValue;
    }

    // Prevent multiple decimal points
    if (newValue.text.split('.').length > 2) {
      return oldValue;
    }

    return newValue;
  }
}

/// Formats a number to display with fixed decimal places
String formatNumber(double value) {
  return value.toStringAsFixed(AppConstants.maxDecimalPlaces);
}

/// Attempts to parse a string to a double, returns null if invalid
double? tryParseDouble(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  
  try {
    return double.parse(value);
  } catch (e) {
    return null;
  }
}