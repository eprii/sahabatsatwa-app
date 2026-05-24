import 'package:flutter/material.dart';

import 'sahabat_satwa_model.dart';
import 'app_theme.dart';

// Halaman ini digunakan oleh admin untuk menambah data destinasi baru.
// Data yang diinput akan disimpan ke collection "destination" di Firestore.
class TambahSahabatSatwaScreen extends StatefulWidget {
  const TambahSahabatSatwaScreen({super.key});

  @override
  State<TambahSahabatSatwaScreen> createState() {
    return _TambahState();
  }
}

class _TambahState extends State<TambahSahabatSatwaScreen> {
  // GlobalKey digunakan untuk menjalankan validasi semua TextFormField.
  final _formKey = GlobalKey<FormState>();

  // Controller digunakan untuk mengambil isi dari setiap input field.
  final namaController = TextEditingController();
  final deskripsiController = TextEditingController();
  final alamatController = TextEditingController();
  final hargaController = TextEditingController();
  final jamBukaController = TextEditingController();
  final jamTutupController = TextEditingController();
  final kontakController = TextEditingController();
  final koordinatController = TextEditingController();
  final fotoUrlController = TextEditingController();
  final linkGmapsController = TextEditingController();

  // Menyimpan provinsi yang dipilih dari dropdown.
  String _selectedProvinsi = '';

  // Daftar provinsi yang akan ditampilkan di DropdownButtonFormField.
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
  void dispose() {
    // Semua controller harus di-dispose agar tidak membuang memory.
    namaController.dispose();
    deskripsiController.dispose();
    alamatController.dispose();
    hargaController.dispose();
    jamBukaController.dispose();
    jamTutupController.dispose();
    kontakController.dispose();
    koordinatController.dispose();
    fotoUrlController.dispose();
    linkGmapsController.dispose();

    super.dispose();
  }

  // Fungsi untuk validasi koordinat.
  // Format yang diterima: latitude,longitude
  // Contoh: -6.2,106.8
  bool isValidKoordinat(String value) {
    // Menghapus spasi di awal dan akhir input.
    String teks = value.trim();

    // Memecah input berdasarkan tanda koma.
    // Contoh "-6.2,106.8" menjadi ["-6.2", "106.8"].
    List<String> bagian = teks.split(',');

    // Koordinat harus memiliki 2 bagian:
    // bagian pertama latitude, bagian kedua longitude.
    if (bagian.length != 2) {
      return false;
    }

    // Mengambil bagian latitude dalam bentuk teks.
    String latitudeText = bagian[0].trim();

    // Mengambil bagian longitude dalam bentuk teks.
    String longitudeText = bagian[1].trim();

    // Mengubah latitude dari String menjadi double.
    // Jika gagal, hasilnya null.
    double? latitude = double.tryParse(latitudeText);

    // Mengubah longitude dari String menjadi double.
    // Jika gagal, hasilnya null.
    double? longitude = double.tryParse(longitudeText);

    // Jika latitude atau longitude gagal menjadi angka, format salah.
    if (latitude == null || longitude == null) {
      return false;
    }

    // Latitude yang valid berada di antara -90 sampai 90.
    if (latitude < -90 || latitude > 90) {
      return false;
    }

    // Longitude yang valid berada di antara -180 sampai 180.
    if (longitude < -180 || longitude > 180) {
      return false;
    }

    // Jika semua pengecekan lolos, koordinat dianggap valid.
    return true;
  }

  // Validator untuk field yang wajib diisi.
  String? _wajibDiisi(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Wajib diisi';
    }

    return null;
  }

  // Validator khusus untuk input koordinat.
  String? _validasiKoordinat(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Wajib diisi';
    }

    if (!isValidKoordinat(value)) {
      return 'Format salah! Contoh: -6.2,106.8';
    }

    return null;
  }

  // Validator untuk dropdown provinsi.
  String? _validasiProvinsi(String? value) {
    if (value == null || value.isEmpty) {
      return 'Pilih provinsi';
    }

    return null;
  }

  // Membuat item dropdown provinsi menggunakan for loop.
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

  // Fungsi ini dijalankan saat tombol tambah ditekan.
  Future<void> _tambahData() async {
    // Jika form belum valid, proses tambah data dihentikan.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Mengambil koordinat dari input dan menghapus spasi.
    final koordinat = koordinatController.text.trim();

    // Mengambil link Google Maps dari input.
    final linkInput = linkGmapsController.text.trim();

    // Jika link Google Maps kosong, maka dibuat otomatis dari koordinat.
    String linkGmaps;

    if (linkInput.isNotEmpty) {
      linkGmaps = linkInput;
    } else {
      linkGmaps = 'https://www.google.com/maps/search/?api=1&query=$koordinat';
    }

    // Membuat object SahabatSatwa dari data yang diinput admin.
    final data = SahabatSatwa(
      id_zoo: '',
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

    // Menyimpan data baru ke Firestore lewat fungsi addData di model.
    await SahabatSatwa.addData(data);

    // Setelah berhasil menambah data, kembali ke halaman sebelumnya.
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,

      appBar: AppBar(
        title: const Text('Tambah Kebun Binatang'),
        backgroundColor: AppTheme.primaryDark,
        elevation: 0,
      ),

      body: Form(
        key: _formKey,

        // ListView digunakan agar form bisa discroll jika layar tidak cukup.
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
              maxLines: 4,
            ),

            _buildField(
              alamatController,
              'Alamat',
            ),

            // Dropdown provinsi.
            // Dibungkus _cardWrap agar tampilannya sama seperti input lain.
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
                validator: _validasiProvinsi,
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
              hint: '50000',
              keyboardType: TextInputType.number,
            ),

            _buildField(
              kontakController,
              'Kontak',
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 20),

            // Tombol untuk menambah data ke Firestore.
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _tambahData,
                child: const Text(
                  '+ Tambah Kebun Binatang',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Tombol batal untuk kembali tanpa menyimpan data.
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
  // Tujuannya agar kode input tidak ditulis berulang-ulang.
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

  // Widget pembungkus agar setiap input memiliki background putih
  // dan sudut membulat.
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