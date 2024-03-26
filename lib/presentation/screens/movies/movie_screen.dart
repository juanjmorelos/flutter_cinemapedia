import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia/config/helpers/human_formats.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:cinemapedia/presentation/providers/storage/favorites_movies_provider.dart';
import 'package:cinemapedia/presentation/providers/storage/local_storage_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MovieScreen extends ConsumerStatefulWidget {
  static const name = 'movie-screen';
  final String movieId;

  const MovieScreen({
    super.key, 
    required this.movieId
  });

  @override
  MovieScreenState createState() => MovieScreenState();
}

class MovieScreenState extends ConsumerState<MovieScreen> {

  @override
  void initState() {
    super.initState();
    ref.read(movieInfoProvider.notifier).loadMovie(widget.movieId);
    ref.read(actorsByMovieProvider.notifier).loadActors(widget.movieId);
  }

  @override
  Widget build(BuildContext context) {

    final Movie? movie = ref.watch(movieInfoProvider)[widget.movieId];

    if(movie == null){
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(strokeWidth: 2),
              SizedBox(height: 12),
              Text("Cargando detalles de la película")
            ],
          ),
        )
      );
    }

    return Scaffold(
      body: FadeIn(
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            _CustomSliverAppbar(movie: movie),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _MovieDetails(movie: movie),
                childCount: 1
              )
            )
          ],
        ),
      ),
    );
  }
}

class _MovieDetails extends StatelessWidget {
  final Movie movie;
  const _MovieDetails({
    required this.movie
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textStyles = Theme.of(context).textTheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  DecoratedBox(
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
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        movie.posterPath,
                        width: size.width * 0.3,
                      )
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: size.width * 0.3,
                    child: Row(
                      children: [
                        Icon(Icons.star_half_outlined, color: Colors.yellow.shade800),
                        const SizedBox(width: 3),
                        Text(HumanFormats.number(movie.voteAverage, 1), style: textStyles.bodyMedium?.copyWith(color: Colors.yellow.shade800)),
                        const Spacer(),
                        Text(HumanFormats.number(movie.popularity), style: textStyles.bodySmall),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: (size.width - 38) * 0.7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(movie.title, style: textStyles.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(movie.overview),
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          child: Text("Género", style: textStyles.titleMedium),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Wrap(
            children: [
              ...movie.genreIds.map((e) => Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: Chip(
                    label: Text(e),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                )
              )
            ],
          ),
        ),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Text("Casting", style: textStyles.titleMedium),
        ),
        _ActorsByMovie(movieId: movie.id.toString()),
        const SizedBox(height: 50)
      ],
    );
  }
}

class _ActorsByMovie extends ConsumerWidget {
  final String movieId;
  const _ActorsByMovie({
    required this.movieId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actorsByMovie = ref.watch(actorsByMovieProvider);
    
    if(actorsByMovie[movieId] == null){
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    
    final actors = actorsByMovie[movieId]!;

    return SizedBox(
      height: 300,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: actors.length,
        itemBuilder: (context, index) {
          final actor = actors[index];
          return Container(
            padding: const EdgeInsets.all(8),
            width: 135,
            child: Column(
              children: [
                FadeInRight(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 10)
                          )
                        ]
                      ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        actor.profilePath,
                        height: 180,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if(loadingProgress != null) {
                            return const SizedBox(
                              height: 180,
                              child: DecoratedBox(
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
                const SizedBox(height: 5),
                Text(actor.name, maxLines: 2, textAlign: TextAlign.center, style: const TextStyle(overflow: TextOverflow.ellipsis),),
                Text(actor.character ?? '', maxLines: 2, style: const TextStyle(fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis), textAlign: TextAlign.center,),
              ],
            ),
          );
        }, 
      ),
    );
  }
}

final isFavoriteProvider = FutureProvider.family.autoDispose((ref, int movieId) {
  final localStorageRepository = ref.watch(localStorageRepositoryprovider);
  return localStorageRepository.isMovieFavorite(movieId);
});

class _CustomSliverAppbar extends ConsumerWidget {
  final Movie movie;

  const _CustomSliverAppbar({
    required this.movie
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final isFavoriteFuture = ref.watch(isFavoriteProvider(movie.id));
    final size = MediaQuery.of(context).size;

    return SliverAppBar(
      backgroundColor: Colors.black,
      expandedHeight: size.height * 0.5,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          onPressed: () async {
            await ref.read(favoriteMoviesProvider.notifier).toggleFavorite(movie);
            ref.invalidate(isFavoriteProvider(movie.id));
          }, 
          icon: isFavoriteFuture.when(
            data: (isFavorite) => !isFavorite ? const Icon(Icons.favorite_outline_rounded) : const Icon(Icons.favorite_rounded, color: Colors.red), 
            error: (_, __) => throw UnimplementedError(), 
            loading: () => const CircularProgressIndicator(strokeWidth: 2)
          ), 
          // ,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        // title: Text(
        //   movie.title,
        //   textAlign: TextAlign.start,
        // ),
        background: Stack(
          children: [
            SizedBox.expand(
              child: Image.network(
                movie.posterPath,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if(loadingProgress != null) {
                    return const SizedBox(
                      height: 180,
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: Colors.black12),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  }
                  return FadeIn(child: child);
                },
              ),
            ),
            const _CustomGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              stops: [0.0,0.2],
              colors: [
                Colors.black54,
                Colors.transparent
              ]
            ),
            const _CustomGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.8,1.0],
              colors: [
                Colors.transparent,
                Colors.black45
              ]
            ),
            const _CustomGradient(
              begin: Alignment.topLeft,
              stops: [0.0,0.3],
              colors: [
                Colors.black54,
                Colors.transparent,
              ]
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomGradient extends StatelessWidget {
  const _CustomGradient({
    this.begin = Alignment.centerLeft, 
    this.end = Alignment.centerRight, 
    required this.stops, 
    required this.colors
  });

  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final List<double> stops;
  final List<Color> colors;


  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: begin,
            end: end,
            stops: stops,
            colors: colors
          )
        )
      )
    );
  }
}