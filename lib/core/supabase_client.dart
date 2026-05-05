import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseCore {
  // Mapping to client.ts
  static Future<void> initialize() async {
    // Requires package: flutter_dotenv configured properly mimicking VITE_ envs.
    // Sanitizing environment variables to remove possible surrounding quotes
    final supabaseUrl = dotenv.env['VITE_SUPABASE_URL']?.replaceAll('"', '').trim();
    final supabaseKey = dotenv.env['VITE_SUPABASE_PUBLISHABLE_KEY']?.replaceAll('"', '').trim();

    if (supabaseUrl == null || supabaseKey == null || supabaseUrl.isEmpty || supabaseKey.isEmpty) {
      throw Exception('Missing or Invalid Supabase Environment Variables');
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
