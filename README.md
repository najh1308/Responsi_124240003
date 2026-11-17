# Template Kuis Praktikum Mobile (Flutter + GetX)

Fitur: Login/Register (Hive) - Session (SharedPreferences) - "Hi, <nama>" -
List API + filter + pencarian + infinite scroll - Detail - Favorit per akun -
Keranjang per akun - Profil (edit + logout).

Akun bawaan: `latresponsi` / `latres123` (ubah di `lib/config/app_config.dart`).

## Cara pakai
```bash
flutter create template_kuis      # atau pakai project yang sudah ada
cd template_kuis
# timpa folder lib/ dan pubspec.yaml dengan milik template ini
# hapus test/widget_test.dart (bawaan flutter create, pasti error)
flutter pub get
flutter run
```
Android release butuh izin internet di AndroidManifest.xml:
`<uses-permission android:name="android.permission.INTERNET"/>`

## Peta file (baca komentar di tiap file)
| Folder | Isi | Yang biasanya diubah saat soal berganti |
|---|---|---|
| config/app_config.dart | semua konstanta | host API, akun bawaan, judul |
| model/ | bentuk data | item.dart (field & key JSON) |
| service/api_service.dart | request HTTP | endpoint & cara baca JSON |
| service/local_db.dart, auth_service.dart | Hive | jarang |
| controller/ | logika & state | item_controller (filter), cart_controller |
| routes/ | daftar halaman | tambah GetPage jika ada halaman baru |
| view/pages/ | tampilan | field yang ditampilkan |

Cari tanda `▶ UBAH` di kode: itu bagian yang paling sering perlu disesuaikan.
