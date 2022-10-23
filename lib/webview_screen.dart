import 'package:flutter/material.dart';
import 'input_screen.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({Key? key}) : super(key: key);

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: (){
              Navigator.push(context,
                MaterialPageRoute(builder: (context)=>InputScreen(isFirstSetup: false))
              );
            },
          ),
        ]
      ),
      body: Center(
        child: Text('dovrebbe esserci la webview'),
      )
    );
  }
}
