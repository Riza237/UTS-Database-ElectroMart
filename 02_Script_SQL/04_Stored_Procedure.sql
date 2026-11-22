-- =========================================================
-- ElectroMart | 04_Stored_Procedure.sql
-- DBMS: MySQL 8.x / MariaDB
-- Procedure: tampil produk, tambah produk, ubah harga.
-- Struktur tabel produk: id_produk, nama_produk, harga, stok.
-- =========================================================

USE ElectroMart;

DROP PROCEDURE IF EXISTS SP_Tampil_Produk;
DROP PROCEDURE IF EXISTS SP_Tambah_Produk;
DROP PROCEDURE IF EXISTS SP_Ubah_Harga;
DROP PROCEDURE IF EXISTS SP_Demo_Hapus;

DELIMITER //

CREATE PROCEDURE SP_Tampil_Produk()
BEGIN
    SELECT id_produk, nama_produk, harga, stok
    FROM produk
    ORDER BY id_produk;
END//

CREATE PROCEDURE SP_Tambah_Produk(
    IN p_id_produk VARCHAR(10),
    IN p_nama_produk VARCHAR(100),
    IN p_harga DECIMAL(12,2),
    IN p_stok INT
)
BEGIN
    IF p_id_produk IS NULL OR p_nama_produk IS NULL
       OR p_harga IS NULL OR p_stok IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Seluruh data produk wajib diisi';
    END IF;

    IF p_harga < 0 OR p_stok < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Harga dan stok tidak boleh negatif';
    END IF;

    IF EXISTS (
        SELECT 1 FROM produk WHERE id_produk = p_id_produk
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ID produk sudah digunakan';
    END IF;

    INSERT INTO produk (id_produk, nama_produk, harga, stok)
    VALUES (p_id_produk, p_nama_produk, p_harga, p_stok);
END//

CREATE PROCEDURE SP_Ubah_Harga(
    IN p_id_produk VARCHAR(10),
    IN p_harga_baru DECIMAL(12,2)
)
BEGIN
    IF p_harga_baru IS NULL OR p_harga_baru < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Harga baru harus valid dan tidak negatif';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM produk WHERE id_produk = p_id_produk
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Produk tidak ditemukan';
    END IF;

    UPDATE produk
    SET harga = p_harga_baru
    WHERE id_produk = p_id_produk;
END//

-- Procedure sementara untuk demonstrasi DROP PROCEDURE.
CREATE PROCEDURE SP_Demo_Hapus()
BEGIN
    SELECT 'Procedure demonstrasi berhasil dipanggil' AS pesan;
END//

DELIMITER ;

-- Pengujian procedure tampil.
CALL SP_Tampil_Produk();

-- Pengujian tambah dan ubah harga menggunakan ID uji PRD011.
-- Pastikan PRD011 belum digunakan. Jalankan dua CALL berikut terpisah.
-- CALL SP_Tambah_Produk('PRD011', 'Produk Uji ElectroMart', 500000, 10);
-- CALL SP_Ubah_Harga('PRD011', 550000);
-- SELECT * FROM produk WHERE id_produk = 'PRD011';

-- Demonstrasi DROP PROCEDURE.
CALL SP_Demo_Hapus();
DROP PROCEDURE IF EXISTS SP_Demo_Hapus;

-- Procedure utama tetap tersedia dan dapat dipanggil:
-- CALL SP_Tampil_Produk();
-- CALL SP_Tambah_Produk('ID_BARU', 'Nama Produk', 100000, 5);
-- CALL SP_Ubah_Harga('ID_PRODUK', 120000);
