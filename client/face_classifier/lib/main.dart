// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, avoid_print

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face Classifier',
      theme: ThemeData(
        primaryColor: Colors.deepPurple,
        fontFamily: 'Roboto',
      ),
      home: const ImageUploader(),
    );
  }
}

class ImageUploader extends StatefulWidget {
  const ImageUploader({super.key});

  @override
  _ImageUploaderState createState() => _ImageUploaderState();
}

class _ImageUploaderState extends State<ImageUploader> {
  File? _image;
  bool isUploading = false;
  String responseMessage = '';

  Future getImage(ImageSource source) async {
    final image = await ImagePicker().pickImage(source: source);

    setState(() {
      if (image != null) {
        _image = File(image.path);
        responseMessage = '';
      } else {
        print('No image selected.');
      }
    });
  }

  Future uploadImage() async {
    if (_image == null) {
      print('No image selected.');
      return;
    }

    setState(() {
      isUploading = true;
    });

    final uri = Uri.parse(""); //ip server
    var request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('image', _image!.path));
    var response = await request.send();
    if (response.statusCode == 200) {
      print('Image uploaded');
      String responseBody = await response.stream.bytesToString();
      setState(() {
        responseMessage = responseBody;
      });
    } else {
      print('Image not uploaded');
    }

    setState(() {
      isUploading = false;
    });
  }

  void resetImage() {
    setState(() {
      _image = null;
      responseMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Face Classifier',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: resetImage,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image != null
                ? Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.file(
                          _image!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                : Image.asset(
                    'assets/images/no_image.png',
                    width: 400,
                    height: 400,
                  ),
            const SizedBox(height: 16),
            Visibility(
              visible: _image != null && !isUploading,
              child: ElevatedButton(
                onPressed: uploadImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.blue, // Use backgroundColor for button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Proses',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            Visibility(
              visible: isUploading,
              child: const CircularProgressIndicator(),
            ),
            const SizedBox(height: 14),
            // Modified output prediction
            if (responseMessage.isNotEmpty)
              Card(
                color: Colors.blueGrey,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        color: Colors.white,
                        size: 35,
                      ),
                      const SizedBox(height: 7),
                      Text(
                        'Hasil Prediksi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        responseMessage,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Wrap(
                children: [
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Choose from Gallery'),
                    onTap: () {
                      getImage(ImageSource.gallery);
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_camera),
                    title: const Text('Take a Photo'),
                    onTap: () {
                      getImage(ImageSource.camera);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
        tooltip: 'Pick Image',
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}
