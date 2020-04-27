// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_method.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentMethod _$PaymentMethodFromJson(Map json) {
  return PaymentMethod()
    ..id = json['id'] as String
    ..card =
        json['card'] == null ? null : PaymentCard.fromJson(json['card'] as Map)
    ..created = json['created'] as int
    ..customer = json['customer'] as String;
}

Map<String, dynamic> _$PaymentMethodToJson(PaymentMethod instance) =>
    <String, dynamic>{
      'id': instance.id,
      'card': instance.card?.toJson(),
      'created': instance.created,
      'customer': instance.customer,
    };

PaymentCard _$PaymentCardFromJson(Map json) {
  return PaymentCard()
    ..brand = json['brand'] as String
    ..country = json['country'] as String
    ..expMonth = json['exp_month'] as int
    ..expYear = json['exp_year'] as int
    ..fingerprint = json['fingerprint'] as String
    ..funding = json['funding'] as String
    ..last4 = json['last4'] as String;
}

Map<String, dynamic> _$PaymentCardToJson(PaymentCard instance) =>
    <String, dynamic>{
      'brand': instance.brand,
      'country': instance.country,
      'exp_month': instance.expMonth,
      'exp_year': instance.expYear,
      'fingerprint': instance.fingerprint,
      'funding': instance.funding,
      'last4': instance.last4,
    };
