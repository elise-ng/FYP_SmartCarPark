
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class SnapshotPage extends StatefulWidget {

  String iotDeviceId;
  DateTime fromDateTime;

  SnapshotPage({@required this.iotDeviceId, @required this.fromDateTime, key}):super(key:key);
  @override
  _SnapshotPageState createState() => _SnapshotPageState();
}

class _SnapshotPageState extends State<SnapshotPage> {

  List<String> imageUrls;

  @override
  void initState() {
    super.initState();
    Firestore.instance.collection('iotStateChanges')
      .where('deviceId', isEqualTo: this.widget.iotDeviceId)
      .where('time', isGreaterThanOrEqualTo: Timestamp.fromDate(this.widget.fromDateTime))
      .orderBy('time', descending: true)
      .snapshots()
      .listen((snapshot) async {
        debugPrint((snapshot.documents.first.data['time'] as Timestamp).toDate().toIso8601String());
        debugPrint((snapshot.documents.last.data['time'] as Timestamp).toDate().toIso8601String());
        final gsImageUrls = snapshot.documents.map((doc) => doc.data['newState']['imageUrl'] as String);
        this.imageUrls = await Future.wait(
          gsImageUrls.map((gsImageUrl) async {
            debugPrint(gsImageUrl);
            if (gsImageUrl == null || !gsImageUrl.startsWith('gs://')) return null;
            final ref = await FirebaseStorage.instance.getReferenceFromUrl(gsImageUrl);
            return await ref.getDownloadURL() as String;
          }).toList()
        );
        print(this.imageUrls.toString());
        this.imageUrls = this.imageUrls.toSet().toList().where((element) => element != null).toList(); // filter duplicate & null
        print(this.imageUrls.toString());
        setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Past Snapshots'),
      ),
      body:
      this.imageUrls != null
      ? CustomScrollView(
        slivers: <Widget>[
          SliverGrid.count(
            crossAxisCount: 2,
            children: this.imageUrls.map((imageUrl) => Image.network(imageUrl)).toList(),
          )
        ]
      )
      : Center(
        child: CircularProgressIndicator(),
      )
    );
  }
}