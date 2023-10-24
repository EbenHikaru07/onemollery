import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tesflut/menu_admin/tampilan_utama_admin.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(TambahDataAdmin());
}

class TambahDataAdmin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: AddDataPage(),
    );
  }
}

class AddDataPage extends StatefulWidget {
  @override
  _AddDataPageState createState() => _AddDataPageState();
}

class _AddDataPageState extends State<AddDataPage> {
  final _formKey = GlobalKey<FormState>();
  late String _urlGambar = '';
  late String _namaPaket = '';
  late String _deskripsi = '';
  late String _orang = '';
  late double _harga = 0;
  late String _keuntungan1 = '';
  late String _keuntungan2 = '';
  late String _waktu = '';
  late String _gantiPakaian = '';

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_urlGambar.isEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Peringatan'),
              content: Text('Gambar harus dipilih'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        try {
          // Menghapus .0 di belakang harga jika perlu
          if (_harga == _harga.toInt()) {
            _harga = _harga.toInt().toDouble();
          }
          _addDataToFirestore();
        } catch (e) {
          print(e);
        }
      }
    }
  }

  Future<String> uploadImageToFirebase(File imageFile) async {
    try {
      if (imageFile == null) {
        throw Exception('File not found');
      }

      DateTime now = DateTime.now();
      String timeStamp =
          '${now.year}-${now.month}-${now.day}-${now.hour}-${now.minute}-${now.second}-${now.millisecond}';
      String fileName =
          'image_$timeStamp-${now.millisecondsSinceEpoch.toString()}.jpg';

      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child('images/$fileName');
      UploadTask uploadTask = firebaseStorageRef.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image to Firebase Storage: $e');
    }
  }

  void _getImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _urlGambar = image.path;
      });
    }
  }

  Future<void> _addDataToFirestore() async {
    try {
      String imageUrl = await uploadImageToFirebase(File(_urlGambar));

      await FirebaseFirestore.instance.collection('Paket').add({
        'url_gambar': imageUrl,
        'nama_paket': _namaPaket,
        'deskripsi': _deskripsi,
        'orang': _orang,
        'harga': _harga,
        'keuntungan1': _keuntungan1,
        'keuntungan2': _keuntungan2,
        'waktu': _waktu,
        'ganti_pakaian': _gantiPakaian,
      });

      print('Data berhasil disimpan!');
      _showSuccessDialog(); // Tampilkan dialog sukses sebelum kembali
    } catch (e) {
      print('Terjadi kesalahan: $e');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sukses'),
          content: Text('Data berhasil disimpan!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PaketApp()),
                ); // Kembali ke layar sebelumnya
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  String basename(String path) {
    var separator = '/';
    if (path.contains('\\')) {
      separator = '\\';
    }
    var parts = path.split(separator);
    return parts.last;
  }

  void _deleteImage() {
    setState(() {
      _urlGambar = '';
    });
  }

  double? parseDouble(String value) {
    try {
      double parsedValue = double.parse(value);
      return double.parse(parsedValue.toStringAsFixed(
          parsedValue.truncateToDouble() == parsedValue ? 0 : 2));
    } on FormatException {
      throw Exception('Harga harus berupa angka yang valid');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Data'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PaketApp()),
            );
          },
        ),
        actions: [
          OutlinedButton(
            onPressed: _submitForm,
            child: Text('Simpan'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Nama Paket',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  onSaved: (value) => _namaPaket = value!,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Data ini tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Deskripsi',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  onSaved: (value) => _deskripsi = value!,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Data ini tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Waktu',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  onSaved: (value) => _waktu = value!,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Data ini tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Orang',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  onSaved: (value) => _orang = value!,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Data ini tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Ganti Pakaian',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  onSaved: (value) => _gantiPakaian = value!,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Data ini tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Keuntungan 1',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  onSaved: (value) => _keuntungan1 = value!,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Data ini tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Keuntungan 2',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  onSaved: (value) => _keuntungan2 = value!,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Data ini tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Harga',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => _harga = double.parse(value!),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Data ini tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _urlGambar.isEmpty
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
                                              Image.file(File(_urlGambar)),
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
                              child: Image.file(
                                File(_urlGambar),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
