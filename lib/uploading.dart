import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gradient_text/gradient_text.dart';
import 'package:payparkingv4/server.dart';
import 'package:payparkingv4/utils/db_helper.dart';
import 'package:http/http.dart' as http;

class UploadPage extends StatefulWidget{
  @override
  _UploadPage createState() => new _UploadPage();
}
class _UploadPage extends State<UploadPage> {
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


  Future<void> updateProgress(int currentIndex, int totalCount) async {
    final percentage = (currentIndex / totalCount) * 100;
    setState(() {
      progressPercentage = percentage;
    });
  }


  Future syncTransData() async {
    if (!mounted) return;
    setState(() {
      statusText = "Uploading history data";
    });

    // ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();
    // bool isLocalNetworkAvailable = connectivityResult == ConnectivityResult.wifi;

//    bool result = await DataConnectionChecker().hasConnection;
    var res = await db.fetchAllHistory();
    setState(() {
      hisData = res;
    });
    if (hisData.isEmpty) {
      print("heelo");
      Fluttertoast.showToast(
          msg: 'History is empty.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 16.0);
      Navigator.of(context).pop();

    } else {

      for (int i = 0; i < hisData.length; i++) {
        uid = hisData[i]['uid'];
        checkDigit = hisData[i]['checkDigit'];
        plateNumber = hisData[i]['plateNumber'];
        dateTimeIn = hisData[i]['dateTimein'];
        dateTimeout = hisData[i]['dateTimeout'];
        amount = hisData[i]['amount'];
        penalty = hisData[i]['penalty'];
        user = hisData[i]['user'];
        outBy = hisData[i]['outBy'];
        location = hisData[i]['location'];


        await http.post(Server.address + "sync_data", body: {
          "uid": uid,
          "checkDigit": checkDigit,
          "plateNumber": plateNumber,
          "dateTimeIn": dateTimeIn,
          "dateTimeout": dateTimeout,
          "amount": amount,
          "penalty": penalty,
          "user": user,
          "outBy": outBy,
          "location": location
        });

        updateProgress(i + 1, hisData.length);

        if (i == hisData.length - 1) {
          await db.emptyHistoryTbl();
        }
      }

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return CupertinoAlertDialog(
          title: new Text("Transactions Successfully Uploaded"),
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
  }


  @override
  void initState(){
    super.initState();
    syncTransData();
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
    return new Scaffold(
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
    );
  }
}