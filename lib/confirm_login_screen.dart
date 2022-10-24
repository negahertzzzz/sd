import 'package:flutter/material.dart';
import 'package:serena_onlus_login/input_screen.dart';
import 'styles.dart';
import 'webview_screen.dart';

class ConfirmLoginScreen extends StatelessWidget {
  const ConfirmLoginScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Homepage'),
      ),
      body: Container(
        color: Colors.white70,
        child: Center(
          child: Column(
            children: [
              const Image(image: AssetImage('s.jpg'),
              alignment: Alignment.center,),
              const Text('Bentornato'),
              TextButton(
                  onPressed: (){
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => const WebViewExample())
                    );
                  },
                  
                style: stileBottoni,
                child: const Text('ESEGUI LOGIN',style: TextStyle(color: Colors.white)),
                              ),
              TextButton(
                  onPressed: (){
                    Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const InputScreen(isFirstSetup: false,))
                    );
                  },
                style: stileBottoni,
                  child: const Text('MODIFICA CREDENZIALI',style: TextStyle(color: Colors.white)),

              )
            ],
          ),
        ),
      ),
    );
  }
}
