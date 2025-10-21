import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../database_helper.dart';
import 'package:image_picker/image_picker.dart';

class NewProduct extends StatefulWidget {
  final String title;
  NewProduct({Key key, this.title}) : super(key: key);

  @override
  _NewProduct createState() => new _NewProduct();

}

class _NewProduct extends State<NewProduct> {

  bool _canShowButton = true;
  String name,desc, imgDecode;
  int harga;
  // A global list to populate
  final dbHelper = DatabaseHelper.instance;

  Uint8List bytes;


  File galleryImage;
  var litems = [];

  final nameController = TextEditingController();
  final hargaController = TextEditingController();
  final descController = TextEditingController();

  // define focus node to manage lifecycle
  FocusNode focusNode;

  @override
  void initState(){
    super.initState();

    focusNode = FocusNode();
    nameController.addListener(_nameInputListener);
    hargaController.addListener(_hargaInputListener);
    descController.addListener(_descInputListener);
    //assume to get all data in sqlite
    _query();
  }

  _nameInputListener(){
    name = nameController.text;
    print(name);
  }
  _hargaInputListener(){
    harga = int.parse(hargaController.text);
    print(harga);
  }

  _descInputListener(){
    desc = descController.text;
  }

  @override
  void dispose() {
    nameController.dispose();
    hargaController.dispose();
    descController.dispose();

    focusNode.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //var assetsImage = new AssetImage("assets/grilled-salmons-2.jpg");
    //final image = new Image(image: assetsImage, width: 100.0, height: 100.0,);

    return new Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        title:new Text(widget.title),
        actions: <Widget>[
          new IconButton(icon: const Icon(Icons.save), onPressed: (){},)
        ],
      ),
      body: new Column(
        mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
      
        children: <Widget>[
          new ListTile(
            title: new TextField(
              
              controller: nameController,
              focusNode: focusNode,
              decoration: new InputDecoration(
                focusedBorder: OutlineInputBorder(

                  borderSide: BorderSide(color: Colors.lightBlue, width: 1.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, ),
                ),
                hintText: "Nama Produk",
              ),
            ),
          ),
          new ListTile(
            title: new TextField(
              controller: hargaController,
              decoration: new InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.lightBlue, width: 1.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, ),
                )
                ,hintText: "Harga Product"),
              keyboardType: TextInputType.number
            ),
          ),
          new ListTile(
            title: new TextField(
              controller: descController,
              decoration: new InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.lightBlue, width: 1.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, ),
                ),
                hintText: "Deskripsi Barang"),
              keyboardType: TextInputType.multiline,
              maxLines: null,
            ),
          ),
          const SizedBox(height: 10),

          _canShowButton ? new FlatButton.icon(
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(4.0)),
            color: Colors.blue[500],
            icon: Icon(Icons.add_a_photo,size: 15.0, color: Colors.white),
            onPressed: selectorGallery,
            label: const Text("Gambar", style: TextStyle(color: Colors.white),),  
          ) : displayImage(galleryImage),

        Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 250.0,
                child: ListView.builder(
                   scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: litems.length,
                      itemBuilder: (BuildContext ctx,int index){
                        String nama = litems[index]["nama"].toString();
                        String harga = litems[index]["harga"].toString();
                        String desc = litems[index]["desc"].toString();
                        String img = litems[index]["img"].toString();

                        bytes = base64.decode(img);

                        return GestureDetector(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 8.0, bottom: 60.0, top: 8.0,),
                            child: Card(
                              child: Container(
                                width: 100.0,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                      
                                        Center(
                                          child: new Column(
                                            children: <Widget>[
                                              AspectRatio(
                                                aspectRatio: 50/50,
                                                child: displayDecodeImage(bytes),
                                                
                                              ),
                                              Container(
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 6.0,top: 5.0),
                                                  child: new Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,

                                                    children: <Widget>[
                                                      SizedBox(
                                                        width: double.infinity,
                                                        child: Container(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,                                  
                                                            children: <Widget>[
                                                              new Text(
                                                                nama,
                                                                textAlign: TextAlign.left,
                                                              ),
                                                              new Text(
                                                                harga,
                                                                textAlign: TextAlign.left
                                                              ),
                                                              new Text(
                                                                desc,
                                                                textAlign: TextAlign.left,
                                                              )
                                                            ],
                                                          )
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                )
                                              )
                                            ],
                                          )
                                        ),
                                      
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                ),
              )
            ],
          ),
        )       

        ],
      ),
      floatingActionButton: new FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: (){
          if(nameController.text == "" || hargaController.text == "" || descController.text == ""){
            //TODO if textfield null dont upload to sqflite
            print("null");
          }else {
            _insertData();
          galleryImage = null;
          _canShowButton = true;
            print("null");
          }

          _query();
          setState(() {});
        },

      ),
    resizeToAvoidBottomPadding: false,
    );
  }

   void selectorGallery() async {
    galleryImage = await ImagePicker.pickImage(
      source: ImageSource.gallery
    );
    if(galleryImage != null){
      _canShowButton = false;
    }
    print("Gallery Path : " + galleryImage.path);
    List<int> imageBytes = await galleryImage.readAsBytes();
    imgDecode = base64.encode(imageBytes);
    // bytes = base64.decode(imgDecode);
    // print(imgDecode);
    setState(() {});
  }
// return widget sizedbox image
  Widget displayImage(File file){
    return new SizedBox(
      height: 100,
      width: 200,
      child: file == null ? new Text("No file") : new GestureDetector(
        child: Image.file(file),
        onTap: (){
          galleryImage = null;
          _canShowButton = true;
          print("Clicked");
          setState((){});
        }, 
      ),
    );
  }

  Widget displayDecodeImage(Uint8List int8){
    return new Container(
      height: 50.0,
      width: 50.0,
      decoration: new BoxDecoration(
        image: new DecorationImage(
          fit: BoxFit.fitWidth,
          alignment: FractionalOffset.topCenter,
          image: new Image.memory(int8).image
        ),
      ),
    );
  }

  void _insertData() async {
    Map<String, dynamic> row = {
      DatabaseHelper.columnName : name,
      DatabaseHelper.columnHarga : harga,
      DatabaseHelper.columnDesc : desc,
      DatabaseHelper.columnImg : imgDecode
    };

    final id = await dbHelper.insert(row);
    nameController.clear();
          hargaController.clear();
          descController.clear();
           
    print('inserted row with id : $id');
  }

  void _query() async {
    final allRows = await dbHelper.queryAllRows();
    print("All Rows : " + allRows.length.toString());
    allRows.forEach((e){
      litems.add(e);
    });
          
    setState(() {});

  }

}