class ApiConstants {
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String apiHost = 'api.themoviedb.org';
  static const String apiKey = 'fa9a1748f67f10485248b7ecffea1484';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  // Server Endpoints
  static const String trendingMovies = '/trending/movie/day';
  static const String nowPlayingMovies = '/movie/now_playing';
  static const String searchMovies = '/search/movie';
  static const String movieDetails = '/movie';

  // API Parameters
  static const String apiKeyParam = 'api_key';
  static const String queryParam = 'query';
  static const String pageParam = 'page';
}
