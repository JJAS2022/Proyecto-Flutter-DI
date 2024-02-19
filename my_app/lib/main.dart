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

// Función de inicio del programa
void main() {
  // Carga asíncrona de datos del CSV mientras se muestra el vídeo
  movie.loadMovieNamesFromCsv();
  runApp(MyApp());
}

// Clase general de la aplicación
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Peli Fiction', // Tñitulo
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
        ),
        home: MyHomePage(), // Carga la página general de la aplicación
      ),
    );
  }
}

// Clase para controlar y notificar los cambios en la aplicación
class MyAppState extends ChangeNotifier {
  // Selecciona de manera aleatoria la película inicial
  var current = movie.random();

  // Selecciona de manera aleatoria la película siguiente a mostrar
  void getNext() {
    current = movie.random();
    notifyListeners();
  }

  // Listas de películas favoritas y pendientes
  var favorites = <String>[];
  var pending = <String>[];

  // Función que permite añadir o eliminar películas favoritas
  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
      // Ordena los favoritos alfabéticamente
      favorites.sort();
    }
    notifyListeners();
  }

  // Función que permite añadir o eliminar películas pendientes
  void togglePending() {
    if (pending.contains(current)) {
      pending.remove(current);
    } else {
      pending.add(current);
      // Ordena las películas pendientes alfabéticamente
      pending.sort();
    }
    notifyListeners();
  }

  // Función para eliminar un favorito por nombre
  void removeFavorite(String movie) {
    favorites.remove(movie);
    notifyListeners();
  }

  // Función para eliminar una película pendiente por nombre
  void removePending(String movie) {
    pending.remove(movie);
    notifyListeners();
  }

  // Función para eliminar una película por nombre
  void removeMovie(String movie) {
    movies.remove(movie);
    if (current == movie) {
      getNext();
    }
    if(favorites.contains(movie)) {
      removeFavorite(movie);
    }
    if (pending.contains(movie)) {
      removePending(movie);
    }
    notifyListeners();
  }

  // Función para añadir una película por nombre
  void addMovie(String movie) {
      movies.add(movie);
      movies.sort();
      notifyListeners();                   
  }
}

// Clase que gestiona las películas
class Movie {
  // Variable que almacena la película actual
  var current = "";

  // Función para leer el csv y almacenar las películas en una lista
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
      // Selecciona el nombre de la película, que está en la primera columna
      String movieName = row[0].toString();
      // Agrega el nombre de la película a la lista
      movies.add(movieName);
    }

    // Ordena las películas alfabéticamente
    movies.sort();
  }

  // Función que permite elegir una película aleatoria de a lista
  String random() {
    final random = Random();
    return movies[random.nextInt(movies.length)];
  }
}

// Clases para controlar el marco principal de la aplicación
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
    // Permite navegar entre las páginas de la aplicación
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
        // Remite a la página de películas pendientes
        page = PendingPage();
        break;
      case 4:
        // Remite a la página con todos los elementos
        page = MovieListPage();
        break;
      default:
        throw UnimplementedError('No hay elementos para el índice $selectedIndex');
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
                    // Destino para la página de películas pendientes
                    NavigationRailDestination(
                      icon: Icon(Icons.bookmark_added),
                      label: Text('Pendientes'),
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
          // Panel que muestra el contenido de las páginas
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

  // Inicialización del controlador para que cargue el buffer
  @override
  void initState() {
    super.initState();
    // Controlador del vídeo inicial
    controller = WinVideoPlayerController.file(File('lib\\video.mov'));
    controller.initialize().then((value) {
      if (controller.value.isInitialized) {
        controller.play();
        setState(() {});
      }
    });
  }

  // Cierre del vídeo al terminar
  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  // Estructura visual de la página inicial
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
              SizedBox(
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

// Clase para la página de selección de películas
class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var movie = appState.current;

    // Gestiona el icono de favoritos del botón
    IconData favIcon;
    if (appState.favorites.contains(movie)) {
      favIcon = Icons.favorite;
    } else {
      favIcon = Icons.favorite_border;
    }

    // Gestiona el icono de favoritos del botón
    IconData pendingIcon;
    if (appState.pending.contains(movie)) {
      pendingIcon = Icons.bookmark_added;
    } else {
      pendingIcon = Icons.bookmark_add_outlined;
    }

    // Estructura de la página
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
                  icon: Icon(favIcon),
                  label: Text('Favorita'),
                ),
                SizedBox(width: 10),
                // Botón de pendientes
                ElevatedButton.icon(
                  onPressed: () {
                    appState.togglePending();
                  },
                  icon: Icon(pendingIcon),
                  label: Text('Pendiente'),
                ),
                SizedBox(width: 10),
                // Botón de siguiente 
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
          Image.asset(
            "lib\\proyector.jpg", // Ruta de la imagen de fondo
            fit: BoxFit.cover,
          ),
          // Contenido centrado
          Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 700),
                Expanded(
                  child: ListView(children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      // Indicación del número de favoritos
                      child: Text(
                        'Tiene ${favorites.length} películas favoritas:',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Lista de elementos en favoritos con icono y botón 
                    for (var movie in favorites)
                      ListTile(
                        leading: Icon(Icons.favorite, color: Colors.white),
                        title: Text(movie,
                            style:
                                TextStyle(fontSize: 24, color: Colors.white)),
                        trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.white),
                            onPressed: () {
                              appState.removeFavorite(movie);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.blueGrey,
                                    content: Text(
                                      'La película se ha eliminado de favoritos.',
                                    ),
                                  ),
                              );
                            },
                        ),
                      )
                  ]),
                ),
              ]),
        ],
      ),
    );
  }
}

// Clase para la página de favoritos
class PendingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pending = appState.pending;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            "lib\\pelicula.jpg", // Ruta de la imagen de fondo
            fit: BoxFit.cover,
          ),
          // Contenido centrado
          Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 20),
                Expanded(
                  child: ListView(children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      // Indicación del número de pendientes
                      child: Text(
                        'Tiene ${pending.length} películas pendientes:',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Lista de elementos en favoritos con icono y botón 
                    for (var movie in pending)
                      ListTile(
                        leading: Icon(Icons.bookmark_added, color: Colors.white),
                        title: Text(movie,
                            style:
                                TextStyle(fontSize: 24, color: Colors.white)),
                        trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.white),
                            onPressed: () {
                              appState.removePending(movie);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.blueGrey,
                                    content: Text(
                                      'La película se ha eliminado de pendientes.',
                                    ),
                                  ),
                              );
                            },
                        ),
                      )
                  ]),
                ),
                SizedBox(width: 680),
              ]),
        ],
      ),
    );
  }
}

// Clases que gestionan la página de todas las películas
class MovieListPage extends StatefulWidget {
  const MovieListPage({super.key});

  @override
  State<MovieListPage> createState() => _MovieListPageState();
}

class _MovieListPageState extends State<MovieListPage> {
  late TextEditingController _movieController;

  @override
  void initState() {
    super.initState();
    _movieController = TextEditingController();
  }

  @override
  void dispose() {
    _movieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo de imagen
          Image.asset(
            "lib\\claqueta.jpg",
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Añadir película:',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _movieController,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Nombre de la película',
                                hintStyle: TextStyle(color: Colors.white70),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: () {
                              String newMovie = _movieController.text.trim();
                              if (newMovie.isNotEmpty) {   
                                String movieToAdd = capitalize(newMovie);
                                print(newMovie);
                                print(movieToAdd);
                                print(movies.contains(movieToAdd));
                                if (!movies.contains(movieToAdd)) {                         
                                  appState.addMovie(movieToAdd);
                                  _movieController.clear();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.blueGrey,
                                    content: Text(
                                      'La película se ha añadido correctamente.',
                                    ),
                                  ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.blueGrey,
                                    content: Text(
                                      'ERROR: La película ya está en la lista.',
                                    ),
                                  ),
                                );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.blueGrey,
                                    content: Text(
                                      'ERROR: La película a añadir no puede estar vacía.',
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Text('Añadir'),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        // Número de películas en la lista
                        child: Text(
                          'Lista de ${movies.length} películas:',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          children: [
                            // Elementos de la lista
                            for (var movie in movies)
                              ListTile(
                                leading:
                                    Icon(Icons.movie_filter, color: Colors.white),
                                title: Text(
                                  movie,
                                  style: TextStyle(fontSize: 24, color: Colors.white),
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.white),
                                  onPressed: () {
                                    appState.removeMovie(movie);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.blueGrey,
                                    content: Text(
                                      'La película se ha eliminado.',
                                    ),
                                  ),
                              );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 650),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String capitalize(String newMovie) {
  List<String> words = newMovie.split(' ');
  String movie = "";
  for (String word in words) {
    movie += "${word.substring(0, 1).toUpperCase()}${word.substring(1).toLowerCase()} ";
  }

  return movie.trim();
}