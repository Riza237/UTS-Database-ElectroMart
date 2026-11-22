-- =========================================================
-- ElectroMart | 03_Transaksi.sql
-- DBMS: MySQL 8.x / MariaDB
-- Memuat contoh COMMIT, ROLLBACK, SAVEPOINT, dan analisis ACID.
--
-- PERHATIAN:
-- Bagian A membuat transaksi TRX009 dan trigger akan mengurangi stok.
-- Jalankan bagian A SATU KALI saja. Jangan jalankan jika TRX009 sudah ada.
-- Bagian B adalah demonstrasi gagal; jalankan terpisah sesuai petunjuk.
-- Bagian C berakhir dengan rollback sehingga stok kembali seperti semula.
-- =========================================================

USE ElectroMart;

-- =========================================================
-- A. TRANSAKSI BERHASIL (COMMIT) - JALANKAN SATU KALI
-- =========================================================

-- Periksa dahulu apakah TRX009 sudah ada.
SELECT id_penjualan
FROM penjualan
WHERE id_penjualan = 'TRX009';

-- Jika hasil pemeriksaan kosong, jalankan blok berikut.
START TRANSACTION;

INSERT INTO penjualan
(id_penjualan, tanggal, id_pelanggan, id_pegawai,
 total_harga, diskon, total_bayar)
VALUES
('TRX009', NOW(), 'PLG001', 'PGW002', 0, 0, 0);

-- Pembelian: 1 PRD001 dan 2 PRD002.
-- Trigger BEFORE INSERT mengisi harga_satuan dan subtotal.
-- Trigger AFTER INSERT mengurangi stok dan mencatat log.
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

-- Verifikasi transaksi dan dampak pada stok.
SELECT * FROM penjualan WHERE id_penjualan = 'TRX009';
SELECT * FROM detail_penjualan WHERE id_penjualan = 'TRX009';
SELECT id_produk, nama_produk, stok
FROM produk
WHERE id_produk IN ('PRD001', 'PRD002');

-- =========================================================
-- B. SIMULASI ROLLBACK KARENA STOK TIDAK CUKUP
-- Jalankan perintah-perintah berikut satu per satu.
-- Jika INSERT detail ditolak trigger, jalankan ROLLBACK.
-- =========================================================

-- START TRANSACTION;
-- INSERT INTO penjualan
-- (id_penjualan, tanggal, id_pelanggan, id_pegawai,
--  total_harga, diskon, total_bayar)
-- VALUES ('TRX010', NOW(), 'PLG002', 'PGW002', 0, 0, 0);
--
-- Jumlah 999 melebihi stok PRD003, sehingga trigger seharusnya menolak:
-- INSERT INTO detail_penjualan
-- (id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
-- VALUES ('TRX010', 'PRD003', 999, 1200000, 1198800000);
--
-- Setelah error muncul, jalankan:
-- ROLLBACK;

-- =========================================================
-- C. SAVEPOINT DAN ROLLBACK TO SAVEPOINT
-- Seluruh perubahan pada bagian ini dibatalkan.
-- =========================================================

START TRANSACTION;

UPDATE produk
SET stok = stok + 2
WHERE id_produk = 'PRD008';

SAVEPOINT sp_setelah_update_pertama;

UPDATE produk
SET stok = stok - 1
WHERE id_produk = 'PRD003';

ROLLBACK TO SAVEPOINT sp_setelah_update_pertama;

-- Batalkan juga perubahan pertama agar data awal tetap terjaga.
ROLLBACK;

-- Verifikasi stok setelah rollback.
SELECT id_produk, nama_produk, stok
FROM produk
WHERE id_produk IN ('PRD001', 'PRD002', 'PRD003', 'PRD008');

-- Analisis ACID:
-- Atomicity: perubahan dalam transaksi disimpan seluruhnya atau dibatalkan.
-- Consistency: constraint, foreign key, dan trigger menjaga validitas data.
-- Isolation: transaksi mengikuti isolation level yang ditetapkan DBMS.
-- Durability: COMMIT menyimpan perubahan secara permanen.
