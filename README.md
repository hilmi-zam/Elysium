# Praktikum Mobile: Implementasi Geocoding pada Flutter

## Overview Aplikasi Geolocation dengan Geocoding

> **Identitas**  
> Nama:  M. Hilmi Zamzami
> NIM: 362458302071
> Kelas: TRPL 2B  
> Mata Kuliah: Pemrograman Mobile

## Deskripsi Tugas

Aplikasi ini merupakan pengembangan dari praktikum geolocation dasar dengan menambahkan fitur geocoding untuk mengkonversi koordinat GPS menjadi alamat yang mudah dibaca. Implementasi ini memenuhi persyaratan tugas untuk menambahkan fungsionalitas reverse geocoding pada aplikasi pelacakan lokasi.

## Fitur Utama

1. **Lokasi Real-time**
   - Mendapatkan koordinat GPS (latitude/longitude)
   - Pembaruan lokasi secara real-time
   - Penanganan izin lokasi secara otomatis

2. **Geocoding (Fitur Baru)**
   - Konversi otomatis dari koordinat ke alamat
   - Menampilkan informasi lokasi lengkap:
     - Nama jalan
     - Area/Kecamatan
     - Kota
     - Kode pos
     - Negara
   - Update alamat otomatis saat lokasi berubah

3. **Kontrol Tracking**
   - Tombol untuk mendapatkan lokasi saat ini
   - Fitur mulai/henti pelacakan lokasi
   - Tampilan error yang informatif

## Implementasi

### Paket yang Digunakan

```yaml
dependencies:
  geolocator: ^14.0.2  # Untuk mendapatkan koordinat GPS
  geocoding: ^2.1.6    # Untuk konversi koordinat ke alamat
```

### Struktur Kode

1. **State Management**
```dart
Position? _currentPosition;   // Koordinat GPS
String? _currentAddress;      // Hasil geocoding
String? _errorMessage;        // Pesan error
StreamSubscription<Position>? _positionStream;  // Untuk tracking
```

2. **Fungsi Geocoding**
```dart
Future<void> getAddressFromLatLng(Position position) async {
  try {
    // Konversi koordinat ke alamat
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    // Ambil data alamat pertama
    Placemark place = placemarks[0];
    setState(() {
      _currentAddress =
          '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
    });
  } catch (e) {
    setState(() {
      _currentAddress = null;
      _errorMessage = 'Gagal mendapatkan alamat: ${e.toString()}';
    });
  }
}
```

## Screenshot dan Demo

[Tambahkan screenshot aplikasi Anda di sini]

## Penjelasan Implementasi

### Langkah-langkah Pengembangan

1. **Persiapan**
   - Menambahkan package geocoding di pubspec.yaml
   - Mengimport package yang diperlukan
   - Menambahkan variable state untuk alamat

2. **Implementasi Geocoding**
   - Membuat fungsi getAddressFromLatLng
   - Mengintegrasikan dengan sistem tracking yang ada
   - Menangani error dan exception

3. **Update UI**
   - Menambahkan tampilan untuk alamat
   - Mengatur layout dan styling
   - Implementasi loading state

### Challenges & Solutions

1. **Penanganan Error**
   - Implementasi try-catch untuk geocoding
   - Menampilkan pesan error yang informatif
   - Graceful fallback saat geocoding gagal

2. **Optimasi Performa**
   - Penggunaan setState yang efisien
   - Pembatalan subscription saat dispose
   - Penanganan state loading

## Cara Menjalankan

1. Clone repository ini
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Jalankan aplikasi:
   ```bash
   flutter run
   ```