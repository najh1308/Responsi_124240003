String formatPrice(double value) => '\$${value.toStringAsFixed(2)}';

String prettyCategory(String slug) {
  if (slug.isEmpty) return slug;
  final s = slug.replaceAll('-', ' ');
  return s[0].toUpperCase() + s.substring(1);
}
