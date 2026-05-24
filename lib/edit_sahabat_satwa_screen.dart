import 'package:flutter/material.dart';

import 'sahabat_satwa_model.dart';
import 'app_theme.dart';
import 'app_notification.dart';

// Halaman ini digunakan oleh admin untuk mengedit data destinasi.
// Data awal diambil dari object SahabatSatwa yang dikirim dari halaman sebelumnya.
class EditSahabatSatwaScreen extends StatefulWidget {
  final SahabatSatwa data;

  const EditSahabatSatwaScreen({
    super.key,
    required this.data,
  });

  @override
  State<EditSahabatSatwaScreen> createState() {
    return _EditState();
  }
}

class _EditState extends State<EditSahabatSatwaScreen> {
  // GlobalKey digunakan untuk mengecek validasi semua TextFormField.
  final _formKey = GlobalKey<FormState>();

  // Controller digunakan untuk membaca dan mengatur isi TextField.
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

  // Menyimpan provinsi yang sedang dipilih di dropdown.
  late String _selectedProvinsi;

  // Daftar provinsi yang akan ditampilkan pada dropdown.
  final List<String> _provinsiList = [
    'Aceh',
    'Sumatera Utara',
    'Sumatera Barat',
    'Riau',
    'Kepulauan Riau',
    'Jambi',
    'Sumatera Selatan',
    'Kepulauan Bangka Belitung',
    'Bengkulu',
    'Lampung',
    'Banten',
    'DKI Jakarta',
    'Jawa Barat',
    'Jawa Tengah',
    'DI Yogyakarta',
    'Jawa Timur',
    'Bali',
    'Nusa Tenggara Barat',
    'Nusa Tenggara Timur',
    'Kalimantan Barat',
    'Kalimantan Tengah',
    'Kalimantan Selatan',
    'Kalimantan Timur',
    'Kalimantan Utara',
    'Sulawesi Utara',
    'Gorontalo',
    'Sulawesi Tengah',
    'Sulawesi Barat',
    'Sulawesi Selatan',
    'Sulawesi Tenggara',
    'Maluku',
    'Maluku Utara',
    'Papua',
    'Papua Barat',
    'Papua Barat Daya',
    'Papua Selatan',
    'Papua Tengah',
    'Papua Pegunungan',
  ];

  @override
  void initState() {
    super.initState();

    // Setiap controller diisi dengan data lama dari destinasi.
    // Jadi saat halaman edit dibuka, form sudah berisi data sebelumnya.
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

    // Jika provinsi lama ada di list, maka jadikan sebagai nilai awal dropdown.
    // Jika tidak ada, dropdown dibuat kosong agar tidak error.
    if (_provinsiList.contains(widget.data.provinsi)) {
      _selectedProvinsi = widget.data.provinsi;
    } else {
      _selectedProvinsi = '';
    }
  }

  @override
  void dispose() {
    // Controller harus di-dispose supaya tidak membuang memory.
    namaController.dispose();
    alamatController.dispose();
    koordinatController.dispose();
    deskripsiController.dispose();
    hargaController.dispose();
    jamBukaController.dispose();
    jamTutupController.dispose();
    kontakController.dispose();
    fotoUrlController.dispose();
    linkGmapsController.dispose();

    super.dispose();
  }

  // Fungsi untuk mengecek format koordinat.
  // Format yang benar: latitude,longitude
  // Contoh: -6.2,106.8
  bool isValidKoordinat(String value) {
    // Menghapus spasi di awal dan akhir input
    String teks = value.trim();

    // Memecah teks menjadi beberapa bagian berdasarkan tanda koma
    List<String> bagian = teks.split(',');

    // Mengecek apakah hasil split berjumlah 2 bagian
    // Format koordinat harus: latitude,longitude
    if (bagian.length != 2) {
      // Jika bukan 2 bagian, berarti format salah
      return false;
    }

    // Mengambil bagian pertama sebagai latitude
    String latitudeText = bagian[0].trim();

    // Mengambil bagian kedua sebagai longitude
    String longitudeText = bagian[1].trim();

    // Mencoba mengubah teks latitude menjadi angka desimal
    double? latitude = double.tryParse(latitudeText);

    // Mencoba mengubah teks longitude menjadi angka desimal
    double? longitude = double.tryParse(longitudeText);

    // Mengecek apakah latitude atau longitude gagal diubah menjadi angka
    if (latitude == null || longitude == null) {
      // Jika salah satu null, berarti input bukan angka yang valid
      return false;
    }

    // Mengecek batas nilai latitude
    // Latitude yang valid harus berada antara -90 sampai 90
    if (latitude < -90 || latitude > 90) {
      // Jika di luar batas, koordinat tidak valid
      return false;
    }

    // Mengecek batas nilai longitude
    // Longitude yang valid harus berada antara -180 sampai 180
    if (longitude < -180 || longitude > 180) {
      // Jika di luar batas, koordinat tidak valid
      return false;
    }

    // Jika semua pengecekan lolos, maka koordinat dianggap valid
    return true;
  }

  // Validator untuk field wajib diisi.
  String? _wajibDiisi(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Wajib diisi';
    }

    return null;
  }

  // Validator khusus untuk koordinat.
  String? _validasiKoordinat(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Wajib diisi';
    }

    if (!isValidKoordinat(value)) {
      return 'Format salah! Contoh: -6.2,106.8';
    }

    return null;
  }

  // Fungsi untuk menyimpan perubahan data ke Firestore.
  Future<void> _simpanPerubahan() async {
    // Jika form belum valid, tampilkan popup error dan hentikan proses.
    if (!_formKey.currentState!.validate()) {
      AppNotification.showError(
        context,
        'Periksa kembali data yang wajib diisi.',
      );

      return;
    }

    final koordinat = koordinatController.text.trim();
    final linkInput = linkGmapsController.text.trim();

    // Jika link Google Maps kosong, maka buat link otomatis dari koordinat.
    String linkGmaps;

    if (linkInput.isNotEmpty) {
      linkGmaps = linkInput;
    } else {
      linkGmaps = 'https://www.google.com/maps/search/?api=1&query=$koordinat';
    }

    // Membuat object SahabatSatwa baru dari data yang sudah diedit.
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
      link_gmaps: linkGmaps,
      foto_url: fotoUrlController.text.trim(),
      provinsi: _selectedProvinsi,
    );

    try {
      // Mengupdate data ke Firestore.
      await SahabatSatwa.updateData(widget.data.id_zoo, updated);

      if (mounted) {
        // Notifikasi tetap muncul walaupun halaman langsung kembali,
        // karena AppNotification memakai rootOverlay.
        AppNotification.showSuccess(
          context,
          'Data berhasil diperbarui.',
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppNotification.showError(
          context,
          'Gagal memperbarui data.',
        );
      }
    }
  }

  // Membuat daftar item dropdown provinsi menggunakan for loop.
  // Ini lebih mudah dijelaskan dibanding .map().
  List<DropdownMenuItem<String>> _buildProvinsiItems() {
    List<DropdownMenuItem<String>> items = [];

    for (int i = 0; i < _provinsiList.length; i++) {
      String provinsi = _provinsiList[i];

      items.add(
        DropdownMenuItem<String>(
          value: provinsi,
          child: Text(provinsi),
        ),
      );
    }

    return items;
  }

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

        // ListView digunakan agar form bisa discroll jika isi layar tidak cukup.
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildField(
              namaController,
              'Nama Kebun Binatang',
              validator: _wajibDiisi,
            ),

            _buildField(
              fotoUrlController,
              'URL Foto',
              hint: 'https://example.com/foto.jpg',
            ),

            _buildField(
              linkGmapsController,
              'Link Google Maps (Shared Link)',
              hint: 'https://maps.google.com/?q=...',
            ),

            _buildField(
              koordinatController,
              'Koordinat (lat,long)',
              hint: '-6.2,106.8',
              keyboardType: const TextInputType.numberWithOptions(
                signed: true,
                decimal: true,
              ),
              validator: _validasiKoordinat,
            ),

            _buildField(
              deskripsiController,
              'Tentang',
              maxLines: 5,
            ),

            _buildField(
              alamatController,
              'Alamat',
            ),

            // Dropdown provinsi dibungkus dengan card putih agar tampilannya sama
            // dengan field lain.
            _cardWrap(
              child: DropdownButtonFormField<String>(
                value: _selectedProvinsi.isEmpty ? null : _selectedProvinsi,
                hint: const Text(
                  'Pilih Provinsi',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                  ),
                ),
                decoration: const InputDecoration(
                  labelText: 'Provinsi',
                  border: InputBorder.none,
                ),
                items: _buildProvinsiItems(),
                onChanged: (value) {
                  setState(() {
                    _selectedProvinsi = value ?? '';
                  });
                },
              ),
            ),

            const SizedBox(height: 12),

            _buildField(
              jamBukaController,
              'Jam Buka',
              hint: '09:00',
            ),

            _buildField(
              jamTutupController,
              'Jam Tutup',
              hint: '17:00',
            ),

            _buildField(
              hargaController,
              'Harga Tiket',
              keyboardType: TextInputType.number,
            ),

            _buildField(
              kontakController,
              'Kontak',
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 20),

            // Tombol untuk menyimpan perubahan.
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _simpanPerubahan,
                child: const Text(
                  'Simpan Perubahan',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Tombol batal untuk kembali tanpa menyimpan perubahan.
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: Colors.white54,
                  ),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
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

  // Widget reusable untuk membuat TextFormField.
  // Dipakai agar kode form tidak ditulis berulang-ulang.
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
          hintStyle: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 13,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // Widget pembungkus agar setiap input field memiliki background putih
  // dan bentuk rounded card.
  Widget _cardWrap({
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}