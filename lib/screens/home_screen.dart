import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cuentibot/screens/profile_screen.dart';
import 'package:cuentibot/screens/library_screen.dart';
import 'package:cuentibot/screens/settings_screen.dart';
import 'package:cuentibot/screens/story_generation_screen.dart';
import 'package:cuentibot/services/profile_service.dart';
import 'package:cuentibot/models/profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProfileService _profileService = ProfileService();
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Profile> _profiles = [];
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeContent(),
    const LibraryScreen(),
    const ProfileScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final userId = _supabase.auth.currentUser?.id ?? '';
    final profiles = await _profileService.getProfiles(userId);
    setState(() {
      _profiles = profiles;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.library_books), label: 'Biblioteca'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfiles'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> storyOptions = [
      {
        'title': 'Generación Automática',
        'icon': Icons.auto_stories,
        'description': 'Genera un cuento basado en uno o varios perfiles.',
        'type': 'Automático',
      },
      {
        'title': 'Por Categoría',
        'icon': Icons.category,
        'description': 'Elige una categoría y selecciona perfiles.',
        'type': 'Por Categoría',
      },
      {
        'title': 'Descriptivo',
        'icon': Icons.edit,
        'description': 'Escribe una breve descripción de la historia.',
        'type': 'Descriptivo',
      },
      {
        'title': 'Cuento Popular',
        'icon': Icons.menu_book,
        'description': 'Personaliza un cuento clásico con tu personaje.',
        'type': 'Popular',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: storyOptions.length,
        itemBuilder: (context, index) {
          final option = storyOptions[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StoryGenerationScreen(
                    storyType: option['type'], // Pasamos el tipo de historia
                  ),
                ),
              );
            },
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(option['icon'], size: 40, color: Colors.blue),
                  const SizedBox(height: 10),
                  Text(option['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(option['description'], textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
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
