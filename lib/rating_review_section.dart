import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_theme.dart';
import 'all_reviews_screen.dart';
import 'package:hugeicons/hugeicons.dart';

// ══════════════════════════════════════════════════════════════════════════════
// RATING SECTION
// Widget ini menampilkan bintang rata-rata dan memungkinkan user memberi rating.
//
// Cara kerja penyimpanan rating:
// Dokumen zoo_rating menyimpan field "ratings_map" berupa Map,
// contoh: { "uid_userA": 4, "uid_userB": 5, "uid_userC": 3 }
// Rata-rata dihitung langsung dari semua nilai di dalam Map tersebut.
// ══════════════════════════════════════════════════════════════════════════════

class RatingSection extends StatefulWidget {
  final String idZoo;
  const RatingSection({super.key, required this.idZoo});

  @override
  State<RatingSection> createState() => _RatingSectionState();
}

class _RatingSectionState extends State<RatingSection> {
  late final Future<String> _roleFuture;

  @override
  void initState() {
    super.initState();
    _roleFuture = _ambilRoleUser();
  }

  Future<String> _ambilRoleUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return 'guest';
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (!userDoc.exists) {
      return 'user';
    }

    // ignore: unnecessary_cast
    final data = userDoc.data() as Map<String, dynamic>?;

    return data?['role'] ?? 'user';
  }
  // ── Fungsi: tentukan warna bintang berdasarkan jumlah bintang terisi ────────
  Color _warnaRating(int jumlah) {
    if (jumlah <= 1) {
      return Colors.red;             // 1 bintang → merah
    } else if (jumlah == 2) {
      return Colors.orange;          // 2 bintang → oranye
    } else if (jumlah == 3) {
      return Colors.amber;           // 3 bintang → oranye terang
    } else if (jumlah == 4) {
      return Colors.yellow.shade700; // 4 bintang → kuning
    } else {
      return Colors.lightGreen;      // 5 bintang → hijau terang
    }
  }

  // ── Fungsi: kirim atau update rating ke Firestore ───────────────────────────
Future<void> _kirimRating(int bintang) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;

  // Jika belum login, tampilkan pesan dan hentikan fungsi
  if (uid == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login dulu untuk memberi rating!')),
    );
    return;
  }

  // Rating hanya boleh 0 sampai 5
  // 0 artinya rating dihapus / kembali kosong
  if (bintang < 0 || bintang > 5) {
    return;
  }

  final zooRatingRef = FirebaseFirestore.instance.collection('zoo_rating');

  final snap = await zooRatingRef
      .where('id_zoo', isEqualTo: widget.idZoo)
      .get();

  if (snap.docs.isEmpty) {
    // Jika belum ada dokumen dan user klik reset, tidak perlu membuat data baru
    if (bintang == 0) {
      return;
    }

    // Dokumen zoo_rating belum ada → buat baru
    await zooRatingRef.add({
      'id_zoo': widget.idZoo,
      'rating': bintang.toDouble(),
      'jumlah_rating': 1,
      'last_update': FieldValue.serverTimestamp(),
      'ratings_map': {uid: bintang},
    });
  } else {
    final doc = snap.docs.first;
    final data = doc.data();

    Map<String, dynamic> ratingsMap = Map<String, dynamic>.from(
      data['ratings_map'] ?? {},
    );

    // Kalau klik bintang yang sama, bintang = 0 → hapus rating user
    if (bintang == 0) {
      ratingsMap.remove(uid);
    } else {
      ratingsMap[uid] = bintang;
    }

    int total = 0;

    for (String key in ratingsMap.keys) {
      total += (ratingsMap[key] as num).toInt();
    }

    // Ini bagian penting supaya tidak error NaN
    double rataRataBaru = 0;

    if (ratingsMap.isNotEmpty) {
      rataRataBaru = total / ratingsMap.length;
    }

    await doc.reference.update({
      'ratings_map': ratingsMap,
      'rating': rataRataBaru,
      'jumlah_rating': ratingsMap.length,
      'last_update': FieldValue.serverTimestamp(),
    });
  }
}

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
          ),
        ],
      ),

      // StreamBuilder: dengarkan perubahan dokumen zoo_rating secara real-time
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('zoo_rating')
            .where('id_zoo', isEqualTo: widget.idZoo)
            .snapshots(),
        builder: (context, snap) {

          // Nilai default sebelum data dimuat
          double rataRata     = 0;
          int    jumlahRating = 0;
          int    bintangTerisi = 0;
          int    ratingUser   = 0; // rating yang sudah diberikan user ini

          // Jika data sudah tersedia, ambil semua nilai yang dibutuhkan
          if (snap.hasData && snap.data!.docs.isNotEmpty) {
            final doc  = snap.data!.docs.first;
            final data = doc.data() as Map<String, dynamic>;

            rataRata     = (data['rating']        as num).toDouble();
            jumlahRating = (data['jumlah_rating'] as num).toInt();
            bintangTerisi = rataRata.floor(); // bulatkan ke bawah

            // Ambil rating user ini dari ratings_map menggunakan uid sebagai key
            final uid        = FirebaseAuth.instance.currentUser?.uid;
            final ratingsMap = Map<String, dynamic>.from(data['ratings_map'] ?? {});

            if (uid != null && ratingsMap.containsKey(uid)) {
              ratingUser = (ratingsMap[uid] as num).toInt();
            }
          }

          // Tentukan warna berdasarkan jumlah bintang terisi
          final warna = _warnaRating(bintangTerisi);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Baris atas: bintang rata-rata + angka ──────────────────────

              Row(
                children: [

                  // 5 bintang display (hanya tampilan, bukan interaktif)
                  Row(
                    children: _buildBintangDisplay(bintangTerisi, warna),
                  ),

                  const Spacer(),

                  // Teks rata-rata dan jumlah penilaian di sebelah kanan
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [

                      // Contoh: "4.53/5"
                      Text(
                        rataRata > 0
                            ? '${rataRata.toStringAsFixed(2)}/5'
                            : 'Belum ada',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),

                      // Contoh: "12 penilaian"
                      Text(
                        '$jumlahRating penilaian',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                        ),
                      ),

                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // ── Baris bawah: bintang interaktif + keterangan user ───────────
              // Hanya muncul untuk user (bukan admin)

              FutureBuilder<String>(
                future: _roleFuture,
                builder: (context, userSnap) {
                  if (userSnap.connectionState == ConnectionState.waiting) {
                    return const SizedBox();
                  }

                  final role = userSnap.data ?? 'user';

                  if (role == 'admin') {
                    return const SizedBox();
                  }

                  if (role == 'guest') {
                    return const Text(
                      'Login untuk memberi rating',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                    );
                  }

                  return Row(
                    children: [
                      const Text(
                        'Penilaian kamu: ',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),

                      BintangRatingInteraktif(
                        ratingUser: ratingUser,
                        onChanged: _kirimRating,
                      ),

                      const SizedBox(width: 6),

                      Text(
                        ratingUser > 0 ? '$ratingUser bintang' : 'Belum dinilai',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  );
                },
              ),

            ],
          );
        },
      ),
    );
  }

  // ── Helper: buat 5 bintang display (tidak interaktif) ───────────────────────
  List<Widget> _buildBintangDisplay(int bintangTerisi, Color warna) {
    List<Widget> daftar = [];

    for (int i = 0; i < 5; i++) {
      bool terisi = i < bintangTerisi;

      daftar.add(
        Icon(
          terisi ? Icons.star : Icons.star_border,
          color: terisi ? warna : Colors.grey[300],
          size: 28,
        ),
      );
    }

    return daftar;
  }

}

// ══════════════════════════════════════════════════════════════════════════════
// REVIEW SECTION
// Widget ini menampilkan 5 preview review + input field untuk mengirim review.
// ══════════════════════════════════════════════════════════════════════════════

class ReviewSection extends StatefulWidget {
  final String idZoo;
  const ReviewSection({super.key, required this.idZoo});

  @override
  State<ReviewSection> createState() => _ReviewSectionState();
}

class _ReviewSectionState extends State<ReviewSection> {

  // Controller untuk field input review
  final _reviewCtrl = TextEditingController();

  // State loading saat review sedang dikirim
  bool _isSubmitting = false;

  // Jangan lupa dispose controller saat widget dihapus dari tree
  @override
  void dispose() {
    _reviewCtrl.dispose();
    super.dispose();
  }

  // ── Fungsi: kirim review ke Firestore ───────────────────────────────────────
  Future<void> _kirimReview() async {

    final uid  = FirebaseAuth.instance.currentUser?.uid;
    final teks = _reviewCtrl.text.trim(); // hapus spasi di awal dan akhir

    // Cek apakah user sudah login
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login dulu untuk mengirim review!')),
      );
      return;
    }

    // Cek apakah field review tidak kosong
    if (teks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review tidak boleh kosong!')),
      );
      return;
    }

    // Mulai proses loading
    setState(() {
      _isSubmitting = true;
    });

    // Ambil data user dari Firestore untuk mendapatkan nama dan username
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

  
    final userData     = userDoc.data() as Map<String, dynamic>;
    final namaReviewer = userData['nama_depan'] ?? 'Pengguna'; // ambil nama depan
    final username     = userData['username']   ?? '';

    // Simpan review ke Firestore collection zoo_review
    await FirebaseFirestore.instance.collection('zoo_review').add({
      'id_zoo':        widget.idZoo,
      'id_user':       uid,
      'nama_reviewer': namaReviewer,
      'username':      username,
      'komentar':      teks,
      'tanggal_review': FieldValue.serverTimestamp(), // waktu server otomatis
    });

    // Kosongkan field setelah berhasil kirim
    _reviewCtrl.clear();

    // Selesai loading
    setState(() {
      _isSubmitting = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review berhasil dikirim!'),
          backgroundColor: AppTheme.primary,
        ),
      );
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Judul section ─────────────────────────────────────────────────

          const Text(
            'Review',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),

          // ── StreamBuilder: ambil 5 preview review terbaru ─────────────────

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('zoo_review')
                .where('id_zoo', isEqualTo: widget.idZoo)
                .orderBy('tanggal_review', descending: true) // terbaru dulu
                .limit(5) // batasi 5 preview
                .snapshots(),
            builder: (context, snap) {

              // Saat data belum dimuat
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CircularProgressIndicator(
                      color: AppTheme.primary,
                      strokeWidth: 2,
                    ),
                  ),
                );
              }

              // Jika belum ada review sama sekali
              if (!snap.hasData || snap.data!.docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Belum ada review. Jadilah yang pertama!',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textMuted,
                    ),
                  ),
                );
              }

              final reviews = snap.data!.docs;

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

                  return Column(
                    children: _buildDaftarReview(reviews, ratingsMap),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 4),

          // ── Tombol Lihat Semua ────────────────────────────────────────────

Align(
  alignment: Alignment.centerRight,
  child: TextButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AllReviewsScreen(idZoo: widget.idZoo),
        ),
      );
    },
    style: TextButton.styleFrom(
      backgroundColor: AppTheme.primary,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 15,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        HugeIcon(
          icon: HugeIcons.strokeRoundedCircleArrowRight01,
          color: Colors.white,
          size: 18,
        ),
        SizedBox(width: 6),
        Text(
          'Lihat semua review',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),

      ],
    ),
  ),
),

          const Divider(height: 24),

          // ── Input review: hanya tampil untuk user (bukan admin) ───────────

          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser?.uid)
                .get(),
            builder: (context, userSnap) {

              if (userSnap.connectionState == ConnectionState.waiting) {
                return const SizedBox();
              }

              final role = userSnap.data?.exists == true
                  ? (userSnap.data!.data() as Map<String, dynamic>)['role'] ?? 'user'
                  : 'user';

              // Admin hanya bisa lihat review, tidak bisa kirim
              if (role == 'admin') return const SizedBox();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Judul input ─────────────────────────────────────────

                  const Text(
                    'Tulis Review',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Field input review ──────────────────────────────────

                  TextField(
                    controller: _reviewCtrl,
                    maxLines: 3,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textDark,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Bagikan pengalamanmu di sini...',
                      hintStyle: const TextStyle(
                        color: Color(0xFFAAAAAA),
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      contentPadding: const EdgeInsets.all(12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppTheme.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── Tombol Kirim ────────────────────────────────────────

                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _kirimReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Kirim Review',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                ],
              );
            },
          ),

        ],
      ),
    );
  }

  // ── Helper: buat daftar widget review dari list dokumen ─────────────────────
  // Menggunakan for loop sesuai materi guru
  List<Widget> _buildDaftarReview(
    List<QueryDocumentSnapshot> reviews,
    Map<String, dynamic> ratingsMap,
  ) {
    List<Widget> daftar = [];

    for (int i = 0; i < reviews.length; i++) {
      daftar.add(
        ReviewCard(
          doc: reviews[i],
          ratingsMap: ratingsMap,
        ),
      );

      if (i < reviews.length - 1) {
        daftar.add(const Divider(height: 20));
      }
    }

    return daftar;
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// REVIEW CARD
// Widget untuk menampilkan satu review (nama, tanggal, komentar).
// Dibuat public supaya bisa dipakai di AllReviewsScreen juga.
// ══════════════════════════════════════════════════════════════════════════════

class ReviewCard extends StatelessWidget {
  final QueryDocumentSnapshot doc; // dokumen review dari Firestore
  final Map<String, dynamic> ratingsMap;

  const ReviewCard({
    super.key,
    required this.doc,
    this.ratingsMap = const {},
  });

  // ── Helper: format Timestamp menjadi teks tanggal ──────────────────────────
  String _formatTanggal(Timestamp? timestamp) {
    if (timestamp == null) return '';

    final dt = timestamp.toDate(); // ubah Timestamp ke DateTime

    // Daftar nama bulan dalam bahasa Indonesia
    final bulan = [
      '',          // index 0 kosong karena bulan mulai dari 1
      'Januari', 'Februari', 'Maret',     'April',
      'Mei',      'Juni',     'Juli',      'Agustus',
      'September','Oktober',  'November',  'Desember',
    ];

    // Format jam dan menit dengan dua digit, contoh: 08:05
    final jam   = dt.hour.toString().padLeft(2, '0');
    final menit = dt.minute.toString().padLeft(2, '0');

    // Gabungkan menjadi: "13:38, 23 Mei 2026"
    return '$jam:$menit, ${dt.day} ${bulan[dt.month]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {

    // Ambil data dari dokumen Firestore sebagai Map
    final data     = doc.data() as Map<String, dynamic>;
    final nama     = data['nama_reviewer'] ?? 'Pengguna';
    final username = data['username'] ?? '';
    final komentar = data['komentar'] ?? '';
    final tanggal  = _formatTanggal(data['tanggal_review'] as Timestamp?);

    final idUser = data['id_user'] ?? '';

    int ratingReviewer = 0;

    if (idUser.toString().isNotEmpty && ratingsMap.containsKey(idUser)) {
      ratingReviewer = (ratingsMap[idUser] as num).toInt();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ── Nama + @username
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: nama,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),

                    if (username.isNotEmpty)
                      TextSpan(
                        text: ' @$username',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            if (ratingReviewer > 0)
              _ReviewRatingBadge(rating: ratingReviewer),
          ],
        ),

        const SizedBox(height: 2),

        // Tanggal review 

        Text(
          tanggal,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textMuted,
          ),
        ),

        const SizedBox(height: 6),

        // ── Komentar ────────────────────────────────────────────────────────

        Text(
          komentar,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textDark,
            height: 1.5, // jarak antar baris
          ),
        ),

      ],
    );
  }
}

class _ReviewRatingBadge extends StatelessWidget {
  final int rating;

  const _ReviewRatingBadge({
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.star,
          size: 15,
          color: Colors.amber,
        ),
        const SizedBox(width: 3),
        Text(
          rating.toString(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
      ],
    );
  }
}

class BintangRatingInteraktif extends StatefulWidget {
  final int ratingUser;
  final Future<void> Function(int) onChanged;

  const BintangRatingInteraktif({
    super.key,
    required this.ratingUser,
    required this.onChanged,
  });

  @override
  State<BintangRatingInteraktif> createState() => _BintangRatingInteraktifState();
}

class _BintangRatingInteraktifState extends State<BintangRatingInteraktif> {
  late int ratingTampil;
  bool sedangKirim = false;

  @override
  void initState() {
    super.initState();
    ratingTampil = widget.ratingUser;
  }

  @override
  void didUpdateWidget(covariant BintangRatingInteraktif oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update dari Firestore hanya kalau user tidak sedang klik rating
    if (!sedangKirim && widget.ratingUser != oldWidget.ratingUser) {
      ratingTampil = widget.ratingUser;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        bool dipilih = i < ratingTampil;

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () async {
            if (sedangKirim) return;

            int ratingBaru;

            if (i + 1 == ratingTampil) {
              ratingBaru = 0; // klik bintang sama = kosong lagi
            } else {
              ratingBaru = i + 1;
            }

            // Ubah bintang langsung, hanya widget ini yang rebuild
            setState(() {
              ratingTampil = ratingBaru;
              sedangKirim = true;
            });

            try {
              await widget.onChanged(ratingBaru);

              // Beri waktu kecil supaya rebuild dari Firestore tidak menimpa tampilan
              await Future.delayed(const Duration(milliseconds: 300));

              if (!mounted) return;

              setState(() {
                sedangKirim = false;
              });
            } catch (e) {
              if (!mounted) return;

              setState(() {
                ratingTampil = widget.ratingUser;
                sedangKirim = false;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Gagal mengirim rating')),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Icon(
              dipilih ? Icons.star : Icons.star_border,
              color: dipilih ? Colors.amber : Colors.grey[400],
              size: 24,
            ),
          ),
        );
      }),
    );
  }
}