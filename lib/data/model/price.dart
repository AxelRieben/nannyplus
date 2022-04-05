import 'dart:convert';

class Price {
  const Price({
    this.id,
    required this.label,
    required this.amount,
    required this.fixedPrice,
    required this.sortOrder,
  });

  final int? id;
  final String label;
  final double amount;
  final int fixedPrice;
  final int sortOrder;

  bool get isFixedPrice => fixedPrice == 1;

  String get detail => amount.toStringAsFixed(2) + (isFixedPrice ? "" : " / h");

  // --------------------------------------------------

  Price copyWith({
    int? id,
    String? label,
    double? amount,
    int? fixedPrice,
    int? sortOrder,
  }) {
    return Price(
      id: id ?? this.id,
      label: label ?? this.label,
      amount: amount ?? this.amount,
      fixedPrice: fixedPrice ?? this.fixedPrice,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'amount': amount,
      'fixedPrice': fixedPrice,
      'sortOrder': sortOrder,
    };
  }

  factory Price.fromMap(Map<String, dynamic> map) {
    return Price(
      id: map['id']?.toInt(),
      label: map['label'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      fixedPrice: map['fixedPrice']?.toInt() ?? 0,
      sortOrder: map['sortOrder']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Price.fromJson(String source) => Price.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Price(id: $id, label: $label, amount: $amount, fixedPrice: $fixedPrice, sortOrder: $sortOrder)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Price &&
        other.id == id &&
        other.label == label &&
        other.amount == amount &&
        other.fixedPrice == fixedPrice &&
        other.sortOrder == sortOrder;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        label.hashCode ^
        amount.hashCode ^
        fixedPrice.hashCode ^
        sortOrder.hashCode;
  }
}
