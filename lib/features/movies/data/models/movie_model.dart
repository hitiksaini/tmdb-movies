import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/movie.dart';

part 'movie_model.g.dart';

@JsonSerializable()
@HiveType(typeId: 0)
class MovieModel {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? overview;

  @HiveField(3)
  @JsonKey(name: 'poster_path')
  final String? posterPath;

  @HiveField(4)
  @JsonKey(name: 'backdrop_path')
  final String? backdropPath;

  @HiveField(5)
  @JsonKey(name: 'release_date')
  final String? releaseDate;

  @HiveField(6)
  @JsonKey(name: 'vote_average')
  final double voteAverage;

  @HiveField(7)
  @JsonKey(name: 'vote_count')
  final int voteCount;

  @HiveField(8)
  @JsonKey(name: 'genre_ids')
  final List<int>? genreIds;

  @HiveField(9)
  final bool adult;

  @HiveField(10)
  @JsonKey(name: 'original_language')
  final String originalLanguage;

  @HiveField(11)
  @JsonKey(name: 'original_title')
  final String originalTitle;

  @HiveField(12)
  final double popularity;

  @HiveField(13)
  final bool video;

  const MovieModel({
    required this.id,
    required this.title,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    required this.voteAverage,
    required this.voteCount,
    this.genreIds,
    required this.adult,
    required this.originalLanguage,
    required this.originalTitle,
    required this.popularity,
    required this.video,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) =>
      _$MovieModelFromJson(json);

  Map<String, dynamic> toJson() => _$MovieModelToJson(this);

  factory MovieModel.fromEntity(Movie movie) => MovieModel(
    id: movie.id,
    title: movie.title,
    overview: movie.overview,
    posterPath: movie.posterPath,
    backdropPath: movie.backdropPath,
    releaseDate: movie.releaseDate,
    voteAverage: movie.voteAverage,
    voteCount: movie.voteCount,
    genreIds: movie.genreIds,
    adult: movie.adult,
    originalLanguage: movie.originalLanguage,
    originalTitle: movie.originalTitle,
    popularity: movie.popularity,
    video: movie.video,
  );

  Movie toEntity() => Movie(
    id: id,
    title: title,
    overview: overview,
    posterPath: posterPath,
    backdropPath: backdropPath,
    releaseDate: releaseDate,
    voteAverage: voteAverage,
    voteCount: voteCount,
    genreIds: genreIds,
    adult: adult,
    originalLanguage: originalLanguage,
    originalTitle: originalTitle,
    popularity: popularity,
    video: video,
  );
}
