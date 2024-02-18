// Librerías importadas en el proyecto
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:csv/csv.dart';
import 'package:video_player_win/video_player_win.dart';

// Atributos de la aplicación
Movie movie = Movie();
List<String> movies = [];

void main() {
  movie.loadMovieNamesFromCsv();
  runApp(MyApp());
}

// Función principal de inicio del programa
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Peli Fiction',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class Movie {
  var current = "";

  Future<void> loadMovieNamesFromCsv() async {
    // Ruta del archivo CSV
    String csvFilePath = 'lib\\movies.csv';

    File file = File(csvFilePath);
    // Lee el contenido del archivo CSV
    String csvData = await file.readAsString();

    // Convierte los datos CSV en filas
    List<List<dynamic>> csvTable = const CsvToListConverter().convert(csvData);

    // Recorre las filas y extrae el nombre de la película
    for (var row in csvTable) {
      // Asumiendo que el nombre de la película está en la primera columna
      String movieName = row[0].toString();
      // Agrega el nombre de la película a la lista
      movies.add(movieName);
    }
  }

  String random() {
    final random = Random();
    return movies[random.nextInt(movies.length)];
  }
}

// Clase principal de la aplicación
class MyAppState extends ChangeNotifier {
  var current = movie.random();

  void getNext() {
    current = movie.random();
    notifyListeners();
  }

  var favorites = <String>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

// Clase para controlar la página principal
class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Índice seleccionado en la barra de navegación
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    // Permiet navegar entre las páginas de la aplicación
    switch (selectedIndex) {
      case 0:
        // Remite a la página inicial
        page = InitialPage();
        break;
      case 1:
        // Remite a la página de generación de palabras
        page = GeneratorPage();
        break;
      case 2:
        // Remite a la página de favoritos
        page = FavoritesPage();
        break;
      case 3:
        // Remite a la página con todos los elementos
        page = MovieListPage();
        break;
      default:
        throw UnimplementedError('No widget for $selectedIndex');
    }

    // Widget para construir la estructura general de la aplicación
    return Scaffold(
      body: Row(
        children: [
          Container(
              color: Colors.grey,
              width: 100,
              // Panel de navegación
              child: SafeArea(
                  child: Stack(children: [
                Image.asset(
                  "lib\\rollo.jpg", // Ruta de la imagen de fondo
                  fit: BoxFit.cover,
                ),
                NavigationRail(
                  backgroundColor: Colors.transparent,
                  extended: false,
                  destinations: [
                    // Destino para la página de inicio
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Inicio'),
                    ),
                    // Destino para la página del generador
                    NavigationRailDestination(
                      icon: Icon(Icons.movie),
                      label: Text('Películas'),
                    ),
                    // Destino para la página de favoritos
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favoritas'),
                    ),
                    // Destino para la página de todos los elementos
                    NavigationRailDestination(
                      icon: Icon(Icons.list),
                      label: Text('Lista de elementos'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ]))),
          // Panel que muestra el contenido de la página
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page,
            ),
          ),
        ],
      ),
    );
  }
}

// Página inicial de la aplicación
class InitialPage extends StatefulWidget {
  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  late WinVideoPlayerController controller;

  @override
  void initState() {
    super.initState();
    controller = WinVideoPlayerController.file(File('lib\\video.mov'));
    controller.initialize().then((value) {
      if (controller.value.isInitialized) {
        controller.play();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo de imagen
          Image.asset(
            "lib\\cine.jpg", // Ruta de la imagen de fondo
            fit: BoxFit.cover,
          ),
          // Contenido centrado
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 50),
              Container(
                width: 500,
                height: 400,
                child: controller.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: controller.value.aspectRatio,
                        child: WinVideoPlayer(controller),
                      )
                    : CircularProgressIndicator(),
              )
            ],
          ),
        ],
      ),
    );
  }
}

// Clase para la página de favoritos
class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var favorites = appState.favorites;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo de imagen
          Image.asset(
            "lib\\proyector.jpg", // Ruta de la imagen de fondo
            fit: BoxFit.cover,
          ),
          // Contenido centrado
          Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 750),
                Expanded(
                  child: ListView(children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Tiene ${favorites.length} películas favoritas:',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    for (var movie in favorites)
                      ListTile(
                        leading: Icon(Icons.favorite, color: Colors.white),
                        title: Text(movie,
                            style:
                                TextStyle(fontSize: 24, color: Colors.white)),
                      )
                  ]),
                ),
              ]),
        ],
      ),
    );
  }
}

// Clase para la página de selección de películas
class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var movie = appState.current;

    // Gestiona el icono de favoritos del botón
    IconData icon;
    if (appState.favorites.contains(movie)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Scaffold(
        body: Stack(fit: StackFit.expand, children: [
      // Fondo de imagen
      Image.asset(
        "lib\\cinta.jpg",
        fit: BoxFit.cover,
      ),

      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BigCard(movie: movie),
            SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Botón de favoritos
                ElevatedButton.icon(
                  onPressed: () {
                    appState.toggleFavorite();
                  },
                  icon: Icon(icon),
                  label: Text('Favorita'),
                ),
                SizedBox(width: 10),
                // Botón de siguiente elemento
                ElevatedButton(
                  onPressed: () {
                    appState.getNext();
                  },
                  child: Text('Siguiente'),
                ),
              ],
            ),
          ],
        ),
      )
    ]));
  }
}

// Tarjeta que muestra las películas a elegir
class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.movie,
  });

  final String movie;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          movie,
          style: style,
        ),
      ),
    );
  }
}

// Itera el documento de películas y guarda los títulos en una lista
class MovieListPage extends StatefulWidget {
  const MovieListPage({Key? key}) : super(key: key);

  @override
  State<MovieListPage> createState() => _MovieListPageState();
}

class _MovieListPageState extends State<MovieListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo de imagen
          Image.asset(
            "lib\\claqueta.jpg",
            fit: BoxFit.cover,
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 50),
                Expanded(
                  child: ListView(children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Lista de ${movies.length} películas:',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    for (var movie in movies)
                      ListTile(
                        leading: Icon(Icons.movie_filter, color: Colors.white),
                        title: Text(movie,
                            style:
                                TextStyle(fontSize: 24, color: Colors.white)),
                      )
                  ]),
                ),
              ]),
        ],
      ),
    );
  }
}
