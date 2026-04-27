import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sahabat_satwa_model.dart';
import 'detail_sahabat_satwa_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String _selectedProvinsi = 'All';

  final List<String> _provinsiList = [
    'All', 'Jawa', 'Bali', 'Sumatra', 'Kalimantan', 'Sulawesi'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cari Kebun Binatang')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Cari kebun binatang...',
              leading: const Icon(Icons.search),
              trailing: [
                if (_query.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                  ),
              ],
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
            ),
          ),

          // Filter chips
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _provinsiList.length,
              itemBuilder: (_, i) {
                final p = _provinsiList[i];
                final selected = _selectedProvinsi == p;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(p),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedProvinsi = p),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('sahabatsatwa-app')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final zoos = snapshot.data!.docs
                    .map((d) => SahabatSatwa.fromDocument(d))
                    .where((z) {
                  final matchQuery = _query.isEmpty ||
                      z.nama_zoo.toLowerCase().contains(_query) ||
                      z.alamat.toLowerCase().contains(_query);
                  final matchProvinsi = _selectedProvinsi == 'All' ||
                      z.provinsi.toLowerCase() ==
                          _selectedProvinsi.toLowerCase();
                  return matchQuery && matchProvinsi;
                }).toList();

                if (zoos.isEmpty) {
                  return const Center(child: Text('Tidak ada hasil'));
                }

                return ListView.builder(
                  itemCount: zoos.length,
                  itemBuilder: (_, i) {
                    final zoo = zoos[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
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
                        subtitle: Text(zoo.alamat,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                DetailSahabatSatwaScreen(data: zoo),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
