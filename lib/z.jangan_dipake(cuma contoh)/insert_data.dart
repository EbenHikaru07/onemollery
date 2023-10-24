import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class InsertData extends StatefulWidget {
  const InsertData({Key? key}) : super(key: key);

  @override
  State<InsertData> createState() => _InsertDataState();
}

class _InsertDataState extends State<InsertData> {
  final userDeskripsiController = TextEditingController();
  final userHargaController = TextEditingController();
  final userNamaController = TextEditingController();
  File? _image;
  final picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _showSuccessDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Data has been successfully inserted.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context)
                    .pop(); // Navigate back to the previous screen
              },
            ),
          ],
        );
      },
    );
  }

  Future<String?> uploadImage() async {
    try {
      if (_image != null) {
        final Reference ref = FirebaseStorage.instance
            .ref()
            .child('images/${DateTime.now()}.jpg');
        final UploadTask uploadTask = ref.putFile(_image!);
        final TaskSnapshot downloadUrl = await uploadTask;
        final String url = await downloadUrl.ref.getDownloadURL();
        return url;
      }
      return null;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  void _insertData() async {
    try {
      final String? imageUrl = await uploadImage();
      if (imageUrl != null) {
        await _firestore.collection('Paket').add({
          'nama_paket': userNamaController.text,
          'deskripsi': userDeskripsiController.text,
          'harga': int.tryParse(userHargaController.text) ?? 0,
          'imageUrl': imageUrl,
        });

        _showSuccessDialog();

        // Berpindah ke halaman sebelumnya setelah notifikasi berhasil ditampilkan
        Navigator.of(context).pop();
      } else {
        // Handle jika gagal mengunggah gambar
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Failed to upload image.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Handle error
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred: $e'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inserting data'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                const Text(
                  'Inserting data in Firestore Database',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 30,
                ),
                TextField(
                  controller: userNamaController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Nama Paket', // Field Nama Paket
                    hintText: 'Nama Paket',
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                TextField(
                  controller: userDeskripsiController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Deskripsi',
                    hintText: 'Kasih deskripsi gan',
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                TextField(
                  controller: userHargaController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Harga',
                    hintText: 'Kasih Harga',
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                if (_image != null)
                  Image.file(
                    _image!,
                    height: 150,
                  )
                else
                  Container(),
                const SizedBox(
                  height: 20,
                ),
                MaterialButton(
                  onPressed: getImage,
                  child: const Text('Choose Image'),
                  color: Colors.blue,
                  textColor: Colors.white,
                  minWidth: 300,
                  height: 40,
                ),
                const SizedBox(
                  height: 20,
                ),
                MaterialButton(
                  onPressed: _insertData,
                  child: const Text('Insert Data'),
                  color: Colors.blue,
                  textColor: Colors.white,
                  minWidth: 300,
                  height: 40,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
