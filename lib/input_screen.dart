import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:serena_onlus_login/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'styles.dart';
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';

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
        backgroundColor: coloreAppBar,
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Image(image: AssetImage('s.jpg')),
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
                SizedBox(
                  width: 200,
                  child: TextButton(
                    onPressed: () async {
                      if (urlController.text.length < 4 ||
                          userController.text.length < 1 ||
                          pwdController.text.length < 1) {
                        Alert(
                            context: context,
                            type: AlertType.error,
                            title: "Attenzione",
                            desc:
                                "Devi compilare tutti i campi per continuare",
                            buttons: [
                              DialogButton(
                                onPressed: () => Navigator.pop(context),
                                color: const Color(0xFF485fa2),
                                child: const Text(
                                  "Riprova",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                              ),
                            ]).show();
                        return;
                      }
                      

                      if((!await canLaunchUrlString(urlController.text)) || !urlController.text.startsWith("https://")){
                        Alert(
                            context: context,
                            type: AlertType.error,
                            title: "Attenzione",
                            desc:
                                "Inserire un url valido.\nRicorda che il link deve inziare con https://",
                            buttons: [
                              DialogButton(
                                onPressed: () => Navigator.pop(context),
                                color: const Color(0xFF485fa2),
                                child: const Text(
                                  "Riprova",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                              ),
                            ]).show();
                        return;
                      }

                      bool result =
                          await InternetConnectionChecker().hasConnection;

                      if (result == false) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return const AlertDialog(
                                title: Text("Attenzione"),
                                content: Text(
                                    "Attenzione connessione internet assente "),
                              );
                            });
                        return;
                      }
                      if (widget.isFirstSetup) {
                        salvaCredenziali();
                        // ignore: use_build_context_synchronously
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: ((context) => const ConfermaLogin())));
                      } else {
                        salvaCredenziali();
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                      }
                    },
                    style: stileBottoni,
                    child: const Text(
                      'Salva Modifiche',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void salvaCredenziali() async {
    var preferences = await SharedPreferences.getInstance();

    link = urlController.text;
    preferences.setString('ut_user', userController.text);
    preferences.setString('ut_pwd', pwdController.text);
    preferences.setString('link', link);
    utUser = userController.text;
    utPwd = pwdController.text;
    //link = urlController.text;
  }
}

Future<bool> checkLogin(user, pwd, link) async {
  try {
    var client = http.Client();
    link = link
        .replaceAll('http://', '')
        .replaceAll('https://', '')
        .replaceAll('www.', '');
    var response = await client.post(
        Uri.https(link.replaceRange(link.indexOf('/'), null, ''),
            link.replaceRange(0, link.indexOf('/'), '')),
        body: {'ut_user': user, 'ut_pwd': pwd});
    if (response.body.contains('Benvenuto')) {
      return true;
    }
    return false;
  } on Exception catch (_) {
    return false;
  }
}
