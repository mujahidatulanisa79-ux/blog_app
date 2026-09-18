import 'package:flutter/material.dart';

import '../services/api_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  int selectedCategoryId = 1;
  bool isLoading = false;

  // =========================
  // DAFTAR KATEGORI
  // =========================

  final List<Map<String, dynamic>> categories = [
    {'id': 1, 'name': 'Teknologi'},
    {'id': 2, 'name': 'Programming'},
    {'id': 3, 'name': 'Tutorial'},
    {'id': 4, 'name': 'Tips & Trik'},
    {'id': 5, 'name': 'Berita'},
    {'id': 6, 'name': 'Review'},
    {'id': 7, 'name': 'Desain'},
    {'id': 8, 'name': 'Career'},
  ];

  // =========================
  // PUBLISH ARTIKEL
  // =========================

  Future<void> publishPost() async {
    final String title = titleController.text.trim();
    final String content = contentController.text.trim();

    // =========================
    // VALIDASI JUDUL
    // =========================

    if (title.isEmpty) {
      showMessage('Judul artikel wajib diisi!');
      return;
    }

    if (title.length < 5) {
      showMessage('Judul artikel minimal 5 karakter!');
      return;
    }

    if (title.length > 100) {
      showMessage('Judul artikel maksimal 100 karakter!');
      return;
    }

    // =========================
    // VALIDASI ISI ARTIKEL
    // =========================

    if (content.isEmpty) {
      showMessage('Isi artikel wajib diisi!');
      return;
    }

    if (content.length < 20) {
      showMessage('Isi artikel minimal 20 karakter!');
      return;
    }

    if (content.length > 5000) {
      showMessage('Isi artikel maksimal 5000 karakter!');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final category = categories.firstWhere(
        (category) => category['id'] == selectedCategoryId,
      );

      await ApiService.createPost(
        title: title,
        content: content,
        author: 'Anisa',
        categoryId: category['id'],
        categoryName: category['name'],
      );

      if (!mounted) return;

      showMessage('Artikel berhasil dipublikasikan!');

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      showMessage('Gagal mempublikasikan artikel');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // =========================
  // SHOW MESSAGE
  // =========================

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // =========================
  // DISPOSE
  // =========================

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Buat Artikel',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================
            // JUDUL ARTIKEL
            // =========================

            const Text(
              'Judul Artikel',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: titleController,
              textInputAction: TextInputAction.next,
              maxLength: 100,
              decoration: const InputDecoration(
                hintText: 'Masukkan judul artikel',
                border: OutlineInputBorder(),
                counterText: 'Maksimal 100 karakter',
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // KATEGORI
            // =========================

            const Text(
              'Kategori',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<int>(
              initialValue: selectedCategoryId,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Pilih kategori',
              ),
              items: categories.map((category) {
                return DropdownMenuItem<int>(
                  value: category['id'],
                  child: Text(category['name']),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  selectedCategoryId = value;
                });
              },
            ),

            const SizedBox(height: 20),

            // =========================
            // ISI ARTIKEL
            // =========================

            const Text(
              'Isi Artikel',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: contentController,
              minLines: 10,
              maxLines: null,
              maxLength: 5000,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                hintText: 'Tulis isi artikel di sini...',
                border: OutlineInputBorder(),
                counterText: 'Maksimal 5000 karakter',
              ),
            ),

            const SizedBox(height: 24),

            // =========================
            // BUTTON PUBLISH
            // =========================

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : publishPost,
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.publish),
                label: Text(
                  isLoading ? 'Menyimpan...' : 'Publikasikan',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}