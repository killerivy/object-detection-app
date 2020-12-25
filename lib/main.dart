import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'package:path_provider/path_provider.dart';


void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget{
  //root
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:'ML CA' ,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,

      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PickedFile imageuri ;
  File pfile;
  File _image1;
  final ImagePicker _picker = ImagePicker();
  List _outputs;
  bool _loading = false;
  String _confidence ='';
  String _name = '';
  @override
  void initState() {
    super.initState();
    _loading = true;

    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  Future getImagecg(bool isCamera) async{
    var image = await _picker.getImage(source: (isCamera == true) ? ImageSource.camera : ImageSource.gallery);
  setState(() {
    imageuri = image;
    pfile = File(image.path);
    _loading = true;
    classifyImage(pfile);
  });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.green,
      body: Container(


        child: imageuri == null ? Text('no image') :
      Center(
        child: Container(
          height : 350,
          width : 350,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: FileImage(File(pfile.path)),
              fit: BoxFit.contain
            )
          ),
          child: _outputs != null
              ? Text(
            "${_outputs[0]["label"]}",
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.0,
              background: Paint()..color = Colors.white,
            ),
          )
              : Container()
        ),

      )),


        floatingActionButton : Column(
          mainAxisAlignment: MainAxisAlignment.end,

          children:<Widget>[
            FloatingActionButton(
              backgroundColor: Colors.black38,
              child: Icon(Icons.camera_alt),
              onPressed: (){getImagecg(true);},
            ),
            SizedBox(height: 20),
            FloatingActionButton(
              backgroundColor: Colors.black38,
              child: Icon(Icons.image),
              onPressed: (){getImagecg(false);},
            ),
          ],

        ),


    );
  }
  classifyImage(File file) async {
    var output = await Tflite.runModelOnImage(
      path: file.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _loading = false;
      _outputs = output;
      print(_outputs);
      String str = _outputs[0]['labels'];


    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }
}
