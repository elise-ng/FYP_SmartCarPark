import 'package:json_annotation/json_annotation.dart';

part 'payment_method.g.dart';

@JsonSerializable(explicitToJson: true, anyMap: true)
class PaymentMethod {
  PaymentMethod();

  String id;
  Card card;
  int created;

  factory PaymentMethod.fromJson(Map json) => _$PaymentMethodFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentMethodToJson(this);
}

/// Representation of a credit card object inside a payment method
@JsonSerializable(anyMap: true)
class Card {
  Card();

  String brand;
  String country;
  @JsonKey(name: "exp_month")
  int expMonth;
  @JsonKey(name: "exp_year")
  int expYear;
  String fingerprint;
  String funding;
  String last4;

  factory Card.fromJson(Map json) => _$CardFromJson(json);
  Map<String, dynamic> toJson() => _$CardToJson(this);
}