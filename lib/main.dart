import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? imageFile;
  bool isLoading = false;
  String result = 'Result will appear here';
  final picker = ImagePicker();

  // Fungsi untuk memilih gambar dari kamera atau galeri
  Future<void> _getImageAndDetectText(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) return;

    setState(() {
      imageFile = File(pickedFile.path);
      isLoading = true;
      result = '';
    });

    // Membuat InputImage dari file yang dipilih
    final inputImage = InputImage.fromFile(imageFile!);
    final textRecognizer = TextRecognizer();

    try {
      // Proses deteksi teks menggunakan ML Kit
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      // Menampilkan hasil teks yang terdeteksi
      setState(() {
        result = recognizedText.text.isEmpty
            ? 'No text found!'
            : recognizedText.text;
      });
    } catch (e) {
      setState(() {
        result = 'Error: $e';
      });
    }

    textRecognizer.close();

    setState(() {
      isLoading = false;
    });
  }

  // Menampilkan indikator loading saat proses pemindaian teks
  Widget _buildWidgetLoading() {
    return Platform.isIOS
        ? CupertinoActivityIndicator()
        : CircularProgressIndicator();
  }

  // Menampilkan dialog untuk memilih sumber gambar (kamera atau galeri)
  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pick an Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _getImageAndDetectText(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.image),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _getImageAndDetectText(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter ML Kit Text Recognition'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: imageFile == null
                  ? Container(color: Colors.grey[200])
                  : Image.file(imageFile!, fit: BoxFit.cover),
            ),
            Expanded(
              child: Center(
                child: isLoading ? _buildWidgetLoading() : Text(result),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        onPressed: _showImageSourceDialog, // Menampilkan dialog sumber gambar
      ),
    );
  }
}
