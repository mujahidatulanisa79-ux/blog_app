import 'package:flutter/material.dart';

import '../models/post.dart';
import '../services/api_service.dart';

class EditPostScreen extends StatefulWidget {
  final Post post;

  const EditPostScreen({
    super.key,
    required this.post,
  });

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  late TextEditingController titleController;
  late TextEditingController contentController;

  late int selectedCategoryId;
  bool isLoading = false;

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

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.post.title);
    contentController = TextEditingController(text: widget.post.content);
    selectedCategoryId = widget.post.categoryId;
  }

  // =========================
  // UPDATE POST KE API
  // =========================

  Future<void> saveChanges() async {
    final title = titleController.text.trim();
    final content = contentController.text.trim();

    if (title.isEmpty) {
      showMessage('Judul artikel wajib diisi!');
      return;
    }

    if (content.isEmpty) {
      showMessage('Isi artikel wajib diisi!');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final category = categories.firstWhere(
        (c) => c['id'] == selectedCategoryId,
      );

      await ApiService.updatePost(
        id: widget.post.id,
        title: title,
        content: content,
        categoryId: category['id'],
        categoryName: category['name'],
      );

      if (mounted) {
        showMessage('Artikel berhasil diperbarui!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        showMessage('Gagal memperbarui artikel!');
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Artikel'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================
            // JUDUL
            // =========================

            const Text(
              'Judul Artikel',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: 'Masukkan judul artikel',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // KATEGORI
            // =========================

            const Text(
              'Kategori',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: selectedCategoryId,
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
                setState(() {
                  selectedCategoryId = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            // =========================
            // ISI
            // =========================

            const Text(
              'Isi Artikel',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: contentController,
              minLines: 10,
              maxLines: null,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                hintText: 'Tulis isi artikel di sini...',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            // =========================
            // BUTTON
            // =========================

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : saveChanges,
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  isLoading ? 'Menyimpan...' : 'Simpan Perubahan',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
