import '../../../core/supabase_config.dart';

Future<Map<String, String>> loadProfileData() async {
  String name = "User"; // Default name
  String profile_url = "";
  final userId = supabase.auth.currentUser?.id;

  if (userId != null) {
    try {
      final response = await supabase
          .from('profiles')
          .select('name, profile_url')
          .eq('id', userId)
          .single();

      if (response != null) {
        if (response['name'] != null) {
          name = response['name'] as String;
        }
        if (response['profile_url'] != null) {
          profile_url = response['profile_url'] as String;
        }
      }
    } catch (error) {
      print("Error loading profile data: $error");
      // Optionally handle the error, e.g., show a snackbar
    }
  } else {
    // User is not authenticated, return default values
    print("User not authenticated, using default profile data.");
  }

  return {'name': name, 'image_url': profile_url};
}