import 'package:cloud_firestore/cloud_firestore.dart';

class GateRecord {
  String id;
  String entryGate;
  DateTime entryScanTime;
  DateTime entryConfirmTime;
  String entryImageUrl;
  String exitGate;
  DateTime exitScanTime;
  DateTime exitConfirmTime;
  String exitImageUrl;
  String paymentStatus;
  DateTime paymentTime;
  String phoneNumber;
  String vehicleId;

  GateRecord({
    this.id,
    this.entryGate,
    this.entryScanTime,
    this.entryImageUrl,
    this.entryConfirmTime,
    this.exitGate,
    this.exitScanTime,
    this.exitImageUrl,
    this.exitConfirmTime,
    this.paymentStatus,
    this.paymentTime,
    this.phoneNumber,
    this.vehicleId
  });

  factory GateRecord.fromDocumentSnapshot(DocumentSnapshot doc) {
    return GateRecord(
      id: doc.documentID,
      entryGate: doc.data['entryGate'],
      entryScanTime: (doc.data['entryScanTime'] as Timestamp)?.toDate(),
      entryImageUrl: doc.data['entryImageUrl'],
      entryConfirmTime: (doc.data['entryConfirmTime'] as Timestamp)?.toDate(),
      exitGate: doc.data['exitGate'],
      exitScanTime: (doc.data['exitScanTime'] as Timestamp)?.toDate(),
      exitImageUrl: doc.data['entryImageUrl'],
      exitConfirmTime: (doc.data['exitConfirmTime'] as Timestamp)?.toDate(),
      paymentStatus: doc.data['paymentStatus'],
      paymentTime: (doc.data['paymentTime'] as Timestamp)?.toDate(),
      phoneNumber: doc.data['phoneNumber'],
      vehicleId: doc.data['vehicleId']
    );
  }
}