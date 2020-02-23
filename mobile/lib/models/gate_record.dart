import 'package:cloud_firestore/cloud_firestore.dart';

class GateRecord {
  String id;
  String entryGate;
  DateTime entryScanTime;
  DateTime entryConfirmTime;
  String exitGate;
  DateTime exitScanTime;
  DateTime exitConfirmTime;
  DateTime paymentTime;
  String phoneNumber;
  String vehicleId;

  GateRecord({
    this.id,
    this.entryGate,
    this.entryScanTime,
    this.entryConfirmTime,
    this.exitGate,
    this.exitScanTime,
    this.exitConfirmTime,
    this.paymentTime,
    this.phoneNumber,
    this.vehicleId
  });

  factory GateRecord.fromDocumentSnapshot(DocumentSnapshot doc) {
    return GateRecord(
      id: doc.documentID,
      entryGate: doc.data['entryGate'],
      entryScanTime: (doc.data['entryScanTime'] as Timestamp)?.toDate(),
      entryConfirmTime: (doc.data['entryConfirmTime'] as Timestamp)?.toDate(),
      exitGate: doc.data['exitGate'],
      exitScanTime: (doc.data['exitScanTime'] as Timestamp)?.toDate(),
      exitConfirmTime: (doc.data['exitConfirmTime'] as Timestamp)?.toDate(),
      paymentTime: doc.data['paymentTime'],
      phoneNumber: doc.data['phoneNumber'],
      vehicleId: doc.data['vehicleId']
    );
  }
}