class AppConstants {
  // Cores
  static const primaryBlue = 0xFF3888D2;
  static const darkBlue = 0xFF043C70;
  
  // URLs
  static const viaCepUrl = 'https://viacep.com.br/ws';
  static const nominatimUrl = 'https://nominatim.openstreetmap.org/search';
  static const osmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  
  // Limites
  static const maxFavoriteParks = 4;
  static const maxPhotos = 3;
  static const maxDescriptionLength = 250;
  
  // Zoom levels
  static const defaultZoom = 14.0;
  static const detailZoom = 18.0;
  
  // Timeouts
  static const locationTimeout = Duration(seconds: 10);
  static const httpTimeout = Duration(seconds: 30);
}