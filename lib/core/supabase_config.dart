class SupabaseConfig {
  static const String url = String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://gcrhhdvfjgzwwokcfjxx.supabase.co');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdjcmhoZHZmamd6d3dva2Nmanh4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODgyNTc3OTUsImV4cCI6MjEwMzgzMzc5NX0.mJ_oYAUSlWu2-bWBclb0tO96pfyRDUQM1GCjD8IeUAM');
  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}