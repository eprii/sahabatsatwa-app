import 'package:flutter/material.dart';
import 'sahabat_satwa_model.dart';

class EditSahabatSatwaScreen extends StatefulWidget {
  final SahabatSatwa data;
  const EditSahabatSatwaScreen({super.key, required this.data});

  @override
  State<EditSahabatSatwaScreen> createState() => _EditState();
}

class _EditState extends State<EditSahabatSatwaScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController namaController;
  late TextEditingController alamatController;
  late TextEditingController koordinatController;
  late TextEditingController deskripsiController;
  late TextEditingController hargaController;
  late TextEditingController jamBukaController;
  late TextEditingController jamTutupController;
  late TextEditingController kontakController;
  late TextEditingController fotoUrlController;
  late TextEditingController linkGmapsController;
  late String _selectedProvinsi;

  final List<String> _provinsiList = [
    'Jawa', 'Bali', 'Sumatra', 'Kalimantan', 'Sulawesi', 'Papua', 'NTB', 'NTT'
  ];

  @override
  void initState() {
    super.initState();
    namaController = TextEditingController(text: widget.data.nama_zoo);
    alamatController = TextEditingController(text: widget.data.alamat);
    koordinatController = TextEditingController(text: widget.data.koordinat);
    deskripsiController = TextEditingController(text: widget.data.deskripsi);
    hargaController = TextEditingController(text: widget.data.harga_tiket);
    jamBukaController = TextEditingController(text: widget.data.jam_buka);
    jamTutupController = TextEditingController(text: widget.data.jam_tutup);
    kontakController = TextEditingController(text: widget.data.kontak);
    fotoUrlController = TextEditingController(text: widget.data.foto_url);
    linkGmapsController = TextEditingController(text: widget.data.link_gmaps);
    _selectedProvinsi = widget.data.provinsi;
  }

  bool isValidKoordinat(String value) =>
      RegExp(r'^-?\d+(\.\d+)?,-?\d+(\.\d+)?$').hasMatch(value.trim());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Data')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: namaController,
              decoration: const InputDecoration(labelText: 'Nama Kebun Binatang', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: fotoUrlController,
              decoration: const InputDecoration(labelText: 'URL Foto', border: OutlineInputBorder(), hintText: 'https://...'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: linkGmapsController,
              decoration: const InputDecoration(labelText: 'Link Google Maps', border: OutlineInputBorder(), hintText: 'https://maps.google.com/...'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: koordinatController,
              decoration: const InputDecoration(labelText: 'Koordinat (lat,long)', border: OutlineInputBorder(), hintText: '-6.2,106.8'),
              keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                if (!isValidKoordinat(v)) return 'Format salah! Contoh: -6.2,106.8';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: deskripsiController,
              decoration: const InputDecoration(labelText: 'Deskripsi', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: alamatController,
              decoration: const InputDecoration(labelText: 'Alamat', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedProvinsi.isEmpty ? null : _selectedProvinsi,
              decoration: const InputDecoration(labelText: 'Provinsi', border: OutlineInputBorder()),
              hint: const Text('Pilih Provinsi'),
              items: _provinsiList.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
              onChanged: (v) => setState(() => _selectedProvinsi = v ?? ''),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: jamBukaController,
              decoration: const InputDecoration(labelText: 'Jam Buka', border: OutlineInputBorder(), hintText: '09:00'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: jamTutupController,
              decoration: const InputDecoration(labelText: 'Jam Tutup', border: OutlineInputBorder(), hintText: '17:00'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: hargaController,
              decoration: const InputDecoration(labelText: 'Harga Tiket', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: kontakController,
              decoration: const InputDecoration(labelText: 'Kontak', border: OutlineInputBorder()),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                final koordinat = koordinatController.text.trim();
                final updated = SahabatSatwa(
                  id_zoo: widget.data.id_zoo,
                  nama_zoo: namaController.text.trim(),
                  deskripsi: deskripsiController.text.trim(),
                  alamat: alamatController.text.trim(),
                  harga_tiket: hargaController.text.trim(),
                  jam_buka: jamBukaController.text.trim(),
                  jam_tutup: jamTutupController.text.trim(),
                  kontak: kontakController.text.trim(),
                  koordinat: koordinat,
                  link_gmaps: linkGmapsController.text.trim().isNotEmpty
                      ? linkGmapsController.text.trim()
                      : 'https://www.google.com/maps/search/?api=1&query=$koordinat',
                  foto_url: fotoUrlController.text.trim(),
                  provinsi: _selectedProvinsi,
                );
                await SahabatSatwa.updateData(widget.data.id_zoo, updated);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Simpan Perubahan'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
