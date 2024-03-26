import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia/config/helpers/human_formats.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:flutter/material.dart';


typedef SearchMoviesCallback = Future<List<Movie>> Function(String query);

class SearchMovieDelegate extends SearchDelegate<Movie?>{

  final SearchMoviesCallback searchMovies;
  List<Movie> initialMovie;
  StreamController debouncedMovies = StreamController.broadcast();
  StreamController<bool> isLoadingStream = StreamController.broadcast();
  Timer? _debounceTimer;

  SearchMovieDelegate({
    required this.searchMovies,
    required this.initialMovie
  }):super();

  void clearStreams() {
    debouncedMovies.close();
  }

  void _onQueryChanged(String query) {
    if(_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 600), () async {
      // if(query.isEmpty) {
      //   debouncedMovies.add([]);
      //   return;
      // }
      isLoadingStream.add(true);
      final movies = await searchMovies(query);
      debouncedMovies.add(movies);
      isLoadingStream.add(false);
      initialMovie = movies;
    });
  }

  @override
  String? get searchFieldLabel => 'Buscar película';
  
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      StreamBuilder(
        initialData: false,
        stream: isLoadingStream.stream,
        builder: (context, snapshot) {
          if(snapshot.data ?? false ) {
          return  FadeIn(
              animate: query.isNotEmpty,
              duration: const Duration(milliseconds: 300),
              child: const SizedBox(
                width: 39, 
                height: 39, 
                child: IconButton(
                  onPressed:null , 
                  icon: CircularProgressIndicator(strokeWidth: 2)
                )
              ),
            );
          }
          return  FadeInRight(
            animate: query.isNotEmpty,
            duration: const Duration(milliseconds: 300),
            child: IconButton(
              onPressed: () => query = '', 
              icon: const Icon(Icons.clear_rounded)
            ),
          );
        },
      ),
      
      
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        clearStreams();
        close(context, null);
      }, 
      icon: const Icon(Icons.arrow_back_rounded)
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildResultsAndSuggestions();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _onQueryChanged(query);
    return buildResultsAndSuggestions();
  }

  Widget buildResultsAndSuggestions() {
    return StreamBuilder(
    initialData: initialMovie,
    stream: debouncedMovies.stream,
    builder: (context, snapshot) {
      final movies = snapshot.data ?? [];
      return ListView.builder(
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return _MovieItem(
            movie: movie,
            onMovieSelected: (context, movie) {
              clearStreams();
              close(context, movie);
            },
          );  
        },
      );
    },
  );
  }

}

class _MovieItem extends StatelessWidget {
  const _MovieItem({
    required this.movie, 
    required this.onMovieSelected,
  });

  final Movie movie;
  final Function onMovieSelected;

  @override
  Widget build(BuildContext context) {

    final textStyle = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
         
        onMovieSelected(context, movie);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          children: [
            SizedBox(
              height: size.height * 0.15,
              width: size.width * 0.2,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5)
                    )
                  ]
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    fit: BoxFit.cover,
                    movie.posterPath,
                    loadingBuilder: (context, child, loadingProgress) {
                      if(loadingProgress != null) {
                        return SizedBox(
                          height: size.height * 0.15,
                          width: size.width * 0.2,
                          child: const DecoratedBox(
                            decoration: BoxDecoration(color: Colors.black12),
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        );
                      }
                      return FadeIn(child: child);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: size.width * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(movie.title, style: textStyle.titleMedium),
                  movie.overview.length > 100 ?
                    Text('${movie.overview.substring(0,100)}...')
                    : Text(movie.overview),
                  Row(
                    children: [
                      Icon(Icons.star_half_rounded, color: Colors.yellow.shade800),
                      const SizedBox(width: 5,),
                      Text(HumanFormats.number(movie.voteAverage, 1), style: textStyle.bodyMedium!.copyWith(color: Colors.yellow.shade900),)
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}