import 'package:supabase_flutter/supabase_flutter.dart';

class LibraryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> saveStory({
    required String userId,
    required String tipo,
    String? categoria,
    String? descripcion,
    String? cuentoPopular,
    required String titulo,
    required String texto,
  }) async {
    await _supabase.from('stories').insert({
      'user_id': userId,
      'tipo': tipo,
      'categoria': categoria,
      'descripcion': descripcion,
      'cuento_popular': cuentoPopular,
      'titulo': titulo,
      'texto': texto,
    });
  }

  Future<List<Map<String, dynamic>>> getUserStories(String userId) async {
    final response = await _supabase
        .from('stories')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return response;
  }
}
