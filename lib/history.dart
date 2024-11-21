import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:payparkingv4/uploading.dart';
import 'utils/db_helper.dart';
import 'syncing.dart';
import 'constants1.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
// import 'package:flutter_appavailability/flutter_appavailability.dart';
import 'package:device_apps/device_apps.dart';
import 'dart:async';
import 'utils/file_creator.dart';
import 'about.dart';

class HistoryTransList extends StatefulWidget {
  final String location;
 final String empId;
  HistoryTransList({Key key, @required this.location,this.empId}) : super(key: key);
  @override
  _HistoryTransList createState() => _HistoryTransList();
}

class _HistoryTransList extends State<HistoryTransList> {
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  final db = PayParkingDatabase();
  final fileCreate = PayParkingFileCreator();
  List plateData;
  List syncData;
  String alert;
  List plateData2;
  TextEditingController _textController;
  // Define app package names
  String oldPrinterPackageName = "com.example.cpcl_test_v1";
  String newPrinterPackageName = "com.example.cpcl_test_v2";
  String zebraPrinterPackageName = "com.example.cpcl_test_v3";

  Future getSyncDate() async{
    var res = await db.fetchSync();
    setState((){
      syncData = res;
    });

    if(syncData.isEmpty){
    }else{
    }
   }

   Future insertSyncDate() async{
    await db.insertSyncDate(DateFormat("yyyy-MM-dd : hh:mm a").format(new DateTime.now()).toString());
    getSyncDate();
   }

   Future getHistoryTransData() async {
    listStat = false;
    var res = await db.fetchAllHistory();
    setState((){
      plateData = res;
    });
   }

   promptSyncData() {

//    if(result == true){
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return CupertinoAlertDialog(
            title: new Text("Confirm Upload History"),
            content: new Text("Are you sure you want to upload history data?"),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new TextButton(
                child: new Text("Confirm"),
                onPressed: () {
                    insertSyncDate();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UploadPage()),
                    ).then((result) {
                      Navigator.of(context).pop();
                    });
                },
              ),
              new TextButton(
                child: new Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
  }

  bool listStat = false;
  Future _onChanged(text) async {
    listStat = true;
    bool result = await DataConnectionChecker().hasConnection;
    if (result == true){
      var res = await db.ofFetchSearchHistory(text);
      setState((){
        plateData2 = res;
      });
    }
    else{
      showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return CupertinoAlertDialog(
            title: new Text("Connection Problem"),
            content: new Text("Please Connect to the wifi hotspot or turn the wifi on"),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new TextButton(
                child: new Text("Close"),
                onPressed:() {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void initState(){
    super.initState();
    getHistoryTransData();
    getSyncDate();
    _textController = TextEditingController();
  }

  @override
   Widget build(BuildContext context){
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        title: Text('History',style: TextStyle(fontWeight: FontWeight.bold,fontSize: width/28, color: Colors.black),),
        leading: new IconButton(
          icon: new Icon(Icons.search, color: Colors.black),
          onPressed: () {
            showDialog(
              barrierDismissible: true,
              context: context,
              builder: (BuildContext context) {
                // return object of type Dialog
                return CupertinoAlertDialog(
                  title: new Text("Search Plate#"),
                  content: new CupertinoTextField(
                    controller: _textController,
                    autofocus: true,
//                    onChanged: _onChanged,
                  ),
                  actions: <Widget>[
                    new TextButton(
                      child: new Text("Search"),
                      onPressed:() {
                        _onChanged(_textController.text);
                        _textController.clear();
                        Navigator.of(context).pop();
                      },
                    ),
                    new TextButton(
                      child: new Text("Close"),
                      onPressed:() {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),

        actions: <Widget>[
          PopupMenuButton<String>(
            icon: Icon(Icons.settings_backup_restore, color: Colors.black),
            onSelected: choiceAction1,
            itemBuilder: (BuildContext context){
              return Constants.choices.map((String choice){
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),

      body:Column(
        children: <Widget>[
          Expanded(
            child:RefreshIndicator(
              onRefresh: getHistoryTransData,
              child:Scrollbar(
                child: listStat == true ?
                ListView.builder(
                  itemCount: plateData2 == null ? 0: plateData2.length,
                  itemBuilder: (BuildContext context, int index) {
                    var f = index;
                    f++;
                    var totalAmount = int.parse(plateData2[index]["penalty"]) + int.parse(plateData2[index]["amount"]);
                    return GestureDetector(
                      onLongPress: (){
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (BuildContext context) {
                            // return object of type Dialog
                            return CupertinoAlertDialog(
                              title: new Text("Manager's key"),
                              content: new Column(
                                children: <Widget>[
                                  new CupertinoTextField(
                                    autofocus: true,
                                    placeholder: "Username",
                                  ),
                                  Divider(),
                                  new CupertinoTextField(
                                    autofocus: true,
                                    placeholder: "Password",
                                    obscureText: true,
                                  ),
                                ],
                              ),
                              actions: <Widget>[
                                new TextButton(
                                    child: new Text("Proceed"),
                                    onPressed:(){
                                      Navigator.of(context).pop();
                                    }
                                ),
                                new TextButton(
                                  child: new Text("Close"),
                                  onPressed:(){
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Card(
                        margin: EdgeInsets.all(5),
                        elevation: 0.0,
                        child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ListTile(
                              title:Text('$f.Plt No : ${plateData2[index]["plateNumber"]}'.toUpperCase(),style: TextStyle(fontWeight: FontWeight.bold,fontSize:  width/20),),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('     Time In : ${plateData2[index]["dateTimein"]}',style: TextStyle(fontSize: width/30),),
                                  Text('     Time Out : ${plateData2[index]["dateTimeout"]}',style: TextStyle(fontSize: width/30),),
                                  Text('     Entrance Fee : '+oCcy.format(int.parse(plateData2[index]["amount"])),style: TextStyle(fontSize: width/30),),
                                  Text('     Charge : '+oCcy.format(int.parse(plateData2[index]["penalty"])),style: TextStyle(fontSize: width/30),),
                                  Text('     Trans Code : ${plateData2[index]["checkDigit"]}',style: TextStyle(fontSize: width/30),),
                                  Text('     In By : ${plateData2[index]["empNameIn"]}',style: TextStyle(fontSize: width/30),),
                                  Text('     Out By : ${plateData2[index]["empNameOut"]}',style: TextStyle(fontSize: width/30),),
                                  Text('     Location : ${plateData2[index]["location"]}',style: TextStyle(fontSize: width/30),),
                                  Text('     Total : '+oCcy.format(totalAmount),style: TextStyle(fontSize: width/30),),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
                :ListView.builder(
//                 physics: BouncingScrollPhysics(),
                  itemCount: plateData == null ? 0: plateData.length,
                  itemBuilder: (BuildContext context, int index) {
                    var f = index;
                    Color cardColor;
                    f++;
                    if(int.parse(plateData[index]["penalty"]) > 0){
                      cardColor = Colors.redAccent.withOpacity(.2);
                    }else{
                      cardColor = Colors.white;
                    }
                    var totalAmount = int.parse(plateData[index]["penalty"]) + int.parse(plateData[index]["amount"]);
                    return GestureDetector(
                      onLongPress: (){
                        if(int.parse(plateData[index]["penalty"])!=0){
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) {
                              // return object of type Dialog
                              return CupertinoAlertDialog(
                                title: new Text("Info"),
                                content: new Text("Press proceed to reprint"),
                                actions: <Widget>[
                                  // usually buttons at the bottom of the dialog
                                  new TextButton(
                                    child: new Text("Proceed"),
                                    onPressed:() async{

                                      // Check if each app is installed
                                      bool isOldPrinterInstalled = await DeviceApps.isAppInstalled(oldPrinterPackageName);
                                      bool isNewPrinterInstalled = await DeviceApps.isAppInstalled(newPrinterPackageName);
                                      bool isZebraPrinterInstalled = await DeviceApps.isAppInstalled(zebraPrinterPackageName);

                                      Navigator.of(context).pop();

                                      Future<void> handlePrinterSelection(
                                          BuildContext context,
                                          String promptMessage,
                                          String packageName,
                                          ) async {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return CupertinoAlertDialog(
                                              title: Text(promptMessage),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: Text("Proceed"),
                                                  onPressed: () async {
                                                    Navigator.of(context).pop();

                                                    await fileCreate.transactionTypeFunc('reprint_penalty');
                                                    await fileCreate.transPenaltyFunc(plateData[index]['uid'],plateData[index]['checkDigit'],plateData[index]['plateNumber'],plateData[index]['dateTimein'],plateData[index]['dateTimeout'],plateData[index]['amount'],plateData[index]['penalty'],plateData[index]['user'],plateData[index]['empNameIn'],plateData[index]['outBy'],plateData[index]['empNameOut'],plateData[index]['location']);

                                                    // Open the external app
                                                    await DeviceApps.openApp(packageName).then((_) {
                                                    });

                                                    print("PRINTING");
                                                  },
                                                ),
                                                TextButton(
                                                  child: Text("Cancel"),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }

                                      showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (BuildContext context) {
                                          // return object of type Dialog
                                          return CupertinoAlertDialog(
                                            title: Text("Select Printer"),
                                            actions: <Widget>[
                                              // Button to trigger the next dialog
                                              TextButton(
                                                child: Text("Old Printer"),
                                                onPressed: isOldPrinterInstalled
                                                    ? () async {
                                                  Navigator.of(context).pop();
                                                  await handlePrinterSelection(
                                                    context,
                                                    "Proceed printing with oldPrinter?",
                                                    oldPrinterPackageName,
                                                  );
                                                }
                                                    : null, // Disable button if app is not installed
                                              ),
                                              TextButton(
                                                child: Text("New Printer"),
                                                onPressed: isNewPrinterInstalled
                                                    ? () async {
                                                  Navigator.of(context).pop();
                                                  await handlePrinterSelection(
                                                    context,
                                                    "Proceed printing with newPrinter?",
                                                    newPrinterPackageName,
                                                  );
                                                }
                                                    : null, // Disable button if app is not installed
                                              ),
                                              TextButton(
                                                child: Text("Zebra ZR138"),
                                                onPressed: isZebraPrinterInstalled
                                                    ? () async {
                                                  Navigator.of(context).pop();
                                                  await handlePrinterSelection(
                                                    context,
                                                    "Proceed printing with Zebra-ZR138 printer?",
                                                    zebraPrinterPackageName,
                                                  );
                                                }
                                                    : null, // Disable button if app is not installed
                                              ),
                                              TextButton(
                                                child: Text("Cancel", style: TextStyle(color: Colors.black),),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  new TextButton(
                                    child: new Text("Close"),
                                    onPressed: () {
                                      Navigator.of(context).pop();

                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      child: Card(
                        color: cardColor,
                        margin: EdgeInsets.all(5),
                        elevation: 0.0,
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              title:Text('$f.Plt No : ${plateData[index]["plateNumber"]}'.toUpperCase(),style: TextStyle(fontWeight: FontWeight.bold,fontSize:  width/20),),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('     Time In : ${plateData[index]["dateTimein"]}',style: TextStyle(fontSize: width/30),),
                                  Text('     Time Out : ${plateData[index]["dateTimeout"]}',style: TextStyle(fontSize: width/30),),
                                  Text('     Entrance Fee : '+oCcy.format(int.parse(plateData[index]["amount"])),style: TextStyle(fontSize: width/30),),
                                  Text('     Charge : '+oCcy.format(int.parse(plateData[index]["penalty"])),style: TextStyle(fontSize: width/30),),
                                  Text('     Trans Code : ${plateData[index]["checkDigit"]}',style: TextStyle(fontSize: width/30),),
                                  Text('     In By : ${plateData[index]["empNameIn"]}',style: TextStyle(fontSize: width/30),),
                                  Text('     Out By : ${plateData[index]["empNameOut"]}',style: TextStyle(fontSize: width/30),),
                                  Text('     Location : ${plateData[index]["location"]}',style: TextStyle(fontSize: width/30),),
                                  Text('     Total : '+oCcy.format(totalAmount),style: TextStyle(fontSize: width/30),),
                                ],
                              ),
//                               trailing: Icon(Icons.more_vert),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void choiceAction1(String choice) {
    if (choice == Constants.dbSync) {
      promptSyncData();
    }
  }
}