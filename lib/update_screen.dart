import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:payparkingv4/api.dart';
import 'package:payparkingv4/app_update.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:payparkingv4/login.dart';

class update_screen extends StatefulWidget {
  @override
  _updatescreen createState() => _updatescreen();
}

class _updatescreen extends State<update_screen> {

  var serverName = [''];
  String prev_server="";
  String new_server ="";
  bool btnUpdateClick = true;
  var version = AppUpdateVersion().versionNumber();


  @override
  void initState()  {
    btnUpdateClick = false;
    if (mounted) setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          title: Text('App Updater'),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Column(
                  children: [
                  TextButton(
                  child: Text("Update", style: TextStyle(fontSize: 30.0),),
                    onPressed: ()async {
                      Navigator.pop(context);
                      checkAppUpdate();
                      },
                    )
                  ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> checkAppUpdate() async {
    print('VERSION: $version');
    var res = await checkUpdate(version);

    // Log the type and content of the response
    print('Response type: ${res.runtimeType}');
    print('Response content: $res');

    if (res is String) {
      if (res == 'Uptodate') {
        await _showDialog(
          "$res",
          "Your app is up to date. \n App version $version",
          '',
        );
      } else {
        await _showDialog(
          "Error",
          "Something went wrong",
          '',
        );
      }
    } else if (res is Map<String, dynamic>) {
      if (res['version'] != null && res['version'] != '') {
        await _showDialog(
          "Latest Version available",
          "App Version ${res['version']}",
          '${res['url']}',
        );
      } else {
        await _showDialog(
          "Error",
          "Something went wrong",
          '',
        );
      }
    } else {
      await _showDialog(
        "Error",
        "Unexpected response format",
        '',
      );
    }

    print("false");
    btnUpdateClick = false;
  }




  Future<void> _showDialog(String title, String message, String url) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
                if (url.isNotEmpty)
                  GestureDetector(
                    onTap: () async {
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                    child: Text(
                      'Download here',
                      style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                    ),
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }



  // _showDialog(String title, String content, String url){
  //   showDialog(
  //       barrierDismissible: true,
  //       context: context,
  //       builder: (BuildContext context){
  //         return CupertinoAlertDialog(
  //           title: title != 'Uptodate' ?
  //           Text("$title"):
  //           Icon(Icons.check_circle, color: Colors.green, size: 36,),
  //           content: Text("$content", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
  //           actions: <Widget>[
  //             title != 'Uptodate' ?
  //             TextButton(
  //               child: Text("Download"),
  //               onPressed: ()async{
  //                 //Navigator.of(context).pop();
  //                 _launchURL(url);
  //                 //openBrowserURL(url: url, inApp: true);
  //               },
  //             ):
  //             SizedBox(),
  //             title != 'Uptodate' ?
  //             TextButton(
  //               child: Text("Later"),
  //               onPressed: (){
  //                 Navigator.of(context).pop();
  //               },
  //             ):
  //             SizedBox(),
  //           ],
  //         );
  //       }
  //   );
  // }

  // _launchURL(String urlApk) async {
  //   var url = Uri.parse(urlApk); // Parse the URL string
  //   if (await canLaunchUrl(url)) {
  //     await launchUrl(url);
  //   } else {
  //     throw 'Could not launch $urlApk';
  //   }
  // }
}
