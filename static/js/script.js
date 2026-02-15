// Dashboard Charts
document.addEventListener('DOMContentLoaded', function() {
    // Inisialisasi semua chart jika kita berada di dashboard
    if (document.getElementById('chartStokKategori')) {
        loadStokKategoriChart();
    }
    
    if (document.getElementById('chartDistribusiTujuan')) {
        loadDistribusiTujuanChart();
    }
    
    if (document.getElementById('chartPenerimaanBulanan')) {
        loadPenerimaanBulananChart();
    }
    
    // Datepicker untuk filter tanggal
    const dateInputs = document.querySelectorAll('input[type="date"]');
    dateInputs.forEach(input => {
        // Set nilai default untuk filter tanggal
        if (!input.value) {
            const today = new Date();
            const firstDay = new Date(today.getFullYear(), today.getMonth(), 1);
            
            if (input.name === 'start_date' || input.id === 'start_date') {
                input.valueAsDate = firstDay;
            }
            
            if (input.name === 'end_date' || input.id === 'end_date') {
                input.valueAsDate = today;
            }
        }
    });
    
    // Konfirmasi hapus data
    const deleteButtons = document.querySelectorAll('.btn-delete');
    deleteButtons.forEach(button => {
        button.addEventListener('click', function(e) {
            if (!confirm('Apakah Anda yakin ingin menghapus data ini?')) {
                e.preventDefault();
            }
        });
    });
    
    // Format mata uang
    const currencyElements = document.querySelectorAll('.currency');
    currencyElements.forEach(el => {
        const value = parseFloat(el.textContent);
        if (!isNaN(value)) {
            el.textContent = formatCurrency(value);
        }
    });
    
    // Format angka
    const numberElements = document.querySelectorAll('.number');
    numberElements.forEach(el => {
        const value = parseFloat(el.textContent);
        if (!isNaN(value)) {
            el.textContent = formatNumber(value);
        }
    });
    
    // Auto-generate kode bahan
    const kodeBahanInput = document.getElementById('kode_bahan');
    if (kodeBahanInput && !kodeBahanInput.value) {
        // Generate kode bahan otomatis
        const today = new Date();
        const timestamp = today.getTime().toString().slice(-6);
        kodeBahanInput.value = `MBG-${timestamp}`;
    }
});

// Format mata uang Rupiah
function formatCurrency(value) {
    return new Intl.NumberFormat('id-ID', {
        style: 'currency',
        currency: 'IDR',
        minimumFractionDigits: 0
    }).format(value);
}

// Format angka dengan pemisah ribuan
function formatNumber(value) {
    return new Intl.NumberFormat('id-ID').format(value);
}

// Load chart stok per kategori
function loadStokKategoriChart() {
    fetch('/api/stok-per-kategori')
        .then(response => response.json())
        .then(data => {
            const ctx = document.getElementById('chartStokKategori').getContext('2d');
            new Chart(ctx, {
                type: 'doughnut',
                data: {
                    labels: data.labels,
                    datasets: [{
                        label: 'Stok per Kategori',
                        data: data.values,
                        backgroundColor: [
                            '#3498db', '#2ecc71', '#e74c3c', '#f39c12',
                            '#9b59b6', '#1abc9c', '#34495e', '#95a5a6'
                        ],
                        borderWidth: 1
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: true,
                            position: 'right'
                        },
                        tooltip: {
                            callbacks: {
                                label: function(context) {
                                    return context.label + ': ' + formatNumber(context.raw);
                                }
                            }
                        }
                    }
                }
            });
        });
}

// Load chart distribusi per tujuan
function loadDistribusiTujuanChart() {
    // Data dari backend (kita bisa buat API juga, tapi untuk sekarang pakai data statis)
    const data = {
        labels: ['Sekolah', 'Posyandu', 'Puskesmas', 'Rumah Sakit', 'Lainnya'],
        values: [45, 25, 15, 10, 5]
    };
    
    const ctx = document.getElementById('chartDistribusiTujuan').getContext('2d');
    new Chart(ctx, {
        type: 'bar',
        data: {
            labels: data.labels,
            datasets: [{
                label: 'Jumlah Distribusi',
                data: data.values,
                backgroundColor: '#2ecc71',
                borderColor: '#27ae60',
                borderWidth: 1
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: true,
                    position: 'top'
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: {
                        callback: function(value) {
                            return value;
                        }
                    }
                }
            }
        }
    });
}

// Load chart penerimaan bulanan
function loadPenerimaanBulananChart() {
    fetch('/api/penerimaan-per-bulan')
        .then(response => response.json())
        .then(data => {
            const ctx = document.getElementById('chartPenerimaanBulanan').getContext('2d');
            new Chart(ctx, {
                type: 'line',
                data: {
                    labels: data.labels,
                    datasets: [{
                        label: 'Penerimaan Bulanan',
                        data: data.values,
                        borderColor: '#3498db',
                        backgroundColor: 'rgba(52, 152, 219, 0.1)',
                        borderWidth: 3,
                        fill: true,
                        tension: 0.4
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: true,
                            position: 'top'
                        },
                        tooltip: {
                            callbacks: {
                                label: function(context) {
                                    return formatNumber(context.raw);
                                }
                            }
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            ticks: {
                                callback: function(value) {
                                    return formatNumber(value);
                                }
                            }
                        }
                    }
                }
            });
        });
}

// Fungsi untuk print laporan
function printLaporan() {
    window.print();
}

// Fungsi untuk export laporan ke CSV
function exportToCSV() {
    // Ambil data dari tabel
    const table = document.querySelector('.table');
    const rows = table.querySelectorAll('tr');
    let csv = [];
    
    rows.forEach(row => {
        const rowData = [];
        const cols = row.querySelectorAll('td, th');
        
        cols.forEach(col => {
            // Bersihkan teks dari format mata uang
            let text = col.textContent.trim();
            // Hilangkan simbol Rp dan titik pemisah ribuan
            text = text.replace('Rp', '').replace(/\./g, '').replace(',', '.');
            rowData.push(`"${text}"`);
        });
        
        csv.push(rowData.join(','));
    });
    
    // Buat file CSV
    const csvContent = csv.join('\n');
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    
    // Buat nama file
    const today = new Date().toISOString().split('T')[0];
    const filename = `laporan_stok_${today}.csv`;
    
    link.href = URL.createObjectURL(blob);
    link.download = filename;
    link.style.display = 'none';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
}

// Validasi form
function validateForm(formId) {
    const form = document.getElementById(formId);
    if (form) {
        form.addEventListener('submit', function(e) {
            let isValid = true;
            const requiredFields = form.querySelectorAll('[required]');
            
            requiredFields.forEach(field => {
                if (!field.value.trim()) {
                    isValid = false;
                    field.style.borderColor = '#e74c3c';
                    
                    // Tambah pesan error
                    let errorMsg = field.parentNode.querySelector('.error-message');
                    if (!errorMsg) {
                        errorMsg = document.createElement('div');
                        errorMsg.className = 'error-message';
                        errorMsg.style.color = '#e74c3c';
                        errorMsg.style.fontSize = '0.85rem';
                        errorMsg.style.marginTop = '5px';
                        errorMsg.textContent = 'Field ini wajib diisi';
                        field.parentNode.appendChild(errorMsg);
                    }
                } else {
                    field.style.borderColor = '#ddd';
                    
                    // Hapus pesan error
                    const errorMsg = field.parentNode.querySelector('.error-message');
                    if (errorMsg) {
                        errorMsg.remove();
                    }
                }
            });
            
            if (!isValid) {
                e.preventDefault();
                alert('Harap isi semua field yang wajib diisi!');
            }
        });
    }
}

// Panggil validasi untuk form tertentu
document.addEventListener('DOMContentLoaded', function() {
    validateForm('formTambahBahan');
    validateForm('formTambahPenerimaan');
    validateForm('formTambahPengeluaran');
});

// Real-time stok check untuk form pengeluaran
const bahanSelect = document.getElementById('bahan_id');
const jumlahInput = document.getElementById('jumlah');
const stokInfo = document.getElementById('stok-info');

if (bahanSelect && jumlahInput && stokInfo) {
    bahanSelect.addEventListener('change', function() {
        const selectedOption = this.options[this.selectedIndex];
        const stok = selectedOption.getAttribute('data-stok');
        const satuan = selectedOption.getAttribute('data-satuan');
        
        if (stok) {
            stokInfo.innerHTML = `Stok tersedia: <strong>${formatNumber(stok)} ${satuan}</strong>`;
            stokInfo.style.display = 'block';
        } else {
            stokInfo.style.display = 'none';
        }
    });
    
    jumlahInput.addEventListener('input', function() {
        const selectedOption = bahanSelect.options[bahanSelect.selectedIndex];
        const stok = parseFloat(selectedOption.getAttribute('data-stok'));
        const jumlah = parseFloat(this.value) || 0;
        
        if (stok && jumlah > stok) {
            this.style.borderColor = '#e74c3c';
            stokInfo.innerHTML = `Stok tidak mencukupi! Stok tersedia: <strong>${formatNumber(stok)}</strong>`;
            stokInfo.style.color = '#e74c3c';
        } else {
            this.style.borderColor = '#ddd';
            const satuan = selectedOption.getAttribute('data-satuan');
            stokInfo.innerHTML = `Stok tersedia: <strong>${formatNumber(stok)} ${satuan}</strong>`;
            stokInfo.style.color = '#666';
        }
    });
}

// Auto-calculate total harga untuk penerimaan
const hargaSatuanInput = document.getElementById('harga_satuan');
const jumlahPenerimaanInput = document.getElementById('jumlah');
const totalHargaDisplay = document.getElementById('total-harga-display');

if (hargaSatuanInput && jumlahPenerimaanInput && totalHargaDisplay) {
    function calculateTotal() {
        const harga = parseFloat(hargaSatuanInput.value) || 0;
        const jumlah = parseFloat(jumlahPenerimaanInput.value) || 0;
        const total = harga * jumlah;
        
        totalHargaDisplay.textContent = formatCurrency(total);
    }
    
    hargaSatuanInput.addEventListener('input', calculateTotal);
    jumlahPenerimaanInput.addEventListener('input', calculateTotal);
    
    // Hitung awal
    calculateTotal();
}