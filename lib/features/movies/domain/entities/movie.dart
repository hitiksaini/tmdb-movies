import 'package:equatable/equatable.dart';

class Movie extends Equatable {
  final int id;
  final String title;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final String? releaseDate;
  final double voteAverage;
  final int voteCount;
  final List<int>? genreIds;
  final bool adult;
  final String originalLanguage;
  final String originalTitle;
  final double popularity;
  final bool video;

  const Movie({
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

  factory Movie.placeholder(int id) => Movie(
    id: id,
    title: 'Loading...',
    overview: null,
    posterPath: null,
    backdropPath: null,
    releaseDate: null,
    voteAverage: 0,
    voteCount: 0,
    genreIds: const [],
    adult: false,
    originalLanguage: 'en',
    originalTitle: 'Loading...',
    popularity: 0,
    video: false,
  );

  @override
  List<Object?> get props => [
    id,
    title,
    overview,
    posterPath,
    backdropPath,
    releaseDate,
    voteAverage,
    voteCount,
    genreIds,
    adult,
    originalLanguage,
    originalTitle,
    popularity,
    video,
  ];
}
