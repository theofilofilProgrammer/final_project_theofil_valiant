import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Model Sekolah
class Sekolah {
  final String kodeProp;
  final String propinsi;
  final String kodeKabKota;
  final String kabupatenKota;
  final String kodeKec;
  final String kecamatan;
  final String id;
  final String npsn;
  final String sekolah;
  final String bentuk;
  final String status;
  final String alamatJalan;
  final String lintang;
  final String bujur;

  Sekolah({
    required this.kodeProp,
    required this.propinsi,
    required this.kodeKabKota,
    required this.kabupatenKota,
    required this.kodeKec,
    required this.kecamatan,
    required this.id,
    required this.npsn,
    required this.sekolah,
    required this.bentuk,
    required this.status,
    required this.alamatJalan,
    required this.lintang,
    required this.bujur,
  });

  factory Sekolah.fromJson(Map<String, dynamic> json) {
    return Sekolah(
      kodeProp: json['kode_prop'],
      propinsi: json['propinsi'],
      kodeKabKota: json['kode_kab_kota'],
      kabupatenKota: json['kabupaten_kota'],
      kodeKec: json['kode_kec'],
      kecamatan: json['kecamatan'],
      id: json['id'],
      npsn: json['npsn'],
      sekolah: json['sekolah'],
      bentuk: json['bentuk'],
      status: json['status'],
      alamatJalan: json['alamat_jalan'],
      lintang: json['lintang'],
      bujur: json['bujur'],
    );
  }
}

// Main Function
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sekolah Informatika',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SekolahListScreen(),
    );
  }
}

// Screen untuk Menampilkan Data dengan Paginasi
class SekolahListScreen extends StatefulWidget {
  @override
  _SekolahListScreenState createState() => _SekolahListScreenState();
}

class _SekolahListScreenState extends State<SekolahListScreen>
    with SingleTickerProviderStateMixin {
  List<Sekolah> _sekolahList = [];
  bool _isLoading = false;
  int _currentPage = 1;
  bool _hasMoreData = true;
  final int _perPage = 15; // Jumlah data per halaman
  final ScrollController _scrollController = ScrollController();

  // Animation Controllers
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fetchMoreData();

    // Set up the animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Fade-in animation
    _fadeInAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    // Slide animation
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoading &&
          _hasMoreData) {
        _fetchMoreData();
      }
    });

    // Start the animations when the screen is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  Future<void> _fetchMoreData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          'https://api-sekolah-indonesia.vercel.app/sekolah/s?sekolah=smks%20informatika&page=$_currentPage&perPage=$_perPage'));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> newData = jsonResponse['dataSekolah'];

        if (newData.isNotEmpty) {
          setState(() {
            _sekolahList.addAll(
              newData.map((json) => Sekolah.fromJson(json)).toList(),
            );
            _currentPage++;
            if (newData.length < _perPage) {
              _hasMoreData = false; // Tidak ada data lagi untuk diambil
            }
          });
        } else {
          _hasMoreData = false;
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print('Error: $error');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daftar Sekolah Informatika',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _sekolahList.length + 1,
              itemBuilder: (context, index) {
                if (index < _sekolahList.length) {
                  final sekolah = _sekolahList[index];
                  return FadeTransition(
                    opacity: _fadeInAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Card(
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            sekolah.sekolah,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Alamat: ${sekolah.alamatJalan}'),
                              Text('Kecamatan: ${sekolah.kecamatan}'),
                              Text('Kabupaten/Kota: ${sekolah.kabupatenKota}'),
                            ],
                          ),
                          trailing: Icon(Icons.school),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetailSekolahScreen(sekolah: sekolah),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                } else {
                  return _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : SizedBox.shrink();
                }
              },
            ),
          ),
          if (_isLoading) CircularProgressIndicator(),
          if (!_hasMoreData)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('No more data to load'),
            ),
        ],
      ),
    );
  }
}

// Screen untuk Menampilkan Detail Sekolah
class DetailSekolahScreen extends StatelessWidget {
  final Sekolah sekolah;

  DetailSekolahScreen({required this.sekolah});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(sekolah.sekolah),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'school-${sekolah.id}',
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: AssetImage(
                          'assets/school_placeholder.jpg'), // Placeholder image
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              sekolah.sekolah,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'NPSN: ${sekolah.npsn}',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 16),
            Text(
              'Alamat:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              sekolah.alamatJalan,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            SizedBox(height: 16),
            Text(
              'Kecamatan: ${sekolah.kecamatan}',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            Text(
              'Kabupaten/Kota: ${sekolah.kabupatenKota}',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            Text(
              'Propinsi: ${sekolah.propinsi}',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            SizedBox(height: 16),
            Text(
              'Koordinat:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Lintang: ${sekolah.lintang}',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            Text(
              'Bujur: ${sekolah.bujur}',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
