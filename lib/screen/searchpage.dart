import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../component/portofolio_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedCategory = "Semua";

  final List<String> _categories = [
    "Semua",
    "RPL",
    "TKJ",
    "Animasi",
    "TJAT",
    "DKV",
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              bottom: 30,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFEE7F3C), Color(0xFFF49B33)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cari Portofolio',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                // Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari Portofolio.....',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        color: Colors.grey[400],
                        fontSize: 16,
                      ),
                      icon: const Icon(Icons.search, color: Colors.black54),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Category Filters ──
          const SizedBox(height: 10),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    selectedColor: const Color(0xFFEE7F3C).withOpacity(0.2),
                    checkmarkColor: const Color(0xFFEE7F3C),
                    labelStyle: GoogleFonts.plusJakartaSans(
                      color: isSelected ? const Color(0xFFEE7F3C) : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFFEE7F3C) : Colors.transparent,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Results List ──
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseService().PortofolioCollection.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'Belum ada portofolio',
                      style: GoogleFonts.plusJakartaSans(color: Colors.grey),
                    ),
                  );
                }

                // Filter logic
                final results = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final title = (data['title'] ?? '').toString().toLowerCase();
                  final username = (data['username'] ?? '').toString().toLowerCase();
                  final category = (data['kategori'] ?? '').toString();
                  final tags = List<String>.from(data['tags'] ?? []);

                  // Search in title, username, and tags
                  final matchesQuery = title.contains(_searchQuery) || 
                                      username.contains(_searchQuery) ||
                                      tags.any((tag) => tag.toLowerCase().contains(_searchQuery));
                  
                  final matchesCategory = _selectedCategory == "Semua" || category == _selectedCategory;

                  return matchesQuery && matchesCategory;
                }).toList();

                if (results.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'Portofolio tidak ditemukan',
                          style: GoogleFonts.plusJakartaSans(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 10, bottom: 100),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    return PortofolioCard(data: results[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}