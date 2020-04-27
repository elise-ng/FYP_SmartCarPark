import 'package:smart_car_park_app/models/parking_invoice.dart';

enum PaymentSourceType {
  alipay,
  wechat,
}

extension Members on PaymentSourceType {
  String getName() {
    switch (this) {
      case PaymentSourceType.alipay:
        return "Alipay";
      case PaymentSourceType.wechat:
        return "Wechat Pay";
      default:
        return "";
    }
  }

  String getAssetPath() {
    switch (this) {
      case PaymentSourceType.alipay:
        return "assets/images/alipay.png";
      case PaymentSourceType.wechat:
        return "assets/images/wechatpay.png";
      default:
        return "";
    }
  }
}

class PaymentSource {
  PaymentSource(this.gateRecordId, this.invoice, this.type);

  String gateRecordId;
  ParkingInvoice invoice;
  PaymentSourceType type;
}
