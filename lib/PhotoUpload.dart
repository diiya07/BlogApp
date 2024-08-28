import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'HomePage.dart';
import 'Authentication.dart';

class UploadPhotoPage extends StatefulWidget {
  final AuthImplementation auth;
  final VoidCallback onSignedOut;

  UploadPhotoPage({
    required this.auth,
    required this.onSignedOut,
  });

  @override
  State<StatefulWidget> createState() {
    return _UploadPhotoPageState();
  }
}

class _UploadPhotoPageState extends State<UploadPhotoPage> {
  File? sampleImage;
  String? _myValue;
  String? url;
  final formKey = GlobalKey<FormState>();

  Future<void> getImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        sampleImage = File(pickedImage.path);
      });
    }
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form != null && form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  Future<void> uploadStatusImage() async {
    if (validateAndSave()) {
      try {
        final Reference postImageRef =
            FirebaseStorage.instance.ref().child('Post Images');
        var timeKey = DateTime.now();
        final Reference imageRef =
            postImageRef.child('${timeKey.toString()}.jpg');

        final UploadTask uploadTask = imageRef.putFile(sampleImage!);
        final TaskSnapshot snapshot = await uploadTask;
        final String downloadUrl = await snapshot.ref.getDownloadURL();
        setState(() {
          url = downloadUrl;
        });

        print("Image url = " + url!);
        goToHomePage();
        saveToDatabase(url!);
      } catch (e) {
        print("Error uploading image: $e");
      }
    }
  }

  void saveToDatabase(String imageUrl) {
    var dbTimeKey = DateTime.now();
    var formatDate = DateFormat('MMM d, yyyy');
    var formatTime = DateFormat('EEEE, hh:mm aaa');

    String date = formatDate.format(dbTimeKey);
    String time = formatTime.format(dbTimeKey);

    DatabaseReference ref = FirebaseDatabase.instance.ref();

    var data = {
      "image": imageUrl,
      "description": _myValue,
      "date": date,
      "time": time,
    };

    ref.child("Posts").push().set(data);
  }

  void goToHomePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) {
          return HomePage(
            auth: widget.auth,
            onSignedOut: widget.onSignedOut,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Image'),
        centerTitle: true,
      ),
      body: sampleImage == null
          ? Center(child: Text('Select an Image'))
          : SingleChildScrollView(
              padding: EdgeInsets.all(20.0),
              child: enableUpload(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Add Image',
        child: Icon(Icons.add_a_photo),
      ),
    );
  }

  Widget enableUpload() {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (sampleImage != null)
            Image.file(
              sampleImage!,
              height: 330.0,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          SizedBox(
            height: 15.0,
          ),
          TextFormField(
            decoration: InputDecoration(labelText: "Description"),
            validator: (value) {
              return value == null || value.isEmpty
                  ? "Blog Description is required"
                  : null;
            },
            onSaved: (value) {
              _myValue = value;
            },
          ),
          SizedBox(
            height: 15,
          ),
          ElevatedButton(
            onPressed: uploadStatusImage,
            style: ElevatedButton.styleFrom(
              elevation: 10,
              backgroundColor: Colors.purple[100],
              foregroundColor: Colors.black,
            ),
            child: Text('Upload'),
          ),
        ],
      ),
    );
  }
}
