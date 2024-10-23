import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Films Favoris'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('favorites')
            .where('userId', isEqualTo: currentUser?.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            // Affiche l'erreur dans le terminal
            print('Erreur : ${snapshot.error}');
            
            // Affiche l'erreur à l'utilisateur
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final favoriteMovies = snapshot.data?.docs ?? [];

          if (favoriteMovies.isEmpty) {
            return Center(child: Text('Aucun film dans vos favoris.'));
          }

          return ListView.builder(
            itemCount: favoriteMovies.length,
            itemBuilder: (context, index) {
              final movie = favoriteMovies[index];
              return ListTile(
                leading: Image.network(movie['poster']),
                title: Text(movie['title']),
                subtitle: Text('Année : ${movie['year']}'),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    movie.reference.delete();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Film supprimé des favoris')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
