-- ElectroMart | 03_Transaksi.sql
-- Target DBMS: MySQL 8.x / MariaDB
-- Jalankan menggunakan koneksi administrator pada database ElectroMart.
-- Catatan: contoh transaksi memakai ID TRX009 agar tidak menimpa TRX001-TRX008.
-- Trigger pengurangan stok yang telah dibuat pada file 05 akan mengurangi stok otomatis
-- ketika detail_penjualan dimasukkan. Karena itu, jangan mengurangi stok secara manual lagi.

USE ElectroMart;

-- Skenario A: transaksi berhasil (COMMIT).
START TRANSACTION;

INSERT INTO penjualan
(id_penjualan, tanggal, id_pelanggan, id_pegawai,
 total_harga, diskon, total_bayar)
VALUES
('TRX009', NOW(), 'PLG001', 'PGW002', 0, 0, 0);

-- Contoh pembelian 1 laptop dan 2 mouse.
-- Subtotal: 14.500.000 + (2 x 250.000) = 15.000.000.
INSERT INTO detail_penjualan
(id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
VALUES
('TRX009', 'PRD001', 1, 14500000, 14500000),
('TRX009', 'PRD002', 2, 250000, 500000);

UPDATE penjualan
SET total_harga = 15000000,
    diskon = 1500000,
    total_bayar = 13500000
WHERE id_penjualan = 'TRX009';

COMMIT;

-- Buktikan transaksi berhasil.
SELECT * FROM penjualan WHERE id_penjualan = 'TRX009';
SELECT * FROM detail_penjualan WHERE id_penjualan = 'TRX009';

-- Skenario B: transaksi gagal dan dibatalkan (ROLLBACK).
-- Jumlah PRD003 sengaja melebihi stok yang tersedia. Jika trigger validasi aktif,
-- INSERT akan ditolak. Jalankan blok ini terpisah untuk demonstrasi ROLLBACK.
START TRANSACTION;

INSERT INTO penjualan
(id_penjualan, tanggal, id_pelanggan, id_pegawai,
 total_harga, diskon, total_bayar)
VALUES
('TRX010', NOW(), 'PLG002', 'PGW002', 0, 0, 0);

-- Contoh ini diharapkan ditolak trigger karena jumlah 999 melebihi stok.
-- Jika INSERT ditolak, jalankan ROLLBACK secara manual di SQL Editor.
-- INSERT INTO detail_penjualan
-- (id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
-- VALUES ('TRX010', 'PRD003', 999, 1200000, 1198800000);

ROLLBACK;

-- Skenario C: SAVEPOINT dan ROLLBACK TO SAVEPOINT.
START TRANSACTION;

UPDATE produk
SET stok = stok + 2
WHERE id_produk = 'PRD008';

SAVEPOINT sp_setelah_stok_masuk;

UPDATE produk
SET stok = stok - 1
WHERE id_produk = 'PRD003';

ROLLBACK TO SAVEPOINT sp_setelah_stok_masuk;
RELEASE SAVEPOINT sp_setelah_stok_masuk;

COMMIT;

-- Verifikasi hasil akhir.
SELECT id_produk, nama_produk, stok
FROM produk
WHERE id_produk IN ('PRD001', 'PRD002', 'PRD003', 'PRD008');

-- Analisis ACID:
-- Atomicity: perubahan satu transaksi disimpan seluruhnya atau dibatalkan.
-- Consistency: constraint, foreign key, dan trigger menjaga validitas data.
-- Isolation: transaksi berjalan dalam batas isolasi yang ditentukan DBMS.
-- Durability: COMMIT membuat perubahan tersimpan secara permanen.
