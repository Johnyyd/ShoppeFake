extension CurrencyFormat on num {
  /// Định dạng số tiền sang chuẩn VND (ví dụ: 250000 -> "250.000đ")
  String toVND({bool showUnit = true}) {
    final intValue = round();
    final str = intValue.abs().toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
      count++;
    }
    final formatted = buffer.toString().split('').reversed.join();
    final prefix = intValue < 0 ? '-' : '';
    return showUnit ? '$prefix$formattedđ' : '$prefix$formatted';
  }
}
