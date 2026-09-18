import 'package:flutter/material.dart';
import 'my_posts_screen.dart';
import 'liked_posts_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Apakah kamu yakin ingin keluar dari akun?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // =========================
            // PROFILE HEADER
            // =========================

            const CircleAvatar(
              radius: 55,
              child: Icon(
                Icons.person,
                size: 60,
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              'Anisa',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              'anisa@email.com',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 35),

            // =========================
            // ARTIKEL SAYA
            // =========================

            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 5,
                ),
                leading: const CircleAvatar(
                  child: Icon(Icons.article_outlined),
                ),
                title: const Text(
                  'Artikel Saya',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  'Lihat artikel yang kamu buat',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const MyPostsScreen(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // =========================
            // ARTIKEL DISUKAI
            // =========================

            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 5,
                ),
                leading: const CircleAvatar(
                  child: Icon(Icons.favorite_border),
                ),
                title: const Text(
                  'Artikel Disukai',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  'Lihat artikel yang kamu sukai',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const LikedPostsScreen(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // =========================
            // LOGOUT
            // =========================

            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 5,
                ),
                leading: const CircleAvatar(
                  child: Icon(Icons.logout),
                ),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  'Keluar dari akun BlogApp',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  showLogoutDialog(context);
                },
              ),
            ),

            const SizedBox(height: 30),

            Text(
              'BlogApp',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              'Tempat berbagi cerita dan pengetahuan',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}