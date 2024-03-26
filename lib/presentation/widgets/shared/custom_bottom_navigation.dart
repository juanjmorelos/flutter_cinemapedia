import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNavigation extends StatelessWidget {
  const CustomBottomNavigation({super.key, required this.currentIndex});
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      onTap: (value) => context.go('/home/$value'),
      currentIndex: currentIndex,
      elevation: 0,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Inicio' 
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.label_outline_rounded),
          label: 'Etiquetas' 
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_outline_rounded),
          label: 'Favoritos' 
        ),
      ]
    );
  }

}