import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'sahabat_satwa_model.dart';
import 'detail_sahabat_satwa_screen.dart';
import 'app_theme.dart';

// Halaman ini menampilkan daftar destinasi yang sudah difavoritkan oleh user.
// Data favorit diambil dari collection "favourites".
class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengambil UID user yang sedang login.
    // Jika null, berarti user belum login.
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppTheme.background,

      appBar: AppBar(
        title: const Text(
          'Favoritku',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.normal,
          ),
        ),
        elevation: 0,
      ),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              // Jika user belum login, tampilkan pesan login.
              child: uid == null
                  ? _buildBelumLogin()
                  : _buildDaftarFavorit(uid),
            ),
          ],
        ),
      ),
    );
  }

  // Widget ini tampil jika user belum login.
  Widget _buildBelumLogin() {
    return const Center(
      child: Text(
        'Login dulu untuk melihat favorit!',
        style: TextStyle(
          color: Colors.white70,
        ),
      ),
    );
  }

  // Widget ini mengambil data favorit dari Firestore.
  Widget _buildDaftarFavorit(String uid) {
    return StreamBuilder<QuerySnapshot>(
      // StreamBuilder dipakai agar daftar favorit berubah secara real-time.
      // Jika user menghapus favorit, data langsung update tanpa refresh manual.
      stream: FirebaseFirestore.instance
          .collection('favourites')
          .where('id_user', isEqualTo: uid)
          .snapshots(),

      builder: (context, snapshot) {
        // Kondisi saat data masih dimuat.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        }

        // Kondisi jika terjadi error saat mengambil data favorit.
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Gagal memuat data favorit.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          );
        }

        // Kondisi jika user belum punya favorit.
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildFavoritKosong();
        }

        // favDocs berisi dokumen dari collection favourites.
        final favDocs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          itemCount: favDocs.length,

          itemBuilder: (context, index) {
            // Mengambil data favorit sebagai Map.
            final favData = favDocs[index].data() as Map<String, dynamic>;

            // id_zoo digunakan untuk mengambil detail destinasi dari collection destination.
            final idZoo = favData['id_zoo'] ?? '';

            // id dokumen favorit digunakan saat user ingin menghapus favorit.
            final idFavourit = favDocs[index].id;

            // Jika id_zoo kosong, item tidak ditampilkan.
            if (idZoo.toString().isEmpty) {
              return const SizedBox();
            }

            // FutureBuilder digunakan untuk mengambil data destinasi berdasarkan id_zoo.
            // Karena collection favourites hanya menyimpan id_zoo, detail destinasi
            // harus diambil lagi dari collection destination.
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('destination')
                  .doc(idZoo)
                  .get(),

              builder: (context, zooSnap) {
                // Saat data destinasi masih dimuat, tampilkan tempat kosong.
                if (zooSnap.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 80,
                  );
                }

                // Jika gagal mengambil data destinasi, item tidak ditampilkan.
                if (zooSnap.hasError) {
                  return const SizedBox();
                }

                // Jika data belum ada atau dokumen destinasi sudah dihapus,
                // maka item favorit tidak ditampilkan.
                if (!zooSnap.hasData || !zooSnap.data!.exists) {
                  return const SizedBox();
                }

                // Mengubah data Firestore menjadi object SahabatSatwa.
                final zoo = SahabatSatwa.fromDocument(
                  zooSnap.data!,
                );

                return _FavouriteCard(
                  zoo: zoo,
                  idFavourit: idFavourit,
                );
              },
            );
          },
        );
      },
    );
  }

  // Widget ini tampil jika daftar favorit masih kosong.
  Widget _buildFavoritKosong() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            color: Colors.white38,
            size: 64,
          ),

          SizedBox(height: 12),

          Text(
            'Belum ada favorit',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),

          SizedBox(height: 4),

          Text(
            'Simpan destinasi favoritmu',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white38,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget card untuk menampilkan satu destinasi favorit.
class _FavouriteCard extends StatelessWidget {
  final SahabatSatwa zoo;
  final String idFavourit;

  const _FavouriteCard({
    required this.zoo,
    required this.idFavourit,
  });

  // Fungsi untuk menghapus destinasi dari collection favourites.
  Future<void> _removeFavourite(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('favourites')
        .doc(idFavourit)
        .delete();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dihapus dari favorit'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Saat card ditekan, user diarahkan ke halaman detail destinasi.
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return DetailSahabatSatwaScreen(data: zoo);
            },
          ),
        );
      },

      child: Container(
        margin: const EdgeInsets.only(
          bottom: 12,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
            ),
          ],
        ),

        child: Row(
          children: [
            // Thumbnail gambar destinasi.
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: zoo.foto_url.isNotEmpty
                  ? Image.network(
                      zoo.foto_url,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,

                      // errorBuilder dipakai jika gambar gagal dimuat dari internet.
                      errorBuilder: (context, error, stackTrace) {
                        return _placeholder();
                      },
                    )
                  : _placeholder(),
            ),

            const SizedBox(width: 12),

            // Bagian informasi nama dan alamat destinasi.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    zoo.nama_zoo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppTheme.textDark,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: AppTheme.textMuted,
                      ),

                      const SizedBox(width: 2),

                      Expanded(
                        child: Text(
                          zoo.alamat.isNotEmpty ? zoo.alamat : '-',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tombol untuk menghapus destinasi dari favorit.
            IconButton(
              icon: const Icon(
                Icons.bookmark,
                color: AppTheme.primary,
                size: 22,
              ),
              onPressed: () {
                _removeFavourite(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Placeholder ditampilkan jika foto kosong atau gagal dimuat.
  Widget _placeholder() {
    return Container(
      width: 70,
      height: 70,
      color: Colors.grey[300],
      child: const Icon(
        Icons.photo,
        color: Colors.grey,
      ),
    );
  }
}