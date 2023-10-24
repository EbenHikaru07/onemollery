import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tesflut/z.jangan_dipake(cuma contoh)/contoh_api.dart';
import 'package:tesflut/z.jangan_dipake(cuma contoh)/fetch_data.dart';
import 'package:tesflut/z.jangan_dipake(cuma contoh)/insert_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0; // Index halaman aktif pada bottom navigation bar

  final List<Widget> _pages = [
    const MyHomePageContent(), // Ganti dengan widget halaman utama Anda
    const InsertData(),
    const FetchData(),
    ContohApi(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: _currentIndex == 3
          ? null
          : Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5), // Warna shadow
                    spreadRadius: 5, // Lebar shadow
                    blurRadius: 7, // Blur shadow
                    offset: const Offset(0, 1), // Posisi shadow
                  ),
                ],
              ),
              child: BottomNavigationBar(
                type: BottomNavigationBarType
                    .fixed, // Mengatur agar label selalu ditampilkan
                currentIndex: _currentIndex,
                onTap: (int index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home, color: Colors.white),
                    label: 'Beranda',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.add, color: Colors.white),
                    label: 'Tambah Data',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.list, color: Colors.white),
                    label: 'Lihat Data',
                  ),
                ],
              ),
            ),
    );
  }
}

class MyHomePageContent extends StatefulWidget {
  const MyHomePageContent({Key? key}) : super(key: key);

  @override
  _MyHomePageContentState createState() => _MyHomePageContentState();
}

class _MyHomePageContentState extends State<MyHomePageContent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Selamat datang di Mollery 2023, Admin',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Ganti warna teks sesuai keinginan Anda
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Image(
            width: 500,
            height: 400,
            image: AssetImage('images/mollery remove-bg.png'),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigasi ke halaman Obrolan
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ContohApi()),
          );
        },
        child: const Icon(Icons.chat),
        backgroundColor: Colors.green,
        elevation: 2, // Atur nilai elevation sesuai preferensi Anda
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12)), // Atur bentuk sesuai keinginan Anda
      ),
    );
  }
}
