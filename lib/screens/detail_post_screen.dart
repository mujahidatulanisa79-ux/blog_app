import 'package:flutter/material.dart';

import '../models/post.dart';
import '../models/comment.dart';
import '../services/api_service.dart';
import '../widgets/comment_item.dart';
import 'edit_post_screen.dart';

class DetailPostScreen extends StatefulWidget {
  final Post post;

  const DetailPostScreen({
    super.key,
    required this.post,
  });

  @override
  State<DetailPostScreen> createState() => _DetailPostScreenState();
}

class _DetailPostScreenState extends State<DetailPostScreen> {
  late Post post;
  final commentController = TextEditingController();

  List<Comment> comments = [];
  bool isLoadingComments = true;

  @override
  void initState() {
    super.initState();
    post = widget.post;
    loadComments();
  }

  // =========================
  // LOAD COMMENTS DARI API
  // =========================

  Future<void> loadComments() async {
    setState(() {
      isLoadingComments = true;
    });

    try {
      final data = await ApiService.getComments(post.id);
      setState(() {
        comments = data;
        isLoadingComments = false;
      });
    } catch (e) {
      setState(() {
        isLoadingComments = false;
      });
    }
  }

  // =========================
  // TOGGLE LIKE (LOKAL)
  // =========================

  void toggleLike() {
    setState(() {
      post.isLiked = !post.isLiked;
      post.likes += post.isLiked ? 1 : -1;
    });
  }

  // =========================
  // ADD COMMENT KE API
  // =========================

  Future<void> addComment() async {
    final content = commentController.text.trim();

    if (content.isEmpty) {
      showMessage('Komentar tidak boleh kosong!');
      return;
    }

    try {
      await ApiService.addComment(
        postId: post.id,
        author: 'Kaysan',
        content: content,
      );

      commentController.clear();
      await loadComments();

      showMessage('Komentar berhasil ditambahkan!');
    } catch (e) {
      showMessage('Gagal menambahkan komentar');
    }
  }

  // =========================
  // EDIT POST
  // =========================

  Future<void> editPost() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPostScreen(post: post),
      ),
    );

    if (result == true && mounted) {
      try {
        final updatedPost = await ApiService.getPostById(post.id);
        setState(() {
          post = updatedPost;
        });
      } catch (e) {
        // Keep current post data
      }
    }
  }

  // =========================
  // DELETE POST
  // =========================

  void deletePost() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Artikel'),
          content: const Text(
            'Apakah kamu yakin ingin menghapus artikel ini?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);

                try {
                  await ApiService.deletePost(post.id);
                  if (mounted) {
                    Navigator.pop(context, true);
                  }
                } catch (e) {
                  showMessage('Gagal menghapus artikel');
                }
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Artikel'),
        actions: [
          IconButton(
            onPressed: editPost,
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: deletePost,
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              post.image,
              width: double.infinity,
              height: 230,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 230,
                  width: double.infinity,
                  color: Colors.grey.shade300,
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 60,
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.categoryName,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 20),
                      const SizedBox(width: 6),
                      Text(post.author),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    post.content,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      IconButton(
                        onPressed: toggleLike,
                        icon: Icon(
                          post.isLiked
                              ? Icons.favorite
                              : Icons.favorite_border,
                        ),
                      ),
                      Text('${post.likes}'),
                      const SizedBox(width: 20),
                      const Icon(Icons.comment_outlined),
                      const SizedBox(width: 6),
                      Text('${comments.length} komentar'),
                    ],
                  ),
                  const Divider(height: 35),
                  const Text(
                    'Komentar',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          minLines: 1,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: 'Tulis komentar...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: addComment,
                        icon: const Icon(Icons.send),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (isLoadingComments)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (comments.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('Belum ada komentar.'),
                      ),
                    )
                  else
                    ...comments.map(
                      (comment) => CommentItem(comment: comment),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
