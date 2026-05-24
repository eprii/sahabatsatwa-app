import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hugeicons/hugeicons.dart';
import 'sahabat_satwa_model.dart';
import 'detail_sahabat_satwa_screen.dart';
import 'app_theme.dart';

class SahabatSatwaListScreen extends StatelessWidget {
  const SahabatSatwaListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(

        child: StreamBuilder<DocumentSnapshot>(
          stream: uid != null
              ? FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .snapshots()
              : const Stream.empty(),
          builder: (context, userSnap) {
            final role = userSnap.data?.exists == true
                ? (userSnap.data!.data()
                        as Map<String, dynamic>)['role'] ??
                    'user'
                : 'user';

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('destination')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildSkeletonLoader();
                }

                final docs = snapshot.data?.docs ?? [];
                final zoos =
                    docs.map((d) => SahabatSatwa.fromDocument(d)).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── TOP BAR ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                'assets/icon/sahabatsatwa_logo.png',
                                width: 36,
                                height: 36,
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'SahabatSatwa',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${zoos.length} destinasi',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: zoos.isEmpty
                          ? const Center(
                              child: Text('Belum ada destinasi',
                                  style:
                                      TextStyle(color: Colors.white70)))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              itemCount: zoos.length + 1,
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFF3D5C33),
                                            Color(0xFF6B8C5A),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Temukan Kebun\nBinatang Favoritmu!',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              height: 1.3,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                final zoo = zoos[index - 1];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 14),
                                  color: AppTheme.cardBg,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Foto
                                      Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                    top: Radius.circular(16)),
                                            child: zoo.foto_url.isNotEmpty
                                                ? Image.network(
                                                    zoo.foto_url,
                                                    height: 160,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (_, __, ___) =>
                                                        _placeholder(),
                                                  )
                                                : _placeholder(),
                                          ),
                                          if (zoo.provinsi.isNotEmpty)
                                            Positioned(
                                              top: 10,
                                              right: 10,
                                              child: Container(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: 10,
                                                    vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.primaryDark
                                                      .withOpacity(0.85),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20),
                                                ),
                                                child: Text(
                                                  zoo.provinsi,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),

                                      // ListTile
                                      ListTile(
                                        title: Text(
                                          zoo.nama_zoo,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: AppTheme.textDark,
                                          ),
                                        ),
                                        subtitle: Row(
                                          children: [
                                            HugeIcon(
                                              icon: HugeIcons
                                                  .strokeRoundedLocation01,
                                              color: AppTheme.textMuted,
                                              size: 13,
                                            ),
                                            const SizedBox(width: 2),
                                            Expanded(
                                              child: Text(
                                                zoo.alamat.isNotEmpty
                                                    ? zoo.alamat
                                                    : '-',
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        AppTheme.textMuted),
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        // ✅ Bookmark hanya untuk user, admin SizedBox
                                        trailing: role == 'admin'
                                            ? const SizedBox()
                                            : StreamBuilder<QuerySnapshot>(
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .collection('favourites')
                                                    .where('id_user',
                                                        isEqualTo: uid)
                                                    .where('id_zoo',
                                                        isEqualTo: zoo.id_zoo)
                                                    .snapshots(),
                                                builder:
                                                    (context, favSnap) {
                                                  final isFav =
                                                      favSnap.hasData &&
                                                          favSnap.data!.docs
                                                              .isNotEmpty;
                                                  return GestureDetector(
                                                    onTap: () async {
                                                      if (uid == null) return;
                                                      final favRef =
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'favourites');
                                                      final existing =
                                                          await favRef
                                                              .where('id_user',
                                                                  isEqualTo:
                                                                      uid)
                                                              .where('id_zoo',
                                                                  isEqualTo:
                                                                      zoo.id_zoo)
                                                              .get();
                                                      if (existing
                                                          .docs.isNotEmpty) {
                                                        await favRef
                                                            .doc(existing
                                                                .docs.first.id)
                                                            .delete();
                                                      } else {
                                                        await favRef.add({
                                                          'id_user': uid,
                                                          'id_zoo': zoo.id_zoo,
                                                          'saved_at': FieldValue
                                                              .serverTimestamp(),
                                                          'created_at':
                                                              DateTime.now()
                                                                  .toString(),
                                                        });
                                                      }
                                                    },
                                                    child: HugeIcon(
                                                      icon: isFav
                                                          ? HugeIcons
                                                              .strokeRoundedBookmarkCheck02
                                                          : HugeIcons
                                                              .strokeRoundedBookmarkAdd01,
                                                      color: isFav
                                                          ? AppTheme.primary
                                                          : AppTheme.textMuted,
                                                      size: 22,
                                                    ),
                                                  );
                                                },
                                              ),
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                DetailSahabatSatwaScreen(
                                                    data: zoo),
                                          ),
                                        ),
                                      ),

                                      // Tombol Lihat Detail
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            16, 0, 16, 14),
                                        child: SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    DetailSahabatSatwaScreen(
                                                        data: zoo),
                                              ),
                                            ),
                                            child:
                                                const Text('Lihat Detail'),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      height: 160,
      width: double.infinity,
      color: Colors.grey[300],
      child: HugeIcon(
        icon: HugeIcons.strokeRoundedImage01,
        color: Colors.grey,
        size: 48,
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── TOP BAR ──
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/icon/sahabatsatwa_logo.png',
                    width: 36,
                    height: 36,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'SahabatSatwa',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '- destinasi',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        // SKELETON ITEMS
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: 6,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF3D5C33),
                          Color(0xFF6B8C5A),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Temukan Kebun\nBinatang Favoritmu!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                );
              }
              return _buildSkeletonCard();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      color: AppTheme.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Skeleton Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              height: 160,
              width: double.infinity,
              color: const Color.fromARGB(255, 213, 238, 180),
              child: _buildShimmer(),
            ),
          ),
          // Skeleton Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 18,
                  width: double.infinity * 0.7,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: _buildShimmer(),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 14,
                  width: double.infinity * 0.9,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: _buildShimmer(),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: _buildShimmer(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color.fromARGB(255, 136, 151, 128),
            const Color.fromARGB(255, 130, 160, 120),
            const Color.fromARGB(255, 112, 138, 99),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}

  

  // Line 1-7: import digunakan untuk memanggil library Flutter, Firebase, icon, model data, halaman detail, dan file tema agar bisa dipakai di halaman ini.

// Line 9-10: membuat class halaman SahabatSatwaListScreen. extends StatelessWidget dipilih karena halaman tidak memakai setState, data berubah dari Firebase StreamBuilder.

// Line 12-13: @override berarti mengganti method bawaan StatelessWidget. build() adalah fungsi utama untuk membentuk tampilan halaman.

// Line 14: final uid mengambil ID user yang sedang login dari FirebaseAuth. final dipakai karena uid tidak diubah lagi, ?. dipakai agar aman kalau currentUser null.

// Line 16-18: Scaffold menjadi kerangka utama halaman, backgroundColor mengambil warna dari AppTheme, SafeArea menjaga tampilan agar tidak tertutup status bar/notch HP.

// Line 20-27: StreamBuilder<DocumentSnapshot> membaca satu dokumen user secara real-time. uid != null dicek dulu; jika ada, ambil data user, jika tidak, pakai Stream.empty() agar tidak error.

// Line 28-32: role mengambil data role user dari Firestore. ?. dan ?? dipakai untuk keamanan null; jika role kosong, default-nya menjadi 'user'.

// Line 34-37: StreamBuilder<QuerySnapshot> membaca banyak dokumen destinasi dari collection destination. QuerySnapshot dipakai karena datanya lebih dari satu, .snapshots() agar real-time.

// Line 38-41: builder menerima hasil data destinasi. context adalah posisi widget di Flutter, snapshot adalah hasil data Firestore. Jika masih loading, tampilkan skeleton UI.

// Line 43: final docs = snapshot.data?.docs ?? []; mengambil daftar dokumen destinasi. final karena tidak diubah, ?. aman dari null, ?? [] memberi list kosong jika data belum ada.

// Line 44-45: docs.map() mengubah dokumen Firebase menjadi object SahabatSatwa. fromDocument() dipakai agar data lebih mudah dipanggil, lalu .toList() mengubah hasilnya menjadi List.

// Line 47-49: Column menyusun tampilan secara vertikal dari atas ke bawah. crossAxisAlignment.start membuat isi rata kiri.

// Line 51-53: Padding memberi jarak luar pada top bar. EdgeInsets.fromLTRB mengatur jarak kiri, atas, kanan, bawah. Row menyusun isi secara horizontal.

// Line 54-55: mainAxisAlignment.spaceBetween memberi jarak antara sisi kiri dan kanan, agar logo/nama ada di kiri dan jumlah destinasi ada di kanan.

// Line 56-73: Row bagian kiri menampilkan logo dan teks SahabatSatwa. Image.asset mengambil gambar dari folder assets, Text menampilkan nama aplikasi.

// Line 74-86: Container menampilkan jumlah destinasi. ${zoos.length} adalah string interpolation untuk memasukkan jumlah data ke dalam teks.

// Line 91-97: Expanded membuat list mengisi sisa layar. zoos.isEmpty memakai ternary; jika kosong tampilkan pesan, jika ada data tampilkan ListView.builder.

// Line 97-101: ListView.builder membuat list scroll yang efisien. itemCount zoos.length + 1 karena index pertama dipakai untuk banner, bukan data destinasi.

// Line 102-137: if index == 0 menampilkan banner paling atas. index 0 dipakai khusus untuk banner agar tampil sebelum daftar destinasi.

// Line 106-118: Container banner dibuat full width dengan double.infinity, diberi padding, gradient, dan borderRadius agar tampil menarik.

// Line 119-134: Column di dalam banner menyusun teks ke bawah. \n pada teks berarti ganti baris.

// Line 139: final zoo = zoos[index - 1]; mengambil data destinasi. index - 1 dipakai karena index 0 sudah digunakan untuk banner.

// Line 140-147: Card membuat kotak untuk setiap destinasi. margin memberi jarak, color mengambil tema, borderRadius membuat sudut melengkung, elevation memberi bayangan.

// Line 147-150: Column di dalam Card menyusun isi kartu dari atas ke bawah, seperti foto, nama, alamat, bookmark, dan tombol detail.

// Line 152-153: Stack dipakai untuk menumpuk widget, karena label provinsi akan diletakkan di atas foto destinasi.

// Line 154-168: ClipRRect membuat sudut foto melengkung. Jika foto_url ada, tampilkan Image.network; jika kosong atau error, tampilkan _placeholder().

// Line 164-165: errorBuilder menangani gambar yang gagal dimuat. Parameter _, __, ___ artinya parameter wajib ada tapi tidak digunakan.

// Line 169-195: if zoo.provinsi.isNotEmpty menampilkan label provinsi hanya jika datanya ada. Positioned menaruh label di kanan atas foto.

// Line 179-183: withOpacity(0.85) membuat warna label agak transparan, borderRadius.circular(20) membuat label berbentuk rounded.

// Line 200-208: ListTile digunakan untuk menampilkan informasi utama destinasi secara rapi. title menampilkan nama kebun binatang dari zoo.nama_zoo.

// Line 209-233: subtitle memakai Row untuk menampilkan icon lokasi dan alamat sejajar. Expanded mencegah overflow, maxLines dan ellipsis memotong alamat yang terlalu panjang.

// Line 220-222: ternary mengecek alamat. Jika alamat ada, tampilkan alamat; jika kosong, tampilkan tanda "-".

// Line 235-237: trailing mengatur bagian kanan ListTile. Jika role admin, tampilkan SizedBox kosong; jika user biasa, tampilkan fitur bookmark.

// Line 237-245: StreamBuilder<QuerySnapshot> mengecek data favorit dari collection favourites. where dipakai untuk mencari favorit berdasarkan id_user dan id_zoo.

// Line 248-251: final isFav mengecek apakah destinasi sudah difavoritkan. hasData memastikan data ada, docs.isNotEmpty berarti data favorit ditemukan.

// Line 252-254: GestureDetector membuat icon bookmark bisa ditekan. onTap async dipakai karena proses Firebase membutuhkan waktu.

// Line 254: if uid == null return; menghentikan proses jika user belum login, agar data favorit tidak disimpan tanpa ID user.

// Line 255-259: favRef adalah referensi ke collection favourites. final dipakai karena referensi ini tidak diubah lagi.

// Line 260-268: await favRef.where(...).get() mengecek apakah data favorit sudah ada. await dipakai untuk menunggu proses Firebase selesai.

// Line 269-275: jika existing.docs.isNotEmpty, artinya favorit sudah ada, maka dokumen favorit dihapus dengan delete().

// Line 275-284: else berarti jika belum favorit, tambahkan data baru ke Firestore dengan add(). Data yang disimpan adalah id_user, id_zoo, saved_at, dan created_at.

// Line 279-280: FieldValue.serverTimestamp() menyimpan waktu dari server Firebase agar waktu lebih akurat.

// Line 281-283: DateTime.now().toString() menyimpan waktu dari perangkat user dalam bentuk teks.

// Line 287-297: HugeIcon menampilkan icon bookmark. Ternary isFav menentukan icon dan warna, apakah sudah favorit atau belum.

// Line 301-308: onTap pada ListTile membuka halaman detail dengan Navigator.push. data: zoo mengirim data destinasi yang dipilih ke halaman detail.

// Line 312-330: Padding dan SizedBox membungkus tombol Lihat Detail. ElevatedButton membuka halaman detail yang sama saat tombol ditekan.

// Line 347-358: _placeholder() adalah function untuk menampilkan gambar cadangan jika foto destinasi kosong atau gagal dimuat.

// Line 360-363: _buildSkeletonLoader() membuat tampilan loading sementara. Column dipakai karena susunannya dari atas ke bawah.

// Line 365-401: bagian ini membuat top bar versi loading, tampilannya mirip top bar asli tetapi jumlah destinasi masih ditampilkan sebagai "- destinasi".

// Line 403-407: Expanded dan ListView.builder membuat daftar skeleton loading. itemCount 6 berarti menampilkan 6 item contoh saat data masih loading.

// Line 408-443: jika index 0 tampilkan banner skeleton, selain itu tampilkan _buildSkeletonCard() sebagai kartu loading.

// Line 451-515: _buildSkeletonCard() membuat kartu loading yang bentuknya mirip kartu destinasi asli, berisi area gambar, teks, dan tombol palsu.

// Line 463-470: ClipRRect dan Container membuat area gambar skeleton. _buildShimmer() dipakai sebagai efek gradasi loading.

// Line 473-510: Padding dan Column membuat isi skeleton card seperti garis judul, garis alamat, dan tombol palsu.

// Line 517-532: _buildShimmer() membuat efek gradasi pada skeleton UI menggunakan LinearGradient dari kiri ke kanan.