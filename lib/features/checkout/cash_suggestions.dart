const _denominations = [5000, 10000, 20000, 50000, 100000];

/// Nominal cepat tunai (§6.3 Claude.md): "Uang pas" (= total) + dua saran
/// pembulatan ke atas yang lebih besar dari total dan berbeda satu sama
/// lain, diambil dari pecahan [_denominations].
List<int> cashSuggestions(int total) {
  final suggestions = <int>[total];
  for (final d in _denominations) {
    final rounded = ((total ~/ d) + 1) * d;
    if (rounded > total && !suggestions.contains(rounded)) {
      suggestions.add(rounded);
      if (suggestions.length == 3) break;
    }
  }
  return suggestions;
}
