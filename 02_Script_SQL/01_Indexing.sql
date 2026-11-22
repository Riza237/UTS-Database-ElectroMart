-- =========================================================
-- ElectroMart | 01_Indexing.sql
-- DBMS: MySQL 8.x / MariaDB
-- Tujuan: membuat single index dan composite index.
-- Jalankan dengan koneksi administrator pada database ElectroMart.
-- Aman dijalankan ulang: index hanya dibuat jika belum ada.
-- =========================================================

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
        CREATE INDEX idx_nama_pelanggan
        ON pelanggan(nama_pelanggan);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.statistics
        WHERE table_schema = DATABASE()
          AND table_name = 'produk'
          AND index_name = 'idx_nama_produk'
    ) THEN
        CREATE INDEX idx_nama_produk
        ON produk(nama_produk);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.statistics
        WHERE table_schema = DATABASE()
          AND table_name = 'penjualan'
          AND index_name = 'idx_tanggal_penjualan'
    ) THEN
        CREATE INDEX idx_tanggal_penjualan
        ON penjualan(tanggal);
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

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.statistics
        WHERE table_schema = DATABASE()
          AND table_name = 'log_stok'
          AND index_name = 'idx_tanggal_log'
    ) THEN
        CREATE INDEX idx_tanggal_log
        ON log_stok(tanggal);
    END IF;
END//

DELIMITER ;

CALL sp_buat_index_electromart();
DROP PROCEDURE IF EXISTS sp_buat_index_electromart;

-- Verifikasi index.
SHOW INDEX FROM pelanggan;
SHOW INDEX FROM produk;
SHOW INDEX FROM penjualan;
SHOW INDEX FROM detail_penjualan;
SHOW INDEX FROM log_stok;

-- Keterangan:
-- idx_nama_pelanggan: pencarian pelanggan berdasarkan nama.
-- idx_nama_produk: pencarian produk berdasarkan nama.
-- idx_tanggal_penjualan: pencarian/rekap transaksi berdasarkan tanggal.
-- idx_pelanggan_tanggal: composite index riwayat pelanggan berdasarkan tanggal.
-- idx_detail_id_penjualan: pencarian rincian berdasarkan ID transaksi.
-- idx_tanggal_log: pencarian riwayat perubahan stok berdasarkan tanggal.
