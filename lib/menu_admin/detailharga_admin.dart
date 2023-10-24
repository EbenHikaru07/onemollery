import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tesflut/data_admin/edit_data.dart';
import 'package:tesflut/menu_admin/tampilan_utama_admin.dart';

final List<String> studioImages = [
  'images/studio1.png',
  'images/studio2.png',
  'images/studio3.png',
  'images/studio4.png',
];

class DetailHargaPage extends StatefulWidget {
  final Map<String, dynamic> paket;
  final String docId;

  DetailHargaPage({required this.paket, required this.docId});

  @override
  _DetailHargaPageState createState() => _DetailHargaPageState();
}

class _DetailHargaPageState extends State<DetailHargaPage> {
  int _selectedStudioIndex = 0;
  late String imageUrl = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  void _loadImage() async {
    setState(() {
      isLoading = true;
    });
    // Kode untuk memuat gambar
    String imagePath = widget.paket['url_gambar'];
    await Future.delayed(
        Duration(seconds: 1)); // Simulasi waktu pemuatan gambar
    setState(() {
      imageUrl = imagePath;
      isLoading = false;
    });
  }

  void _deletePaket() async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Konfirmasi"),
          content: Text("Apakah Anda yakin ingin menghapus data ini?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("Tidak"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text("Ya"),
            ),
          ],
        );
      },
    );

    if (confirmDelete != null && confirmDelete) {
      setState(() {
        isLoading = true; // Menampilkan indikator loading
      });

      try {
        // Hapus gambar di storage
        String imageUrl = widget.paket['url_gambar'];
        Reference ref = FirebaseStorage.instance.refFromURL(imageUrl);
        await ref.delete();

        // Hapus data di firestore
        String documentName = widget.docId;
        await FirebaseFirestore.instance
            .collection('Paket')
            .doc(documentName)
            .delete();

        // Menutup indikator loading dan memperbarui halaman
        setState(() {
          isLoading = false;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PaketApp()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Data berhasil dihapus"),
          ),
        );
      } catch (e) {
        print("Error deleting data: $e");
        // Menutup indikator loading jika terjadi kesalahan
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showDocId(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Info"),
          content: Text("Document ID: $docId"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF101720),
      body: Stack(
        children: [
          Positioned(
            bottom: 20.0,
            left: 0.0,
            right: 0.0,
            child: Center(
              child: isLoading
                  ? CircularProgressIndicator() // Tampilkan indikator loading
                  : ElevatedButton(
                      // Tambahkan tombol refresh
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => PaketApp()),
                        );
                      },
                      child: Text('Refresh'),
                    ),
            ),
          ),
          Positioned(
            top: 0,
            left: 5,
            right: 0,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        height: 400.0,
                        width: 400.0,
                      )
                    : Container(),
                Positioned(
                  top: 30, // Atur posisi vertikal
                  left: 10, // Atur posisi horizontal
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromARGB(255, 74, 74, 70).withOpacity(0.3),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 350.0,
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF101720),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(40.0),
                ),
              ),
              child: ListView(
                padding: EdgeInsets.all(0),
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 10),
                      Text(
                        widget.paket['nama_paket'] ??
                            'Nama Paket Tidak Tersedia',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Rincian:',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.people,
                            color: Colors.white,
                          ),
                          SizedBox(width: 10),
                          Text(
                            widget.paket['deskripsi'],
                            style: GoogleFonts.roboto(
                              textStyle: TextStyle(
                                  color: Colors.white, fontSize: 20.0),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Colors.white,
                          ),
                          SizedBox(width: 10),
                          Text(
                            widget.paket['waktu'],
                            style: GoogleFonts.roboto(
                              textStyle: TextStyle(
                                  color: Colors.white, fontSize: 20.0),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.layers,
                            color: Colors.white,
                          ),
                          SizedBox(width: 10),
                          Text(
                            widget.paket['ganti_pakaian'],
                            style: GoogleFonts.roboto(
                              textStyle: TextStyle(
                                  color: Colors.white, fontSize: 20.0),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      Text(
                        'Keuntungan:',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.folder,
                            color: Colors.white,
                          ),
                          SizedBox(width: 10),
                          Text(
                            widget.paket['keuntungan1'],
                            style: GoogleFonts.roboto(
                              textStyle: TextStyle(
                                  color: Colors.white, fontSize: 20.0),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        children: [
                          Icon(
                            Icons.picture_in_picture_sharp,
                            color: Colors.white,
                          ),
                          SizedBox(width: 10),
                          Text(
                            widget.paket['keuntungan2'],
                            style: GoogleFonts.roboto(
                              textStyle: TextStyle(
                                  color: Colors.white, fontSize: 20.0),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Pilih Studio',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: studioImages.asMap().entries.map((entry) {
                          final int index = entry.key;
                          final String imagePath = entry.value;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedStudioIndex = index;
                              });
                            },
                            child: Container(
                              width: 80.0,
                              height: 80.0,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(imagePath),
                                  fit: BoxFit.cover,
                                ),
                                border: Border.all(
                                  color: _selectedStudioIndex == index
                                      ? Colors.blue
                                      : Colors.transparent,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      Text('Studio Terpilih: ${_selectedStudioIndex + 1}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ))
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: ElevatedButton(
          onPressed: () {
            // Tambahkan logika pemesanan di sini
          },
          style: ElevatedButton.styleFrom(
            primary: Color(0xFF445256),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Pesan Sekarang',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // Existing code...

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.all(10.0),
            child: FloatingActionButton(
              heroTag: 'editButton',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditForm(
                      paket: widget.paket,
                      docId: widget.docId, // Kirimkan docId ke EditForm
                    ),
                  ),
                );
              },
              backgroundColor: Color(0xFF445256),
              child: Icon(
                Icons.edit,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: FloatingActionButton(
              heroTag:
                  'deleteButton', // Unique tag for the second FloatingActionButton
              onPressed: _deletePaket,
              backgroundColor: Colors.red,
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: FloatingActionButton(
              heroTag:
                  'infoButton', // Unique tag for the third FloatingActionButton
              onPressed: () {
                _showDocId(context, widget.docId);
              },
              backgroundColor: Colors.green,
              child: Icon(
                Icons.info,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),

// Existing code...
    );
  }
}
