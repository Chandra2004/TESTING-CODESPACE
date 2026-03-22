# Panduan Membuat Proyek Laravel Baru dengan Koneksi MySQL di GitHub Codespace

## Pendahuluan
GitHub Codespace memungkinkan pengembangan aplikasi Laravel dengan mudah di lingkungan cloud. Panduan ini menjelaskan langkah-langkah lengkap untuk membuat proyek Laravel baru dan menghubungkannya ke database MySQL.

## Prasyarat
- Akun GitHub aktif
- VS Code dengan ekstensi GitHub Codespaces terinstal
- Pengetahuan dasar tentang terminal dan Laravel

## Langkah 1: Membuat Repository Baru di GitHub
1. Buka GitHub.com dan login ke akun Anda.
2. Klik tombol **"New repository"**.
3. Berikan nama repository (misalnya: `laravel-project`).
4. Pilih **"Public"** atau **"Private"** sesuai kebutuhan.
5. Centang **"Add a README file"** untuk inisialisasi awal.
6. Klik **"Create repository"**.

## Langkah 2: Membuat dan Mengakses Codespace
1. Dari halaman repository yang baru dibuat, klik tombol **"Code"**.
2. Pilih tab **"Codespaces"**.
3. Klik **"Create codespace on main"**.
4. Tunggu beberapa menit hingga codespace fully loaded (Anda akan melihat VS Code interface di browser).

## Langkah 3: Instal Laravel
1. Buka terminal di codespace (Ctrl + ` atau View > Terminal).
2. Pastikan Composer terinstal (biasanya sudah tersedia di codespace Ubuntu).
3. Jalankan perintah berikut untuk membuat proyek Laravel baru:
   ```bash
   composer create-project laravel/laravel .
   ```
   Perintah ini akan mengunduh dan menginstal Laravel ke direktori saat ini.

## Langkah 4: Instal dan Konfigurasi MySQL
1. Update paket sistem:
   ```bash
   sudo apt update
   ```
2. Instal MySQL server:
   ```bash
   sudo apt install -y mysql-server
   ```
3. Mulai layanan MySQL:
   ```bash
   sudo service mysql start
   ```
4. Buat database untuk proyek Laravel:
   ```bash
   sudo mysql -u root -e "CREATE DATABASE laravel;"
   ```

## Langkah 5: Konfigurasi PHP untuk Mendukung MySQL
1. Instal ekstensi PHP MySQL yang sesuai dengan versi PHP (biasanya PHP 8.3):
   ```bash
   sudo apt install -y php8.3-mysql
   ```
2. Edit file konfigurasi PHP (`php.ini`) untuk mengaktifkan ekstensi:
   - Cari lokasi `php.ini`: `php --ini | grep "Configuration File"`
   - Edit file tersebut (misalnya `/usr/local/php/8.3.14/ini/php.ini`)
   - Uncomment baris berikut:
     ```
     extension=mysqlnd
     extension=pdo_mysql
     ```
   - Pastikan `extension_dir` menunjuk ke direktori ekstensi yang benar:
     ```
     extension_dir = "/usr/lib/php/20230831/"
     ```
3. Verifikasi ekstensi terload:
   ```bash
   php -r "var_dump(extension_loaded('pdo_mysql'));"
   ```
   Harus mengembalikan `bool(true)`.

## Langkah 6: Konfigurasi Laravel untuk Koneksi Database
1. Edit file `.env` di root proyek Laravel:
   ```
   DB_CONNECTION=mysql
   DB_HOST=127.0.0.1
   DB_PORT=3306
   DB_DATABASE=laravel
   DB_USERNAME=root
   DB_PASSWORD=
   ```
2. Atur autentikasi user root MySQL agar bisa digunakan oleh Laravel:
   ```bash
   sudo mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '';"
   sudo mysql -u root -e "FLUSH PRIVILEGES;"
   ```
3. Jalankan migrasi database untuk membuat tabel-tabel default Laravel:
   ```bash
   php artisan migrate
   ```

## Langkah 7: Menjalankan Aplikasi Laravel
1. Jalankan server development Laravel:
   ```bash
   php artisan serve
   ```
2. Buka browser dan akses `http://localhost:8000` (atau port yang ditampilkan di terminal).

## Catatan Tambahan dan Troubleshooting
- **Koneksi MySQL tanpa sudo**: Jika `mysql -u root` tidak bisa, gunakan `mysql -u root -h 127.0.0.1 -P 3306` (password kosong).
- **Error "could not find driver"**: Pastikan ekstensi PHP MySQL sudah terinstal dan diaktifkan.
- **Restart MySQL**: Jika ada masalah koneksi, restart dengan `sudo service mysql restart`.
- **Permission socket**: Jika socket MySQL bermasalah, ubah permission dengan `sudo chmod 666 /var/run/mysqld/mysqld.sock` (hati-hati, hanya untuk development).
- **Versi PHP**: Pastikan versi PHP kompatibel dengan Laravel (minimal 8.1).

## Kesimpulan
Dengan mengikuti panduan ini, Anda dapat dengan mudah membuat proyek Laravel baru dan menghubungkannya ke database MySQL di GitHub Codespace. Lingkungan ini ideal untuk pengembangan dan testing aplikasi Laravel tanpa perlu setup lokal.

Jika ada masalah atau pertanyaan, periksa log error Laravel di `storage/logs/laravel.log` atau tanyakan di komunitas Laravel.

## Tambahan: Skrip Startup MySQL Otomatis di Codespace
1. Tambahkan alias (opsional) ke `~/.bashrc` atau `~/.zshrc`:
   ```bash
   alias startmysql='sudo service mysql start && sudo service mysql status'
   ```
2. Muat ulang konfigurasi shell:
   ```bash
   source ~/.bashrc  # atau source ~/.zshrc
   ```
3. Jalankan setiap masuk codespace:
   ```bash
   startmysql
   ```

Jika Anda tetap ingin `mysql -u root` tanpa `sudo`, gunakan koneksi TCP:
```bash
mysql -u root -h 127.0.0.1 -P 3306
```
Ini biasanya bekerja di Codespace ketika koneksi socket lokal dibatasi.

## Otomatisasi dengan devcontainer
Bila proyek Anda menggunakan DevContainer (recommended untuk Codespaces), buat folder dan file:
- `.devcontainer/devcontainer.json`
- `.devcontainer/init-mysql.sh`

Isi `devcontainer.json`:
```json
{
  "name": "Laravel Codespace",
  "image": "mcr.microsoft.com/devcontainers/php:8.3",
  "features": {
    "ghcr.io/devcontainers/features/mysql:1": {}
  },
  "postStartCommand": "bash .devcontainer/init-mysql.sh",
  "customizations": {
    "vscode": {
      "extensions": ["amiralizadeh9480.laravel-extra-intellisense"]
    }
  }
}
```

Isi `init-mysql.sh`:
```bash
#!/bin/bash
sudo service mysql start
sudo chmod 755 /var/run/mysqld
sudo chmod 666 /var/run/mysqld/mysqld.sock
sudo mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY ''; FLUSH PRIVILEGES;"
mysql -u root -h 127.0.0.1 -P 3306 -e "SELECT 1;"
```

Beri izin execute:
```bash
chmod +x .devcontainer/init-mysql.sh
```

Setelah itu, rebuild/restart Codespace, MySQL akan di-start dan dicek otomatis di awal sesi.

## Perbaikan Permisi Socket MySQL (untuk mysql -u root tanpa sudo)
Jika `mysql -u root` gagal dengan error `Can't connect ... (13)`, kemungkinan direktori socket MySQL tidak dapat diakses oleh user non-root.

Jalankan:
```bash
sudo chmod 755 /var/run/mysqld
sudo chmod 666 /var/run/mysqld/mysqld.sock
```
Kemudian cek lagi:
```bash
mysql -u root -e "SELECT 1;"
```
