import 'package:json_annotation/json_annotation.dart';
import 'package:stripe_sdk/stripe_sdk_ui.dart';

part 'payment_method.g.dart';

@JsonSerializable(explicitToJson: true, anyMap: true)
class PaymentMethod {
  PaymentMethod();

  String id;
  PaymentCard card;
  int created;

  factory PaymentMethod.fromJson(Map json) => _$PaymentMethodFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentMethodToJson(this);
}

/// Representation of a credit card object inside a payment method
@JsonSerializable(anyMap: true)
class PaymentCard {
  PaymentCard();

  String brand;
  String country;
  @JsonKey(name: "exp_month")
  int expMonth;
  @JsonKey(name: "exp_year")
  int expYear;
  String fingerprint;
  String funding;
  String last4;

  factory PaymentCard.fromJson(Map json) => _$CardFromJson(json);

  Map<String, dynamic> toJson() => _$CardToJson(this);

  String getBrandName() {
    switch (this.brand) {
      case "amex":
        return StripeCard.AMERICAN_EXPRESS;
      case "diners":
        return StripeCard.DINERS_CLUB;
      case "discover":
        return StripeCard.DISCOVER;
      case "jcb":
        return StripeCard.JCB;
      case "mastercard":
        return StripeCard.MASTERCARD;
      case "unionpay":
        return StripeCard.UNIONPAY;
      case "visa":
        return StripeCard.VISA;
      default:
        return "Credit Card";
    }
  }

  String getCardDescription() {
    return "${this.getBrandName()} ending in ${this.last4}";
  }
}