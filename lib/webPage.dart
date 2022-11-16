import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import "package:flutter/material.dart";
import 'package:dio/dio.dart';
//import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';
import "package:path/path.dart" as path;

import 'main.dart';
import 'styles.dart';

class WebViewRegistroProfessori extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const WebViewRegistroProfessori({this.cookieManager});

  final CookieManager? cookieManager;

  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewRegistroProfessori> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    const andorid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const initSetting = InitializationSettings(android: andorid, iOS: ios);
    flutterLocalNotificationsPlugin.initialize(initSetting);

    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cookieManager = WebviewCookieManager();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: coloreAppBar,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            //print(utUser+' '+utPwd+' '+link);
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const ConfermaLogin()));
          },
        ),
        title: const Text(''),
        actions: <Widget>[
          NavigationControls(_controller.future),
        ],
      ),
      body: Stack(
        children: <Widget>[
          WebView(
            initialUrl: "serena-onlus.com/mob/mob.php",
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) async {
              _controller.complete(webViewController);
              final WebViewRequest request = WebViewRequest(
              uri: Uri.parse(link),
              method: WebViewRequestMethod.post,
              headers: <String, String>{'Content-Type': 'text/plain'},
              body:
                  Uint8List.fromList('ut_user=$utUser&ut_pwd=$utPwd'.codeUnits),
              );
              await webViewController.loadRequest(request);
            },
            onProgress: (int progress) async {},
            javascriptChannels: <JavascriptChannel>{
              _toasterJavascriptChannel(context),
            },
            navigationDelegate: (NavigationRequest request) {
              print(request.url);
              
              if (request.url.contains(".pdf") ||
                  request.url.contains(".zip")) {
                download(request.url, request.url.split("/").last);
              } else {
                return NavigationDecision.navigate;
              }
              return NavigationDecision.prevent;
            },
            onPageFinished: (finish) {
              setState(() {
                isLoading = false;
              });
            },
            gestureNavigationEnabled: true,
            backgroundColor: const Color(0x00000000),
          ),
          Visibility(
            visible: isLoading,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        ],
      ),
    );
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }

  String progresss = "0";
  final Dio dio = Dio();

  Future _onSelectedNotification(String? json) async {
    final obj = jsonDecode(json!);
    if (obj["isSuccess"]) {
      if (obj['filePath'].toString().contains(".zip")) {
        return;
      }
      //OpenFile.open(obj['filePath']);
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text("Errore"),
                content: Text(obj['error']),
              ));
    }
  }

  Future<bool> requestPermission() async {
    final permission = await Permission.storage.status;
    if (permission != PermissionStatus.granted) {
      await Permission.storage.request();
    }
    return permission == PermissionStatus.granted;
  }

  Future<Directory?> getDownloadDirectory() async {
    if (Platform.isAndroid) {
      //return await DownloadsPathProvider.downloadsDirectory;
    }
    return await getApplicationDocumentsDirectory();
  }

  _onReceiveProgress(int receive, int total) {
    if (total != -1) {
      setState(() {
        progresss = (receive / total * 100).toStringAsFixed(0) + "%";
      });
    }
  }

  Future _showNotification(Map<String, dynamic> downloadStatus) async {
    const android = AndroidNotificationDetails("channelId", "IIS Cossali",
        importance: Importance.max, priority: Priority.high, playSound: false);

    const ios = DarwinNotificationDetails(presentSound: false);
    const notificationDetails = NotificationDetails(android: android, iOS: ios);
    final json = jsonEncode(downloadStatus);
    final isSuccess = downloadStatus["isSuccess"];
    if (downloadStatus["filePath"].toString().contains(".zip")) {
      await FlutterLocalNotificationsPlugin().show(
          0,
          isSuccess ? "File scaricato con successo" : "Errore",
          isSuccess
              ? "Controllare la cartella di download per aprire il file"
              : "Riprova a scaricare il file",
          notificationDetails,
          payload: json);
    } else {
      await FlutterLocalNotificationsPlugin().show(
          0,
          isSuccess ? "File scaricato con successo" : "Errore",
          isSuccess
              ? "Clicca questa notifica per aprire il file"
              : "Riprova a scaricare il file",
          notificationDetails,
          payload: json);
    }
  }

  Future startDownload(String savePath, String urlPath) async {
    Map<String, dynamic> result = {
      "isSuccess": false,
      "filePath": null,
      "error": null
    };

    try {
      var response = await dio.download(urlPath, savePath,
          onReceiveProgress: _onReceiveProgress);
      result["isSuccess"] = (response.statusCode == 200);
      result["filePath"] = savePath;
    } catch (e) {
      result["error"] = e.toString();
    } finally {
      _showNotification(result);
    }
  }

  Future download(String fileUrl, String fileName) async {
    final dir = await getDownloadDirectory();
    final permissionStatus = await requestPermission();

    if (permissionStatus) {
      final savePath = path.join(dir!.path, fileName);
      await startDownload(savePath, fileUrl);
    }
  }
}

class NavigationControls extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const NavigationControls(this._webViewControllerFuture);

  final Future<WebViewController> _webViewControllerFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: _webViewControllerFuture,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
        final bool webViewReady =
            snapshot.connectionState == ConnectionState.done;
        final WebViewController? controller = snapshot.data;
        return Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: !webViewReady
                  ? null
                  : () async {
                      if (await controller!.canGoBack()) {
                        await controller.goBack();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Nessun elemento della cronologia')),
                        );
                        return;
                      }
                    },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: !webViewReady
                  ? null
                  : () async {
                      if (await controller!.canGoForward()) {
                        await controller.goForward();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Nessun elemento della cronologia degli inoltri')),
                        );
                        return;
                      }
                    },
            ),
            IconButton(
              icon: const Icon(Icons.replay),
              onPressed: !webViewReady
                  ? null
                  : () {
                      controller!.reload();
                    },
            ),
          ],
        );
      },
    );
  }
}
