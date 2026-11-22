-- ElectroMart | 05_Function_Trigger.sql
-- Target DBMS: MySQL 8.x / MariaDB
-- Fungsi sesuai tugas: hitung_total dan hitung_diskon.
-- Trigger sesuai tugas: validasi_penjualan dan update_stok_penjualan.
-- Trigger bekerja pada detail_penjualan agar stok berkurang per item yang dijual.

USE ElectroMart;

DROP TRIGGER IF EXISTS trg_validasi_stok;
DROP TRIGGER IF EXISTS trg_kurangi_stok;
DROP TRIGGER IF EXISTS validasi_penjualan;
DROP TRIGGER IF EXISTS update_stok_penjualan;

DROP FUNCTION IF EXISTS hitung_total;
DROP FUNCTION IF EXISTS hitung_diskon;

DELIMITER //

CREATE FUNCTION hitung_total(
    p_harga DECIMAL(12,2),
    p_jumlah INT
)
RETURNS DECIMAL(14,2)
DETERMINISTIC
NO SQL
BEGIN
    RETURN p_harga * p_jumlah;
END//

CREATE FUNCTION hitung_diskon(
    p_total DECIMAL(14,2)
)
RETURNS DECIMAL(14,2)
DETERMINISTIC
NO SQL
BEGIN
    IF p_total >= 1000000 THEN
        RETURN p_total * 0.10;
    END IF;
    RETURN 0;
END//

CREATE TRIGGER validasi_penjualan
BEFORE INSERT ON detail_penjualan
FOR EACH ROW
BEGIN
    DECLARE v_stok INT DEFAULT NULL;
    DECLARE v_harga DECIMAL(12,2) DEFAULT NULL;

    IF NEW.jumlah IS NULL OR NEW.jumlah <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Jumlah pembelian harus lebih dari nol';
    END IF;

    SELECT stok, harga
      INTO v_stok, v_harga
    FROM produk
    WHERE id_produk = NEW.id_produk;

    IF v_stok IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Produk tidak ditemukan';
    END IF;

    IF NEW.jumlah > v_stok THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stok produk tidak mencukupi';
    END IF;

    IF NEW.harga_satuan IS NULL OR NEW.harga_satuan <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Harga satuan harus lebih dari nol';
    END IF;

    SET NEW.harga_satuan = v_harga;
    SET NEW.subtotal = hitung_total(v_harga, NEW.jumlah);
END//

CREATE TRIGGER update_stok_penjualan
AFTER INSERT ON detail_penjualan
FOR EACH ROW
BEGIN
    UPDATE produk
    SET stok = stok - NEW.jumlah
    WHERE id_produk = NEW.id_produk;

    INSERT INTO log_stok
    (id_produk, jumlah_perubahan, tipe_transaksi, keterangan)
    VALUES
    (NEW.id_produk, -NEW.jumlah, 'KELUAR',
     CONCAT('Penjualan otomatis: ', NEW.id_penjualan));
END//

DELIMITER ;

-- Pengujian function.
SELECT hitung_total(250000, 2) AS total_pembelian;
SELECT hitung_diskon(1500000) AS diskon_10_persen;
SELECT hitung_diskon(850000) AS tanpa_diskon;

-- Pengujian trigger yang aman: periksa definisi trigger.
SHOW TRIGGERS;

-- Pengujian valid/tidak valid dilakukan pada transaksi uji terpisah.
-- Valid: INSERT detail dengan produk yang tersedia dan jumlah positif.
-- Tidak valid: jumlah nol/negatif, produk tidak terdaftar, atau jumlah melebihi stok.
-- Jangan jalankan pengujian insert berulang pada transaksi produksi karena stok akan berubah.
