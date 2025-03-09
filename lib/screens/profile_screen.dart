import 'package:flutter/material.dart';
import 'package:cuentibot/services/profile_service.dart';
import 'package:cuentibot/models/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  final SupabaseClient _supabase = Supabase.instance.client;
  late String _userId;
  List<Profile> _profiles = [];

  @override
  void initState() {
    super.initState();
    _userId = _supabase.auth.currentUser?.id ?? '';
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final profiles = await _profileService.getProfiles(_userId);
    setState(() {
      _profiles = profiles;
    });
  }

  Future<void> _addProfile(Profile newProfile) async {
    try {
      await _profileService.addProfile(newProfile);
      _loadProfiles();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al añadir perfil: $e')),
      );
    }
  }


  Future<void> _deleteProfile(String profileId) async {
    await _profileService.deleteProfile(profileId);
    _loadProfiles();
  }

  Future<void> _setFavorite(String profileId) async {
    await _profileService.setFavoriteProfile(_userId, profileId);
    _loadProfiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfiles')),
      body: ListView.builder(
        itemCount: _profiles.length,
        itemBuilder: (context, index) {
          final profile = _profiles[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: profile.avatar.isNotEmpty
                  ? NetworkImage(profile.avatar)
                  : const AssetImage('assets/default_avatar.png') as ImageProvider,
            ),
            title: Text(profile.name),
            subtitle: Text('Edad: ${profile.age}, Sexo: ${profile.gender}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(profile.favorite ? Icons.star : Icons.star_border),
                  onPressed: () => _setFavorite(profile.id),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteProfile(profile.id),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showProfileForm,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showProfileForm() async {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  String selectedGender = 'Otro';

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Crear Nuevo Perfil'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          TextField(
            controller: ageController,
            decoration: const InputDecoration(labelText: 'Edad'),
            keyboardType: TextInputType.number,
          ),
          DropdownButton<String>(
            value: selectedGender,
            items: ['Masculino', 'Femenino', 'Otro'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedGender = value;
                });
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final newProfile = Profile(
              id: '', // No enviar ID
              userId: _userId,
              name: nameController.text,
              age: int.tryParse(ageController.text) ?? 0,
              gender: selectedGender,
              favorite: false,
              description: '',
              avatar: 'https://example.com/avatar.png', // Agregar URL por defecto
              createdAt: DateTime.now(),
            );
            _addProfile(newProfile);
            Navigator.pop(context); // Cerrar el formulario
          },
          child: const Text('Guardar'),
        ),
      ],
    ),
  );
}


}
