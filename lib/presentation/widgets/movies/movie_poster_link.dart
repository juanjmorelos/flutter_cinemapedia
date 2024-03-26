import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/presentation/providers/storage/favorites_movies_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MoviePosterLink extends ConsumerWidget {
  final Movie movie;

  const MoviePosterLink({
    super.key, 
    required this.movie
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FadeInUp(
      child: InkWell(
        onTap: (() => context.push("/home/0/movie/${movie.id}")),
        onLongPress: (() => showConfirmDialog(context, ref, movie)),
        child: Material(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: FadeIn(
              child: Image.network(movie.posterPath),
            ),
          ),
        ),
      ),
    );
  }
}

showConfirmDialog(BuildContext context, WidgetRef ref, Movie movie) {
  showDialog(
    context: context, 
    builder: (context) => AlertDialog.adaptive(
      content: const Text("¿Desea eliminar esta película de sus favoritos?", style: TextStyle(fontSize: 17)),
      actionsPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      contentPadding: const EdgeInsets.only(top: 25, left: 25, right: 25),
      actions: [
        TextButton(
            onPressed: () async => await ref.read(favoriteMoviesProvider.notifier).toggleFavorite(movie).then((value) => context.pop() )
            ,
            child: const Text('Aceptar', style: TextStyle(fontSize: 16)),
          ),
          TextButton(
            onPressed: () {
              context.pop();
            },
            child: const Text('Cerrar', style: TextStyle(fontSize: 16)),
          ),
      ],
    ),
  );
}