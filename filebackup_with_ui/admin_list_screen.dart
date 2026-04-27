import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sahabat_satwa_model.dart';
import 'detail_sahabat_satwa_screen.dart';
import 'tambah_sahabat_satwa_screen.dart';

class AdminListScreen extends StatelessWidget {
  const AdminListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Destinasi')),
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
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Hapus Data'),
                          content:
                              const Text('Yakin ingin menghapus data ini?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Hapus',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await SahabatSatwa.deleteData(zoo.id_zoo);
                      }
                    },
                  ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const TambahSahabatSatwaScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
