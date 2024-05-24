import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart'; // Importando a tela de login

class MoviesScreen extends StatefulWidget {
  final Key? key;
  MoviesScreen({this.key}) : super(key: key);

  @override
  _MoviesScreenState createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  List movies = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadMovies();
  }

  Future<void> loadMovies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? moviesData = prefs.getString('movies');

    if (moviesData != null) {
      setState(() {
        movies = json.decode(moviesData);
        isLoading = false;
      });
    } else {
      fetchMovies();
    }
  }

  Future<void> fetchMovies() async {
    final response = await http.get(Uri.parse('https://raw.githubusercontent.com/danielvieira95/DESM-2/master/filmes.json'));
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      setState(() {
        movies = json.decode(response.body)['filmes'];
        isLoading = false;
      });
      saveMovies();
    } else {
      throw Exception('Failed to load movies');
    }
  }

  Future<void> saveMovies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('movies', json.encode(movies));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Mange Flix',
          style: TextStyle(
            color: Colors.red,
          ),
        ),
        backgroundColor: Colors.black,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()), // Redirecionando para a tela de login
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];

                final imageUrl = movie['imagem'] ?? '';
                final title = movie['nome'] ?? 'No title';
                final duration = movie['duração'] ?? 'No duration';
                final year = movie['ano de lançamento'] ?? 'No year';
                final rating = movie['nota'] ?? 'No rating';

                return Card(
                  margin: EdgeInsets.all(10),
                  child: InkWell(
                    onTap: () {
                      // Implementar ação ao clicar no filme, se necessário
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 300, // Ajuste o tamanho da imagem conforme necessário
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Container(
                          color: Colors.grey[800], // Definindo a cor de fundo cinza escuro
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber, // Alterando a cor do texto para dourado
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Duration: $duration',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.amber, // Alterando a cor do texto para dourado
                                ),
                              ),
                              Text(
                                'Year: $year',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.amber, // Alterando a cor do texto para dourado
                                ),
                              ),
                              Text(
                                'Rating: $rating',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.amber, // Alterando a cor do texto para dourado
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
