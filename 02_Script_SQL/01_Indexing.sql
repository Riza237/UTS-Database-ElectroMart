-- ElectroMart | 01_Indexing.sql
-- Target DBMS: MySQL 8.x / MariaDB
-- Catatan: Struktur tabel mengikuti database yang telah dibuat di DBeaver.
-- Index dibuat bersyarat agar file aman dijalankan ulang.

USE ElectroMart;

DELIMITER //

DROP PROCEDURE IF EXISTS sp_buat_index_electromart//
CREATE PROCEDURE sp_buat_index_electromart()
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.statistics
        WHERE table_schema = DATABASE()
          AND table_name = 'pelanggan'
          AND index_name = 'idx_nama_pelanggan'
    ) THEN
        CREATE INDEX idx_nama_pelanggan ON pelanggan(nama_pelanggan);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.statistics
        WHERE table_schema = DATABASE()
          AND table_name = 'produk'
          AND index_name = 'idx_nama_produk'
    ) THEN
        CREATE INDEX idx_nama_produk ON produk(nama_produk);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.statistics
        WHERE table_schema = DATABASE()
          AND table_name = 'penjualan'
          AND index_name = 'idx_tanggal_penjualan'
    ) THEN
        CREATE INDEX idx_tanggal_penjualan ON penjualan(tanggal);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.statistics
        WHERE table_schema = DATABASE()
          AND table_name = 'penjualan'
          AND index_name = 'idx_pelanggan_tanggal'
    ) THEN
        CREATE INDEX idx_pelanggan_tanggal
        ON penjualan(id_pelanggan, tanggal);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.statistics
        WHERE table_schema = DATABASE()
          AND table_name = 'detail_penjualan'
          AND index_name = 'idx_detail_id_penjualan'
    ) THEN
        CREATE INDEX idx_detail_id_penjualan
        ON detail_penjualan(id_penjualan);
    END IF;
END//

DELIMITER ;

CALL sp_buat_index_electromart();
DROP PROCEDURE sp_buat_index_electromart;

-- Pemeriksaan index pada MySQL (pengganti katalog pg_indexes PostgreSQL).
SHOW INDEX FROM pelanggan;
SHOW INDEX FROM produk;
SHOW INDEX FROM penjualan;
SHOW INDEX FROM detail_penjualan;
SHOW INDEX FROM log_stok;

-- Alasan pemilihan:
-- 1. pelanggan(nama_pelanggan): mempercepat pencarian pelanggan berdasarkan nama.
-- 2. produk(nama_produk): mempercepat pencarian produk berdasarkan nama.
-- 3. penjualan(tanggal): mempercepat pencarian/rekap transaksi berdasarkan tanggal.
-- 4. penjualan(id_pelanggan, tanggal): composite index untuk riwayat transaksi pelanggan
--    dalam rentang waktu. id_pelanggan diletakkan pertama karena pencarian dibatasi
--    berdasarkan pelanggan, kemudian tanggal.
-- 5. detail_penjualan(id_penjualan): mempercepat pengambilan rincian berdasarkan transaksi.
