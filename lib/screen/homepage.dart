import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'upload_portfolio.dart';
import '../component/portofolio_card.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['Semua', 'RPL', 'TKJ', 'Animasi', 'TJAT', 'DKV'];

  final AuthService _authService = AuthService();
  String _username = 'Loading...';

  @override
  void initState() {
    super.initState();
    if (AuthService.cachedUser != null) {
      _username = AuthService.cachedUser!.username;
    }
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    UserModel? user = await _authService.getCurrentUserData();
    if (mounted) {
      setState(() {
        _username = user?.username ?? 'Guest';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0),
                    ),
                    child: Header(),
                  ),
                  SizedBox(height: 20.0),
                  TabMenu(),
                  HomeText1(),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('portofolios')
                        .snapshots(),
                    builder: (context, snapshot) {
                      //cek loading
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      //cek jika error
                      if (snapshot.hasError) {
                        return Center(child: Text("error : ${snapshot.error}"));
                      }

                      //cek jika data kosong
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text("belum ada portofolio"),
                        );
                      }

                      //jika aman baru ambil data
                      final dataPorto = snapshot.data!.docs;

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: dataPorto.length,
                        itemBuilder: (context, index) {
                          return PortofolioCard(data: dataPorto[index]);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container Header() {
    return Container(
      height: 200.0,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF49B33), Color(0xFFEE7F3C)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 25.0, top: 75.0, right: 25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang ',
                  style: GoogleFonts.plusJakartaSans(
                    color: Color(0xFFFFFFFF),
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Text(
                    _username,
                    style: GoogleFonts.plusJakartaSans(
                      color: Color(0xFFFFFFFF),
                      fontWeight: FontWeight.w800,
                      fontSize: 28.0,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            right: 30.0,
            top: 85.0,
            child: Container(
              width: 35.0,
              height: 35.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFD9D9D9),
              ),
              child: Icon(Icons.notifications, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget TabMenu() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            _tabs.length,
            (index) => Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTabIndex = index;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  decoration: BoxDecoration(
                    gradient: _selectedTabIndex == index
                        ? LinearGradient(
                            colors: [Color(0xFFEE7F3C), Color(0xFFF49B33)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: _selectedTabIndex == index
                        ? null
                        : Color(0x1a808080),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Text(
                    _tabs[index],
                    style: GoogleFonts.plusJakartaSans(
                      color: _selectedTabIndex == index
                          ? Colors.white
                          : Colors.black,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeText1 extends StatelessWidget {
  const HomeText1({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 30.0, right: 30.0),
      child: Row(
        children: [
          Container(
            child: Text(
              "portofolio Terbaru",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15.0),
            ),
          ),
        ],
      ),
    );
  }
}
