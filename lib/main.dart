import 'package:flutter/material.dart';
import 'DataEntry.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
void main()=>runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);


  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final databaseReference = FirebaseDatabase.instance.reference().child("nameDemo");
  List<Map<String,dynamic>> lstName = List<Map<String,dynamic>>();
  int selectedIndex;
  String _appTitle ="Firebase";
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  _MyHomePageState()
  {
    databaseReference.onChildAdded.listen(_AddRecordListener);
    databaseReference.onChildChanged.listen(_EditRecordListener);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMessage();
    _register();
  }


  _register()
  {
    _firebaseMessaging.getToken().then((token){ print(token);});
  }

  void getMessage(){
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print('on message $message');
          setState(() => _appTitle = message["notification"]["title"]);
        }, onResume: (Map<String, dynamic> message) async {
      print('on resume $message');
      setState(() => _appTitle = message["notification"]["title"]);
    }, onLaunch: (Map<String, dynamic> message) async {
      print('on launch $message');
      setState(() => _appTitle = message["notification"]["title"]);
    });
  }

  _AddRecordListener(Event event)
  {
    var dataSnapshot = event.snapshot;
    var map ={
      "key":dataSnapshot.value["key"],
      "name":dataSnapshot.value["name"]
    };
    setState(() {
      lstName.add(map);
    });
  }

  _EditRecordListener(Event event)
  {
    var dataSnapshot = event.snapshot;
    var map ={
      "key":dataSnapshot.value["key"],
      "name":dataSnapshot.value["name"]
    };
    lstName.removeAt(selectedIndex);
    setState(() {
      if(lstName.length>selectedIndex)
        {
          lstName.insert(selectedIndex,map);
        }
      else
        {
          lstName.add(map);
        }
    });
  }

  void deleteRecord(int index)
  {
    var map = lstName[index];
    databaseReference.child(map["key"]).remove().then((_){
      setState(() {
        lstName.removeAt(index);
      });
    });
  }

  void editRecord(int index)
  {
    selectedIndex=index;
    var map = lstName[index];
    Navigator.push(context, MaterialPageRoute(builder: (context)=>DataEntry(keyId: map["key"],name: map["name"],)));
  }




  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        title: Text(_appTitle),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.add), onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>DataEntry()));
          })
        ],
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            ListView.builder(
              shrinkWrap: true,
                itemCount: lstName.length,
                itemBuilder: (context,index){
                  return Row(
                    children: <Widget>[
                      Text(lstName[index]["name"],style: TextStyle(fontSize: 24.0),),
                      IconButton(icon: Icon(Icons.edit,color: Colors.blue,), onPressed: (){
                        editRecord(index);
                      }),
                      IconButton(icon: Icon(Icons.delete,color: Colors.red,), onPressed: (){
                        deleteRecord(index);
                      }),
                    ],
                  );
                })
          ],
        ),
      ),
    );
  }
}
