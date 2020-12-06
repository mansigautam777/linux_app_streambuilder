import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

String x, webdata;

class MyApp extends StatelessWidget {
  var fsconnect = FirebaseFirestore.instance;

  myget() async {
    var d = await fsconnect.collection("command output").get();
    for (var i in d.docs) {
      print(i.data());
    }
  }

  web(cmd) async {
    print(cmd);
    var url = "http://192.168.43.150/cgi-bin/web2.py?x=${cmd}";
    var r = await http.get(url);
    webdata = r.body;
    print(r.body);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
        home: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amberAccent,
        title: Text('Linux App'),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          width: 500,
          height: 1000,
          color: Colors.yellowAccent[100],
          child: Column(
            children: <Widget>[
              Card(
                shadowColor: Colors.amber,
                child: TextField(
                  decoration: InputDecoration(
                    fillColor: Colors.amberAccent,
                    border: InputBorder.none,
                    hintText: "Type the command",
                  ),
                  onChanged: (val) {
                    x = val;
                    // print(val);
                  },
                ),
              ),
              SizedBox(
               height: 50,
             ),
              Card(
                child: FlatButton(
                  color: Colors.amber[300],
                  onPressed: () {
                    // print(x); // x=date
                    web(x);
                  },
                  child: Text('SUBMIT'),
                ),
              ),
              SizedBox(
               height: 10,
             ),
              Card(
                child: FlatButton(
                  color: Colors.amber[300],
                  onPressed: () {
                    fsconnect
                        .collection("http_app")
                        .add({'command': '${webdata}'});
                    print('running the command');
                  },
                  child: Text('RUN'),
                ),
              ),
             SizedBox(
               height: 50,
             ),
              StreamBuilder<QuerySnapshot>(
                builder: (context, snapshot) {
                  print('new data comes');

                  var msg = snapshot.data.docs;

                  List<Widget> y = [];
                  for (var d in msg) {
                    var msgText = d.data()['command'];
                    var msgWidget = Text("$msgText");

                    y.add(msgWidget);
                  }

                  print(y);

                  return Container(
                    color: Colors.amberAccent,
                    child: Column(
                      children: y,
                    ),
                  );
                },
                stream: fsconnect.collection("http_app").snapshots(),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
