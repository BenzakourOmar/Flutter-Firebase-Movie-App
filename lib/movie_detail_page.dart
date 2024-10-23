import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MovieDetailPage extends StatefulWidget {
  final Map movie;

  MovieDetailPage({required this.movie});

  @override
  _MovieDetailPageState createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  final TextEditingController _reviewController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();

  // Méthode pour envoyer l'avis dans Firestore
  Future<void> submitReview() async {
    final String review = _reviewController.text;
    final int rating = int.tryParse(_ratingController.text) ?? 0;

    final user = FirebaseAuth.instance.currentUser;
    final String email = user?.email ?? 'Anonyme';
    final String userId = user?.uid ?? '';

    if (review.isNotEmpty && rating >= 1 && rating <= 5) {
      try {
        await FirebaseFirestore.instance.collection('reviews').add({
          'movieId': widget.movie['imdbID'],
          'review': review,
          'rating': rating,
          'timestamp': FieldValue.serverTimestamp(),
          'username': email,
          'userId': userId,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Avis ajouté avec succès !')),
        );

        _reviewController.clear();
        _ratingController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'ajout de l\'avis.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez saisir un avis et une note valide entre 1 et 5.')),
      );
    }
  }

  // Méthode pour ajouter un film aux favoris
  Future<void> addToFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    final String userId = user?.uid ?? '';

    if (userId.isNotEmpty) {
      await FirebaseFirestore.instance.collection('favorites').add({
        'userId': userId,
        'movieId': widget.movie['imdbID'],
        'title': widget.movie['Title'],
        'poster': widget.movie['Poster'],
        'year': widget.movie['Year'],
        'timestamp': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Film ajouté aux favoris !')),
      );
    }
  }

  // Méthode pour récupérer les avis associés à ce film depuis Firestore
  Stream<QuerySnapshot> getReviews() {
    return FirebaseFirestore.instance
        .collection('reviews')
        .where('movieId', isEqualTo: widget.movie['imdbID'])
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie['Title']),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: addToFavorites,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(widget.movie['Poster']),
            SizedBox(height: 16),
            Text('Titre : ${widget.movie['Title']}', style: TextStyle(fontSize: 24)),
            Text('Année : ${widget.movie['Year']}', style: TextStyle(fontSize: 18)),
            Text('Type : ${widget.movie['Type']}', style: TextStyle(fontSize: 18)),

            SizedBox(height: 20),

            // Formulaire pour soumettre un avis
            TextField(
              controller: _reviewController,
              decoration: InputDecoration(labelText: 'Votre avis'),
              maxLines: 3,
            ),

            // Champ pour saisir la note
            TextField(
              controller: _ratingController,
              decoration: InputDecoration(labelText: 'Note (1-5)'),
              keyboardType: TextInputType.number,
            ),

            SizedBox(height: 16),

            // Bouton pour soumettre l'avis
            ElevatedButton(
              onPressed: submitReview,
              child: Text('Soumettre Avis'),
            ),

            SizedBox(height: 16),

            // Affichage des avis récupérés depuis Firestore
            Text('Avis des utilisateurs', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),

            StreamBuilder<QuerySnapshot>(
              stream: getReviews(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Erreur lors du chargement des avis: ${snapshot.error}');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                final reviews = snapshot.data!.docs;

                if (reviews.isEmpty) {
                  return Text('Aucun avis pour ce film');
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    final timestamp = (review['timestamp'] as Timestamp).toDate();
                    return Card(
                      child: ListTile(
                        title: Text('Note : ${review['rating']} par ${review['username']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(review['review']),
                            Text(
                              'Posté le : ${timestamp.day}/${timestamp.month}/${timestamp.year}',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
