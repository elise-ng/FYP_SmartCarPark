// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_method.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentMethod _$PaymentMethodFromJson(Map json) {
  return PaymentMethod()
    ..id = json['id'] as String
    ..card = json['card'] == null ? null : Card.fromJson(json['card'] as Map)
    ..created = json['created'] as int;
}

Map<String, dynamic> _$PaymentMethodToJson(PaymentMethod instance) =>
    <String, dynamic>{
      'id': instance.id,
      'card': instance.card?.toJson(),
      'created': instance.created,
    };

Card _$CardFromJson(Map json) {
  return Card()
    ..brand = json['brand'] as String
    ..country = json['country'] as String
    ..expMonth = json['exp_month'] as int
    ..expYear = json['exp_year'] as int
    ..fingerprint = json['fingerprint'] as String
    ..funding = json['funding'] as String
    ..last4 = json['last4'] as String;
}

Map<String, dynamic> _$CardToJson(Card instance) => <String, dynamic>{
      'brand': instance.brand,
      'country': instance.country,
      'exp_month': instance.expMonth,
      'exp_year': instance.expYear,
      'fingerprint': instance.fingerprint,
      'funding': instance.funding,
      'last4': instance.last4,
    };
