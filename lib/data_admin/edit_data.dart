import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tesflut/menu_admin/tampilan_utama_admin.dart';

class EditForm extends StatefulWidget {
  final Map<String, dynamic> paket;
  final String docId;

  EditForm({required this.paket, required this.docId});

  @override
  _EditFormState createState() => _EditFormState();
}

class _EditFormState extends State<EditForm> {
  late TextEditingController _namaController;
  late TextEditingController _deskripsiController;
  late TextEditingController _hargaController;
  late TextEditingController _waktuController;
  late TextEditingController _orangController;
  late TextEditingController _keuntungan1Controller;
  late TextEditingController _keuntungan2Controller;
  late TextEditingController _gantiPakaianController;
  // Add more controllers as needed
  late String _urlGambar = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.paket['nama_paket']);
    _deskripsiController =
        TextEditingController(text: widget.paket['deskripsi']);
    _hargaController =
        TextEditingController(text: widget.paket['harga'].toString());
    _waktuController =
        TextEditingController(text: widget.paket['waktu'].toString());
    _orangController =
        TextEditingController(text: widget.paket['orang'].toString());
    _keuntungan1Controller =
        TextEditingController(text: widget.paket['keuntungan1']);
    _keuntungan2Controller =
        TextEditingController(text: widget.paket['keuntungan2']);
    _gantiPakaianController =
        TextEditingController(text: widget.paket['ganti_pakaian']);
    // Initialize more controllers as needed
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _hargaController.dispose();
    _waktuController.dispose();
    _orangController.dispose();
    _keuntungan1Controller.dispose();
    _keuntungan2Controller.dispose();
    _gantiPakaianController.dispose();
    // Dispose more controllers as needed
    super.dispose();
  }

  void _updateData() async {
    setState(() {
      _isLoading = true;
    });

    // Implement logic to update the package
    // Use the values from the controllers
    String namaPaket = _namaController.text;
    String deskripsi = _deskripsiController.text;
    String hargaText = _hargaController.text;
    int harga = int.parse(hargaText.split('.').first);

    String waktu = _waktuController.text;
    String orang = _orangController.text;
    String keuntungan1 = _keuntungan1Controller.text;
    String keuntungan2 = _keuntungan2Controller.text;
    String gantiPakaian = _gantiPakaianController.text;

    // Implement the logic to update the package data using the above values
    // For example, you can use Firestore to update the data
    // For demonstration purposes, print the values to the console
    print('Nama Paket: $namaPaket');
    print('Deskripsi: $deskripsi');
    print('Harga: $harga');
    print('Waktu: $waktu');
    print('Orang: $orang');
    print('Keuntungan 1: $keuntungan1');
    print('Keuntungan 2: $keuntungan2');
    print('Ganti Pakaian: $gantiPakaian');

    // Update data di Firestore
    try {
      Map<String, dynamic> updatedData = {
        'nama_paket': namaPaket,
        'deskripsi': deskripsi,
        'harga': harga,
        'waktu': waktu,
        'orang': orang,
        'keuntungan1': keuntungan1,
        'keuntungan2': keuntungan2,
        'ganti_pakaian': gantiPakaian,
      };

      // Hanya tambahkan 'url_gambar' jika _urlGambar tidak kosong
      if (_urlGambar.isNotEmpty) {
        updatedData['url_gambar'] = _urlGambar;
      }

      await FirebaseFirestore.instance
          .collection('Paket')
          .doc(widget.docId)
          .update(updatedData);

      // Show a snackbar to indicate the successful update
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Berhasil"),
            content: Text("Data berhasil diperbarui"),
            actions: [
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PaketApp()),
                  );
                },
              ),
            ],
          );
        },
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to update data in Firestore: $e');
    }
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File file = File(pickedFile.path);

      try {
        if (file == null) {
          throw Exception('File not found');
        }

        // Hapus gambar lama dari Firebase Storage jika ada
        if (widget.paket['url_gambar'] != null) {
          Reference oldImageRef =
              FirebaseStorage.instance.refFromURL(widget.paket['url_gambar']);
          await oldImageRef.delete();
        }

        // Upload gambar baru
        DateTime now = DateTime.now();
        String timeStamp =
            '${now.year}-${now.month}-${now.day}-${now.hour}-${now.minute}-${now.second}-${now.millisecond}';
        String fileName =
            'image_$timeStamp-${now.millisecondsSinceEpoch.toString()}.jpg';

        Reference firebaseStorageRef =
            FirebaseStorage.instance.ref().child('images/$fileName');
        UploadTask uploadTask = firebaseStorageRef.putFile(file);
        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        setState(() {
          _urlGambar = downloadUrl;
        });
      } catch (e) {
        throw Exception('Failed to update image: $e');
      }
    }
  }

  String _twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  void _deleteImage() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Konfirmasi"),
          content: Text("Apakah Anda yakin ingin menghapus gambar?"),
          actions: <Widget>[
            TextButton(
              child: Text("Ya"),
              onPressed: () async {
                Navigator.of(context).pop();
                // Jika gambar dihapus, set _urlGambar menjadi kosong
                setState(() {
                  _urlGambar = '';
                });
              },
            ),
            TextButton(
              child: Text("Tidak"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Paket'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              TextFormField(
                initialValue: widget.docId,
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'ID Dokumen',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(
                  labelText: 'Nama Paket',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _deskripsiController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _hargaController,
                decoration: InputDecoration(
                  labelText: 'Harga',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _waktuController,
                decoration: InputDecoration(
                  labelText: 'Waktu',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _orangController,
                decoration: InputDecoration(
                  labelText: 'Orang',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _keuntungan1Controller,
                decoration: InputDecoration(
                  labelText: 'Keuntungan 1',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _keuntungan2Controller,
                decoration: InputDecoration(
                  labelText: 'Keuntungan 2',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _gantiPakaianController,
                decoration: InputDecoration(
                  labelText: 'Ganti Pakaian',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              // Tampilkan gambar
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _urlGambar.isEmpty && widget.paket['url_gambar'] != null
                    ? Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Scaffold(
                                    backgroundColor: Colors.black,
                                    body: SingleChildScrollView(
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.network(
                                                widget.paket['url_gambar']),
                                            SizedBox(height: 20),
                                          ],
                                        ),
                                      ),
                                    ),
                                    floatingActionButton: FloatingActionButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Icon(Icons.arrow_back),
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: Image.network(
                              widget.paket['url_gambar'],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 200,
                            ),
                          ),
                          Positioned(
                            top: 15,
                            right: 15,
                            child: GestureDetector(
                              onTap: _getImage,
                              child: Container(
                                padding: EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue,
                                ),
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : _urlGambar.isEmpty
                        ? InkWell(
                            onTap: _getImage,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Add Photo',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Scaffold(
                                        backgroundColor: Colors.black,
                                        body: SingleChildScrollView(
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Image.network(_urlGambar),
                                                SizedBox(height: 20),
                                              ],
                                            ),
                                          ),
                                        ),
                                        floatingActionButton:
                                            FloatingActionButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Icon(Icons.arrow_back),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: Image.network(
                                  _urlGambar,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 200,
                                ),
                              ),
                              Positioned(
                                top: 15,
                                right: 15,
                                child: GestureDetector(
                                  onTap: _deleteImage,
                                  child: Container(
                                    padding: EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color.fromARGB(255, 74, 71, 71),
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
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
