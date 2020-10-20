import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
class DataEntry extends StatefulWidget {
  String keyId,name;

  DataEntry({this.keyId,this.name});

  @override
  _DataEntryState createState() => _DataEntryState();
}

class _DataEntryState extends State<DataEntry> {
  String key;
  TextEditingController txtName = TextEditingController();
  final databaseReference = FirebaseDatabase.instance.reference().child("nameDemo");
  void saveData()
  {
      if(key==null)
        {
          key = databaseReference.push().key;
        }
      var map = {
        "key":key,
        "name":txtName.text
      };

      databaseReference.child(key).set(map).then((value){
        print("Data Save");
        Navigator.pop(context);
      });
  }
  @override
  Widget build(BuildContext context) {
    if(widget.keyId!=null)
      {
        key=widget.keyId;
        txtName.text=widget.name;
      }
    return Scaffold(
      appBar: AppBar(
        title: Text("Data Entry"),
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(

          children: <Widget>[

            TextField(
              controller: txtName,
              decoration: InputDecoration(hintText: "Name"),
            ),
            RaisedButton(onPressed: (){
                saveData();
            },child: Text("Save"),)

          ],
        ),
      ),
    );
  }
}
