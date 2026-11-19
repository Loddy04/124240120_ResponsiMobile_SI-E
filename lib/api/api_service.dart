// =============================================================
// API SERVICE (Modul V - "Class dengan Static Method")
// =============================================================
// File ini = "KURIR" yang mengambil data dari internet.
// SEMUA link API ditulis di file ini, bukan di halaman (screen).
//
// Halaman cukup memanggil:
//     final data = await ApiService.getList('articles');
// tanpa perlu tahu link-nya apa atau bentuk JSON-nya bagaimana.
//
// "static" = fungsi bisa dipanggil lewat nama class (ApiService.getList)
// tanpa membuat object dulu (tidak perlu ApiService().getList).
//
// ALUR SETIAP FUNGSI:
//   1. http.get(link)        -> minta data ke server, tunggu jawabannya
//   2. cek statusCode == 200 -> 200 = berhasil, selain itu = gagal
//   3. jsonDecode(body)      -> teks JSON diubah jadi Map / List Dart
//   4. ambil bagian datanya  -> misal data['results']
//   5. fromJson              -> setiap Map diubah jadi object model
//
// SAAT RESPONSI: cari [UBAH-API-1], [UBAH-API-2], [UBAH-API-3].
import 'dart:convert'; // berisi jsonDecode
import 'package:http/http.dart' as http; // "as http" -> dipanggil dengan http.get

import '../models/recipes_item.dart';

class ApiService {
  // 🔧 [UBAH-API-1] BASE URL
  // Bagian AWAL link yang sama untuk semua endpoint.
  // Sisanya disambung di setiap fungsi:
  //   News    -> https://api.spaceflightnewsapi.net/v4/articles/
  //   Blogs   -> https://api.spaceflightnewsapi.net/v4/blogs/
  //   Reports -> https://api.spaceflightnewsapi.net/v4/reports/
  static const String baseUrl = 'https://dummyjson.com/recipes';

  // -----------------------------------------------------------
  // FUNGSI LIST: mengambil banyak data sesuai menu
  // -----------------------------------------------------------
  // Future<List<SpaceItem>> artinya: fungsi ini mengembalikan
  // List<SpaceItem>, tapi "nanti" (setelah internet menjawab).
  // Karena itu dipanggil dengan "await" di dalam fungsi "async".
  //
  // Parameter `menu` diisi 'articles' / 'blogs' / 'reports' (dari Home).
  // Jadi SATU fungsi bisa dipakai untuk TIGA endpoint, karena bentuk
  // JSON ketiganya sama.
  // (parameter `menu` dihapus: dummyjson hanya punya 1 endpoint resep)
  static Future<List<RecipesItem>> getList() async {
    // Uri.parse mengubah teks menjadi alamat yang dimengerti http.get.
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      // response.body = teks JSON mentah dari server.
      // jsonDecode mengubahnya menjadi Map (jika diawali { )
      // atau List (jika diawali [ ).
      final data = jsonDecode(response.body);

      // 🔧 [UBAH-API-2] LETAK DAFTAR DATA DI JSON
      // JSON API ini berbentuk: { "count": ..., "results": [ ... ] }
      // -> daftarnya ada di laci "results".
      // Jika JSON soalmu langsung berbentuk [ ... ], tulis:
      //     final List<dynamic> results = data;
      // dummyjson: { "recipes": [ ... ], "total": ... } -> laci "recipes"
      final List<dynamic> results = data['recipes'];

      // .map  -> untuk SETIAP item di results, jalankan fromJson
      // .toList() -> kumpulkan hasilnya menjadi List<SpaceItem>
      return results.map((json) => RecipesItem.fromJson(json)).toList();
    } else {
      // throw = "lempar" error. Nanti ditangkap oleh try-catch di halaman,
      // lalu halaman menampilkan pesan error.
      throw Exception('Gagal memuat data');
    }
  }

  // -----------------------------------------------------------
  // FUNGSI DETAIL: mengambil SATU data berdasarkan id
  // -----------------------------------------------------------
  // Contoh link: https://api.spaceflightnewsapi.net/v4/articles/40887/
  static Future<RecipesItem> getDetail(int id) async {
    // 🔧 [UBAH-API-3] FORMAT LINK DETAIL
    // Sesuaikan dengan soal:
    //   path  -> '$baseUrl/$menu/$id/'     (seperti di sini)
    //   query -> '$baseUrl/game?id=$id'    (misal API FreeToGame)
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      // Endpoint detail mengembalikan SATU object { ... },
      // jadi langsung diubah dengan fromJson (tanpa .map)
      final data = jsonDecode(response.body);
      return RecipesItem.fromJson(data);
    } else {
      throw Exception('Gagal memuat detail data');
    }
  }
}
