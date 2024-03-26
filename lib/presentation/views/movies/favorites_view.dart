import 'package:cinemapedia/presentation/providers/storage/favorites_movies_provider.dart';
import 'package:cinemapedia/presentation/widgets/movies/movie_masonry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FavoritesView extends ConsumerStatefulWidget {
  const FavoritesView({super.key});

  @override
  FavoritesViewState createState() => FavoritesViewState();
}


class FavoritesViewState extends ConsumerState<FavoritesView> {
  bool isLastPage = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadNextPage();
  }

  void loadNextPage() async {
    if(isLoading || isLastPage) return;
    isLoading = true;
    
    final movies = await ref.read(favoriteMoviesProvider.notifier).loadNextPage();
    isLoading = false;
    
    if(movies.isEmpty) {
      isLastPage = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoriteMovies = ref.watch(favoriteMoviesProvider).values.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Películas favoritas'),
        actions: favoriteMovies.isNotEmpty ? [
            IconButton(
              onPressed: () => showConfirmDeleteDialog(context, ref), 
              icon: const Icon(Icons.delete_forever_rounded)
          )
        ] : null,
      ),
      body: favoriteMovies.isEmpty ? const _EmptyFavorites() : MovieMasonry(movie: favoriteMovies, loadNextPage: loadNextPage)
    );
  } 
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();


  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border_rounded, size: 70, color: colors.primary.withOpacity(0.8),),
            Text('Ohhh no!!', style: TextStyle(fontSize: 30, color: colors.primary.withOpacity(0.8))),
            Text('No tienes peliculas favoritas!!', style: TextStyle(fontSize: 25, color: colors.primary.withOpacity(0.8))),
            const SizedBox(height: 20),
            FilledButton.tonal(
              onPressed: () => context.go("/home/0"), 
              child: const Text('Empieza a buscar')
            )
          ]
        ),
      ),
    );
  }
}

showConfirmDeleteDialog(BuildContext context, WidgetRef ref) {
  showDialog(
  context: context, 
  builder: (context) => AlertDialog.adaptive(
    content: const Text("¿Desea eliminar todas sus peliculas favoritas?", style: TextStyle(fontSize: 17)),
    actionsPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
    contentPadding: const EdgeInsets.only(top: 25, left: 25, right: 25),
    actions: [
      TextButton(
          onPressed: () async => await ref.read(favoriteMoviesProvider.notifier).deleteAllFavoriteMovies().then((value) => context.pop() )
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

