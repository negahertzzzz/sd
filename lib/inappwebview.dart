import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:serena_onlus_login/styles.dart';
import 'package:url_launcher/url_launcher.dart';

import 'main.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
}

var payload = Uint8List.fromList(utf8.encode('ut_user=$utUser&ut_pwd=$utPwd'));

class MyAppa extends StatefulWidget {
  const MyAppa({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyAppa> {
  final GlobalKey webViewKey = GlobalKey();

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    //print([id, status, progress]);
  }

  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
          useShouldOverrideUrlLoading: true,
          mediaPlaybackRequiresUserGesture: false,
          useOnDownloadStart: true),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  late PullToRefreshController pullToRefreshController;
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        /*appBar: AppBar(
          backgroundColor: coloreAppBar,

          title: const Text(''),
          actions: <Widget>[
            IconButton(
                onPressed: () {
                  webViewController?.goBack();
                },
                icon: const Icon(Icons.arrow_back_ios)),
            IconButton(
                onPressed: () {
                  webViewController?.goForward();
                },
                icon: const Icon(Icons.arrow_forward_ios)),
            IconButton(
                onPressed: () {
                  webViewController?.reload();
                },
                icon: const Icon(Icons.refresh))
          ],
        ),*/
        body: SafeArea(
            child: Column(children: <Widget>[
          Expanded(
            child: Stack(
              children: [
                InAppWebView(
                  key: webViewKey,
                  initialUrlRequest: URLRequest(
                    url: Uri.parse(link),
                    method: 'POST',
                    headers: <String, String>{'Content-Type': 'text/plain',
                      'Content-Length': payload.length.toString()
                    },
                    body: payload,
                  ),
                  initialOptions: options,
                  pullToRefreshController: pullToRefreshController,
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                  },
                  onLoadStart: (controller, url) {
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  androidOnPermissionRequest:
                      (controller, origin, resources) async {
                    return PermissionRequestResponse(
                        resources: resources,
                        action: PermissionRequestResponseAction.GRANT);
                  },
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {
                    var uri = navigationAction.request.url!;

                    if (![
                      "http",
                      "https",
                      "file",
                      "chrome",
                      "data",
                      "javascript",
                      "about"
                    ].contains(uri.scheme)) {
                      if (await canLaunchUrl(Uri.parse(url))) {
                        // Launch the App
                        await launchUrl(
                          Uri.parse(url),
                        );
                        // and cancel the request
                        return NavigationActionPolicy.CANCEL;
                      }
                    }

                    return NavigationActionPolicy.ALLOW;
                  },
                  onLoadStop: (controller, url) async {
                    pullToRefreshController.endRefreshing();
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  onLoadError: (controller, url, code, message) {
                    pullToRefreshController.endRefreshing();
                  },
                  onProgressChanged: (controller, progress) {
                    if (progress == 100) {
                      pullToRefreshController.endRefreshing();
                    }
                    setState(() {
                      this.progress = progress / 100;
                      urlController.text = url;
                    });
                  },
                  onUpdateVisitedHistory: (controller, url, androidIsReload) {
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  onConsoleMessage: (controller, consoleMessage) {
                    //print(consoleMessage);
                  },
                  onDownloadStartRequest:
                      (controller, downloadStartRequest) async {
                    var status = await Permission.storage.status;

                    if (!status.isGranted) {
                      await Permission.storage.request();
                    }
                    var rng = Random();

                    FlutterDownloader.registerCallback(downloadCallback);
                    if (Platform.isAndroid) {
                      Directory? tempDir =
                          await DownloadsPathProvider.downloadsDirectory;
                      var count = 0;
                      var fileName = downloadStartRequest.suggestedFilename!;
                      var tmpfileName = fileName;
                      while (await File('${tempDir!.path}/$tmpfileName').exists()) {
                        if (count > 0) {
                          tmpfileName = fileName;
                        }
                        tmpfileName = '${'($count'})$fileName';
                        count++;
                      }
                      fileName = tmpfileName;

                      final taskId = await FlutterDownloader.enqueue(
                        url: downloadStartRequest.url.toString(),
                        fileName: fileName,
                        savedDir: /*(await getApplicationDocumentsDirectory()).path*/ tempDir!
                            .path,
                        showNotification:
                            true, // show download progress in status bar (for Android)
                        openFileFromNotification:
                            true, // click on notification to open downloaded file (for Android)
                      );
                    } else {
                      Directory documents =
                          await getApplicationDocumentsDirectory();
                      final taskId = await FlutterDownloader.enqueue(
                        url: downloadStartRequest.url.toString(),
                        savedDir: /*(await getApplicationDocumentsDirectory()).path*/ documents
                            .path,
                        showNotification:
                            true, // show download progress in status bar (for Android)
                        openFileFromNotification:
                            true, // click on notification to open downloaded file (for Android)
                      );
                    }

                    //print(tempDir!.path);
                    /*print("onDownloadSsdasdatart: " +
                        (await getApplicationDocumentsDirectory()).path);*/
                  },
                ),
                progress < 1.0
                    ? LinearProgressIndicator(value: progress)
                    : Container(),
              ],
            ),
          ),
        ])));
  }
}

class NavigationControls extends StatelessWidget {
  const NavigationControls(this._webViewControllerFuture, {Key? key})
      : super(key: key);

  final InAppWebViewController? _webViewControllerFuture;

  @override
  Widget build(BuildContext context) {
    //Future<InAppWebViewController> webController = _webViewControllerFuture as Future<InAppWebViewController>;
    return FutureBuilder<InAppWebViewController>(
      //future: webController,
      builder: (BuildContext context,
          AsyncSnapshot<InAppWebViewController> snapshot) {
        final bool webViewReady =
            snapshot.connectionState == ConnectionState.done;
        final InAppWebViewController? controller = snapshot.data;
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
                                  Text('Non ci sono elementi in cornologia')),
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
                              content: Text('No forward history item')),
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
