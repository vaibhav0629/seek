import 'dart:async';

import 'package:geolocator/geolocator.dart';

class ClubLocationException implements Exception {
  final String message;
  final bool openSettings;
  const ClubLocationException(this.message, {this.openSettings = false});
}

class ClubLocationService {
  Future<Position> locate() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const ClubLocationException(
        'GPS belum aktif. Aktifkan lokasi perangkat lalu coba lagi.',
      );
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw const ClubLocationException(
        'Izin lokasi diblokir. Izinkan lokasi melalui pengaturan aplikasi atau browser.',
        openSettings: true,
      );
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.unableToDetermine) {
      throw const ClubLocationException(
        'Izin lokasi diperlukan untuk mencari club di sekitarmu.',
      );
    }
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
    } on TimeoutException {
      throw const ClubLocationException(
        'Lokasi belum ditemukan. Coba lagi di tempat dengan sinyal GPS lebih baik.',
      );
    }
  }
}
