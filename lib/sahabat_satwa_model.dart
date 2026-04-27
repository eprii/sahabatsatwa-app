// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

class SahabatSatwa {
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
  String foto_url;   // 🆕 foto thumbnail
  String provinsi;   // 🆕 provinsi (Jawa, Bali, Sumatra, dll)

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

  factory SahabatSatwa.fromDocument(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return SahabatSatwa(
      id_zoo: doc.id,
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

  Map<String, dynamic> toMap() {
    return {
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
    };
  }

  List<double>? get parsedKoordinat {
    try {
      final parts = koordinat.split(',');
      if (parts.length != 2) return null;
      return [double.parse(parts[0].trim()), double.parse(parts[1].trim())];
    } catch (_) {
      return null;
    }
  }

  static Future<void> addData(SahabatSatwa data) async {
    await FirebaseFirestore.instance
        .collection('sahabatsatwa-app')
        .add(data.toMap());
  }

  static Future<void> updateData(String id, SahabatSatwa data) async {
    await FirebaseFirestore.instance
        .collection('sahabatsatwa-app')
        .doc(id)
        .update(data.toMap());
  }

  static Future<void> deleteData(String id) async {
    await FirebaseFirestore.instance
        .collection('sahabatsatwa-app')
        .doc(id)
        .delete();
  }
}
