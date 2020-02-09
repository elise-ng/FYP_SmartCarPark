import 'package:flutter/material.dart';

class SigninWidget extends StatefulWidget {

  SigninWidget({
    Key key
  }) : super(key: key);

  @override
  _SigninWidgetState createState() => new _SigninWidgetState();
}

class _SigninWidgetState extends State<SigninWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
      height: 300,
      padding: EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        boxShadow: [ BoxShadow(blurRadius: 4.0, color: Colors.grey, spreadRadius: 2.0) ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,              
              children: <Widget>[
                Text(
                  "Welcome to Smart Car Park",
                  style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.w500)
                ),
                Padding(padding: EdgeInsets.only(top: 4.0)),
                Text(
                  "Login to access more features.",
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w300),
                )
              ],
            ),
          ),
          // Padding(padding: EdgeInsets.only(top: 4.0)),
          Container(
            width: double.infinity,
            child: TextFormField(
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: "Phone Number"),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                flex: 7,
                child: TextFormField(
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(labelText: "Verification Code"),
                )
              ),
              Expanded(
                flex: 3,
                child: Container(
                  child: OutlineButton(
                    child: Text("Get Code"),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                    onPressed: () {},
                  )
                )
              )
            ],
          ),
          Padding(padding: EdgeInsets.only(top: 24.0)),
          Container(
            width: double.infinity,
            height: 40.0,
            child: RaisedButton(
              child: Text("Login"),
              color: Colors.blueAccent,
              textColor: Colors.white,
              onPressed: () {},
            ),
          )
        ],
      )
    );
  }
}