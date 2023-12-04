import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'parkingtrans.dart';
import 'parkingTransList.dart';
import 'history.dart';
import  'settings.dart';
import 'utils/db_helper.dart';
import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:flutter_blue/flutter_blue.dart';


class HomeT extends StatefulWidget {
  final logInData;
  HomeT({Key key, @required this.logInData}) : super(key: key);
  @override
  _Home createState() => _Home();
}

class _Home extends State<HomeT> {
  final db = PayParkingDatabase();
  //bluetooth var
//  BluetoothDevice device;
//  BluetoothState state;
//  BluetoothDeviceState deviceState;
  //end bluetooth var
  List userData;
  List getUsernameList;
  List userData1;
  String empId;
  String name;
  String empNameFn;
  String location;
  String loc = " ";
  String data;
  Timer timer;
  int counter;

  DateTime pre_backpress = DateTime.now();

  Future getCounter() async {
    var res = await db.getCounter();
    setState(() {
      if (counter == null) {
        counter = 0;
      } else {
        counter = res;
      }
    });
  }

  Future getUserData() async{
    print(widget.logInData+"hello");
//    var res = await db.olFetchUserData(widget.logInData);
    var getLoc = await db.ofCountFetchUserData();
    var getUsername = await db.ofGetUsername(widget.logInData);
    userData = getLoc;
    getUsernameList = getUsername;
    int count = userData[0]['count'];
//    var locId = userData[0]['location_id'];
    var res = await db.ofFetchUserData();
    userData1 = res;
    print(userData1);

    setState(() {
      print(userData1);
      for(var q = 0; q < count; q++) {
        loc = (userData1[q]['location'])+" , "+loc;
        if(count>1){
          loc = loc.substring(0, loc.length - 1);
        }else{
          loc = loc.substring(0, loc.length - 1);
        }
      }
      name = getUsernameList[0]['username'];
      empNameFn = getUsernameList[0]['fullname'];
      location = loc;
      empId = getUsernameList[0]['empid'];
      print(name);
      print(empNameFn);
      print(location);
      print(empId);
    });
  }

  @override
  void initState(){
    super.initState();
    if(empId == null || name == null || location == null || empNameFn == null)
    {
      empId = "";
      name = "";
      empNameFn = "";
      location = "";

      print("di pwde kai walai location");
//      Navigator.of(context).pop();

    }else{
      empId = empId;
      name = name;
      empNameFn = empNameFn;
      location = location;
    }
    getUserData();
    super.initState();
    getCounter();
    timer = Timer.periodic(Duration(seconds: 5), (Timer t) => getCounter());
//    if (state == BluetoothState.off) {
//      print("bluetooth is off");
//    }

  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }


  // //For back button to exit the app
  // Future<bool> _onWillPop() async {
  //   return (await showDialog(
  //     context: context,
  //     builder: (context) =>
  //         CupertinoAlertDialog(
  //           title: new Text('Confirm to exit'),
  //           content: new Text('Are you sure you want to exit?'),
  //           actions: <Widget>[
  //             TextButton(
  //               onPressed: () => SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
  //               // Navigator.of(context).pop(true),
  //               //<-- SEE HERE
  //               child: new Text('Yes'),
  //             ),
  //             TextButton(
  //               onPressed: () => Navigator.of(context).pop(false),
  //               // <-- SEE HERE
  //               child: new Text('No'),
  //             ),
  //           ],
  //         ),
  //   )) ??
  //       false;
  // }


  @override
  Widget build(BuildContext context){
    double width = MediaQuery.of(context).size.width;
    var  defFontSize = 12.0;
    if(width <= 400){
      defFontSize = 10.0;
    }
    else{
      defFontSize = 12.0;
    }

    // For double click to back button
    return WillPopScope(
      // onWillPop:  _onWillPop,
        onWillPop: () async {
          return false;
        },
        // onWillPop: () async{
        //   final timegap = DateTime.now().difference(pre_backpress);
        //   final cantExit = timegap >= Duration(seconds: 2);
        //   pre_backpress = DateTime.now();
        //   if(cantExit){
        //     Fluttertoast.showToast(
        //         msg: "Press back button again to exit",
        //         toastLength: Toast.LENGTH_SHORT,
        //         gravity: ToastGravity.BOTTOM,
        //         backgroundColor: Colors.black54,
        //         textColor: Colors.white,
        //         fontSize: 16.0
        //     );
        //     return false;
        //   }else{
        //     return SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        //   }
        // },

    child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home,size: 25.0),
            label: 'Park me'
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.collections,size: 25.0),
              label: 'Transactions'
          ),
          BottomNavigationBarItem(
            icon: new Stack(
              children: <Widget>[
                new Icon(Icons.notifications),
                new Positioned(
                  right: 0,
                  child: new Container(
                    padding: EdgeInsets.all(3),
                    decoration: new BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: new Text(
                      '$counter',
                      style: new TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              ],
            ),
              label: 'History'
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person,size: 25.0),
              label: 'User'
          ),
        ],
      ),
      tabBuilder: (context, index) {
        CupertinoTabView returnValue;
        switch (index) {
          case 0:
            returnValue = CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
//                child: ParkTrans(id:id,nameL:nameL,nameF:nameF,location:location),
                child: ParkTrans(empId:empId, name:name, empNameFn:empNameFn, location:location),
              );
            });
            break;
          case 1:
            returnValue = CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child: ParkTransList(empId:empId, name:name, location:location, empNameFn:empNameFn),
              );
            });
            break;
          case 2:
            returnValue = CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child: HistoryTransList(empId:empId,location:location),
              );
            });
            break;
          case 3:
            returnValue = CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child: Settings(empNameFn:empNameFn, location:location),
              );
            });
            break;
        }
        return returnValue;
      },
        )
    );
  }
}
