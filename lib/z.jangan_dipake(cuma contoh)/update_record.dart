import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditData extends StatefulWidget {
  final String documentId;
  final String namaPaket;
  final String deskripsi;
  final String harga;
  final String imageUrl;

  EditData({
    required this.documentId,
    required this.namaPaket,
    required this.deskripsi,
    required this.harga,
    required this.imageUrl,
  });

  @override
  _EditDataState createState() => _EditDataState();
}

class _EditDataState extends State<EditData> {
  final TextEditingController namaPaketController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();
  final TextEditingController hargaController = TextEditingController();
  File? _image;
  final picker = ImagePicker();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    namaPaketController.text = widget.namaPaket;
    deskripsiController.text = widget.deskripsi;
    hargaController.text = widget.harga;
  }

  Future<void> _updateData() async {
    final updatedData = {
      'nama_paket': namaPaketController.text,
      'deskripsi': deskripsiController.text,
      'harga': hargaController.text,
    };

    // Hapus gambar lama dari Firebase Storage jika ada
    if (_image != null) {
      if (widget.imageUrl.isNotEmpty) {
        final Reference oldImageRef =
            FirebaseStorage.instance.refFromURL(widget.imageUrl);
        await oldImageRef.delete();
      }
    }

    // Upload gambar baru jika ada perubahan
    if (_image != null) {
      final Reference ref =
          FirebaseStorage.instance.ref('images/${DateTime.now().toString()}');
      final UploadTask uploadTask = ref.putFile(_image!);
      await uploadTask.whenComplete(() async {
        final String imageUrl = await ref.getDownloadURL();
        updatedData['imageUrl'] = imageUrl;
      });
    }

    await _firestore
        .collection('Paket')
        .doc(widget.documentId)
        .update(updatedData);

    Navigator.of(context).pop(); // Kembali ke halaman sebelumnya
  }

  Future<void> getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Data'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: namaPaketController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Nama Paket'),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: deskripsiController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Deskripsi'),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: hargaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Harga'),
              ),
              SizedBox(height: 16.0),
              _image != null
                  ? Image.file(_image!, height: 250)
                  : widget.imageUrl.isNotEmpty
                      ? Image.network(widget.imageUrl, height: 250)
                      : Container(),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: getImage,
                child: Text('Ganti Gambar'),
              ),
              ElevatedButton(
                onPressed: _updateData,
                child: Text('Simpan Perubahan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
