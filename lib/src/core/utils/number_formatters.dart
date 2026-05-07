import 'package:flutter/services.dart';

abstract final class NumberFormatters {
  static String formatCurrency(
    double amount, {
    String symbol = '\$',
    int decimals = 2,
  }) {
    final fixed = amount.toStringAsFixed(decimals);
    final parts = fixed.split('.');
    final whole = _addThousands(parts.first);
    final fraction = parts.length > 1 ? '.${parts[1]}' : '';
    return '$symbol $whole$fraction';
  }

  static String _addThousands(String digits) {
    final negative = digits.startsWith('-');
    final source = negative ? digits.substring(1) : digits;
    final sb = StringBuffer();
    for (var i = 0; i < source.length; i++) {
      final fromEnd = source.length - i;
      sb.write(source[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) {
        sb.write(',');
      }
    }
    final out = sb.toString();
    return negative ? '-$out' : out;
  }

  static String digitsAndDotOnly(String raw) =>
      raw.replaceAll(RegExp(r'[^0-9.]'), '');

  static double? parseCurrencyInput(String raw) {
    final normalized = digitsAndDotOnly(raw);
    return double.tryParse(normalized);
  }
}

/// Formats numeric input as thousands-separated while typing.
class CurrencyTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = NumberFormatters.digitsAndDotOnly(newValue.text);
    if (raw.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final pieces = raw.split('.');
    var whole = pieces.first;
    var decimal = pieces.length > 1 ? pieces[1] : '';
    if (decimal.length > 2) {
      decimal = decimal.substring(0, 2);
    }

    whole = whole.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    if (whole.isEmpty) {
      whole = '0';
    }
    final grouped = _groupWhole(whole);
    final text = decimal.isNotEmpty ? '$grouped.$decimal' : grouped;

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  String _groupWhole(String whole) {
    final chars = whole.split('');
    final out = <String>[];
    for (var i = 0; i < chars.length; i++) {
      final fromEnd = chars.length - i;
      out.add(chars[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) {
        out.add(',');
      }
    }
    return out.join();
  }
}
