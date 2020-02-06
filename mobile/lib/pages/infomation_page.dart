import 'package:flutter/material.dart';

class InformationPage extends StatefulWidget {
  InformationPage({
    key,
  }) : super(key: key);

  @override
  _InformationPageState createState() => _InformationPageState();
}

class _InformationPageState extends State<InformationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: EdgeInsets.all(24.0),
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
                    "Getting Started",
                    style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.w500)
                  ),
                  Text(
                    "Login to access more features.",
                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w300),
                  )
                ],
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 12.0)),
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
                    obscureText: true,
                    decoration: InputDecoration(labelText: "Verification Code"),
                  )
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    child: RaisedButton(
                      child: Text("Get Code"),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                      onPressed: () {},
                    )
                  )
                )
              ],
            ),
            Padding(padding: EdgeInsets.only(top: 12.0)),
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
      )
    );
  }
}
