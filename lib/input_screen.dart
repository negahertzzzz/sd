import 'package:flutter/material.dart';
import 'package:serena_onlus_login/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'styles.dart';
import 'package:http/http.dart' as http;

class InputScreen extends StatefulWidget {
  const InputScreen({Key? key, required this.isFirstSetup}) : super(key: key);

  final bool isFirstSetup;

  @override
  // ignore: library_private_types_in_public_api
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  TextEditingController userController = TextEditingController();
  TextEditingController pwdController = TextEditingController();
  TextEditingController urlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: widget.isFirstSetup
            ? Container()
            : IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back)),
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white70,
        child: Container(
          padding:
              const EdgeInsets.only(left: 9, right: 9, top: 12, bottom: 12),
          margin: const EdgeInsets.all(50),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: TextField(
                  controller: userController,
                  decoration: const InputDecoration(labelText: 'username'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: TextField(
                  controller: pwdController,
                  decoration: const InputDecoration(labelText: 'password'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: TextField(
                  controller: urlController,
                  decoration: const InputDecoration(labelText: 'url'),
                ),
              ),
              TextButton(
                onPressed: () async {
                  if (widget.isFirstSetup) {
                    var client = http.Client();
                    try {
                      var link = urlController.text;
                      link = link.replaceAll('http://', '');
                      link = link.replaceAll('https://', '');
                      link = link.replaceAll('www.', '');
                      var response = await client.post(
                          Uri.https(
                              link.replaceRange(link.indexOf('/'), null, ''),
                              link.replaceRange(0, link.indexOf('/'), '')),
                          body: {
                            'ut_user': userController.text,
                            'ut_pwd': pwdController.text
                          });
                      print(response.body);
                      if (!response.body.contains("Credenziali errete")) {
                        // ignore: use_build_context_synchronously
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ConfermaLogin()));
                        var preferences = await SharedPreferences.getInstance();
                        preferences.setString('ut_user', userController.text);
                        preferences.setString('ut_pwd', pwdController.text);
                        preferences.setString('link', link);
                      } else {
                        //Popup credenziali errate
                      }
                    } finally {
                      client.close();
                    }
                  } else {
                    Navigator.pop(context);
                  }
                },
                style: stileBottoni,
                child: const Text(
                  'SALVA',
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
