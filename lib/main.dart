import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elysium Project',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Position? _currentPosition;
  String? _errorMessage;
  StreamSubscription<Position>? _positionStream;
  String? _currentAddress;
  String? _distanceToPNB;

  // Titik tetap PNB (koordinat referensi)
  static const double _pnbLatitude = -6.2088;
  static const double _pnbLongitude = 106.8456;


  @override
  void dispose() {
    // PENTING: Selalu batalkan stream saat widget dihancurkan
    _positionStream?.cancel();
    super.dispose();
  }

  // Konversi koordinat ke alamat lengkap
  Future<void> getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
            '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
        _errorMessage = null;
      }); 
    } catch (e) {
      setState(() {
        _currentAddress = null;
        _errorMessage = 'Gagal mendapatkan alamat: ${e.toString()}';
      });
    }
  }

  

  Future<Position> _getPermissionAndLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Cek apakah layanan lokasi (GPS) di perangkat aktif
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Layanan lokasi tidak aktif. Harap aktifkan GPS.');
    }

    // 2. Cek izin lokasi dari aplikasi
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Jika ditolak, minta izin
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Jika tetap ditolak, kirim error
        return Future.error('Izin lokasi ditolak.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Jika ditolak permanen, kirim error
      return Future.error(
        'Izin lokasi ditolak permanen. Harap ubah di pengaturan aplikasi.',
      );
    }

    // 3. Jika izin diberikan, ambil lokasi saat ini
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  void _handleGetLocation() async {
    try {
      Position position = await _getPermissionAndLocation();
      setState(() {
        _currentPosition = position;
        _errorMessage = null;
      });
      
      await getAddressFromLatLng(position);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString(); // Tampilkan error di UI
      });
    }
  }

  void _handleStartTracking() {
    _positionStream?.cancel();

    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Update setiap ada pergerakan 10 meter
    );

    try {
      // Mulai mendengarkan stream
      _positionStream =
          Geolocator.getPositionStream(
            locationSettings: locationSettings,
          ).listen((Position position) async {
            // Hitung jarak ke titik tetap PNB
            double distanceInMeters = await Geolocator.distanceBetween(
              position.latitude,
              position.longitude,
              _pnbLatitude,
              _pnbLongitude,
            );
            
            setState(() {
              _currentPosition = position;
              _errorMessage = null;
              // Format jarak dalam kilometer (2 desimal)
              _distanceToPNB = '${(distanceInMeters / 1000).toStringAsFixed(2)} km';
            });
            
            await getAddressFromLatLng(position);
          });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  void _handleStopTracking() {
    _positionStream?.cancel(); // Hentikan stream
    setState(() {
      _errorMessage = "Pelacakan dihentikan.";
    });
  }

  // --- TAMPILAN (UI) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Elysium Project")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on, size: 50, color: Colors.blue),
                SizedBox(height: 16),

                // --- Area Tampilan Informasi ---
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 150),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Tampilkan Error
                      if (_errorMessage != null)
                        Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),

                      SizedBox(height: 16),

                      // Tampilkan Posisi (Lat/Lng)
                      if (_currentPosition != null) ...[
                          Text(
                          "Lat: ${_currentPosition!.latitude}\nLng: ${_currentPosition!.longitude}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_currentAddress != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _currentAddress!,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        if (_distanceToPNB != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Text(
                              'Jarak ke PNB: $_distanceToPNB',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: 32),

                //
                ElevatedButton.icon(
                  icon: Icon(Icons.location_searching),
                  label: Text('Dapatkan Lokasi Sekarang'),
                  onPressed: _handleGetLocation,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 40),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(Icons.play_arrow),
                      label: Text('Mulai Lacak'),
                      onPressed: _handleStartTracking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.stop),
                      label: Text('Henti Lacak'),
                      onPressed: _handleStopTracking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}