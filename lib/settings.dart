import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:payparkingv4/server.dart';
import 'login.dart';

class Settings extends StatefulWidget {
  final String empNameFn;
  final String location;
  Settings({Key key, @required this.empNameFn, this.location}) : super(key: key);
  @override
  _Settings createState() => _Settings();
}

class _Settings extends State<Settings>{

  String name;
  String location;
  Future getData() async{

      name = widget.empNameFn;
      location = widget.location;
  }


  @override
  void initState(){
    super.initState();
    getData();
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    new MaterialApp(
      routes: <String, WidgetBuilder> {
        '/login': (BuildContext context) => new SignInPage(),
      },
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        title: Text('User',style: TextStyle(fontWeight: FontWeight.bold,fontSize: width/28, color: Colors.black),),
        textTheme: TextTheme(
              caption: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold
              )
        ),

        // For logout button
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.logout, color: Colors.black,),
              onPressed: (){
                showDialog(
                    barrierDismissible: true,
                    context: context,
                    builder: (BuildContext context){
                      return CupertinoAlertDialog(
                        title: Text("Confirm to logout"),
                        content: Text("Are you sure you want to logout?"),
                        actions: <Widget>[
                          TextButton(
                            child: Text("Yes"),
                            onPressed: (){
                              Navigator.of(context).pop();
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SignInPage()),
                              );
                              Fluttertoast.showToast(
                                  msg: "Successfully logged out",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIos: 1,
                                  backgroundColor: Colors.black54,
                                  textColor: Colors.white,
                                  fontSize: 16.0
                              );
                              // SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                            },
                          ),
                          TextButton(
                            child: Text("No"),
                            onPressed: (){
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    }
                );
              }
          ),
        ],

      ),

      body:Column(
          children: <Widget>[
            Expanded(
              child:RefreshIndicator(
                  onRefresh:getData,
                  child:ListView(
                    children: <Widget>[
                      Divider(
                        color: Colors.transparent,
                        height: 100.0,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Divider(
                            color: Colors.transparent,
                            height: 40.0,
                          ),
                          new Text(name,textScaleFactor: 1.5),
                          new Text(location,textScaleFactor: 1.1),
                          Divider(
                            color: Colors.transparent,
                            height: 60.0,
                          ),
                          Divider(
                            color: Colors.transparent,
                          ),
                          TextButton(
                            child: new Text('Server'.toString(),style: TextStyle(fontSize: width/31.0, color: Colors.grey),),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              // foregroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
                              padding: EdgeInsets.symmetric(horizontal: width/70.0,vertical: 18.0),
                              shape: RoundedRectangleBorder(  borderRadius: new BorderRadius.circular(20.0),
                                    side: BorderSide(color: Colors.lightBlue))
                            ),
                            onPressed:(){
                              Fluttertoast.showToast(
                                  msg: Server.address,
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIos: 2,
                                  backgroundColor: Colors.black54,
                                  textColor: Colors.white,
                                  fontSize: 16.0
                              );
                            },
                          ),
                        ],
                      )
                    ],
                  )
              ),
            ),
          ],
      ),
    );
  }
}




