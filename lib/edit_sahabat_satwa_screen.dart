import 'package:flutter/material.dart';
import 'sahabat_satwa_model.dart';
import 'app_theme.dart';

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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Edit Data'),
        backgroundColor: AppTheme.primaryDark,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildField(namaController, 'Nama Kebun Binatang',
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
            _buildField(fotoUrlController, 'URL Foto',
                hint: 'https://example.com/foto.jpg'),
            _buildField(linkGmapsController, 'Link Google Maps (Shared Link)',
                hint: 'https://maps.google.com/?q=...'),
            _buildField(koordinatController, 'Koordinat (lat,long)',
                hint: '-6.2,106.8',
                keyboardType: const TextInputType.numberWithOptions(
                    signed: true, decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                  if (!isValidKoordinat(v)) return 'Format salah! Contoh: -6.2,106.8';
                  return null;
                }),
            _buildField(deskripsiController, 'Tentang', maxLines: 4),
            _buildField(alamatController, 'Alamat'),

            _cardWrap(
              child: DropdownButtonFormField<String>(
                value: _selectedProvinsi.isEmpty ? null : _selectedProvinsi,
                hint: const Text('Pilih Provinsi',
                    style: TextStyle(color: AppTheme.textMuted)),
                decoration: const InputDecoration(
                  labelText: 'Provinsi',
                  border: InputBorder.none,
                ),
                items: _provinsiList
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedProvinsi = v ?? ''),
              ),
            ),
            const SizedBox(height: 12),

            _buildField(jamBukaController, 'Jam Buka', hint: '09:00'),
            _buildField(jamTutupController, 'Jam Tutup', hint: '17:00'),
            _buildField(hargaController, 'Harga Tiket',
                keyboardType: TextInputType.number),
            _buildField(kontakController, 'Kontak',
                keyboardType: TextInputType.phone),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
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
                child: const Text('Simpan Perubahan', style: TextStyle(fontSize: 15)),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white54),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Batal'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label, {
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return _cardWrap(
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _cardWrap({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}
