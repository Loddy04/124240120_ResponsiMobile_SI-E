// =============================================================
// FAVORITE SCREEN - Halaman Favorite
// =============================================================
// Menampilkan SEMUA data favorit (news, blog, report jadi satu)
// yang tersimpan di Hive box 'favorites'.
//
// KENAPA LIST INI SELALU TER-UPDATE?
//   Karena dibungkus ValueListenableBuilder yang "mendengarkan" box.
//   Setiap ada put/delete (dari halaman Detail MAUPUN dari halaman ini),
//   builder dijalankan ulang -> list digambar ulang otomatis.
//   (Soal: "list favourite terupdate terlepas dilakukannya perubahan
//    di halaman favourite maupun dari halaman detil")
//
// ALUR:
//   box kosong?  -> pesan "Belum ada data favorite"
//   ada isinya   -> box.values.toList() -> ListView
//   tombol ♥     -> fav.delete()  -> item hilang dari list
//   klik item    -> buka DetailScreen lagi (pakai menu & itemId)
//
// SAAT RESPONSI: cari [UBAH-FAVSCREEN-1] & [UBAH-FAVSCREEN-2].
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/favorite.dart';
import 'detail_screen.dart';

// StatelessWidget cukup: perubahan tampilan diurus ValueListenableBuilder,
// bukan setState.
class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorite')),
      // ⚠️ BAGIAN ValueListenableBuilder INI JANGAN DIUBAH
      body: ValueListenableBuilder(
        // .listenable() (dari package hive_flutter) = mengubah box menjadi
        // sesuatu yang bisa "didengarkan"
        valueListenable: Hive.box<Favorite>('favorites').listenable(),
        // builder dijalankan ulang SETIAP KALI isi box berubah
        builder: (context, Box<Favorite> box, _) {
          // ----- Favorit masih kosong -----
          if (box.isEmpty) {
            return const Center(child: Text('Belum ada data favorite'));
          }

          // ----- Ambil semua data favorit -----
          // box.values = semua isi box, .toList() = jadikan List
          final favorites = box.values.toList();

          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final fav = favorites[index]; // satu data favorit (object Favorite)
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  // 🔧 [UBAH-FAVSCREEN-1] FIELD YANG DITAMPILKAN
                  // (harus ada di models/favorite.dart)
                  leading: SizedBox(
                    width: 64,
                    height: 48,
                    child: Image.network(
                      fav.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.broken_image, size: 32);
                      },
                    ),
                  ),
                  title: Text(
                    fav.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text('${fav.author}  •  ★ ${fav.rating}'),
                  // ----- HAPUS FAVORIT -----
                  // Tombol ♥ merah di kanan. Setelah dihapus,
                  // ValueListenableBuilder otomatis menggambar ulang list
                  // sehingga item langsung hilang.
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    tooltip: 'Hapus dari favorite',
                    onPressed: () {
                      // fav adalah HiveObject, jadi bisa menghapus DIRINYA
                      // SENDIRI dengan .delete() tanpa perlu tahu key-nya.
                      // (Sama saja dengan: box.delete(Favorite.makeKey(fav.menu, fav.itemId)))
                      fav.delete();
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Dihapus dari favorite')),
                      );
                    },
                  ),
                  // Klik item -> buka detail-nya lagi
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            // 🔧 [UBAH-FAVSCREEN-2] data yang dikirim ke DetailScreen
                            DetailScreen(id: fav.itemId),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
