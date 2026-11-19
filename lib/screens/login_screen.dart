// =============================================================
// LOGIN SCREEN (Modul VI - Shared Preferences)
// =============================================================
// ALUR:
//   1. User mengisi username & password, lalu tekan "Login"
//   2. Validasi: kosong?               -> SnackBar merah
//   3. Cari akun di Hive box 'users'
//      tidak ada / password salah?     -> SnackBar merah
//   4. Berhasil -> simpan 'isLogin' & 'username' ke SharedPreferences
//                  (supaya tetap login walau aplikasi ditutup)
//   5. Pindah ke HomeScreen dengan pushReplacement
//
// 🟡 SALIN, UBAH SEDIKIT: cari [UBAH-LOGIN-1] & [UBAH-LOGIN-2]
//    (hanya jika halaman utamamu bukan HomeScreen)
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 🔧 [UBAH-LOGIN-1] import halaman tujuan setelah login berhasil
import 'list_screen.dart';
// import 'register_screen.dart';

// StatefulWidget karena halaman ini punya data yang berubah
// (isi TextField) dan memakai controller.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // TextEditingController = "remote" untuk membaca isi TextField.
  // Cara baca: _usernameController.text
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // Fungsi bantu: menampilkan SnackBar MERAH berisi pesan error.
  // Dibuat fungsi supaya tidak menulis kode yang sama berulang kali.
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // async karena ada proses yang harus ditunggu (SharedPreferences)
  void _login() async {
    // .trim() membuang spasi di awal & akhir input
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // ----- VALIDASI 1: tidak boleh kosong -----
    if (username.isEmpty || password.isEmpty) {
      _showError('Username dan password tidak boleh kosong!');
      return; // "return" = hentikan fungsi di sini, jangan lanjut login
    }

    // ----- VALIDASI 2: cocokkan dengan akun tetap dari soal -----
    // Soal: username = nama panggilan, password = 3 digit akhir NIM.
    // (versi template memakai Hive box 'users' + Register, tidak dipakai lagi)
    if (username != 'Loddy' || password != '120') {
      _showError('Login Gagal! Username atau password salah.');
      return;
    }

    // ----- LOGIN BERHASIL: simpan ke SharedPreferences -----
    // Format: prefs.set<TipeData>('key', nilai)
    //   setBool   -> true/false
    //   setString -> teks
    //   setInt    -> angka
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLogin', true); // dibaca di main.dart
    await prefs.setString('username', username); // ditampilkan di Home

    // "mounted" = apakah halaman ini masih tampil?
    // WAJIB dicek sebelum memakai context SETELAH await, karena selama
    // menunggu bisa saja halaman sudah ditutup.
    if (mounted) {
      // pushReplacement: halaman Login DIGANTI Home (bukan ditumpuk),
      // jadi tombol back di Home tidak kembali ke Login (Modul IV).
      Navigator.pushReplacement(
        context,
        // 🔧 [UBAH-LOGIN-2] halaman tujuan setelah login berhasil
        MaterialPageRoute(builder: (context) => ListScreen(username: username)),
      );
    }
  }

  // dispose dipanggil saat halaman ditutup.
  // Controller harus dibersihkan supaya tidak boros memori.
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login'), centerTitle: true),
      body: Center(
        // SingleChildScrollView: halaman bisa di-scroll, mencegah error
        // "overflow" (garis kuning-hitam) saat keyboard muncul
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text(
                'Selamat Datang di Resep Makanan',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24), // jarak kosong 24 pixel
              TextField(
                controller: _usernameController, // hubungkan dengan controller
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24), // sudut bulat
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true, // menyembunyikan password (•••)
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // onPressed: _login -> tanpa tanda (), karena kita
              // MEMBERIKAN fungsinya, bukan menjalankannya sekarang
              ElevatedButton(onPressed: _login, child: const Text('Login')),
              const SizedBox(height: 8),
              // TextButton(
              //   // push biasa: Register DITUMPUK di atas Login,
              //   // jadi bisa kembali ke Login dengan tombol back / pop
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => const RegisterScreen(),
              //       ),
              //     );
              //   },
              //   child: const Text('Belum punya akun? Daftar di sini'),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
