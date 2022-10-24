import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'input_screen.dart';
import 'confirm_login_screen.dart';
import 'package:http/http.dart' as http;

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
  if (utUser == '' && utPwd == '' && link == '') {
    //non sono presenti dei dati quindi vieni reindirizzato alla pagina di inserimento dei dati
    
    runApp(const InsertimentoDati());
  } else {
    //tutto presente e ti apro la pagina per confermarti il login
    if(await checkLogin(utUser, utPwd, link)){
      runApp(const InsertimentoDati());
      loginError( BuildContext);
    }
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

Future<bool> checkLogin(user, pwd, link) async {
  try{
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
}catch(Exeption){
  return false;
}
}

void loginError(context) {
  showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text("Errore"),
          content: Text(
              "Attenzione hai inserito delle credenziali non valide, riprova"),
        );
      });
}
