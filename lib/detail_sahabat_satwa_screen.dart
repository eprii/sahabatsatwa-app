import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sahabat_satwa_model.dart';
import 'edit_sahabat_satwa_screen.dart';
import 'app_theme.dart';

class DetailSahabatSatwaScreen extends StatelessWidget {
  final SahabatSatwa data;
  const DetailSahabatSatwaScreen({super.key, required this.data});

  Future<void> _bukaMaps(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('sahabatsatwa-app')
            .doc(data.id_zoo)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          final zoo = SahabatSatwa.fromDocument(snapshot.data!);
          final coords = zoo.parsedKoordinat;

          return CustomScrollView(
            slivers: [
              // ── HERO IMAGE ──
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: AppTheme.primaryDark,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: CircleAvatar(
                    backgroundColor: Colors.black38,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: CircleAvatar(
                      backgroundColor: Colors.black38,
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => EditSahabatSatwaScreen(data: zoo)),
                        ),
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Foto
                      zoo.foto_url.isNotEmpty
                          ? Image.network(zoo.foto_url,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  Container(color: AppTheme.primaryDark))
                          : Container(color: AppTheme.primaryDark,
                              child: const Icon(Icons.photo, size: 60, color: Colors.white30)),
                      // Gradient overlay
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black54],
                          ),
                        ),
                      ),
                      // Teks di bawah foto
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
                                shadows: [Shadow(color: Colors.black45, blurRadius: 8)],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.white70, size: 14),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    zoo.alamat.isNotEmpty ? zoo.alamat : '-',
                                    style: const TextStyle(color: Colors.white70, fontSize: 13),
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

              // ── CONTENT ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [

                      // Tentang
                      _SectionCard(
                        title: 'Tentang',
                        child: Text(
                          zoo.deskripsi.isNotEmpty ? zoo.deskripsi : '-',
                          style: const TextStyle(
                              fontSize: 14, color: AppTheme.textDark, height: 1.6),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Visit Information
                      _SectionCard(
                        title: 'Visit Information',
                        child: Column(
                          children: [
                            _InfoRow(
                              icon: Icons.access_time_rounded,
                              label: 'Jam Operasional',
                              value: '${zoo.jam_buka} - ${zoo.jam_tutup}',
                            ),
                            const SizedBox(height: 12),
                            _InfoRow(
                              icon: Icons.phone_rounded,
                              label: 'Kontak',
                              value: zoo.kontak,
                            ),
                            const SizedBox(height: 12),
                            _InfoRow(
                              icon: Icons.location_on_rounded,
                              label: 'Alamat',
                              value: zoo.alamat,
                            ),
                            const SizedBox(height: 12),
                            _InfoRow(
                              icon: Icons.confirmation_number_rounded,
                              label: 'Harga Tiket',
                              value: zoo.harga_tiket.isNotEmpty
                                  ? 'Rp ${zoo.harga_tiket}'
                                  : '-',
                            ),
                            const SizedBox(height: 12),

                            // ✅ Link Google Maps — tap to copy
                            if (zoo.link_gmaps.isNotEmpty)
                              GestureDetector(
                                onTap: () async {
                                  await Clipboard.setData(
                                      ClipboardData(text: zoo.link_gmaps));
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Row(
                                          children: [
                                            Icon(Icons.check_circle,
                                                color: Colors.white, size: 18),
                                            SizedBox(width: 8),
                                            Text('Link berhasil disalin!'),
                                          ],
                                        ),
                                        backgroundColor: AppTheme.primary,
                                        duration: Duration(seconds: 2),
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
                                        color: AppTheme.primary.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.link_rounded,
                                          size: 16, color: AppTheme.primary),
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
                                      const Icon(Icons.copy_rounded,
                                          size: 16, color: AppTheme.primary),
                                    ],
                                  ),
                                ),
                              ),

                            const SizedBox(height: 20),
                            // Get Directions button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _bukaMaps(zoo.link_gmaps),
                                icon: const Icon(Icons.directions_rounded),
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
                            ? GestureDetector(
                                onTap: () => _bukaMaps(zoo.link_gmaps),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: SizedBox(
                                    height: 200,
                                    child: FlutterMap(
                                      options: MapOptions(
                                        initialCenter: LatLng(coords[0], coords[1]),
                                        initialZoom: 15,
                                        onTap: (_, __) => _bukaMaps(zoo.link_gmaps),
                                        interactionOptions: const InteractionOptions(
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
                                ),
                              )
                            : Container(
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                    child: Text('Koordinat tidak tersedia')),
                              ),
                      ),
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
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppTheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
              const SizedBox(height: 2),
              Text(value.isNotEmpty ? value : '-',
                  style: const TextStyle(fontSize: 14, color: AppTheme.textDark)),
            ],
          ),
        ),
      ],
    );
  }
}
