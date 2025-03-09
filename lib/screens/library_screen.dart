import 'package:flutter/material.dart';
import 'package:cuentibot/services/library_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final LibraryService _libraryService = LibraryService();
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _stories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  Future<void> _loadStories() async {
    final userId = _supabase.auth.currentUser?.id ?? '';
    final stories = await _libraryService.getUserStories(userId);
    setState(() {
      _stories = stories;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Biblioteca')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stories.isEmpty
              ? const Center(child: Text('No hay cuentos guardados'))
              : ListView.builder(
                  itemCount: _stories.length,
                  itemBuilder: (context, index) {
                    final story = _stories[index];
                    return ListTile(
                      title: Text(story['titulo']),
                      subtitle: Text('Tipo: ${story['tipo']}'),
                      onTap: () => _showStoryDetails(story),
                    );
                  },
                ),
    );
  }

  void _showStoryDetails(Map<String, dynamic> story) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(story['titulo']),
        content: SingleChildScrollView(
          child: Text(story['texto']),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
