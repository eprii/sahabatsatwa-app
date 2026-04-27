import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sahabat_satwa_model.dart';
import 'detail_sahabat_satwa_screen.dart';

class SahabatSatwaListScreen extends StatelessWidget {
  const SahabatSatwaListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Kebun Binatang')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('sahabatsatwa-app')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Belum ada data'));
          }

          final zoos = snapshot.data!.docs
              .map((d) => SahabatSatwa.fromDocument(d))
              .toList();

          return ListView.builder(
            itemCount: zoos.length,
            itemBuilder: (context, index) {
              final zoo = zoos[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: zoo.foto_url.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            zoo.foto_url,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.photo, size: 40),
                          ),
                        )
                      : const Icon(Icons.photo, size: 40),
                  title: Text(zoo.nama_zoo),
                  subtitle: Text(
                    zoo.alamat.isNotEmpty ? zoo.alamat : '-',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: zoo.provinsi.isNotEmpty
                      ? Chip(label: Text(zoo.provinsi, style: const TextStyle(fontSize: 11)))
                      : const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailSahabatSatwaScreen(data: zoo),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
