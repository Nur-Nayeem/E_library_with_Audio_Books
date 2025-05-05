import 'package:audiobook_e_library/core/style/app_styles.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import 'dart:ui'; // Import for ImageFilter

import 'package:flutter/material.dart';

import 'auth_wrapper.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _ImageUploadState();
}

class _ImageUploadState extends State<UserProfile> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;
  String? imageUrl;
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _uploadImage() async {
    try {
      final imagePicker = ImagePicker();
      final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() => _isLoading = true);
        final Uint8List fileBytes = await pickedFile.readAsBytes();
        final String fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
        await supabase.storage.from("images").uploadBinary(fileName, fileBytes);

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Successfully Uploaded Image",
            style: TextStyle(fontSize: 21, color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ));

        // Get the public URL of the newly uploaded image
        final imageUrl = supabase.storage.from("images").getPublicUrl(fileName);

        // Update the user's profile with this new image URL
        final userId = supabase.auth.currentUser?.id;
        if (userId != null) {
          await supabase
              .from('profiles')
              .update({'profile_url': imageUrl})
              .eq('id', userId);

          // Update the local state to reflect the new image URL immediately
          if (mounted) {
            setState(() {
              this.imageUrl = imageUrl;
            });
          }
        }
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Failed Uploading Image: $error",
          style: const TextStyle(fontSize: 21, color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final userId = supabase.auth.currentUser?.id;
        final newName = _nameController.text.trim();
        final newProfileUrl = imageUrl;

        if (userId != null) {
          final response = await supabase
              .from('profiles')
              .update({'name': newName, 'profile_url': newProfileUrl})
              .eq('id', userId)
              .select();

          if (response != null && response.isNotEmpty) {
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
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        final response = await supabase
            .from('profiles')
            .select('name, profile_url')
            .eq('id', userId)
            .single();

        if (response != null) {
          if (response['name'] != null) {
            _nameController.text = response['name'] as String;
          }
          if (response['profile_url'] != null) {
            setState(() {
              imageUrl = response['profile_url'] as String;
            });
          }
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
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchLatestImage() async {
    try {
      final files = await supabase.storage.from("images").list();
      if (files.isNotEmpty) {
        // Sort files by name (assuming names are timestamps) to get the latest
        files.sort((a, b) => b.name.compareTo(a.name));
        final latestFile = files.first;
        final url = supabase.storage.from("images").getPublicUrl(latestFile.name);

        if (mounted) {
          setState(() {
            imageUrl = url;
          });
        }
      } else if (mounted) {
        setState(() {
          imageUrl = null;
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Can't fetch image: $error")));
    }
  }


  Future<void> _logout() async {
    await supabase.auth.signOut();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logged out successfully'),
          backgroundColor: Colors.green,
        ),
      );
      // Navigate to the AuthGate and remove all previous routes from the stack
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthGate()),
            (Route<dynamic> route) => false,
      );

    }
  }

  @override
  Widget build(BuildContext context) {
    print(Navigator);
    return Scaffold(
      backgroundColor: AppStyles.bgColor.withOpacity(0.8), // Make background slightly transparent
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor.withOpacity(0.8), // Make app bar slightly transparent
        title: const Text("Profile", style: TextStyle(color: Colors.black87)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87), // Color of back button
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black87),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200]?.withOpacity(0.8), // Transparent container
                    ),
                    child: imageUrl == null
                        ? Icon(
                      Icons.person,
                      size: 100,
                      color: Colors.grey.withOpacity(0.8), // Transparent icon
                    )
                        : ClipOval(
                      child: Image.network(
                        imageUrl!,
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                                  : null,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.black54),
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
                      onPressed: _uploadImage,
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
                      child: const Icon(Icons.edit, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black54.withOpacity(0.8))),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black54.withOpacity(0.8))),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
                  prefixIcon: Icon(Icons.person, color: Colors.black54.withOpacity(0.8)),
                  labelStyle: TextStyle(color: Colors.black54.withOpacity(0.8)),
                ),
                style: const TextStyle(color: Colors.black87),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}