-- =========================================================
-- ElectroMart | 06_View.sql
-- DBMS: MySQL 8.x / MariaDB
-- View: produk, transaksi (JOIN), laporan agregasi, stok rendah.
-- =========================================================

USE ElectroMart;

DROP VIEW IF EXISTS View_Produk;
DROP VIEW IF EXISTS View_Transaksi;
DROP VIEW IF EXISTS View_Laporan_Penjualan;
DROP VIEW IF EXISTS View_Stok_Rendah;
DROP VIEW IF EXISTS View_Demo_Hapus;

-- 1. View produk.
CREATE VIEW View_Produk AS
SELECT id_produk, nama_produk, harga, stok
FROM produk;

-- 2. View transaksi dengan JOIN tabel pelanggan.
CREATE VIEW View_Transaksi AS
SELECT
    p.id_penjualan,
    p.tanggal,
    p.id_pelanggan,
    pl.nama_pelanggan,
    p.id_pegawai,
    p.total_harga,
    p.diskon,
    p.total_bayar
FROM penjualan AS p
INNER JOIN pelanggan AS pl
    ON p.id_pelanggan = pl.id_pelanggan;

-- 3. View agregasi laporan penjualan per bulan.
CREATE VIEW View_Laporan_Penjualan AS
SELECT
    DATE_FORMAT(tanggal, '%Y-%m') AS periode,
    COUNT(*) AS jumlah_transaksi,
    SUM(total_harga) AS total_penjualan,
    SUM(diskon) AS total_diskon,
    SUM(total_bayar) AS total_pendapatan
FROM penjualan
GROUP BY DATE_FORMAT(tanggal, '%Y-%m');

-- 4. View produk dengan stok rendah (di bawah 5 unit).
CREATE VIEW View_Stok_Rendah AS
SELECT id_produk, nama_produk, stok
FROM produk
WHERE stok < 5
WITH CASCADED CHECK OPTION;

-- Pengujian seluruh view.
SELECT * FROM View_Produk;
SELECT * FROM View_Transaksi;
SELECT * FROM View_Laporan_Penjualan;
SELECT * FROM View_Stok_Rendah;

-- Uji WITH CHECK OPTION secara opsional dan terpisah:
-- UPDATE View_Stok_Rendah
-- SET stok = 10
-- WHERE id_produk = 'PRD003';
-- Hasil yang diharapkan: ditolak karena stok 10 tidak memenuhi kondisi stok < 5.
-- Jangan jalankan pada data utama kecuali untuk demonstrasi.

-- Demonstrasi DROP VIEW.
CREATE VIEW View_Demo_Hapus AS
SELECT id_produk, nama_produk
FROM produk;

SELECT * FROM View_Demo_Hapus;
DROP VIEW IF EXISTS View_Demo_Hapus;
