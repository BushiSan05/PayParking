import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:payparkingv4/server.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';

class PayParkingDatabase {
  static final PayParkingDatabase _instance = PayParkingDatabase._();
  static Database _database;

  PayParkingDatabase._();

  factory PayParkingDatabase() {
    return _instance;
  }

  Future<Database> get db async {
    if (_database != null) {
      return _database;
    }
    _database = await init();
    return _database;
  }

  Future<Database> init() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String dbPath = join(directory.path, 'payparking.db');

    var database = openDatabase(dbPath, version: 1, onCreate: _onCreate, onUpgrade: _onUpgrade);

    return database;
  }


  void _onCreate(Database db, int version) {
    db.execute('''
      CREATE TABLE tbl_oftransactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uid TEXT,
        checkDigit TEXT,
        plateNumber TEXT,
        dateToday TEXT,
        dateTimeToday TEXT,
        dateUntil TEXT,
        amount TEXT,
        empId TEXT,
        fname TEXT,
        status TEXT,
        location TEXT
        )''');

    db.execute('''
      CREATE TABLE payparhistory(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uid TEXT,
        checkDigit TEXT,
        plateNumber TEXT,
        dateTimein TEXT,
        dateTimeout TEXT,
        amount TEXT,
        penalty TEXT,
        user TEXT,
        empNameIn TEXT,
        outBy TEXT,
        empNameOut TEXT,
        location TEXT
        )''');

    db.execute('''
      CREATE TABLE tbl_users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uid TEXT,
        empid TEXT,
        fullname TEXT,
        username TEXT,
        password TEXT,
        usertype TEXT,
        status TEXT
        )''');

    db.execute('''
      CREATE TABLE tbl_manager(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        empId TEXT,
        username TEXT,
        password TEXT,
        usertype TEXT,
        status TEXT
        )''');

    db.execute('''
      CREATE TABLE tbl_usersLocationUser(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        locUserId TEXT,
        userId TEXT,
        locationId TEXT,
        empId TEXT
        )''');

    db.execute('''
      CREATE TABLE tbl_location(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        locationId TEXT,
        location TEXT,
        locationaddress TEXT,
        status TEXT
        )''');

    db.execute('''
      CREATE TABLE synchistory(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        syncDate TEXT
        )''');

    db.execute('''
      CREATE TABLE tbl_delinquent(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uid TEXT,
        plateno TEXT,
        dateToday TEXT,
        empName TEXT,
        secNameC TEXT,
        imgEmp TEXT
        )''');

    print("Database was created!");
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) {
    // Run migration according database versions
  }

  Future<int> ofSaveTransaction(String uid,String checkDigitResult,String plateNumber,String dateToday,String dateTimeToday,String dateUntil,String amount,String empId, String fName,int stat,String locationAnew) async {
    var client = await db;
    return client.insert('tbl_oftransactions', {'uid':uid,'checkDigit':checkDigitResult,'plateNumber':plateNumber,'dateToday':dateToday,'dateTimeToday':dateTimeToday,'dateUntil':dateUntil,'amount':amount,'empId':empId,'fname':fName,'status':stat,'location':locationAnew});
  }

  Future ofFetchAll() async {
    var client = await db;
    //return client.query('tbl_oftransactions', where: 'status = ? and location = ?'  ,whereArgs: ['1',location] );
      return client.rawQuery('SELECT * FROM tbl_oftransactions WHERE status ="1"',null);
  }

  Future ofSaveUsers(uid,empId,fullName,userName,password,userType,status) async{
    var client = await db;
    return client.insert('tbl_users',{'uid':uid,'empid':empId,'fullname':fullName,'username':userName,'password':password,'usertype':userType,'status':status});

  }

  Future ofSaveLocationUsers(locUserId,userId,locationId,empId) async{
    var client = await db;
    return client.insert('tbl_usersLocationUser',{'locUserId':locUserId,'userId':userId,'locationId':locationId,'empId':empId});
  }

  Future ofSaveLocation(locationId,location,locationAddress,status) async{
    var client = await db;
    return client.insert('tbl_location',{'locationId':locationId,'location':location,'locationaddress':locationAddress,'status':status});
  }

  Future ofSaveManagers(empId,username,password,userType,status) async{
    var client = await db;
    return client.insert('tbl_manager',{'empId':empId,'username':username,'password':password,'usertype':userType,'status':status,});
  }

  Future ofFetchSearch(text) async{
    var client = await db;
    return client.rawQuery("SELECT * FROM tbl_oftransactions WHERE plateNumber LIKE '%$text%' AND status ='1'",null);
  }

  Future<int> updatePayTranStat(int id) async{
    var client = await db;
    return client.update('tbl_oftransactions', {'status': '0'}, where: 'id = ?', whereArgs: [id]);
  }

  Future ofUpdateTransaction(int id, String plateNumber) async {
    var client = await db;
    return client.update('tbl_oftransactions', {'plateNumber': plateNumber}, where: 'id = ?', whereArgs: [id]);
  }

  Future<List> fetchSync() async{
    var client = await db;
    return client.query('synchistory ORDER BY id DESC LIMIT 1');
  }

  Future<int> insertSyncDate(String date) async{
    var client = await db;
    return client.insert('synchistory', {'syncDate':date});
  }

  Future<List> fetchAllHistory() async {
    var client = await db;
    return await client.query('payparhistory ORDER BY id DESC');
  }

  Future ofFetchSearchHistory(text) async{
    var client = await db;
    return client.rawQuery("SELECT * FROM payparhistory WHERE plateNumber LIKE '%$text%'",null);
  }

  Future<int> addTransHistory(String uid,checkDigit,String plateNumber,String dateIn,String dateNow,String amountPay,String penalty,String user,String empNameIn,String outBy, String empNameOut,String location) async {
    var client = await db;
    return client.insert('payparhistory', {'uid':uid,'checkDigit':checkDigit,'plateNumber':plateNumber,'dateTimein':dateIn,'dateTimeout':dateNow,'amount':amountPay,'penalty':penalty,'user':user,'empNameIn':empNameIn,'outBy':outBy,'empNameOut':empNameOut ,'location':location});

  }

  Future emptyHistoryTbl() async{
    var client = await db;
    return client.rawQuery("DELETE FROM payparhistory");
  }


  Future emptyUserTbl() async{
    var client = await db;
    return client.rawQuery("DELETE FROM tbl_users");
  }

  Future emptyLocationUserTbl() async{
    var client = await db;
    return client.rawQuery("DELETE FROM tbl_usersLocationUser");
  }

  Future emptyLocationTbl() async{
    var client = await db;
    return client.rawQuery("DELETE FROM tbl_location");
  }

  Future emptyManagerTbl() async{
    var client = await db;
    return client.rawQuery("DELETE FROM tbl_manager");
  }

  Future emptyDelinquent() async{
    var client = await db;
    return client.rawQuery("DELETE FROM tbl_delinquent");
  }

  Future<int> getCounter() async {
    //database connection
    var client = await db;
    int  count  = Sqflite.firstIntValue(await client.rawQuery('SELECT COUNT(*) FROM payparhistory'));
    return count;
  }

   Future ofLogin(username,password) async{
    var client = await db;
    var passwordF = md5.convert(utf8.encode(password));
    var res  = client.rawQuery("SELECT * FROM tbl_users WHERE username = '$username' AND password = '$passwordF'",null);
    return res;
  }

  Future ofCountFetchUserData() async{
//    var client = await db;
//    var count = client.rawQuery("SELECT COUNT(*) as count, group_concat(locationId) as location_id ,fullname,user.empid as userEmpID,username FROM tbl_usersLocationUser as userloc INNER JOIN tbl_users as user ON userloc.userId = user.uid WHERE user.empId = '$userId'",null);
//    return count;
    var client = await db;
    var count = client.rawQuery("SELECT COUNT(*) as count FROM tbl_location",null);
    return count;
  }
  Future ofGetUsername(empId) async {
    var client = await db;
    var res = client.rawQuery("SELECT * from tbl_users WHERE empid = '$empId'");
    return res;
  }

  Future ofFetchUserData() async{
    var client = await db;
//    var res = client.rawQuery("SELECT * FROM tbl_usersLocationUser as userloc INNER JOIN tbl_location as loc ON loc.locationId = userloc.locUserId  INNER JOIN tbl_users as users ON users.empid = userloc.empId WHERE users.empid = '$userId'");
    var res = client.rawQuery("SELECT location from tbl_location");
    return res;
  }

  Future ofSaveDelinquent(uid,plateNo,date,appUser,manager,signImg) async{
    var client = await db;
    return client.insert('tbl_delinquent', {'uid':uid,'plateno':plateNo,'dateToday':date,'empName':appUser,'secNameC':manager,'imgEmp':signImg});

  }

  Future ofManagerLogin(username,password) async{
    var client = await db;
    var passwordF = md5.convert(utf8.encode(password));
    var res  = client.rawQuery("SELECT * FROM tbl_manager WHERE username = '$username' AND password = '$passwordF'",null);
    return res;
  }

  //mysql query code
  Future countTblHistory() async{
    var dataUser;
    final response = await http.post(Uri.parse(Server.address +"app_countDataHistory"),body:{
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  // Future countTblUser() async{
  //   var dataUser;
  //   final response = await http.post(Server.address +"app_countDataDownload",body:{
  //   });
  //   dataUser = jsonDecode(response.body);
  //   return dataUser;
  // }

  Future countTblUser() async{
    print("countTblUser");
    var dataUser;
    final response = await http.post(Uri.parse(Server.address +"app_countDataDownload"),body:{
    });
    print("countTblUser response :: ${response.body}");
    dataUser = jsonDecode(response.body);
    print("countTblUser response :: $dataUser");
    return dataUser;
  }

  Future countTblLocationUser() async{
    var dataUser;
    final response = await http.post(Server.address +"app_countLocationUser",body:{
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future countTblLocation() async{
    var dataUser;
    final response = await http.post(Server.address +"app_countLocation",body:{
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future countTblManager() async{
    var dataUser;
    final response = await http.post(Server.address +"app_countTblManager",body:{
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future countTblDelinquent() async{
    var dataUser;
    final response = await http.post(Server.address +"app_countTblDelinquent",body:{
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future mysqlLogin(username,password) async{
      final response = await http.post(Server.address +"app_login",body:{
        "username": username,
        "password": password,
      });
      if(response.body.length >= 1  && response.statusCode == 200){
        return response.body;
      }
      else{
        return 'error';
      }
  }

  Future olFetchUserData(userId) async{
    Map dataUser;
    final response = await http.post(Server.address +"app_getUserData",body:{
      "userId": userId,
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future olSaveTransaction(uid,checkDigitResult,plateNumber,dateToday,dateTimeToday,dateUntil,amount,user,stat,location) async{
     await http.post(Server.address +"olSaveTransaction",body:{
      'uid':uid.toString(),
      'checkDigitResult':checkDigitResult.toString(),
      'plateNumber':plateNumber.toString(),
      'dateToday':dateToday.toString(),
      'dateTimeToday':dateTimeToday.toString(),
      'dateUntil':dateUntil.toString(),
      'amount':amount.toString(),
      'user':user.toString(),
      'stat':stat.toString(),
      'location':location.toString(),
    });
  }

  Future olFetchAll(location) async{
    Map dataUser;
    final response = await http.post(Server.address +"appGetTransaction",body:{
          'location':location.toString()
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future olAddTransHistory(id,uid,checkDigit,plateNumber,dateIn,dateNow,amountPay,penalty,user,outBy,location) async{
    await http.post(Server.address +"appSaveToHistory",body:{
          'id':id.toString(),
          'uid':uid.toString(),
          'checkDigit':checkDigit.toString(),
          'plateNumber':plateNumber.toString(),
          'dateIn':dateIn.toString(),
          'dateNow':dateNow.toString(),
          'amountPay':amountPay.toString(),
          'penalty':penalty.toString(),
          'user':user.toString(),
          'outBy':outBy.toString(),
          'location':location.toString(),
    });
  }

  Future olUpdateTransaction(id,plateNumber,wheel,locationA) async{
    await http.post("http://172.16.46.130/e_parking/appUpdateTrans",body:{
          'id':id.toString(),
          'plateNumber':plateNumber.toString(),
          'wheel':wheel.toString(),
          'locationA':locationA.toString(),
    });
  }

  Future trapLocation(id) async{
    final response = await http.post("http://172.16.46.130/e_parking/trapLocation",body:{
      "id": id.toString(),
    });
    if(response.body.toString() == 'true'  ){
      return true;
    }else{
      return false;
    }
  }
  Future olFetchSearch(text,location) async{
    Map dataUser;
    final response = await http.post("http://172.16.46.130/e_parking/olFetchSearch",body:{
      "text": text.toString(),
      "location":location.toString(),
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future olFetchSearchHistory(text,location) async{
    Map dataUser;
    final response = await http.post("http://172.16.46.130/e_parking/olFetchSearchHistory",body:{
      "text": text.toString(),
      "location":location.toString(),
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }


  Future olFetchHistory(location) async{
    Map dataUser;
    final response = await http.post("http://172.16.46.130/e_parking/olFetchHistory",body:{
      "location":location.toString(),
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future olSaveDelinquent(id,uid,plateNo,dateToday,fullName,secNameC,imgEmp,imgGuard) async{
    await http.post(Server.address +"olSaveDelinquent",body:{
      "id":id.toString(),
      "uid":uid.toString(),
      "plateNo":plateNo.toString(),
      "dateToday":dateToday.toString(),
      "fullName":fullName.toString(),
      "secNameC":secNameC.toString(),
      "imgEmp":imgEmp.toString(),
      "imgGuard":imgGuard.toString(),
    });
  }

  Future olManagerLogin(username,password) async{
    final response = await http.post("http://172.16.46.130/e_parking/olManagerKey",body:{
      "username":username,
      "password": password,
    });
    if(response.body.length >=1  && response.statusCode == 200){
      return response.body;
    }
    else{
      return 'error';
    }
  }

  Future olSendTransType(empId,type) async{
    await http.post("http://172.16.46.130/e_parking/olSendTransType",body:{
      "empId": empId,
      "type":type,
    });
  }

  Future olReprintCouponTicket(uid,checkDigit,plateNo,dateToday,dateTimeToday,dateUntil,amount,empId,location) async{
    await http.post("http://172.16.46.130/e_parking/olReprintCouponTicket",body:{
      'uid':uid.toString(),
      'checkDigit':checkDigit.toString(),
      'plateNo':plateNo.toString(),
      'dateToday':dateToday.toString(),
      'dateTimeToday':dateTimeToday.toString(),
      'dateUntil':dateUntil.toString(),
      'amount':amount.toString(),
      'empId':empId.toString(),
      'location':location.toString(),
    });
  }

  Future olCancel(id) async{
    await http.post(Server.address +"olCancel",body:{
      'id':id.toString(),
    });
  }

  Future olPenaltyReprint(uId,transCode,plate,dateTimeIn,dateTimeout,amount,penalty,inEmpId,outEmpId,location) async{
    await http.post("http://172.16.46.130/e_parking/olPenaltyReprint",body:{
          'uId':uId.toString(),
          'transCode':transCode.toString(),
          'plate':plate.toString(),
          'dateTimeIn':dateTimeIn.toString(),
          'dateTimeout':dateTimeout.toString(),
          'amount':amount.toString(),
          'penalty':penalty.toString(),
          'inEmpId':inEmpId.toString(),
          'outEmpId':outEmpId.toString(),
          'location':location.toString(),
    });
  }

//  Future<Car> fetchCar(int id) async {
//    var client = await db;
//    final Future<List<Map<String, dynamic>>> futureMaps = client.query('car', where: 'id = ?', whereArgs: [id]);
//    var maps = await futureMaps;
//
//    if (maps.length != 0) {
//      return Car.fromDb(maps.first);
//    }
//
//    return null;
//  }
//
//  Future<List<Car>> fetchAll() async {
//    var client = await db;
//    var res = await client.query('car');
//
//    if (res.isNotEmpty) {
//      var cars = res.map((carMap) => Car.fromDb(carMap)).toList();
//      return cars;
//    }
//    return [];
//  }
//
//  Future<int> updateCar(Car newCar) async {
//    var client = await db;
//    return client.update('car', newCar.toMapForDb(),
//        where: 'id = ?', whereArgs: [newCar.id], conflictAlgorithm: ConflictAlgorithm.replace);
//  }
//
//  Future<void> removeCar(int id) async {
//    var client = await db;
//    return client.delete('car', where: 'id = ?', whereArgs: [id]);
//  }
//
//  Future closeDb() async {
//    var client = await db;
//    client.close();
//  }
}
