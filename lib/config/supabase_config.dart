import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // Phase 1 Credentials
  // Replace with your actual Project URL
  static const String url = 'https://yltepchbwwrsavfgbhzx.supabase.co';
  
  // Replace with your actual Anon Key
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlsdGVwY2hid3dyc2F2ZmdiaHp4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM4MjAxMjEsImV4cCI6MjA3OTM5NjEyMX0.28YDeB_bzmc2M6YWwDrdzWuuHoBcpd54vUwUMO5yYl0';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }
}