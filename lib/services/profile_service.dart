import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Obtener perfiles del usuario
  Future<List<Profile>> getProfiles(String userId) async {
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: true);

    if (response.isEmpty) return [];

    return response.map((profile) => Profile.fromJson(profile)).toList();
  }

  // Eliminar un perfil
  Future<void> deleteProfile(String profileId) async {
    await _supabase.from('profiles').delete().eq('id', profileId);
  }

  // Marcar un perfil como favorito
  Future<void> setFavoriteProfile(String userId, String profileId) async {
    await _supabase
        .from('profiles')
        .update({'favorite': false})
        .eq('user_id', userId);

    await _supabase
        .from('profiles')
        .update({'favorite': true})
        .eq('id', profileId);
  }

  // Agregar un nuevo perfil
  Future<void> addProfile(Profile profile) async {
  final existingProfiles = await getProfiles(profile.userId);
  if (existingProfiles.length >= 3) {
    throw Exception('No puedes crear más de 3 perfiles.');
  }

  // ❌ No incluir `id`, Supabase lo genera automáticamente
  await _supabase.from('profiles').insert({
    'user_id': profile.userId,
    'name': profile.name,
    'age': profile.age,
    'gender': profile.gender,
    'favorite': profile.favorite,
    'description': profile.description,
    'avatar': profile.avatar,
    'created_at': DateTime.now().toIso8601String(),
  });
}


}
