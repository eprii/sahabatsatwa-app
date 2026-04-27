import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong2.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sahabat_satwa_model.dart';
import 'edit_sahabat_satwa_screen.dart';

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
      appBar: AppBar(
        title: Text(data.nama_zoo),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => EditSahabatSatwaScreen(data: data)),
            ),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('sahabatsatwa-app')
            .doc(data.id_zoo)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final zoo = SahabatSatwa.fromDocument(snapshot.data!);
          final coords = zoo.parsedKoordinat;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Foto
              if (zoo.foto_url.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    zoo.foto_url,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox(),
                  ),
                ),
              const SizedBox(height: 16),

              // Info dasar
              Text(zoo.nama_zoo,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold)),
              if (zoo.provinsi.isNotEmpty) ...[
                const SizedBox(height: 4),
                Chip(label: Text(zoo.provinsi)),
              ],
              const Divider(height: 24),

              // Tentang
              Text('Tentang',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(zoo.deskripsi.isNotEmpty ? zoo.deskripsi : '-'),
              const Divider(height: 24),

              // Info kunjungan
              Text('Informasi Kunjungan',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Jam Operasional'),
                subtitle: Text('${zoo.jam_buka} - ${zoo.jam_tutup}'),
                contentPadding: EdgeInsets.zero,
              ),
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Kontak'),
                subtitle: Text(zoo.kontak.isNotEmpty ? zoo.kontak : '-'),
                contentPadding: EdgeInsets.zero,
              ),
              ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text('Alamat'),
                subtitle: Text(zoo.alamat.isNotEmpty ? zoo.alamat : '-'),
                contentPadding: EdgeInsets.zero,
              ),
              ListTile(
                leading: const Icon(Icons.confirmation_number),
                title: const Text('Harga Tiket'),
                subtitle: Text(zoo.harga_tiket.isNotEmpty
                    ? 'Rp ${zoo.harga_tiket}'
                    : '-'),
                contentPadding: EdgeInsets.zero,
              ),

              // Link Google Maps — tap to copy
              if (zoo.link_gmaps.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.link),
                  title: const Text('Link Google Maps'),
                  subtitle: Text(
                    zoo.link_gmaps,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.blue),
                  ),
                  trailing: const Icon(Icons.copy, size: 18),
                  contentPadding: EdgeInsets.zero,
                  onTap: () async {
                    await Clipboard.setData(
                        ClipboardData(text: zoo.link_gmaps));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Link berhasil disalin!')),
                      );
                    }
                  },
                ),

              const Divider(height: 24),

              // Peta
              Text('Lokasi', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              coords != null
                  ? ClipRRect(
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
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName:
                                  'com.example.sahabatsatwaApp',
                            ),
                            MarkerLayer(markers: [
                              Marker(
                                point: LatLng(coords[0], coords[1]),
                                width: 40,
                                height: 40,
                                child: const Icon(Icons.location_pin,
                                    color: Colors.red, size: 40),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    )
                  : const Text('Koordinat tidak tersedia'),
              const SizedBox(height: 16),

              // Tombol Get Directions
              FilledButton.icon(
                onPressed: () => _bukaMaps(zoo.link_gmaps),
                icon: const Icon(Icons.directions),
                label: const Text('Get Directions'),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}
