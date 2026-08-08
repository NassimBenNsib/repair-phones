import 'line_item.dart';

/// Récapitulatif de montants d'un document.
class Totals {
  const Totals({
    required this.subtotal,
    required this.taxAmount,
    required this.total,
  });

  final double subtotal; // HT après remise
  final double taxAmount;
  final double total; // TTC

  /// Calcule les totaux à partir des lignes.
  ///
  /// [globalTaxRate] non nul → une TVA unique sur le sous-total ; sinon la TVA
  /// est cumulée par ligne.
  factory Totals.compute(
    List<LineItem> lines, {
    double discount = 0,
    double? globalTaxRate,
  }) {
    final gross = lines.fold<double>(0, (s, l) => s + l.totalHT);
    final subtotal = (gross - discount).clamp(0, double.infinity).toDouble();
    final tax = globalTaxRate != null
        ? subtotal * globalTaxRate
        : lines.fold<double>(0, (s, l) => s + l.totalHT * l.taxRate);
    return Totals(subtotal: subtotal, taxAmount: tax, total: subtotal + tax);
  }
}
