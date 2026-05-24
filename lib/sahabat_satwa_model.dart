// ignore_for_file: non_constant_identifier_names
import 'package:cloud_firestore/cloud_firestore.dart';

class SahabatSatwa {
  // Field-field berikut mengikuti nama field yang ada di Firestore.
  String id_zoo;
  String nama_zoo;
  String deskripsi;
  String alamat;
  String harga_tiket;
  String jam_buka;
  String jam_tutup;
  String kontak;
  String koordinat;
  String link_gmaps;
  String foto_url;
  String provinsi;

  // Constructor digunakan untuk membuat object SahabatSatwa.
  // required berarti data tersebut wajib diisi saat object dibuat.
  SahabatSatwa({
    required this.id_zoo,
    required this.nama_zoo,
    required this.deskripsi,
    required this.alamat,
    required this.harga_tiket,
    required this.jam_buka,
    required this.jam_tutup,
    required this.kontak,
    required this.koordinat,
    required this.link_gmaps,
    this.foto_url = '',
    this.provinsi = '',
  });

  // Factory constructor ini digunakan untuk membuat object SahabatSatwa dari dokumen Firestore.
  // DocumentSnapshot adalah satu dokumen dari Firestore.
  // Contoh: satu dokumen dalam collection "destination".
  factory SahabatSatwa.fromDocument(DocumentSnapshot doc) {
    // Mengambil isi dokumen Firestore sebagai Map, artinya data berbentuk pasangan key dan value.
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Mengembalikan object SahabatSatwa dari data Firestore.
    return SahabatSatwa(
      // doc.id adalah ID dokumen Firestore.
      id_zoo: doc.id,

      // Jika field di Firestore kosong/null, maka gunakan string kosong.
      nama_zoo: data['nama_zoo'] ?? '',
      deskripsi: data['deskripsi'] ?? '',
      alamat: data['alamat'] ?? '',
      harga_tiket: data['harga_tiket'] ?? '',
      jam_buka: data['jam_buka'] ?? '',
      jam_tutup: data['jam_tutup'] ?? '',
      kontak: data['kontak'] ?? '',
      koordinat: data['koordinat'] ?? '',
      link_gmaps: data['link_gmaps'] ?? '',
      foto_url: data['foto_url'] ?? '',
      provinsi: data['provinsi'] ?? '',
    );
  }

  // Fungsi toMap digunakan untuk mengubah object SahabatSatwa
  // menjadi Map<String, dynamic>.
  // Firestore menyimpan data dalam bentuk Map / key-value.
  // Jadi sebelum object SahabatSatwa dikirim ke Firestore, object ini harus diubah dulu menjadi Map.
  Map<String, dynamic> toMap() {
    return {
      // Bagian kiri adalah nama field di Firestore.
      // Bagian kanan adalah nilai dari object SahabatSatwa.
      'nama_zoo': nama_zoo,
      'deskripsi': deskripsi,
      'alamat': alamat,
      'harga_tiket': harga_tiket,
      'jam_buka': jam_buka,
      'jam_tutup': jam_tutup,
      'kontak': kontak,
      'koordinat': koordinat,
      'link_gmaps': link_gmaps,
      'foto_url': foto_url,
      'provinsi': provinsi,

      // created_at digunakan untuk menyimpan waktu data dibuat/diupdate.
      // DateTime.now() mengambil waktu dari device saat ini.
      'created_at': DateTime.now(),
    };
  }

  // Getter ini digunakan untuk mengubah koordinat dari String menjadi List<double>.

  // Di Firestore, koordinat disimpan sebagai String.
  // Contoh: "-6.2,106.8"

  // Untuk FlutterMap, koordinat perlu dipakai sebagai angka double.
  // Maka string tersebut dipisah menjadi latitude dan longitude.

  List<double>? get parsedKoordinat {
    // Menghapus spasi di awal dan akhir teks koordinat.
    String teks = koordinat.trim();

    // Memecah teks berdasarkan tanda koma.
    // Contoh "-6.2,106.8" menjadi ["-6.2", "106.8"].
    List<String> parts = teks.split(',');

    // Koordinat harus memiliki 2 bagian:
    // bagian pertama latitude, bagian kedua longitude.
    if (parts.length != 2) {
      return null;
    }

    // Mengambil latitude dalam bentuk teks.
    String latitudeText = parts[0].trim();

    // Mengambil longitude dalam bentuk teks.
    String longitudeText = parts[1].trim();

    // Mengubah latitude dari String menjadi double.
    // Jika gagal, hasilnya null.
    double? latitude = double.tryParse(latitudeText);

    // Mengubah longitude dari String menjadi double.
    // Jika gagal, hasilnya null.
    double? longitude = double.tryParse(longitudeText);

    // Jika salah satu gagal diubah menjadi angka, return null.
    if (latitude == null || longitude == null) {
      return null;
    }

    // Jika berhasil, kembalikan dalam bentuk List<double>.
    // Index 0 adalah latitude, index 1 adalah longitude.
    return [
      latitude,
      longitude,
    ];
  }

  // Fungsi static ini digunakan untuk menambah data destinasi baru
  // ke collection "destination" di Firestore.
  static Future<void> addData(SahabatSatwa data) async {
    await FirebaseFirestore.instance
        .collection('destination')
        .add(data.toMap());
  }

  // Fungsi static ini digunakan untuk mengupdate data destinasi
  // berdasarkan id dokumen Firestore.
  static Future<void> updateData(String id, SahabatSatwa data) async {
    await FirebaseFirestore.instance
        .collection('destination')
        .doc(id)
        .update(data.toMap());
  }

  // Fungsi static ini digunakan untuk menghapus data destinasi
  // berdasarkan id dokumen Firestore.
  static Future<void> deleteData(String id) async {
    await FirebaseFirestore.instance
        .collection('destination')
        .doc(id)
        .delete();
  }
}