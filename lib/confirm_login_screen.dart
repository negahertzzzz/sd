import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
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
              const Image(
                image: AssetImage('s.jpg'),
                alignment: Alignment.center,
              ),
              const Text('Bentornato'),
              TextButton(
                onPressed: () async {
                  bool result = await InternetConnectionChecker().hasConnection;
                  if (result == false) {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return const AlertDialog(
                            title: Text("Errore"),
                            content: Text(
                                "Attenzione connessione internet assente "),
                          );
                        });
                    return;
                  }
                  // ignore: use_build_context_synchronously
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const WebViewExample()));
                },
                style: stileBottoni,
                child: const Text('ESEGUI LOGIN',
                    style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const InputScreen(
                                isFirstSetup: false,
                              )));
                },
                style: stileBottoni,
                child: const Text('MODIFICA CREDENZIALI',
                    style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
