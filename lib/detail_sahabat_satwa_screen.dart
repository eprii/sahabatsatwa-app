import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hugeicons/hugeicons.dart';

import 'sahabat_satwa_model.dart';
import 'edit_sahabat_satwa_screen.dart';
import 'app_theme.dart';
import 'rating_review_section.dart'; // Berisi RatingSection dan ReviewSection

// Halaman detail destinasi.
// Halaman ini menampilkan informasi lengkap satu kebun binatang.
class DetailSahabatSatwaScreen extends StatefulWidget {
  final SahabatSatwa data;

  const DetailSahabatSatwaScreen({
    super.key,
    required this.data,
  });

  @override
  State<DetailSahabatSatwaScreen> createState() =>
      _DetailSahabatSatwaScreenState();
}

class _DetailSahabatSatwaScreenState extends State<DetailSahabatSatwaScreen> {
  late final Future<String> _roleFuture;

  @override
  void initState() {
    super.initState();

    // Role user/admin diambil sekali saat halaman dibuka.
    // Ini mencegah request Firestore berulang saat widget rebuild.
    _roleFuture = _ambilRoleUser();
  }

  // Fungsi untuk mengambil role user dari collection users.
  // Jika belum login, user dianggap sebagai guest.
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

    final dataUser = userDoc.data() as Map<String, dynamic>?;

    return dataUser?['role'] ?? 'user';
  }

  // Fungsi untuk membuka Google Maps dari link yang tersimpan di Firestore.
  Future<void> _bukaMaps(String url) async {
    // Jika link kosong, fungsi langsung dihentikan.
    if (url.isEmpty) {
      return;
    }

    final uri = Uri.parse(url);

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  // Fungsi untuk menambah atau menghapus destinasi dari favorit.
  Future<void> _toggleFavourite(BuildContext context, String idZoo) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    // Jika belum login, user tidak boleh menyimpan favorit.
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login dulu untuk menyimpan favorit!')),
      );
      return;
    }

    final favRef = FirebaseFirestore.instance.collection('favourites');

    // Mengecek apakah destinasi ini sudah difavoritkan oleh user.
    final existing = await favRef
        .where('id_user', isEqualTo: uid)
        .where('id_zoo', isEqualTo: idZoo)
        .get();

    if (existing.docs.isNotEmpty) {
      // Jika sudah ada, berarti user ingin menghapus dari favorit.
      await favRef.doc(existing.docs.first.id).delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dihapus dari favorit')),
        );
      }
    } else {
      // Jika belum ada, berarti user ingin menambahkan ke favorit.
      await favRef.add({
        'id_user': uid,
        'id_zoo': idZoo,
        'saved_at': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ditambahkan ke favorit!'),
            backgroundColor: AppTheme.primary,
          ),
        );
      }
    }
  }

  // Fungsi untuk like atau unlike destinasi.
  Future<void> _toggleLike(
    BuildContext context,
    String idZoo,
    List likedBy,
  ) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    // Jika belum login, user tidak boleh like.
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login dulu untuk menyukai destinasi!')),
      );
      return;
    }

    final ref = FirebaseFirestore.instance
        .collection('destination')
        .doc(idZoo);

    if (likedBy.contains(uid)) {
      // Jika UID user sudah ada di liked_by, maka unlike.
      await ref.update({
        'liked_by': FieldValue.arrayRemove([uid]),
        'likes_count': FieldValue.increment(-1),
      });
    } else {
      // Jika UID user belum ada di liked_by, maka like.
      await ref.update({
        'liked_by': FieldValue.arrayUnion([uid]),
        'likes_count': FieldValue.increment(1),
      });
    }
  }

  // Fungsi untuk menyalin alamat ke clipboard.

  // Fungsi untuk menyalin link Google Maps ke clipboard.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,

      // StreamBuilder dipakai agar data destinasi update otomatis
      // jika admin mengubah data di Firestore.
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('destination')
            .doc(widget.data.id_zoo)
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

          // Kondisi jika ada error saat mengambil data.
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Gagal memuat detail destinasi.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            );
          }

          // Kondisi jika dokumen tidak ditemukan.
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                'Data destinasi tidak ditemukan.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            );
          }

          // Mengubah data Firestore menjadi object SahabatSatwa.
          final zoo = SahabatSatwa.fromDocument(snapshot.data!);

          // Mengambil koordinat dari model.
          // Jika koordinat valid, akan digunakan untuk menampilkan map.
          final coords = zoo.parsedKoordinat;

          return CustomScrollView(
            slivers: [
              // SliverAppBar digunakan karena halaman detail punya header gambar besar.
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: AppTheme.primaryDark,

                // Tombol kembali.
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: CircleAvatar(
                    backgroundColor: Colors.black38,
                    child: IconButton(
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowLeft01,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),

                // Tombol edit hanya tampil jika role adalah admin.
                actions: [
                  FutureBuilder<String>(
                    future: _roleFuture,
                    builder: (context, userSnap) {
                      if (userSnap.connectionState == ConnectionState.waiting) {
                        return const SizedBox();
                      }

                      if (userSnap.hasError) {
                        return const SizedBox();
                      }

                      final role = userSnap.data ?? 'user';

                      if (role != 'admin') {
                        return const SizedBox();
                      }

                      return Padding(
                        padding: const EdgeInsets.all(8),
                        child: CircleAvatar(
                          backgroundColor: Colors.black38,
                          child: IconButton(
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedPencilEdit01,
                              color: Colors.white,
                              size: 18,
                            ),
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
                          ),
                        ),
                      );
                    },
                  ),
                ],

                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Gambar utama destinasi.
                      // errorBuilder dipakai jika gambar gagal dimuat.
                      zoo.foto_url.isNotEmpty
                          ? Image.network(
                              zoo.foto_url,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppTheme.primaryDark,
                                );
                              },
                            )
                          : Container(
                              color: AppTheme.primaryDark,
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedImage01,
                                color: Colors.white30,
                                size: 60,
                              ),
                            ),

                      // Gradient agar tulisan nama destinasi tetap terbaca.
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black54,
                            ],
                          ),
                        ),
                      ),

                      // Nama dan alamat singkat di atas gambar.
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              zoo.nama_zoo,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black45,
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 4),

                            Row(
                              children: [
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedLocation01,
                                  color: Colors.white70,
                                  size: 14,
                                ),

                                const SizedBox(width: 4),

                                Expanded(
                                  child: Text(
                                    zoo.alamat.isNotEmpty ? zoo.alamat : '-',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
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
                    ],
                  ),
                ),
              ),

              // SliverToBoxAdapter dipakai agar widget biasa seperti Column
              // bisa masuk ke dalam CustomScrollView.
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Menampilkan rating rata-rata dan rating user.
                      RatingSection(idZoo: zoo.id_zoo),

                      const SizedBox(height: 12),

                      // Bar untuk like dan favorit.
                      Builder(
                        builder: (context) {
                          final uid = FirebaseAuth.instance.currentUser?.uid;
                          final rawData =
                              snapshot.data!.data() as Map<String, dynamic>;

                          // liked_by adalah list UID user yang sudah like.
                          final likedBy = List.from(
                            rawData['liked_by'] ?? [],
                          );

                          final likesCount = rawData['likes_count'] ?? 0;

                          // Cek apakah user saat ini sudah like.
                          final isLiked =
                              uid != null && likedBy.contains(uid);

                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
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

                            // FutureBuilder digunakan untuk mengetahui role.
                            // Jika admin, tombol like dan favorit disembunyikan.
                            child: FutureBuilder<String>(
                              future: _roleFuture,
                              builder: (context, userSnap) {
                                if (userSnap.connectionState ==
                                    ConnectionState.waiting) {
                                  return const SizedBox(
                                    height: 40,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                }

                                if (userSnap.hasError) {
                                  return const SizedBox(
                                    height: 40,
                                    child: Center(
                                      child: Text(
                                        'Error memuat data',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textMuted,
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                final role = userSnap.data ?? 'user';

                                return Row(
                                  children: [
                                    // Tombol like hanya muncul untuk non-admin.
                                    if (role != 'admin') ...[
                                      GestureDetector(
                                        onTap: () {
                                          _toggleLike(
                                            context,
                                            zoo.id_zoo,
                                            likedBy,
                                          );
                                        },
                                        child: Icon(
                                          isLiked
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: isLiked
                                              ? Colors.red
                                              : AppTheme.textMuted,
                                          size: 26,
                                        ),
                                      ),

                                      const SizedBox(width: 8),
                                    ],

                                    // Jumlah like tetap tampil untuk semua role.
                                    Expanded(
                                      child: Text(
                                        '$likesCount orang menyukai destinasi ini',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textMuted,
                                        ),
                                      ),
                                    ),

                                    // Tombol favorit hanya muncul untuk non-admin.
                                    if (role != 'admin') ...[
                                      const SizedBox(width: 16),

                                      // StreamBuilder ini mengecek apakah destinasi
                                      // sudah ada di favorit user.
                                      StreamBuilder<QuerySnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection('favourites')
                                            .where(
                                              'id_user',
                                              isEqualTo: FirebaseAuth.instance
                                                  .currentUser?.uid,
                                            )
                                            .where(
                                              'id_zoo',
                                              isEqualTo: zoo.id_zoo,
                                            )
                                            .snapshots(),

                                        builder: (context, favSnap) {
                                          final isFav = favSnap.hasData &&
                                              favSnap.data!.docs.isNotEmpty;

                                          return GestureDetector(
                                            onTap: () {
                                              _toggleFavourite(
                                                context,
                                                zoo.id_zoo,
                                              );
                                            },
                                            child: HugeIcon(
                                              icon: isFav
                                                  ? HugeIcons
                                                      .strokeRoundedBookmarkCheck02
                                                  : HugeIcons
                                                      .strokeRoundedBookmarkAdd01,
                                              color: isFav
                                                  ? const Color.fromARGB(
                                                      255,
                                                      69,
                                                      185,
                                                      15,
                                                    )
                                                  : AppTheme.textMuted,
                                              size: 26,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ],
                                );
                              },
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 12),

                      // Section deskripsi destinasi.
                      _SectionCard(
                        title: 'Tentang',
                        child: Text(
                          zoo.deskripsi.isNotEmpty ? zoo.deskripsi : '-',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textDark,
                            height: 1.6,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Section informasi kunjungan.
                      _SectionCard(
                        title: 'Visit Information',
                        child: Column(
                          children: [
                            _InfoRow(
                              icon: HugeIcons.strokeRoundedClock01,
                              label: 'Jam Operasional',
                              value: '${zoo.jam_buka} - ${zoo.jam_tutup}',
                            ),

                            const SizedBox(height: 12),

                            _InfoRow(
                              icon: HugeIcons.strokeRoundedCall,
                              label: 'Kontak',
                              value: zoo.kontak,
                            ),
                            const SizedBox(height: 12),

                            _InfoRow(
                              icon: HugeIcons.strokeRoundedTicket01,
                              label: 'Harga Tiket',
                              value: zoo.harga_tiket.isNotEmpty
                                  ? 'Rp ${zoo.harga_tiket}'
                                  : '-',
                            ),

                            const SizedBox(height: 12),

                            GestureDetector(
                              onTap: () async {
                                if (zoo.alamat.isNotEmpty) {
                                  await Clipboard.setData(
                                      ClipboardData(text: zoo.alamat));
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            HugeIcon(
                                              icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            const Text('Alamat berhasil disalin!'),
                                          ],
                                        ),
                                        backgroundColor: AppTheme.primary,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color:
                                          AppTheme.primary.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    HugeIcon(
                                      icon: HugeIcons.strokeRoundedLocation01,
                                      color: AppTheme.primary,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('Alamat',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: AppTheme.textMuted)),
                                          const SizedBox(height: 2),
                                          Text(
                                            zoo.alamat.isNotEmpty
                                                ? zoo.alamat
                                                : '-',
                                            style: const TextStyle(
                                                fontSize: 13,
                                                color: AppTheme.primary),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    HugeIcon(
                                      icon: HugeIcons.strokeRoundedCopy01,
                                      color: AppTheme.primary,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 12),

                            // Link Google Maps — tap to copy
                            if (zoo.link_gmaps.isNotEmpty)
                              GestureDetector(
                                onTap: () async {
                                  await Clipboard.setData(
                                      ClipboardData(text: zoo.link_gmaps));
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            HugeIcon(
                                              icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            const Text('Link berhasil disalin!'),
                                          ],
                                        ),
                                        backgroundColor: AppTheme.primary,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color:
                                            AppTheme.primary.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      HugeIcon(
                                        icon: HugeIcons.strokeRoundedLink01,
                                        color: AppTheme.primary,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text('Link Google Maps',
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    color: AppTheme.textMuted)),
                                            const SizedBox(height: 2),
                                            Text(
                                              zoo.link_gmaps,
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  color: AppTheme.primary),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      HugeIcon(
                                        icon: HugeIcons.strokeRoundedCopy01,
                                        color: AppTheme.primary,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _bukaMaps(zoo.link_gmaps),
                                icon: HugeIcon(
                                  icon: HugeIcons.strokeRoundedMapsLocation01,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                label: const Text('Get Directions'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Lokasi / Peta
                      _SectionCard(
                        title: 'Lokasi',
                        child: coords != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  height: 200,
                                  child: FlutterMap(
                                    options: MapOptions(
                                      initialCenter:
                                          LatLng(coords[0], coords[1]),
                                      initialZoom: 15,
                                      onTap: (_, __) =>
                                          _bukaMaps(zoo.link_gmaps),
                                      interactionOptions:
                                          const InteractionOptions(
                                        flags: InteractiveFlag.none,
                                      ),
                                    ),
                                    children: [
                                      TileLayer(
                                        urlTemplate:
                                            'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                                        userAgentPackageName:
                                            'com.example.sahabatsatwaApp',
                                      ),
                                      MarkerLayer(
                                        markers: [
                                          Marker(
                                            point: LatLng(coords[0], coords[1]),
                                            width: 40,
                                            height: 40,
                                            child: const Icon(
                                              Icons.location_pin,
                                              color: Colors.red,
                                              size: 40,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Container(
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                    child:
                                        Text('Koordinat tidak tersedia')),
                              ),
                      ),
                      const SizedBox(height: 20),

                      // ── REVIEW SECTION ───────────────────────────────────
                      // Tampilkan 5 preview review + input field kirim review
                      ReviewSection(idZoo: zoo.id_zoo),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final dynamic icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HugeIcon(icon: icon, color: AppTheme.primary, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textMuted)),
              const SizedBox(height: 2),
              Text(value.isNotEmpty ? value : '-',
                  style: const TextStyle(
                      fontSize: 14, color: AppTheme.textDark)),
            ],
          ),
        ),
      ],
    );
  }
}