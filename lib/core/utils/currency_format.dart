/// Formats a whole-rupiah amount, for example 50000 -> "Rp 50.000".
String formatRupiah(int amount) {
  final digits = amount.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final digitsLeft = digits.length - i;
    buffer.write(digits[i]);
    // a dot after every group of three digits, counting from the right
    if (digitsLeft > 1 && digitsLeft % 3 == 1) buffer.write('.');
  }
  return '${amount < 0 ? '-' : ''}Rp $buffer';
}
