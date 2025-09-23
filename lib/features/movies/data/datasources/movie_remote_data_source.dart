import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/movie_model.dart';
import '../models/movie_response_model.dart';

part 'movie_remote_data_source.g.dart';

abstract class MovieRemoteDataSource {
  Future<List<MovieModel>> getTrendingMovies();
  Future<List<MovieModel>> getNowPlayingMovies();
  Future<List<MovieModel>> searchMovies(String query);
  Future<MovieModel> getMovieDetails(int movieId);
}

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class MovieApiService {
  factory MovieApiService(Dio dio, {String baseUrl}) = _MovieApiService;

  @GET(ApiConstants.trendingMovies)
  Future<MovieResponseModel> getTrendingMovies(
    @Query(ApiConstants.apiKeyParam) String apiKey,
  );

  @GET(ApiConstants.nowPlayingMovies)
  Future<MovieResponseModel> getNowPlayingMovies(
    @Query(ApiConstants.apiKeyParam) String apiKey,
  );

  @GET(ApiConstants.searchMovies)
  Future<MovieResponseModel> searchMovies(
    @Query(ApiConstants.apiKeyParam) String apiKey,
    @Query(ApiConstants.queryParam) String query,
  );

  @GET('${ApiConstants.movieDetails}/{id}')
  Future<MovieModel> getMovieDetails(
    @Path('id') int movieId,
    @Query(ApiConstants.apiKeyParam) String apiKey,
  );
}

class MovieRemoteDataSourceImpl implements MovieRemoteDataSource {
  final MovieApiService apiService;

  MovieRemoteDataSourceImpl(Dio dio) 
      : apiService = MovieApiService(dio);

  @override
  Future<List<MovieModel>> getTrendingMovies() async {
    try {
      final response = await apiService.getTrendingMovies(ApiConstants.apiKey);
      return response.results;
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Server error occurred');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<MovieModel>> getNowPlayingMovies() async {
    try {
      final response = await apiService.getNowPlayingMovies(ApiConstants.apiKey);
      return response.results;
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Server error occurred');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<MovieModel>> searchMovies(String query) async {
    try {
      final response = await apiService.searchMovies(ApiConstants.apiKey, query);
      return response.results;
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Server error occurred');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<MovieModel> getMovieDetails(int movieId) async {
    try {
      return await apiService.getMovieDetails(movieId, ApiConstants.apiKey);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Server error occurred');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}