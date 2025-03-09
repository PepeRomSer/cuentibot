import 'package:flutter/material.dart';
import 'package:cuentibot/models/profile.dart';
import 'package:cuentibot/services/profile_service.dart';
import 'package:cuentibot/services/story_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cuentibot/services/library_service.dart'; // Nuevo servicio para guardar cuentos

class StoryGenerationScreen extends StatefulWidget {
  final String storyType;

  const StoryGenerationScreen({super.key, required this.storyType});

  @override
  _StoryGenerationScreenState createState() => _StoryGenerationScreenState();
}

class _StoryGenerationScreenState extends State<StoryGenerationScreen> {
  final ProfileService _profileService = ProfileService();
  final SupabaseClient _supabase = Supabase.instance.client;
  final StoryService _storyService = StoryService();
  final LibraryService _libraryService = LibraryService();

  List<Profile> _profiles = [];
  List<Profile> _selectedProfiles = [];
  String _selectedCategory = 'Aventura';
  String _userInputDescription = '';
  String _selectedPopularStory = 'Caperucita Roja';
  bool _isLoading = false;
  String _generatedStory = '';
  String _generatedTitle = '';

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

  void _toggleProfileSelection(Profile profile) {
    setState(() {
      if (_selectedProfiles.contains(profile)) {
        _selectedProfiles.remove(profile);
      } else {
        _selectedProfiles.add(profile);
      }
    });
  }

  void _startStoryGeneration() async {
    if (_selectedProfiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un perfil')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, String> storyData = await _storyService.generateStory(
        storyType: widget.storyType,
        profiles: _selectedProfiles,
        category: _selectedCategory,
        description: _userInputDescription,
        popularStory: _selectedPopularStory,
      );

      setState(() {
        _generatedStory = storyData["texto"]!;
        _generatedTitle = storyData["titulo"]!;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al generar el cuento: $e')),
      );
    }
  }


  void _saveStory() async {
    if (_generatedStory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay cuento para guardar')),
      );
      return;
    }

    final userId = _supabase.auth.currentUser?.id ?? '';

    try {
      await _libraryService.saveStory(
        userId: userId,
        tipo: widget.storyType,
        categoria: widget.storyType == 'Por Categoría' ? _selectedCategory : null,
        descripcion: widget.storyType == 'Descriptivo' ? _userInputDescription : null,
        cuentoPopular: widget.storyType == 'Popular' ? _selectedPopularStory : null,
        titulo: _generatedTitle,
        texto: _generatedStory,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cuento guardado en la biblioteca')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar el cuento: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generar Cuento')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Tipo de cuento seleccionado: ${widget.storyType}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Selecciona perfiles:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: _profiles.map((profile) {
                final isSelected = _selectedProfiles.contains(profile);
                return ChoiceChip(
                  label: Text(profile.name),
                  selected: isSelected,
                  onSelected: (_) => _toggleProfileSelection(profile),
                  selectedColor: Colors.blueAccent,
                );
              }).toList(),
            ),
            if (widget.storyType == 'Por Categoría') ...[
              const SizedBox(height: 20),
              const Text('Selecciona una categoría:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: _selectedCategory,
                items: ['Aventura', 'Magia', 'Ciencia Ficción', 'Misterio', 'Animales', 'Valores'].map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
            ],
            if (widget.storyType == 'Descriptivo') ...[
              const SizedBox(height: 20),
              const Text('Describe tu cuento:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextField(
                onChanged: (value) {
                  setState(() {
                    _userInputDescription = value;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Ejemplo: Un niño que encuentra un dragón mágico...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
            if (widget.storyType == 'Popular') ...[
              const SizedBox(height: 20),
              const Text('Selecciona un cuento popular:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: _selectedPopularStory,
                items: ['Caperucita Roja', 'Los Tres Cerditos', 'Blancanieves', 'Hansel y Gretel', 'El Gato con Botas'].map((String story) {
                  return DropdownMenuItem<String>(
                    value: story,
                    child: Text(story),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPopularStory = value;
                    });
                  }
                },
              ),
            ],
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _startStoryGeneration,
                child: _isLoading ? const CircularProgressIndicator() : const Text('Generar Cuento'),
              ),
            ),
            if (_generatedStory.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text('Cuento Generado:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _generatedStory,
                  textAlign: TextAlign.justify,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _saveStory,
                  child: const Text('Guardar en Biblioteca'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
