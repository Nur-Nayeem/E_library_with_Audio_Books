import 'package:audiobook_e_library/core/book-model/data.dart';
import 'package:audiobook_e_library/core/style/app_styles.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/style/book_card.dart';
import '../../../core/theme/theme_provider.dart';
import 'auth_wrapper.dart';
import 'package:google_fonts/google_fonts.dart';

class UserProfile  extends ConsumerStatefulWidget {
  const UserProfile ({super.key});

  @override
  ConsumerState<UserProfile > createState() =>
      _UserProfileState();
}

class _UserProfileState
    extends ConsumerState<UserProfile> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;
  String? _imageUrl;
  final _nameController = TextEditingController();
  bool _isLoadingProfile = false;
  List<Booksdata> savedBooks = [];
  bool _isLoadingLibrary = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _fetchSavedBooks();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleImageUpload() async {
    try {
      final pickedFile =
      await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      setState(() => _isLoadingProfile = true);
      final Uint8List fileBytes = await pickedFile.readAsBytes();
      final String fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";

      await supabase.storage.from("images").uploadBinary(fileName, fileBytes);

      final newImageUrl = supabase.storage.from("images").getPublicUrl(fileName);

      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        await supabase
            .from('profiles')
            .update({'profile_url': newImageUrl})
            .eq('id', userId);

        if (mounted) {
          setState(() {
            _imageUrl = newImageUrl;
          });
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Image uploaded successfully!",
              style: TextStyle(fontSize: 16),
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Failed to upload image: $error",
              style: const TextStyle(fontSize: 16),
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingProfile = false);
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoadingProfile = true);
      try {
        final userId = supabase.auth.currentUser?.id;
        final newName = _nameController.text.trim();
        final newProfileUrl = _imageUrl;

        if (userId == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('User not authenticated.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        final response = await supabase
            .from('profiles')
            .update({'name': newName, 'profile_url': newProfileUrl})
            .eq('id', userId)
            .select();

        if (response.isNotEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to update profile.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating profile: $error'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoadingProfile = false);
        }
      }
    }
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoadingProfile = true);
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        final response = await supabase
            .from('profiles')
            .select('name, profile_url')
            .eq('id', userId)
            .maybeSingle();

        if (response != null) {
          _nameController.text = response['name'] ?? '';
          _imageUrl = response['profile_url'];
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: $error'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingProfile = false);
      }
    }
  }
  // It's generally better to use camelCase for variable names in Dart

  // List<Booksdata> savebooks = [];

  Future<void> _fetchSavedBooks() async {
    setState(() => _isLoadingLibrary = true);
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }
      final response = await supabase
          .from('user_saved_books')
          .select('''
          book_id,
          books_data (*)
        ''')
          .eq('user_id', userId);

      if (response.isNotEmpty) {
        print("enter");
        savedBooks = response
            .map((item) => Booksdata.fromMap(item['books_data'] as Map<String, dynamic>))
            .toList();
      } else {
        savedBooks = [];
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching saved books: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingLibrary = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor:
      isDarkMode ? Colors.grey[800] : AppStyles.bgColor.withOpacity(0.8),
      appBar: AppBar(
        backgroundColor:
        isDarkMode ? Colors.grey[700] : AppStyles.bgColor.withOpacity(0.8),
        title: const Text("Profile", style: TextStyle(color: Colors.black87)),
        centerTitle: true,
        iconTheme:
        IconThemeData(color: isDarkMode ? Colors.white : Colors.black87),
        leading: IconButton(
          icon: Icon(isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: isDarkMode ? Colors.white : Colors.black87),
          onPressed: () {
            ref.read(themeProvider.notifier).toggleTheme();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout,
                color: isDarkMode ? Colors.white : Colors.black87),
            tooltip: 'Logout',
            onPressed: () async {
              await supabase.auth.signOut();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const AuthGate()),
                      (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildProfileImage(isDarkMode),
                    const SizedBox(height: 30),
                    _buildNameField(isDarkMode),
                    const SizedBox(height: 30),
                    _buildUpdateProfileButton(),
                    const SizedBox(height: 40),
                    Divider(
                      color: Colors.grey.withOpacity(0.3),
                      thickness: 1,
                    ),
                    const SizedBox(height: 20),
                    _buildLibrarySection(isDarkMode),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(bool isDarkMode) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[200]?.withOpacity(0.8),
          ),
          child: _imageUrl == null
              ? Icon(
            Icons.person,
            size: 50,
            color: Colors.grey.withOpacity(0.8),
          )
              : ClipOval(
            child: Image.network(
              _imageUrl!,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                        : null,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.secondary),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(
                    Icons.error,
                    color: Colors.red,
                    size: 50,
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          right: 10,
          child: FloatingActionButton(
            mini: true,
            onPressed: _handleImageUpload,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0),
            child: const Icon(Icons.edit, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildNameField(bool isDarkMode) {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Name',
        border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black54.withOpacity(0.8))),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black54.withOpacity(0.8))),
        focusedBorder:
        const OutlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
        prefixIcon: Icon(Icons.person, color: Colors.black54.withOpacity(0.8)),
        labelStyle: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.black54.withOpacity(0.8)),
      ),
      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your name';
        }
        return null;
      },
    );
  }

  Widget _buildUpdateProfileButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _updateProfile,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
          foregroundColor: Colors.white,
        ),
        child: const Text(
          'Update Profile',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildLibrarySection(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Saved Books',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        _isLoadingLibrary
            ? Center(
            child: CircularProgressIndicator(
                color: isDarkMode ? Colors.white : null))
            : savedBooks.isEmpty
            ? Text('No saved books found',
            style:
            TextStyle(color: isDarkMode ? Colors.white : Colors.black87))
            : GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.6,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: savedBooks.length,
          itemBuilder: (context, index) {
            return Books(book: savedBooks[index].toMap(), typeed: "saved");
          },
        ),
      ],
    );
  }
}