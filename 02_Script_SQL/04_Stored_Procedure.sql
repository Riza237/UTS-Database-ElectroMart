-- ElectroMart | 04_Stored_Procedure.sql
-- Target DBMS: MySQL 8.x / MariaDB
-- Stored procedure sesuai spesifikasi tugas: tampil produk, tambah produk, ubah harga.
-- Struktur produk yang digunakan saat ini: id_produk, nama_produk, harga, stok.
-- Jika tabel produk Anda memiliki kolom kategori, sesuaikan SP_Tambah_Produk.

USE ElectroMart;

DROP PROCEDURE IF EXISTS SP_Tampil_Produk;
DROP PROCEDURE IF EXISTS SP_Tambah_Produk;
DROP PROCEDURE IF EXISTS SP_Ubah_Harga;
DROP PROCEDURE IF EXISTS SP_Demo_Hapus;

DELIMITER //

CREATE PROCEDURE SP_Tampil_Produk()
BEGIN
    SELECT * FROM produk ORDER BY id_produk;
END//

CREATE PROCEDURE SP_Tambah_Produk(
    IN p_id_produk VARCHAR(10),
    IN p_nama_produk VARCHAR(100),
    IN p_harga DECIMAL(12,2),
    IN p_stok INT
)
BEGIN
    IF p_harga < 0 OR p_stok < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Harga dan stok tidak boleh negatif';
    END IF;

    INSERT INTO produk (id_produk, nama_produk, harga, stok)
    VALUES (p_id_produk, p_nama_produk, p_harga, p_stok);
END//

CREATE PROCEDURE SP_Ubah_Harga(
    IN p_id_produk VARCHAR(10),
    IN p_harga_baru DECIMAL(12,2)
)
BEGIN
    IF p_harga_baru < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Harga baru tidak boleh negatif';
    END IF;

    UPDATE produk
    SET harga = p_harga_baru
    WHERE id_produk = p_id_produk;

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Produk tidak ditemukan atau harga tidak berubah';
    END IF;
END//

-- Procedure sementara untuk demonstrasi DROP PROCEDURE.
CREATE PROCEDURE SP_Demo_Hapus()
BEGIN
    SELECT 'Procedure demonstrasi berhasil dipanggil' AS pesan;
END//

DELIMITER ;

-- Pengujian procedure utama:
CALL SP_Tampil_Produk();

-- Contoh pengujian tambah produk (gunakan ID baru yang belum terpakai):
-- CALL SP_Tambah_Produk('PRD011', 'Produk Uji ElectroMart', 500000, 10);

-- Contoh pengujian ubah harga (gunakan produk uji agar harga produk utama tidak berubah):
-- CALL SP_Ubah_Harga('PRD011', 550000);

-- Demonstrasi pemanggilan dan penghapusan procedure sementara.
CALL SP_Demo_Hapus();
DROP PROCEDURE SP_Demo_Hapus;

-- Procedure utama tetap tersedia:
-- CALL SP_Tampil_Produk();
-- CALL SP_Tambah_Produk(...);
-- CALL SP_Ubah_Harga(...);
