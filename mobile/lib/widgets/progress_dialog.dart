import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pedantic/pedantic.dart';

/// Show progress dialog busying for something
/// Use the widget as-is
/// Or call the static function show directly with a busy async function
class ProgressDialog extends StatefulWidget {
  final String message;

  ProgressDialog({
    this.message = "Loading...",
  });

  static bool isShowing = false;

  static Future<T> showBlocking<T>(BuildContext context, Future<T> future,
      {String message}) async {
    isShowing = true;
    unawaited(showDialog(
      context: context,
      builder: (BuildContext context) {
        if (message == null) {
          return ProgressDialog();
        } else {
          return ProgressDialog(message: message);
        }
      },
      barrierDismissible: false,
    ));
    final results = await future;
    Navigator.pop(context);
    isShowing = false;
    return results;
  }

  static void show(BuildContext context, {String message}) {
    isShowing = true;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        if (message == null) {
          return ProgressDialog();
        } else {
          return ProgressDialog(message: message);
        }
      },
      barrierDismissible: false,
    );
  }

  static void hide(BuildContext context) {
    Navigator.pop(context);
    isShowing = false;
  }

  @override
  _ProgressDialogState createState() => _ProgressDialogState();
}

class _ProgressDialogState extends State<ProgressDialog> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48.0),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: <Widget>[
              CircularProgressIndicator(),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  widget.message,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.none,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
