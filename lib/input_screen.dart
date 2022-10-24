import 'package:flutter/material.dart';
import 'package:serena_onlus_login/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'styles.dart';
//import 'package:http/http.dart' as http;

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
    userController.text = utUser;
    pwdController.text = utPwd;
    urlController.text = link;
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
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: TextField(
                  obscureText: true,
                  controller: pwdController,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: TextField(
                  autocorrect: false,
                  controller: urlController,
                  decoration: const InputDecoration(labelText: 'Url'),
                ),
              ),
              TextButton(
                onPressed: () async {
                  if (widget.isFirstSetup) {
                    salvaCredenziali();
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: ((context) => const ConfermaLogin())));
                  } else {
                    salvaCredenziali();
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

  void salvaCredenziali() async {
    var preferences = await SharedPreferences.getInstance();

    if (!urlController.text.contains('https://') ||
        !urlController.text.contains('http://')) {
      link = 'https://${urlController.text}';
    }

    preferences.setString('ut_user', userController.text);
    preferences.setString('ut_pwd', pwdController.text);
    preferences.setString('link', link);
    utUser = userController.text;
    utPwd = pwdController.text;
    //link = urlController.text;
  }
}
