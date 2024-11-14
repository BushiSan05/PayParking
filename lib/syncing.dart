import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gradient_text/gradient_text.dart';
import 'utils/db_helper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'server.dart';
import 'package:connectivity/connectivity.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:data_connection_checker/data_connection_checker.dart';

class SyncingPage extends StatefulWidget{
  @override
  _SyncingPage createState() => new _SyncingPage();
}
class _SyncingPage extends State<SyncingPage>{
  List hisData;
  final db = PayParkingDatabase();
  String uid;
  String checkDigit;
  String plateNumber;
  String dateTimeIn;
  String dateTimeout;
  String amount;
  String penalty;
  String user;
  String empNameIn;
  String outBy;
  String empNameOut;
  String location;
  String statusText = "";
  double progressPercentage = 0;
  // String statusNumber = "";
  // int totalSteps = 6;
  // int currentStep = 0;



  Future<void> updateProgress(int currentIndex, int totalCount) async {
    final percentage = (currentIndex / totalCount) * 100;
    setState(() {
      progressPercentage = percentage;
    });
  }

  Future<void> userDownLoad()async{
    if (!mounted) return;
    setState(() {
      // statusNumber = "2/6";
      statusText = "Updating users";
    });

    try {
      final response = await http.post(Server.address+"app_downLoadUser",body:{
        "tohide":"tohide"
      });

      if (response.statusCode == 200) {
        Map dataUser = jsonDecode(response.body);
        List plateData = dataUser['user_details'];

        await db.emptyUserTbl();

        for(int i = 0; i < plateData.length; i++){

          print(dataUser['user_details']);
          try {
            await db.ofSaveUsers(plateData[i]['d_user_id'],
                plateData[i]['d_emp_id'],
                plateData[i]['d_full_name'],
                plateData[i]['d_username'],
                plateData[i]['d_password'],
                plateData[i]['d_usertype'],
                plateData[i]['d_status']
            );
          } on SocketException catch (_) {
            Fluttertoast.showToast(
              msg: "Network error: Unable to reach the server.",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
            );
            break;
          }

          // Update progress based on the current index and total count
          updateProgress(i + 1, plateData.length);

          if(i == plateData.length-1){
            downloadLocationUser();
          }
        }
      } else {
        Fluttertoast.showToast(
          msg: "Network error: Unable to reach server.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "An error occurred: Please check your network.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> downloadLocationUser() async{
    if (!mounted) return;
    setState(() {
      // statusNumber = "3/6";
      statusText = "Updating location user";
    });

    try {
      final response = await http.post(Server.address+"app_downLoadlocation_user", body: {
        "tohide": "tohide"
      });

      if (response.statusCode == 200) {
        Map dataUser = jsonDecode(response.body);
        List plateData = dataUser['user_details'];

        await db.emptyLocationUserTbl();

        for(int i = 0; i < plateData.length; i++) {

          print(plateData);
          await db.ofSaveLocationUsers(plateData[i]['d_loc_user_id'],
              plateData[i]['d_user_id'],
              plateData[i]['d_location_id'],
              plateData[i]['d_emp_id']);

          updateProgress(i + 1, plateData.length);

          if(i == plateData.length-1){
            downloadManager();
          }
        }
      } else {
        Fluttertoast.showToast(
          msg: "Network error: Unable to reach server.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "An error occurred: Please check your network.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> downloadManager() async{
    if (!mounted) return;
    setState(() {
      // statusNumber = "4/6";
      statusText = "Updating managers";
    });

    try {
      final response = await http.post(Server.address+"app_downLoadManager", body: {
        "tohide": "tohide"
      });

      if (response.statusCode == 200) {
        Map dataUser = jsonDecode(response.body);
        List plateData = dataUser['user_details'];

        await db.emptyManagerTbl();

        for(int i = 0; i < plateData.length; i++) {

          print(plateData);
          await db.ofSaveManagers(plateData[i]['d_emp_id'],
              plateData[i]['d_username'],
              plateData[i]['d_password'],
              plateData[i]['d_usertype'],
              plateData[i]['d_status']);

          updateProgress(i + 1, plateData.length);

          if(i == plateData.length-1){
            downloadLocation();
          }
        }
      } else {
        Fluttertoast.showToast(
          msg: "Network error: Unable to reach server.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "An error occurred: Please check your network.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> downloadLocation() async{
    if (!mounted) return;
    setState(() {
      // statusNumber = "5/6";
      statusText = "Updating locations";
    });

    try {
      final response = await http.post(Server.address+"app_downLoadlocation", body: {
        "tohide": "tohide"
      });

      if (response.statusCode == 200) {
        Map dataUser = jsonDecode(response.body);
        List plateData = dataUser['user_details'];

        await db.emptyLocationTbl();

        for(int i = 0; i < plateData.length; i++) {

          print(plateData);
          await db.ofSaveLocation(plateData[i]['d_location_id'],
              plateData[i]['d_location'],
              plateData[i]['d_location_address'],
              plateData[i]['d_status']);

          updateProgress(i + 1, plateData.length);

          if(i == plateData.length-1){
            downloadDelinquent();
          }
        }
      } else {
        Fluttertoast.showToast(
          msg: "Network error: Unable to reach server.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "An error occurred: Please check your network.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> downloadDelinquent() async{
    if (!mounted) return;
    setState(() {
      // statusNumber = "6/6";
      statusText = "Updating delinquents";
    });

    try {
      final response = await http.post(Server.address+"app_downloadDelinquent", body: {
        "tohide": "tohide"
      });

      if (response.statusCode == 200) {
        Map dataUser = jsonDecode(response.body);
        List plateData = dataUser['user_details'];

        await db.emptyDelinquent();

        for(int i = 0; i < plateData.length; i++) {

          print(plateData);
          await db.ofSaveDelinquent(plateData[i]['d_uid'],
              plateData[i]['d_plateno'],
              plateData[i]['d_dateToday'],
              plateData[i]['d_empName'],
              plateData[i]['d_secNameC'],
              plateData[i]['d_imgEmp']);

          updateProgress(i + 1, plateData.length);

          if(i == plateData.length-1){
          }
        }
      } else {
        Fluttertoast.showToast(
          msg: "Network error: Unable to reach server.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "An error occurred: Please check your network.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return CupertinoAlertDialog(
          title: new Text("Update Complete"),
          content: new Text("Press ok to continue"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new TextButton(
              child: new Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    print("okna!");
  }

  @override
  void initState(){
    super.initState();
    userDownLoad();
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double setHeight;
    double screenHeight = MediaQuery.of(context).size.height;
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    if(isPortrait == true){
      setHeight = screenHeight - 490;
    }else{
      setHeight = screenHeight - 280;
    }

    return WillPopScope(
      onWillPop: () async {
        // Show the dialog to confirm exiting
        return await showDialog(
          context: context,
          barrierDismissible: false, // Prevent closing by tapping outside
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text("Exit Syncing"),
              content: Text("Are you sure you want to exit the syncing process?"),
              actions: <Widget>[
                TextButton(
                  child: Text("Yes"),
                  onPressed: () {
                    Fluttertoast.showToast(msg: "Syncing process cancelled.");
                    Navigator.of(context).pop(true); // Exit
                  },
                ),
                TextButton(
                  child: Text("No"),
                  onPressed: () {
                    Navigator.of(context).pop(false); // Don't exit
                  },
                ),

              ],
            );
          },
        ) ??
            false; // Prevent closing if the user cancels the dialog
      },

    child: Scaffold(
      body: Column(
        children: <Widget>[
          SizedBox(
            height:setHeight,
          ),
          GradientText('Syncing...',
              gradient: LinearGradient(colors: [Colors.deepOrangeAccent, Colors.blue, Colors.pink]),
              style: TextStyle(fontSize: 32),
              textAlign: TextAlign.center),
          SizedBox(
            height: 40,
          ),
          Center(
            child:SpinKitRing(
              color: Colors.blue,
              size: 80,
            ),
          ),
          SizedBox(
            height: 40,
          ),
          GradientText(
            'Progress: ${progressPercentage.toStringAsFixed(0)}%',
            gradient: LinearGradient(colors: [
              Colors.deepOrangeAccent,
              Colors.blue,
              Colors.pink
            ]),
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 20,
          ),
          GradientText(statusText,
              gradient: LinearGradient(colors: [Colors.black, Colors.blue, Colors.blueGrey]),
              style: TextStyle(fontSize: 17),
              textAlign: TextAlign.center),
        ],
      ),
    ),
    );
  }
}


