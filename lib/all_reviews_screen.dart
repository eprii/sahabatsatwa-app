import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'app_theme.dart';
import 'rating_review_section.dart';

// ALL REVIEWS SCREEN
// Halaman ini menampilkan semua review untuk satu destinasi zoo.
// User bisa sort review dari terbaru atau terlama.

class AllReviewsScreen extends StatefulWidget {
  final String idZoo; // id zoo yang reviewnya ingin ditampilkan

  const AllReviewsScreen({
    super.key,
    required this.idZoo,
  });

  @override
  State<AllReviewsScreen> createState() => _AllReviewsScreenState();
}

class _AllReviewsScreenState extends State<AllReviewsScreen> {
  // _terbaru = true menampilkan urutan review terbaru di atas
  // _terbaru = false menampilkan urutan review terlama di atas
  bool _terbaru = true;

  // Fungsi untuk mengubah urutan review
  void _ubahUrutanReview() {
    setState(() {
      _terbaru = !_terbaru;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,

      appBar: AppBar(
        backgroundColor: AppTheme.primaryDark,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,

        // Tombol kembali
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        // Judul halaman
        title: const Text(
          'Semua Review',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        // Tombol sort di kanan AppBar
        actions: [
          _buildTombolSort(),
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        // Query berubah setiap kali _terbaru diubah
        stream: FirebaseFirestore.instance
            .collection('zoo_review')
            .where('id_zoo', isEqualTo: widget.idZoo)
            .orderBy('tanggal_review', descending: _terbaru)
            .snapshots(),

        builder: (context, snap) {
          // Saat data sedang dimuat
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primary,
              ),
            );
          }

          // Jika terjadi error saat mengambil review
          if (snap.hasError) {
            return const Center(
              child: Text(
                'Gagal memuat review.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            );
          }

          // Jika tidak ada review sama sekali
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada review untuk destinasi ini.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            );
          }

          final reviews = snap.data!.docs;

          // Setelah review didapat, ambil data rating agar rating user bisa tampil
          return _buildRatingStream(reviews);
        },
      ),
    );
  }

  // Widget tombol sort terbaru / terlama
  Widget _buildTombolSort() {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: TextButton.icon(
        onPressed: _ubahUrutanReview,
        icon: Icon(
          _terbaru ? Icons.arrow_downward : Icons.arrow_upward,
          color: Colors.white,
          size: 16,
        ),
        label: Text(
          _terbaru ? 'Terbaru' : 'Terlama',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // StreamBuilder kedua untuk mengambil ratings_map dari collection zoo_rating
  Widget _buildRatingStream(List<QueryDocumentSnapshot> reviews) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('zoo_rating')
          .where('id_zoo', isEqualTo: widget.idZoo)
          .limit(1)
          .snapshots(),

      builder: (context, ratingSnap) {
        Map<String, dynamic> ratingsMap = {};

        if (ratingSnap.hasData && ratingSnap.data!.docs.isNotEmpty) {
          final ratingData =
              ratingSnap.data!.docs.first.data() as Map<String, dynamic>;

          ratingsMap = Map<String, dynamic>.from(
            ratingData['ratings_map'] ?? {},
          );
        }

        return _buildKotakReview(
          reviews: reviews,
          ratingsMap: ratingsMap,
        );
      },
    );
  }

  // Widget box putih yang membungkus semua review
  Widget _buildKotakReview({
    required List<QueryDocumentSnapshot> reviews,
    required Map<String, dynamic> ratingsMap,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),

        // ClipRRect digunakan supaya isi ListView mengikuti border radius Container
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: reviews.length,

            // Divider antar review
            separatorBuilder: (context, index) {
              return const Divider(
                height: 1,
                thickness: 1,
                indent: 16,
                endIndent: 16,
                color: Color(0xFFE5E5E5),
              );
            },

            // Isi setiap review
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: ReviewCard(
                  doc: reviews[index],
                  ratingsMap: ratingsMap,
                  showActions: true,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}