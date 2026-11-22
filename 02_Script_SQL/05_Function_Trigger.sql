-- =========================================================
-- ElectroMart | 05_Function_Trigger.sql
-- DBMS: MySQL 8.x / MariaDB
-- Functions: hitung_total, hitung_diskon, fn_hitung_total_bayar.
-- Triggers: trg_validasi_stok dan trg_kurangi_stok.
--
-- PENTING:
-- Hanya satu trigger BEFORE dan satu trigger AFTER yang digunakan.
-- Trigger lama dengan nama lain dihapus untuk mencegah pengurangan stok ganda.
-- =========================================================

USE ElectroMart;

-- Hapus trigger versi sebelumnya agar tidak terjadi eksekusi ganda.
DROP TRIGGER IF EXISTS validasi_penjualan;
DROP TRIGGER IF EXISTS update_stok_penjualan;
DROP TRIGGER IF EXISTS trg_validasi_stok;
DROP TRIGGER IF EXISTS trg_kurangi_stok;

-- Hapus function versi sebelumnya sebelum dibuat kembali.
DROP FUNCTION IF EXISTS hitung_total;
DROP FUNCTION IF EXISTS hitung_diskon;
DROP FUNCTION IF EXISTS fn_hitung_total_bayar;

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

-- Function kompatibilitas untuk procedure penjualan tahap sebelumnya.
CREATE FUNCTION fn_hitung_total_bayar(
    p_total DECIMAL(12,2),
    p_diskon DECIMAL(12,2)
)
RETURNS DECIMAL(12,2)
DETERMINISTIC
NO SQL
BEGIN
    RETURN GREATEST(p_total - p_diskon, 0);
END//

-- Validasi dilakukan sebelum detail transaksi disimpan.
CREATE TRIGGER trg_validasi_stok
BEFORE INSERT ON detail_penjualan
FOR EACH ROW
BEGIN
    DECLARE v_stok INT DEFAULT NULL;
    DECLARE v_harga DECIMAL(12,2) DEFAULT NULL;
    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_stok = NULL, v_harga = NULL;

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

    SET NEW.harga_satuan = v_harga;
    SET NEW.subtotal = hitung_total(v_harga, NEW.jumlah);
END//

-- Setelah detail berhasil dimasukkan, stok dikurangi dan log dicatat.
CREATE TRIGGER trg_kurangi_stok
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

-- Pengujian function tanpa mengubah data tabel.
SELECT hitung_total(250000, 2) AS total_pembelian;
SELECT hitung_diskon(1500000) AS diskon_10_persen;
SELECT hitung_diskon(850000) AS tanpa_diskon;
SELECT fn_hitung_total_bayar(1500000, 150000) AS total_setelah_diskon;

-- Verifikasi trigger dan function.
SHOW TRIGGERS;
SHOW FUNCTION STATUS WHERE Db = 'ElectroMart';

-- Uji trigger dengan INSERT detail hanya jika tersedia transaksi induk.
-- Uji stok tidak cukup: masukkan jumlah lebih besar daripada stok produk.
-- Hasil yang diharapkan: error 'Stok produk tidak mencukupi'.
-- Jangan mengulang INSERT yang berhasil karena stok dan log akan berubah.
