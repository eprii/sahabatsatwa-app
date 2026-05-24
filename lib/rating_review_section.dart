import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'app_theme.dart';
import 'all_reviews_screen.dart';
import 'app_notification.dart';
import 'package:hugeicons/hugeicons.dart';

// Widget ini menampilkan bintang rata-rata dan memungkinkan user memberi rating.
// Cara kerja penyimpanan rating:
// Dokumen zoo_rating menyimpan field "ratings_map" berupa Map,
// contoh: { "uid_userA": 4, "uid_userB": 5, "uid_userC": 3 }
// Rata-rata dihitung langsung dari semua nilai di dalam Map tersebut.

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
    AppNotification.showInfo(
      context,
      'Login dulu untuk memberi rating!',
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

  // Fungsi: kirim review ke Firestore
  Future<void> _kirimReview() async {
    // Mengambil UID user yang sedang login.
    final uid = FirebaseAuth.instance.currentUser?.uid;

    // Mengambil isi input review dan menghapus spasi awal/akhir.
    final teks = _reviewCtrl.text.trim();

    // Jika user belum login, review tidak boleh dikirim.
    if (uid == null) {
      AppNotification.showInfo(
        context,
        'Login dulu untuk mengirim review!',
      );
      return;
    }

    // Jika input review kosong, tampilkan notifikasi error.
    if (teks.isEmpty) {
      AppNotification.showError(
        context,
        'Review tidak boleh kosong!',
      );
      return;
    }

    // Mulai loading saat proses kirim review berjalan.
    setState(() {
      _isSubmitting = true;
    });

    try {
      // Mengambil data user dari collection users.
      // Data ini dipakai untuk menyimpan nama reviewer dan username.
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      // Jika data user tidak ditemukan, proses dihentikan.
      if (!userDoc.exists) {
        if (mounted) {
          AppNotification.showError(
            context,
            'Data user tidak ditemukan.',
          );
        }
        return;
      }

      // Mengubah data user dari Firestore menjadi Map.
      final userData = userDoc.data() as Map<String, dynamic>;

      // Mengambil nama depan dan username user.
      final namaReviewer = userData['nama_depan'] ?? 'Pengguna';
      final username = userData['username'] ?? '';

      // Menyimpan review ke collection zoo_review.
      await FirebaseFirestore.instance.collection('zoo_review').add({
        'id_zoo': widget.idZoo,
        'id_user': uid,
        'nama_reviewer': namaReviewer,
        'username': username,
        'komentar': teks,
        'tanggal_review': FieldValue.serverTimestamp(),
      });

      // Mengosongkan input setelah review berhasil dikirim.
      _reviewCtrl.clear();

      // Menampilkan notifikasi sukses.
      if (mounted) {
        AppNotification.showSuccess(
          context,
          'Review berhasil dikirim!',
        );
      }
    } catch (e) {
      // Jika proses kirim review gagal, tampilkan notifikasi error.
      if (mounted) {
        AppNotification.showError(
          context,
          'Gagal mengirim review.',
        );
      }
    } finally {
      // Loading dimatikan kembali setelah proses selesai.
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
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

// ══════════════════════════════════════════════════════════════════════════════
// REVIEW CARD
// Widget untuk menampilkan satu review.
// Menampilkan nama, username, tanggal, rating user, komentar,
// dan tombol hapus jika review tersebut milik user yang sedang login.
// ══════════════════════════════════════════════════════════════════════════════

class ReviewCard extends StatelessWidget {
  final QueryDocumentSnapshot doc; // Dokumen review dari Firestore

  // ratingsMap berisi data rating dari collection zoo_rating.
  // Bentuknya: { uidUser: jumlahRating }
  final Map<String, dynamic> ratingsMap;

  // showActions digunakan untuk menentukan apakah tombol titik tiga ditampilkan.
  // Di halaman all_reviews_screen.dart nanti dibuat true.
  // Di preview review halaman detail bisa tetap false.
  final bool showActions;

  const ReviewCard({
    super.key,
    required this.doc,
    this.ratingsMap = const {},
    this.showActions = false,
  });

  // Helper untuk format Timestamp menjadi teks tanggal.
  String _formatTanggal(Timestamp? timestamp) {
    if (timestamp == null) {
      return '';
    }

    // Mengubah Timestamp Firestore menjadi DateTime Dart.
    final dt = timestamp.toDate();

    // Nama bulan dalam Bahasa Indonesia.
    final bulan = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    // Membuat format jam dua digit.
    final jam = dt.hour.toString().padLeft(2, '0');

    // Membuat format menit dua digit.
    final menit = dt.minute.toString().padLeft(2, '0');

    // Contoh hasil: 13:38, 23 Mei 2026
    return '$jam:$menit, ${dt.day} ${bulan[dt.month]} ${dt.year}';
  }

  // Fungsi untuk menampilkan dialog konfirmasi sebelum menghapus review.
  Future<bool> _konfirmasiHapus(BuildContext context) async {
    final hasil = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Review'),
          content: const Text(
            'Yakin ingin menghapus review ini?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                'Hapus',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    // Jika hasil null, anggap user tidak jadi menghapus.
    return hasil ?? false;
  }

  // Fungsi untuk menghapus review dari Firestore.
  Future<void> _hapusReview(BuildContext context) async {
    // Ambil data review dari dokumen Firestore.
    final data = doc.data() as Map<String, dynamic>;

    // Ambil uid user yang sedang login.
    final uid = FirebaseAuth.instance.currentUser?.uid;

    // Ambil id_user dari review.
    final idUserReview = (data['id_user'] ?? '').toString();

    // Cek apakah user yang login adalah pemilik review.
    if (uid == null || uid != idUserReview) {
      AppNotification.showError(
        context,
        'Kamu hanya bisa menghapus review milikmu sendiri.',
      );
      return;
    }

    // Tampilkan dialog konfirmasi sebelum benar-benar menghapus.
    final bolehHapus = await _konfirmasiHapus(context);

    if (!bolehHapus) {
      return;
    }

    try {
      // Menghapus dokumen review dari collection zoo_review.
      await FirebaseFirestore.instance
          .collection('zoo_review')
          .doc(doc.id)
          .delete();

      if (context.mounted) {
        AppNotification.showSuccess(
          context,
          'Review berhasil dihapus.',
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppNotification.showError(
          context,
          'Gagal menghapus review.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil data dari dokumen review.
    final data = doc.data() as Map<String, dynamic>;

    final nama = data['nama_reviewer'] ?? 'Pengguna';
    final username = data['username'] ?? '';
    final komentar = data['komentar'] ?? '';
    final tanggal = _formatTanggal(data['tanggal_review'] as Timestamp?);

    // id_user digunakan untuk mencocokkan review dengan rating user.
    final idUserReview = (data['id_user'] ?? '').toString();

    // uid user yang sedang login.
    final uidLogin = FirebaseAuth.instance.currentUser?.uid;

    // User hanya boleh menghapus review miliknya sendiri.
    final bool bolehTampilkanAksi =
        showActions && uidLogin != null && uidLogin == idUserReview;

    // Mengambil rating reviewer dari ratingsMap.
    int ratingReviewer = 0;

    if (idUserReview.isNotEmpty && ratingsMap.containsKey(idUserReview)) {
      ratingReviewer = (ratingsMap[idUserReview] as num).toInt();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Baris atas: nama + username di kiri, titik tiga di kanan.
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
                      text: nama.toString(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                    if (username.toString().isNotEmpty)
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

            if (bolehTampilkanAksi)
              SizedBox(
                width: 24,
                height: 24,
                child: PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  tooltip: 'Opsi review',
                  offset: const Offset(0, 24),
                  child: const Icon(
                    Icons.more_vert,
                    size: 18,
                    color: AppTheme.textMuted,
                  ),
                  onSelected: (value) {
                    if (value == 'hapus') {
                      _hapusReview(context);
                    }
                  },
                  itemBuilder: (context) {
                    return [
                      const PopupMenuItem<String>(
                        value: 'hapus',
                        child: Text('Hapus review'),
                      ),
                    ];
                  },
                ),
              ),
          ],
        ),

        const SizedBox(height: 2),

        // Tanggal review.
        Text(
          tanggal,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textMuted,
          ),
        ),

        // Rating user dalam bentuk 5 bintang.
        if (ratingReviewer > 0) ...[
          const SizedBox(height: 4),
          _ReviewStars(rating: ratingReviewer),
        ],

        const SizedBox(height: 6),

        // Isi komentar.
        Text(
          komentar.toString(),
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textDark,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

// Widget untuk menampilkan rating review dalam bentuk 5 bintang.
// Jika rating = 3, maka 3 bintang terisi dan 2 bintang kosong.
class _ReviewStars extends StatelessWidget {
  final int rating;

  const _ReviewStars({
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,

      // List.generate membuat 5 icon bintang.
      children: List.generate(5, (index) {
        bool terisi = index < rating;

        return Icon(
          terisi ? Icons.star : Icons.star_border,
          size: 14,
          color: Colors.amber,
        );
      }),
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

              AppNotification.showError(
                // ignore: use_build_context_synchronously
                context,
                'Gagal mengirim rating',
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