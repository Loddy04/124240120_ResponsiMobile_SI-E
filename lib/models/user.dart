// =============================================================
// MODEL USER UNTUK HIVE (Modul VI)
// =============================================================
// Menyimpan akun hasil Register ke database lokal Hive.
// Saat Login, username & password dicocokkan dengan data di sini.
//
// 🟢 FILE INI BISA DISALIN UTUH ke proyek baru.
//
// LANGKAH MEMBUAT MODEL HIVE (berlaku juga untuk favorite.dart):
//   1. import 'package:hive/hive.dart';
//   2. tulis: part 'nama_file.g.dart';
//   3. beri @HiveType(typeId: X) di atas class, lalu extends HiveObject
//   4. beri @HiveField(0), @HiveField(1), ... di atas setiap field
//   5. jalankan di terminal:
//        dart run build_runner build --delete-conflicting-outputs
//   6. muncul file user.g.dart yang berisi class UserAdapter
//   7. daftarkan di main.dart: Hive.registerAdapter(UserAdapter());
import 'package:hive/hive.dart';

// "part" menghubungkan file ini dengan file hasil generate build_runner.
// Selama build_runner belum dijalankan, baris ini MERAH (error). Itu normal.
part 'user.g.dart';

// typeId = nomor identitas class di Hive. Hive tidak menyimpan nama class,
// yang disimpan adalah angka ini.
// ⚠️ Setiap model Hive WAJIB punya typeId BERBEDA (User = 0, Favorite = 1).
@HiveType(typeId: 0)
class User extends HiveObject {
  // Nomor di @HiveField juga harus unik DI DALAM class ini (0, 1, 2, ...)
  @HiveField(0)
  final String username;

  @HiveField(1)
  final String password;

  User({required this.username, required this.password});
}
