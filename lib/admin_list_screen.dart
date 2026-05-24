import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hugeicons/hugeicons.dart';

import 'sahabat_satwa_model.dart';
import 'detail_sahabat_satwa_screen.dart';
import 'tambah_sahabat_satwa_screen.dart';
import 'edit_sahabat_satwa_screen.dart';
import 'app_theme.dart';

class AdminListScreen extends StatelessWidget {
  const AdminListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,

      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('destination')
              .snapshots(),

          builder: (context, snapshot) {
            // Saat data masih loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              );
            }

            // Jika terjadi error saat mengambil data
            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  'Gagal memuat data destinasi.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              );
            }

            final docs = snapshot.data?.docs ?? [];

            // Menggunakan for loop (modul)
            List<SahabatSatwa> zoos = [];

            for (int i = 0; i < docs.length; i++) {
              zoos.add(SahabatSatwa.fromDocument(docs[i]));
            }

            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 20),
              itemCount: zoos.length + 1,
              itemBuilder: (context, index) {
                // Index 0 digunakan untuk kotak total data di bagian atas
                if (index == 0) {
                  return _AdminHeader(totalZoo: zoos.length);
                }

                // Karena index 0 adalah header, data zoo dimulai dari index - 1
                int zooIndex = index - 1;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _AdminCard(zoo: zoos[zooIndex]),
                );
              },
            );
          },
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) {
                return const TambahSahabatSatwaScreen();
              },
            ),
          );
        },
        child: HugeIcon(
          icon: HugeIcons.strokeRoundedPlusSign,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}

class _AdminHeader extends StatelessWidget {
  final int totalZoo;

  const _AdminHeader({
    required this.totalZoo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Bagian kiri: total kebun binatang
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Kebun Binatang',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textMuted,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '$totalZoo',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),

            // Tombol tambah data
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) {
                      return const TambahSahabatSatwaScreen();
                    },
                  ),
                );
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedPlusSign,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  final SahabatSatwa zoo;

  const _AdminCard({
    required this.zoo,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) {
              return DetailSahabatSatwaScreen(data: zoo);
            },
          ),
        );
      },

      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian gambar destinasi
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: _buildGambarZoo(),
                ),

                // Label provinsi
                if (zoo.provinsi.isNotEmpty)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryDark.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        zoo.provinsi,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Nama destinasi
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
              child: Text(
                zoo.nama_zoo,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ),

            // Alamat destinasi
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
              child: Row(
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedLocation01,
                    color: AppTheme.textMuted,
                    size: 13,
                  ),

                  const SizedBox(width: 4),

                  Expanded(
                    child: Text(
                      zoo.alamat,
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
            ),

            // Tombol edit dan hapus
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) {
                              return EditSahabatSatwaScreen(data: zoo);
                            },
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: AppTheme.primary,
                        ),
                        foregroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text('Edit'),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _konfirmasiHapus(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text('Hapus'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk menampilkan gambar zoo
  Widget _buildGambarZoo() {
    if (zoo.foto_url.isNotEmpty) {
      return Image.network(
        zoo.foto_url,
        height: 160,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _placeholder();
        },
      );
    } else {
      return _placeholder();
    }
  }

  // Dialog konfirmasi sebelum menghapus data
  Future<void> _konfirmasiHapus(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Hapus Data'),
          content: const Text('Yakin ingin menghapus?'),
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

    if (confirm == true) {
      await SahabatSatwa.deleteData(zoo.id_zoo);
    }
  }

  Widget _placeholder() {
    return Container(
      height: 160,
      width: double.infinity,
      color: Colors.grey[300],
      child: HugeIcon(
        icon: HugeIcons.strokeRoundedImage01,
        color: Colors.grey,
        size: 40,
      ),
    );
  }
}