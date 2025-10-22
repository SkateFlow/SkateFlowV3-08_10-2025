class AppConstants {
  // Cores - Design System da Web
  static const primaryBlue = 0xFF043C70;  // Cor principal
  static const secondaryBlue = 0xFF3888D2; // Cor secundária
  static const darkBlue = 0xFF043C70;      // Mantido para compatibilidade
  static const backgroundColor = 0xFFFFFFFF;
  static const textColor = 0xFF000000;
  static const lightGray = 0xFF888888;
  
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