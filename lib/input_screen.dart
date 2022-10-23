import 'package:flutter/material.dart';
import 'package:serena_onlus_login/main.dart';
import 'styles.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({Key? key,required this.isFirstSetup}) : super(key: key);

  final bool isFirstSetup;

  @override
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
        leading: widget.isFirstSetup ? Container() : IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back)),
        title: Text('Login'),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white70,
        child: Container(
          padding: EdgeInsets.only(left: 9,right: 9,top: 12,bottom: 12),
          margin: EdgeInsets.all(50),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: TextField(
                  controller: userController,
                  decoration: const InputDecoration(
                    labelText: 'username'
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: TextField(
                  controller: pwdController,
                  decoration: const InputDecoration(
                      labelText: 'password'
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: TextField(
                  controller: urlController,
                  decoration: const InputDecoration(
                      labelText: 'url'
                  ),
                ),
              ),
              TextButton(
                  onPressed: (){
                    if(widget.isFirstSetup){
                      Navigator.pushReplacement(context,MaterialPageRoute(builder:(context) => ConfermaLogin()));
                    }else{
                      Navigator.pop(context);
                    }
                  },
                  child: Text('SALVA',style: TextStyle(color: Colors.white),),
                style: stileBottoni,
              )
            ],
          ),
        ),
      ),
    );
  }
}


