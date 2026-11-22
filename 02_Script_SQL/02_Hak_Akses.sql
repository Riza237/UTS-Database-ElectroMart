-- =========================================================
-- ElectroMart | 02_Hak_Akses.sql
-- DBMS: MySQL 8.x / MariaDB
-- Jalankan menggunakan koneksi administrator/root.
-- Password kosong mengikuti konfigurasi akun praktikum.
-- =========================================================

USE ElectroMart;

-- 1. Membuat role dan user jika belum tersedia.
CREATE ROLE IF NOT EXISTS 'role_admin';
CREATE ROLE IF NOT EXISTS 'role_penjualan';
CREATE ROLE IF NOT EXISTS 'role_gudang';
CREATE ROLE IF NOT EXISTS 'role_manajer';

CREATE USER IF NOT EXISTS 'admin_em'@'localhost' IDENTIFIED BY '';
CREATE USER IF NOT EXISTS 'penjualan_em'@'localhost' IDENTIFIED BY '';
CREATE USER IF NOT EXISTS 'gudang_em'@'localhost' IDENTIFIED BY '';
CREATE USER IF NOT EXISTS 'manajer_em'@'localhost' IDENTIFIED BY '';

-- 2. Memberikan hak akses minimum sesuai pekerjaan (least privilege).
GRANT ALL PRIVILEGES ON ElectroMart.* TO 'role_admin';

GRANT SELECT ON ElectroMart.produk TO 'role_penjualan';
GRANT SELECT ON ElectroMart.pelanggan TO 'role_penjualan';
GRANT INSERT ON ElectroMart.penjualan TO 'role_penjualan';
GRANT INSERT ON ElectroMart.detail_penjualan TO 'role_penjualan';

GRANT SELECT ON ElectroMart.produk TO 'role_gudang';
GRANT UPDATE (stok) ON ElectroMart.produk TO 'role_gudang';
GRANT SELECT, INSERT ON ElectroMart.log_stok TO 'role_gudang';

GRANT SELECT ON ElectroMart.produk TO 'role_manajer';
GRANT SELECT ON ElectroMart.penjualan TO 'role_manajer';
GRANT SELECT ON ElectroMart.detail_penjualan TO 'role_manajer';

-- 3. Menghubungkan user dengan role.
GRANT 'role_admin' TO 'admin_em'@'localhost';
GRANT 'role_penjualan' TO 'penjualan_em'@'localhost';
GRANT 'role_gudang' TO 'gudang_em'@'localhost';
GRANT 'role_manajer' TO 'manajer_em'@'localhost';

SET DEFAULT ROLE ALL TO
    'admin_em'@'localhost',
    'penjualan_em'@'localhost',
    'gudang_em'@'localhost',
    'manajer_em'@'localhost';

-- 4. Demonstrasi REVOKE:
-- Hak SELECT diberikan sementara lalu dicabut kembali.
-- Hasil akhir: role_penjualan tidak mempunyai hak SELECT pada log_stok.
GRANT SELECT ON ElectroMart.log_stok TO 'role_penjualan';
REVOKE SELECT ON ElectroMart.log_stok FROM 'role_penjualan';

-- 5. Verifikasi role dan hak akses dari koneksi administrator.
SHOW GRANTS FOR 'role_admin';
SHOW GRANTS FOR 'role_penjualan';
SHOW GRANTS FOR 'role_gudang';
SHOW GRANTS FOR 'role_manajer';

-- 6. Pengujian dari koneksi masing-masing user (jalankan terpisah).
-- Semua koneksi:
-- SELECT CURRENT_USER();
-- SHOW GRANTS;

-- Penjualan:
-- SELECT * FROM produk;       -- diizinkan
-- SELECT * FROM pelanggan;    -- diizinkan
-- SELECT * FROM log_stok;     -- seharusnya ditolak

-- Gudang:
-- SELECT * FROM produk;       -- diizinkan
-- UPDATE produk SET stok = stok + 1
-- WHERE id_produk = 'PRD001'; -- diizinkan, tetapi mengubah data; hanya untuk uji

-- Manajer:
-- SELECT * FROM penjualan;    -- diizinkan
-- UPDATE penjualan SET total_harga = 1
-- WHERE id_penjualan = 'TRX008'; -- seharusnya ditolak

-- Prinsip least privilege: user hanya memperoleh hak minimum sesuai tugas.
