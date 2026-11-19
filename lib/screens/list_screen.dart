// =============================================================
// LIST SCREEN - Halaman List
// =============================================================
// Isi halaman:
//   - List data (news / blog / report) dari API
//   - Tiap item: thumbnail (leading), judul, author
//   - Ikon ♥ di AppBar untuk membuka halaman Favorite
//
// POLA AMBIL DATA API (dipakai di HAMPIR SEMUA halaman yang memuat API):
//   1. Siapkan variabel state : items, isLoading, errorMessage
//   2. initState()            : panggil fetchItems() saat halaman dibuka
//   3. fetchItems()           : try { ambil data } catch { simpan error }
//                               lalu setState -> layar digambar ulang
//   4. build()                : isLoading?  -> lingkaran loading
//                               error?      -> pesan error
//                               selain itu  -> tampilkan data
//
// SAAT RESPONSI: cari [UBAH-LIST-1] sampai [UBAH-LIST-6].
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_service.dart';
import '../models/recipes_item.dart';
import 'detail_screen.dart';
import 'favorite_screen.dart';
import 'login_screen.dart';

class ListScreen extends StatefulWidget {
  // Data yang DITERIMA dari LoginScreen / main.dart lewat constructor
  final String username;

  const ListScreen({super.key, required this.username});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

// Class State: tempat menyimpan data yang BERUBAH-UBAH.
// Untuk mengakses variabel milik ListScreen di atas, pakai widget.xxx
// (contoh: widget.menu, widget.title).
class _ListScreenState extends State<ListScreen> {
  // ---------------------------------------------------------
  // LOGOUT
  // ---------------------------------------------------------
  // Bisa disalin ke halaman lain yang punya tombol logout.
  // Butuh import: shared_preferences & login_screen.dart
  void _logout() async {
    // Hapus data login dari SharedPreferences, sehingga saat aplikasi
    // dibuka lagi, main.dart membaca isLogin = null -> ke LoginScreen.
    // Key HARUS SAMA dengan yang disimpan di login_screen.dart.
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLogin');
    await prefs.remove('username');
    // (prefs.clear() juga bisa: menghapus SEMUA data SharedPreferences)

    // context.mounted: cek halaman masih tampil setelah await
    if (mounted) {
      // pushAndRemoveUntil: buka Login dan HAPUS semua halaman sebelumnya
      // dari tumpukan. (route) => false artinya "jangan sisakan satu pun".
      // Hasilnya: di Login, tombol back tidak bisa kembali ke Home.
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  // ---------- 1. VARIABEL STATE ----------
  List<RecipesItem> items = []; // semua data dari API (awalnya kosong)
  bool isLoading = true; // true = sedang memuat -> tampilkan loading
  String? errorMessage; // null = tidak ada error. "?" = boleh null

  // ---------- 2. initState ----------
  // Dipanggil OTOMATIS satu kali saat halaman pertama kali dibuat.
  // Tempat yang tepat untuk mengambil data dari API (Modul V).
  @override
  void initState() {
    super.initState(); // wajib dipanggil paling atas
    fetchItems();
  }

  // ---------- 3. AMBIL DATA ----------
  // Future<void> + async: fungsi ini butuh waktu (menunggu internet)
  Future<void> fetchItems() async {
    // Reset tampilan ke "loading" (berguna saat tombol Coba Lagi ditekan)
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    // try-catch: jika terjadi error di dalam "try" (tidak ada internet,
    // server error, JSON tidak sesuai), program lompat ke "catch"
    // dan TIDAK crash.
    try {
      // 🔧 [UBAH-LIST-1] PANGGIL FUNGSI API
      // Ganti dengan fungsi list di api_service.dart milikmu,
      // misal: await ApiService.getGames();
      final data = await ApiService.getList();

      // setState: ubah data LALU gambar ulang layar.
      // Tanpa setState, data sudah masuk tapi layar tetap loading.
      setState(() {
        items = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Gagal memuat data. Periksa koneksi internet.';
        isLoading = false;
      });
    }
  }

  // ---------- 4. TAMPILAN ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resep - ${widget.username}'),
        // actions = tombol-tombol di kanan AppBar
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Favorite', // teks yang muncul saat ditekan lama
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoriteScreen()),
              );
            },
          ),
          // tombol logout
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  // Isi body dipisah ke fungsi sendiri supaya build() tetap rapi.
  // Fungsi ini memilih tampilan berdasarkan state.
  Widget _buildBody() {
    // (a) Masih loading -> indikator berputar di tengah
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // (b) Terjadi error -> pesan + tombol coba lagi
    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, // tinggi Column = setinggi isinya
          children: [
            Text(errorMessage!), // "!" = yakin tidak null (sudah dicek di if)
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: fetchItems, // ulangi ambil data
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    // (c) Data berhasil dimuat -> tampilkan list
    return Column(
      children: [
        // ---------- LIST DATA ----------
        // Expanded WAJIB: ListView di dalam Column harus diberi batas
        // tinggi. Expanded = "ambil semua sisa tinggi layar".
        Expanded(
          // ListView.builder: membuat item satu per satu sesuai kebutuhan
          // (hemat memori untuk data banyak)
          child: ListView.builder(
            itemCount: items.length, // jumlah item
            // itemBuilder dipanggil untuk SETIAP index (0, 1, 2, ...)
            itemBuilder: (context, index) {
              final item = items[index]; // data ke-index
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                // ListTile = baris siap pakai: leading | title/subtitle | trailing
                child: ListTile(
                  leading: SizedBox(
                    width: 80,
                    height: 56,
                    child: Image.network(
                      // 🔧 [UBAH-LIST-3] field GAMBAR
                      item.imageUrl,
                      fit: BoxFit.cover, // gambar memenuhi kotak, dipotong rapi
                      // EXCEPTION HANDLING gambar (diminta soal):
                      // jika gambar gagal dimuat (url rusak / kosong /
                      // tidak ada internet), tampilkan ikon pengganti
                      // alih-alih error.
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.broken_image, size: 32);
                      },
                    ),
                  ),
                  title: Text(
                    // 🔧 [UBAH-LIST-4] field JUDUL
                    item.name,
                    maxLines: 2, // maksimal 2 baris
                    overflow: TextOverflow.ellipsis, // sisanya jadi "..."
                  ),
                  // 🔧 [UBAH-LIST-5] field KETERANGAN (author/genre/dll.)
                  subtitle: Row(
                    children: [
                      Text(item.author), // asal makanan
                      const SizedBox(width: 12),
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      Text(item.rating.toString()), // rating
                    ],
                  ),
                  onTap: () {
                    // Buka detail sambil mengirim menu & id data yang diklik
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            // 🔧 [UBAH-LIST-6] data yang dikirim ke DetailScreen
                            DetailScreen(id: item.id),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
