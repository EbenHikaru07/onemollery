import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tesflut/fitur_chat/a_p_i.dart';
import 'package:tesflut/menu_admin/detailharga_admin.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tesflut/menu_admin/bar_admin.dart';
import 'package:tesflut/data_admin/tambah_data_admin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(PaketApp());
}

class PaketApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Map<String, dynamic>> paketList;
  List<bool> checkedItems = [];
  late QuerySnapshot querySnapshot; // Tambahkan variabel ini
  bool isLoading = true; // Tambahkan variabel isLoading

  @override
  void initState() {
    super.initState();
    paketList = []; // Inisialisasi paketList sebagai list kosong
    getPaketList();
  }

  void getPaketList() {
    FirebaseFirestore.instance
        .collection('Paket')
        .orderBy('nama_paket')
        .get()
        .then((snapshot) {
      setState(() {
        querySnapshot = snapshot; // Simpan snapshot di variabel ini
        List<Map<String, dynamic>> tempList = [];
        snapshot.docs.forEach((document) {
          Map<String, dynamic> paket = document.data() as Map<String, dynamic>;
          tempList.add(paket);
        });
        tempList.sort((a, b) => a['nama_paket'].compareTo(b['nama_paket']));
        paketList = tempList;
        isLoading = false; // Set isLoading menjadi false setelah data dimuat
      });
    }).catchError((error) {
      print('Error while loading data: $error');
      setState(() {
        isLoading = false; // Set isLoading menjadi false jika terjadi kesalahan
      });
    });
  }

  void _navigateToDetailPage(Map<String, dynamic> paket) {
    String docId = '';
    for (var doc in querySnapshot.docs) {
      if (doc['nama_paket'] == paket['nama_paket']) {
        docId = doc.id;
        break;
      }
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailHargaPage(paket: paket, docId: docId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          if (isLoading) // Tambahkan kondisi untuk menampilkan CircularProgressIndicator
            Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          if (!isLoading && paketList.isEmpty)
            Expanded(
              child: Center(
                child: Text('Data Kosong'),
              ),
            ),
          if (!isLoading && paketList.isNotEmpty)
            Stack(
              alignment: Alignment.topCenter,
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Paket')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      List<String> imageUrls = [];
                      snapshot.data!.docs.forEach((doc) {
                        if (doc['url_gambar'] != null) {
                          imageUrls.add(doc['url_gambar']);
                        }
                      });
                      if (imageUrls.isNotEmpty) {
                        return CarouselSlider(
                          items: imageUrls.map((imageUrl) {
                            return Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                            );
                          }).toList(),
                          options: CarouselOptions(
                            autoPlay: true,
                            height: 400.0,
                            viewportFraction: 1,
                            disableCenter: true,
                            autoPlayInterval: Duration(seconds: 4),
                            autoPlayAnimationDuration:
                                Duration(milliseconds: 800),
                            onPageChanged: (index, reason) {
                              setState(() {});
                            },
                          ),
                        );
                      } else {
                        return Center(child: Text('Gambar Tidak Tersedia'));
                      }
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
                Positioned(
                  top: 50.0,
                  left: 20.0,
                  child: Text(
                    'Selamat Datang',
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        shadows: [
                          Shadow(
                            blurRadius: 4.0,
                            color: Colors.black,
                            offset: Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 80.0,
                  left: 20.0,
                  child: Text(
                    'Admin',
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        shadows: [
                          Shadow(
                            blurRadius: 4.0,
                            color: Colors.black,
                            offset: Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Text(
                  'Paket Tersedia:',
                  style: GoogleFonts.roboto(
                      textStyle: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Container(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TambahDataAdmin()),
                      );
                      // Tambah logika penambahan data di sini
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 0, 0, 0),
                      side: BorderSide(
                        color: Color.fromARGB(255, 255, 255,
                            255), // Atur warna outline sesuai keinginan Anda
                        width: 1, // Atur lebar outline sesuai keinginan Anda
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            8), // Atur nilai border radius sesuai keinginan Anda
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 1.0, horizontal: 1.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Tambah Data',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (isLoading) // Tampilkan indikator loading jika isLoading adalah true
            Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          if (!isLoading &&
              paketList
                  .isNotEmpty) // Tampilkan data jika isLoading adalah false
            Expanded(
              child: ListView.builder(
                itemCount: paketList.length,
                itemBuilder: (BuildContext context, int index) {
                  final paket = paketList[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 5.0),
                    color: Color(0xFF101717), // Warna latar belakang #101717
                    child: ListTile(
                      leading: SizedBox(
                        width: 100.0,
                        height: 100.0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5.0),
                          child: paket['url_gambar'] != null
                              ? Image.network(
                                  paket[
                                      'url_gambar'], // Ubah ini agar memuat gambar dari URL
                                  fit: BoxFit.cover,
                                )
                              : Container(),
                        ),
                      ),
                      title: Text(
                        paket['nama_paket'] ?? 'Deskripsi Tidak Tersedia',
                        style: GoogleFonts.roboto(
                          textStyle:
                              TextStyle(color: Colors.white, fontSize: 20.0),
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            paket['deskripsi'] ?? 'Deskripsi Tidak Tersedia',
                            style: GoogleFonts.roboto(
                              textStyle: TextStyle(
                                  color: Colors.white, fontSize: 10.0),
                            ),
                          ),
                          Text(
                            paket['keuntungan1'] ?? 'Keuntungan Tidak Tersedia',
                            style: GoogleFonts.roboto(
                              textStyle: TextStyle(
                                  color: Colors.white, fontSize: 10.0),
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        _navigateToDetailPage(paket);
                      },
                      trailing: TextButton(
                        onPressed: () {
                          _navigateToDetailPage(paket);
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.blueGrey,
                          ),
                        ),
                        child: Text(
                          paket['harga'] != null
                              ? 'Rp ${paket['harga']}'
                              : 'Harga Tidak Tersedia',
                          style: GoogleFonts.roboto(
                            textStyle:
                                TextStyle(color: Colors.white, fontSize: 14.0),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.fromLTRB(0, 120, 0, 52),
        child: Align(
          alignment: Alignment.topRight,
          child: FloatingActionButton(
            onPressed: () {
              // Navigasi ke halaman Obrolan
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ContohApi()),
              );
            },
            child: const Icon(Icons.chat),
            backgroundColor:
                const Color.fromARGB(255, 81, 85, 81).withOpacity(0.3),
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      bottomNavigationBar:
          BottomNavigation(), // Use the BottomNavigation widget here
    );
  }
}
