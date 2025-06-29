import 'package:flutter/material.dart';
import '../models/user_models.dart';
import '../pages/book_favorite_pages.dart';
import '../pages/book_saved_pages.dart';
import '../pages/profile_pages.dart';

class CustomDrawer extends StatelessWidget {
  final Future<UserProfile> Function() fetchUserProfile;
  final VoidCallback onProfileUpdated;
  final VoidCallback onFavoritesChanged;
  final VoidCallback onSavedChanged;

  const CustomDrawer({
    super.key,
    required this.fetchUserProfile,
    required this.onProfileUpdated,
    required this.onFavoritesChanged,
    required this.onSavedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          FutureBuilder<UserProfile>(
            future: fetchUserProfile(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: DrawerHeader(
                    decoration: BoxDecoration(color: Color(0xfff8c9d3)),
                    margin: EdgeInsets.zero,
                    padding: EdgeInsets.zero,
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                );
              } else if (snapshot.hasError || !snapshot.hasData) {
                return const SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: DrawerHeader(
                    decoration: BoxDecoration(color: Color(0xfff8c9d3)),
                    margin: EdgeInsets.zero,
                    padding: EdgeInsets.zero,
                    child: Center(
                      child: Text(
                        'User not found',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                );
              }

              final user = snapshot.data!;
              final imageUrl = user.profileImages.isNotEmpty
                  ? user.profileImages.first.url
                  : null;

              return SizedBox(
                height: 225,
                width: double.infinity,
                child: DrawerHeader(
                  decoration: const BoxDecoration(color: Color(0xfff8c9d3)),
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Picture
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white,
                        backgroundImage: imageUrl != null
                            ? NetworkImage(imageUrl)
                            : null,
                        child: imageUrl == null
                            ? const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                      const SizedBox(height: 12),

                      // Full Name
                      Text(
                        user.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // Email
                      Text(
                        user.email,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Profile'),
                  onTap: () async {
                    Navigator.pop(context);

                    final updated = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfilePage(),
                      ),
                    );

                    if (updated == true) {
                      onProfileUpdated();
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.favorite),
                  title: const Text('Favorite'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FavoritePage(
                          onFavoritesChanged: onFavoritesChanged,
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.bookmark),
                  title: const Text('Saved'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            SavedPage(onSavedChanged: onSavedChanged),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 16, bottom: 32),
            child: Column(
              children: [
                Text(
                  'Developed with ❤️ by Amelia Rizky Yuniar',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                SizedBox(height: 4),
                Text(
                  'Version 1.0.1',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
