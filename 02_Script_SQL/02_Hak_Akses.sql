-- ElectroMart | 02_Hak_Akses.sql
-- Target DBMS: MySQL 8.x / MariaDB
-- Jalankan menggunakan koneksi administrator/root.
-- Akun menggunakan password kosong sesuai konfigurasi praktikum saat ini.

USE ElectroMart;

CREATE ROLE IF NOT EXISTS 'role_admin';
CREATE ROLE IF NOT EXISTS 'role_penjualan';
CREATE ROLE IF NOT EXISTS 'role_gudang';
CREATE ROLE IF NOT EXISTS 'role_manajer';

CREATE USER IF NOT EXISTS 'admin_em'@'localhost' IDENTIFIED BY '';
CREATE USER IF NOT EXISTS 'penjualan_em'@'localhost' IDENTIFIED BY '';
CREATE USER IF NOT EXISTS 'gudang_em'@'localhost' IDENTIFIED BY '';
CREATE USER IF NOT EXISTS 'manajer_em'@'localhost' IDENTIFIED BY '';

-- Hak akses sesuai prinsip least privilege.
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

-- Hubungkan user dengan role.
GRANT 'role_admin' TO 'admin_em'@'localhost';
GRANT 'role_penjualan' TO 'penjualan_em'@'localhost';
GRANT 'role_gudang' TO 'gudang_em'@'localhost';
GRANT 'role_manajer' TO 'manajer_em'@'localhost';

SET DEFAULT ROLE ALL TO
    'admin_em'@'localhost',
    'penjualan_em'@'localhost',
    'gudang_em'@'localhost',
    'manajer_em'@'localhost';

-- Contoh REVOKE: pembatasan akses log stok untuk role penjualan.
REVOKE ALL PRIVILEGES ON ElectroMart.log_stok FROM 'role_penjualan';

-- Pengujian dijalankan dari masing-masing koneksi user, bukan dari koneksi admin:
-- SELECT CURRENT_USER();
-- SHOW GRANTS;
-- Penjualan: SELECT * FROM produk; SELECT * FROM pelanggan; (berhasil)
-- Penjualan: SELECT * FROM log_stok; (harus ditolak)
-- Gudang: SELECT * FROM produk; (berhasil)
-- Gudang: UPDATE produk SET stok = stok + 1 WHERE id_produk = 'PRD001'; (berhasil)
-- Manajer: SELECT * FROM penjualan; (berhasil)
-- Manajer: UPDATE penjualan SET total_harga = 100000 WHERE id_penjualan = 'TRX008';
-- (harus ditolak)

-- Prinsip least privilege: setiap user hanya menerima hak minimum sesuai pekerjaannya.
