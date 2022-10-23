import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'input_screen.dart';
import 'confirm_login_screen.dart';

String utUser = '';
String utPwd = '';
String link = '';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Acquisizione dati utente e password dalle SharedPreferences
  var preferences = await SharedPreferences.getInstance();
  utUser = preferences.getString('ut_user') ?? '';
  utPwd = preferences.getString('ut_pwd') ?? '';
  link = preferences.getString('link') ?? '';
  //fine acquisizione
  //Controllo presenza dati utente e reindirizzazione
  //alla pagina di login in caso siano assenti
  if (utUser == '' && utPwd == '') {
    //non sono presenti dei dati quindi vieni reindirizzato alla pagina di inserimento dei dati
    runApp(const InsertimentoDati());
  } else {
    //tutto presente e ti apro la pagina per confermarti il login
    runApp(const ConfermaLogin());
  }
}

class InsertimentoDati extends StatelessWidget {
  const InsertimentoDati({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        home: InputScreen(
      isFirstSetup: true,
    ));
  }
}

class ConfermaLogin extends StatelessWidget {
  const ConfermaLogin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: ConfirmLoginScreen());
  }
}
