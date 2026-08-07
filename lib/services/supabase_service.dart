import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient client = Supabase.instance.client;

  // Example: wrap any remaining custom API calls to the AI backend here
  // For instance, sending the uploaded file URL to the FastAPI /api/v1/reports/upload endpoint
  // This can use standard http or dio if added back, but since we removed them, 
  // we might need to use Supabase edge functions or just use Supabase client's native features.
}

final supabaseService = SupabaseService();
