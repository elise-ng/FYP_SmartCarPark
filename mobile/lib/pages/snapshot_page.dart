import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class SnapshotPage extends StatefulWidget {
  final String iotDeviceId;
  final DateTime fromDateTime;

  SnapshotPage({@required this.iotDeviceId, @required this.fromDateTime, key})
      : super(key: key);
  @override
  _SnapshotPageState createState() => _SnapshotPageState();
}

class _SnapshotPageState extends State<SnapshotPage> {
  List<String> imageUrls;

  @override
  void initState() {
    super.initState();
    Firestore.instance
        .collection('iotStateChanges')
        .where('deviceId', isEqualTo: this.widget.iotDeviceId)
        .where('time',
            isGreaterThanOrEqualTo:
                Timestamp.fromDate(this.widget.fromDateTime))
        .orderBy('time', descending: true)
        .snapshots()
        .listen((snapshot) async {
      debugPrint((snapshot.documents.first.data['time'] as Timestamp)
          .toDate()
          .toIso8601String());
      debugPrint((snapshot.documents.last.data['time'] as Timestamp)
          .toDate()
          .toIso8601String());
      final gsImageUrls = snapshot.documents
          .map((doc) => doc.data['newState']['imageUrl'] as String);
      this.imageUrls = await Future.wait(gsImageUrls.map((gsImageUrl) async {
        debugPrint(gsImageUrl);
        if (gsImageUrl == null || !gsImageUrl.startsWith('gs://')) return null;
        final ref =
            await FirebaseStorage.instance.getReferenceFromUrl(gsImageUrl);
        return await ref.getDownloadURL() as String;
      }).toList());
      this.imageUrls = this
          .imageUrls
          .toSet()
          .toList()
          .where((element) => element != null)
          .toList(); // filter duplicate & null
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Past Snapshots'),
      ),
      body: this.imageUrls != null
          ? CustomScrollView(
              slivers: <Widget>[
                SliverGrid.count(
                  crossAxisCount: 2,
                  children: this
                      .imageUrls
                      .map((imageUrl) => InkWell(
                            onTap: () {
                              Navigator.of(context).push(PageRouteBuilder(
                                barrierColor: Colors.black.withOpacity(0.5),
                                opaque: false,
                                pageBuilder: (context, _, __) => ZoomableImage(
                                  imageUrl: imageUrl,
                                ),
                              ));
                            },
                            child: Hero(
                              tag: imageUrl,
                              child: Image.network(imageUrl),
                            ),
                          ))
                      .toList(),
                ),
              ],
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

class ZoomableImage extends StatelessWidget {
  final String imageUrl;

  ZoomableImage({
    this.imageUrl,
  });
  
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: this.imageUrl,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          child: PhotoView.customChild(
            backgroundDecoration: BoxDecoration(
              color: Colors.transparent,
            ),
            child: Image.network(this.imageUrl),
            childSize: Size(1000, 1000),
          ),
        ),
      ),
    );
  }
}
