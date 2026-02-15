-- Database: inventaris_sppg
CREATE DATABASE IF NOT EXISTS inventaris_sppg;
USE inventaris_sppg;

-- Tabel users untuk login
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    nama_lengkap VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    role ENUM('admin', 'gudang', 'distribusi', 'pimpinan') DEFAULT 'gudang',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel kategori bahan
CREATE TABLE kategori_bahan (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nama_kategori VARCHAR(100) NOT NULL,
    deskripsi TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel satuan
CREATE TABLE satuan (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nama_satuan VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel bahan (master data bahan makanan)
CREATE TABLE bahan (
    id INT AUTO_INCREMENT PRIMARY KEY,
    kode_bahan VARCHAR(20) UNIQUE NOT NULL,
    nama_bahan VARCHAR(200) NOT NULL,
    kategori_id INT,
    satuan_id INT,
    stok_minimum DECIMAL(10,2) DEFAULT 0,
    stok_maksimum DECIMAL(10,2) DEFAULT 0,
    berat_per_unit DECIMAL(10,2) DEFAULT 1.00,
    kalori_per_unit DECIMAL(10,2) DEFAULT 0,
    protein_per_unit DECIMAL(10,2) DEFAULT 0,
    status ENUM('aktif', 'nonaktif') DEFAULT 'aktif',
    keterangan TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (kategori_id) REFERENCES kategori_bahan(id),
    FOREIGN KEY (satuan_id) REFERENCES satuan(id)
);

-- Tabel penerimaan (barang masuk ke gudang)
CREATE TABLE penerimaan (
    id INT AUTO_INCREMENT PRIMARY KEY,
    no_penerimaan VARCHAR(50) UNIQUE NOT NULL,
    tanggal DATE NOT NULL,
    bahan_id INT NOT NULL,
    jumlah DECIMAL(10,2) NOT NULL,
    satuan_id INT NOT NULL,
    harga_satuan DECIMAL(15,2) DEFAULT 0,
    total_harga DECIMAL(15,2) AS (jumlah * harga_satuan),
    supplier VARCHAR(200),
    no_batch VARCHAR(100),
    tanggal_produksi DATE,
    tanggal_kadaluarsa DATE,
    kondisi ENUM('baik', 'rusak_sebagian', 'rusak_total') DEFAULT 'baik',
    penerima VARCHAR(100),
    catatan TEXT,
    status ENUM('draft', 'disetujui', 'ditolak') DEFAULT 'draft',
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (bahan_id) REFERENCES bahan(id),
    FOREIGN KEY (satuan_id) REFERENCES satuan(id)
);

-- Tabel pengeluaran (barang keluar dari gudang)
CREATE TABLE pengeluaran (
    id INT AUTO_INCREMENT PRIMARY KEY,
    no_pengeluaran VARCHAR(50) UNIQUE NOT NULL,
    tanggal DATE NOT NULL,
    bahan_id INT NOT NULL,
    jumlah DECIMAL(10,2) NOT NULL,
    satuan_id INT NOT NULL,
    tujuan VARCHAR(200) NOT NULL,
    jenis_tujuan ENUM('sekolah', 'posyandu', 'puskesmas', 'rumah_sakit', 'lainnya') DEFAULT 'sekolah',
    nama_tujuan VARCHAR(200),
    alamat_tujuan TEXT,
    penerima VARCHAR(100),
    catatan TEXT,
    status ENUM('draft', 'dikirim', 'diterima') DEFAULT 'draft',
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (bahan_id) REFERENCES bahan(id),
    FOREIGN KEY (satuan_id) REFERENCES satuan(id)
);

-- Tabel stok (current stock)
CREATE TABLE stok (
    id INT AUTO_INCREMENT PRIMARY KEY,
    bahan_id INT UNIQUE NOT NULL,
    jumlah DECIMAL(10,2) DEFAULT 0,
    satuan_id INT NOT NULL,
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (bahan_id) REFERENCES bahan(id),
    FOREIGN KEY (satuan_id) REFERENCES satuan(id)
);

-- Tabel monitoring kualitas
CREATE TABLE monitoring_kualitas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    bahan_id INT NOT NULL,
    tanggal_check DATE NOT NULL,
    suhu_gudang DECIMAL(5,2),
    kelembaban_gudang DECIMAL(5,2),
    kondisi_fisik ENUM('sangat_baik', 'baik', 'cukup', 'buruk') DEFAULT 'baik',
    kondisi_kemasan ENUM('utuh', 'rusak_ringan', 'rusak_berat') DEFAULT 'utuh',
    status_kadaluarsa ENUM('aman', 'mendekati', 'kadaluarsa') DEFAULT 'aman',
    petugas VARCHAR(100),
    catatan TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (bahan_id) REFERENCES bahan(id)
);

-- Insert data user
INSERT INTO users (username, password, nama_lengkap, email, role) VALUES
('admin', 'admin123', 'Administrator SPPG', 'admin@sppg.local', 'admin'),
('gudang', 'gudang123', 'Budi Santoso', 'gudang@sppg.local', 'gudang'),
('distribusi', 'dist123', 'Siti Aminah', 'distribusi@sppg.local', 'distribusi'),
('pimpinan', 'pimp123', 'Dr. Ahmad Fauzi', 'pimpinan@sppg.local', 'pimpinan');

-- Insert satuan
INSERT INTO satuan (nama_satuan) VALUES
('Kilogram'),
('Gram'),
('Liter'),
('Mililiter'),
('Unit'),
('Pieces'),
('Karton'),
('Sachet'),
('Bungkus');

-- Insert kategori bahan
INSERT INTO kategori_bahan (nama_kategori, deskripsi) VALUES
('Protein Hewani', 'Sumber protein dari hewan'),
('Protein Nabati', 'Sumber protein dari tumbuhan'),
('Karbohidrat', 'Sumber energi utama'),
('Sayuran', 'Sumber vitamin dan mineral'),
('Buah-buahan', 'Sumber vitamin dan serat'),
('Produk Susu', 'Sumber kalsium dan protein'),
('Minuman', 'Minuman bergizi'),
('Lainnya', 'Bahan tambahan lainnya');

-- Insert data bahan (contoh bahan MBG)
INSERT INTO bahan (kode_bahan, nama_bahan, kategori_id, satuan_id, stok_minimum, stok_maksimum, berat_per_unit, kalori_per_unit, protein_per_unit) VALUES
('MBG-001', 'Telur Ayam', 1, 5, 1000, 5000, 60.00, 77.00, 6.30),
('MBG-002', 'Daging Ayam', 1, 1, 50, 200, 1.00, 165.00, 31.00),
('MBG-003', 'Ikan Segar', 1, 1, 30, 150, 1.00, 130.00, 22.00),
('MBG-004', 'Tempe', 2, 1, 20, 100, 1.00, 150.00, 20.00),
('MBG-005', 'Kacang Tanah', 2, 1, 15, 80, 1.00, 567.00, 25.80),
('MBG-006', 'Beras', 3, 1, 200, 1000, 1.00, 360.00, 6.80),
('MBG-007', 'Mie Instan', 3, 9, 500, 2000, 85.00, 380.00, 8.00),
('MBG-008', 'Wortel', 4, 1, 25, 100, 1.00, 41.00, 0.90),
('MBG-009', 'Bayam', 4, 1, 20, 80, 1.00, 23.00, 2.90),
('MBG-010', 'Apel', 5, 5, 100, 500, 182.00, 95.00, 0.50),
('MBG-011', 'Pisang', 5, 5, 150, 600, 118.00, 105.00, 1.30),
('MBG-012', 'Susu UHT', 6, 8, 200, 1000, 250.00, 150.00, 8.00),
('MBG-013', 'Air Mineral', 7, 3, 50, 200, 1.00, 0.00, 0.00);

-- Insert initial stok
INSERT INTO stok (bahan_id, jumlah, satuan_id) VALUES
(1, 1500, 5),
(2, 100, 1),
(3, 50, 1),
(4, 40, 1),
(5, 30, 1),
(6, 300, 1),
(7, 800, 9),
(8, 50, 1),
(9, 40, 1),
(10, 200, 5),
(11, 250, 5),
(12, 600, 8),
(13, 100, 3);

-- Insert data penerimaan
INSERT INTO penerimaan (no_penerimaan, tanggal, bahan_id, jumlah, satuan_id, harga_satuan, supplier, tanggal_kadaluarsa, kondisi, penerima, status) VALUES
('TRM-2024-001', '2024-01-15', 1, 3000, 5, 2000, 'PT Sumber Protein', '2024-03-15', 'baik', 'Budi Santoso', 'disetujui'),
('TRM-2024-002', '2024-01-16', 6, 500, 1, 12000, 'BULOG', '2024-12-31', 'baik', 'Budi Santoso', 'disetujui'),
('TRM-2024-003', '2024-01-18', 12, 1000, 8, 5000, 'PT Indomilk', '2024-06-30', 'baik', 'Siti Aminah', 'disetujui'),
('TRM-2024-004', '2024-01-20', 8, 50, 1, 8000, 'Supplier Sayuran', '2024-02-20', 'baik', 'Budi Santoso', 'disetujui');

-- Insert data pengeluaran
INSERT INTO pengeluaran (no_pengeluaran, tanggal, bahan_id, jumlah, satuan_id, tujuan, jenis_tujuan, nama_tujuan, alamat_tujuan, penerima, status) VALUES
('KLR-2024-001', '2024-01-20', 1, 1000, 5, 'distribusi', 'sekolah', 'SDN 01 Jakarta', 'Jl. Merdeka No.1', 'Guru Andi', 'dikirim'),
('KLR-2024-002', '2024-01-22', 6, 100, 1, 'distribusi', 'posyandu', 'Posyandu Melati', 'Jl. Bunga No.5', 'Bidan Rina', 'dikirim'),
('KLR-2024-003', '2024-01-25', 12, 300, 8, 'distribusi', 'sekolah', 'SDN 02 Bandung', 'Jl. Asia Afrika No.10', 'Kepala Sekolah', 'dikirim');

-- Insert monitoring kualitas
INSERT INTO monitoring_kualitas (bahan_id, tanggal_check, suhu_gudang, kelembaban_gudang, kondisi_fisik, kondisi_kemasan, status_kadaluarsa, petugas, catatan) VALUES
(1, '2024-01-25', 18.5, 65.0, 'sangat_baik', 'utuh', 'aman', 'Budi Santoso', 'Kondisi telur baik, tidak ada retak'),
(6, '2024-01-25', 20.0, 60.0, 'baik', 'utuh', 'aman', 'Budi Santoso', 'Beras kering, bebas kutu'),
(12, '2024-01-25', 15.0, 55.0, 'sangat_baik', 'utuh', 'aman', 'Siti Aminah', 'Susu disimpan di rak pendingin');