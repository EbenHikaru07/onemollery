import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tesflut/z.jangan_dipake(cuma contoh)/update_record.dart';

class FetchData extends StatefulWidget {
  const FetchData({Key? key}) : super(key: key);

  @override
  State<FetchData> createState() => _FetchDataState();
}

class _FetchDataState extends State<FetchData> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true; // Tambahkan variabel isLoading

  @override
  void initState() {
    super.initState();
    // Saat widget diinisialisasi, set isLoading menjadi true
    _isLoading = true;
  }

  Widget listItem({required DocumentSnapshot document}) {
    Map<String, dynamic> student = document.data() as Map<String, dynamic>;

    return Card(
      color: Color.fromARGB(255, 100, 123, 72),
      margin: const EdgeInsets.all(10),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Text(
                          student['nama_paket'] ?? '',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color.fromARGB(255, 10, 224,
                                21), // Ganti dengan warna teks yang cocok dengan latar belakang Anda
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Text(
                        student['deskripsi'] ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        student['harga']?.toString() ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Image.network(
                    student['imageUrl'] ?? '',
                    width: 100,
                    height: 100,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditData(
                                documentId: document.id,
                                namaPaket: student['nama_paket'],
                                deskripsi: student['deskripsi'] ?? '',
                                harga: student['harga']?.toString() ?? '',
                                imageUrl: student['imageUrl'] ?? '',
                              ),
                            ),
                          );
                        },
                        child: Icon(
                          Icons.edit,
                          color: Colors.yellowAccent,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          _showDeleteConfirmationDialog(
                            document.id,
                            student['imageUrl'],
                          );
                        },
                        child: Icon(
                          Icons.delete,
                          color: Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(color: Color.fromARGB(255, 8, 245, 48)),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(String studentKey, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Confirmation'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this record?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                await _deleteDataAndImage(studentKey, imageUrl);
                Navigator.of(context).pop(); // Close the dialog
                // Tampilkan SnackBar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Data has been deleted successfully.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteDataAndImage(String studentKey, String imageUrl) async {
    // Hapus gambar dari Firebase Storage
    final Reference storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
    try {
      await storageRef.delete();
    } catch (e) {
      print('Error deleting image from Firebase Storage: $e');
    }

    // Hapus data dari Firestore
    await _firestore.collection('Paket').doc(studentKey).delete();
  }

  Future<void> _fetchData() async {
    final snapshot =
        await _firestore.collection('Paket').orderBy('deskripsi').get();

    // Simulasi penundaan untuk melihat animasi loading.
    await Future.delayed(Duration(seconds: 2));

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Paket'),
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
      ),
      body: Container(
        height: double.infinity,
        child: _isLoading
            ? Center(
                child: RotationTransition(
                  turns: AlwaysStoppedAnimation(
                      0.5), // Putar setengah putaran (0.5)
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
              )
            : StreamBuilder(
                stream: _firestore
                    .collection('Paket')
                    .orderBy('deskripsi')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator(); // Menampilkan indikator loading jika data belum tersedia
                  }
                  final documents = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      return listItem(document: documents[index]);
                    },
                  );
                },
              ),
      ),
    );
  }
}
