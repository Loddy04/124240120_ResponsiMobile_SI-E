// =============================================================
// MAIN.DART - titik awal aplikasi (yang PERTAMA dijalankan)
// =============================================================
// ALUR APLIKASI:
//
//   main()
//    ├─ siapkan Hive (box 'users' & 'favorites')
//    ├─ baca SharedPreferences 'isLogin'
//    └─ runApp(MainApp)
//         ├─ isLogin == true  -> HomeScreen   (langsung masuk)
//         └─ isLogin == false -> LoginScreen  <-> RegisterScreen
//
//   HomeScreen  -> klik menu  -> ListScreen  -> klik item -> DetailScreen
//                               (ikon ♥)    -> FavoriteScreen
//
// PEMBAGIAN PENYIMPANAN:
//   - Hive              : data berbentuk object (akun, favorit)
//   - SharedPreferences : data kecil key-value (status login, username)
//
// SAAT RESPONSI: cari [UBAH-MAIN-1] sampai [UBAH-MAIN-5].
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 🔧 [UBAH-MAIN-1] IMPORT
// Sesuaikan dengan nama file model Hive & halaman yang kamu pakai.
import 'models/favorite.dart';
// import 'models/user.dart'; // tidak dipakai: login memakai akun tetap
import 'screens/list_screen.dart';
import 'screens/login_screen.dart';

// main() dibuat "async" karena di dalamnya ada proses yang harus
// ditunggu ("await") sebelum aplikasi tampil.
void main() async {
  // WAJIB jika main() memakai await sebelum runApp.
  // Memastikan Flutter sudah siap berkomunikasi dengan sistem HP.
  // Tanpa baris ini aplikasi bisa crash saat dibuka (Modul VI).
  WidgetsFlutterBinding.ensureInitialized();

  // ---------- HIVE ----------
  // 1. Inisialisasi Hive & tentukan lokasi penyimpanan di HP
  await Hive.initFlutter();

  // 🔧 [UBAH-MAIN-2] DAFTARKAN ADAPTER
  // Adapter (dari file .g.dart hasil build_runner) mengajari Hive cara
  // menyimpan object kita. Nama adapter = NamaClass + "Adapter".
  // Satu baris untuk setiap model Hive.
  // Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(FavoriteAdapter());

  // 🔧 [UBAH-MAIN-3] BUKA BOX
  // Box = "tabel" penyimpanan. Harus dibuka SEBELUM dipakai.
  // Nama box di sini HARUS SAMA dengan yang dipakai di halaman lain:
  //   'users'     -> login_screen.dart & register_screen.dart
  //   'favorites' -> detail_screen.dart & favorite_screen.dart
  // await Hive.openBox<User>('users');
  await Hive.openBox<Favorite>('favorites');

  // ---------- SHARED PREFERENCES ----------
  // Cek apakah user sebelumnya sudah login (dan belum logout).
  // getBool('isLogin') -> true / false / null (jika belum pernah disimpan).
  // "?? false" -> kalau null, anggap belum login.
  // Key 'isLogin' & 'username' HARUS SAMA dengan di login_screen.dart
  // dan fungsi _logout di home_screen.dart.
  final prefs = await SharedPreferences.getInstance();
  final bool isLogin = prefs.getBool('isLogin') ?? false;
  final String username = prefs.getString('username') ?? '';

  // Jalankan aplikasi, sambil mengirim status login ke MainApp
  runApp(MainApp(isLogin: isLogin, username: username));
}

// Widget paling atas aplikasi.
// StatelessWidget karena isinya tidak pernah berubah.
class MainApp extends StatelessWidget {
  final bool isLogin;
  final String username;

  const MainApp({super.key, required this.isLogin, required this.username});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // hilangkan pita "DEBUG" di pojok
      // 🔧 [UBAH-MAIN-4] JUDUL & TEMA
      // Tema berlaku untuk SEMUA halaman. Ganti warna di sini saja.
      title: 'Rumah Makan',
      theme: ThemeData(
        useMaterial3: true,
        // warna dasar; warna tombol, chip, dll. diturunkan dari sini
        colorSchemeSeed: const Color.fromARGB(255, 138, 244, 140),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 14, 182, 50), // warna AppBar
          foregroundColor: Color.fromARGB(255, 138, 244, 140), // warna teks & ikon di AppBar
        ),
      ),
      // 🔧 [UBAH-MAIN-5] HALAMAN PERTAMA
      // Kondisi ? jikaTrue : jikaFalse  (ternary operator)
      // Ganti HomeScreen dengan halaman utamamu jika namanya berbeda.
      home: isLogin ? ListScreen(username: username) : const LoginScreen(),
    );
  }
}
