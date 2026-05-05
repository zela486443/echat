import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  print('URL: ${dotenv.env['VITE_SUPABASE_URL']}');
  print('KEY: ${dotenv.env['VITE_SUPABASE_PUBLISHABLE_KEY']}');
}
