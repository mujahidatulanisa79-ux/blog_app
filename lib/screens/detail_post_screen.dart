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

  final TextEditingController commentController =
      TextEditingController();

  List<Comment> comments = [];

  bool isLoadingComments = true;
  bool isSendingComment = false;
  bool isDeletingPost = false;

  @override
  void initState() {
    super.initState();

    post = widget.post;

    loadComments();
  }

  // =========================
  // LOAD COMMENTS
  // =========================

  Future<void> loadComments() async {
    if (mounted) {
      setState(() {
        isLoadingComments = true;
      });
    }

    try {
      final data = await ApiService.getComments(post.id);

      if (!mounted) return;

      setState(() {
        comments = data;
        isLoadingComments = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingComments = false;
      });
    }
  }

  // =========================
  // TOGGLE LIKE
  // =========================

  void toggleLike() {
    setState(() {
      post.isLiked = !post.isLiked;

      post.likes += post.isLiked ? 1 : -1;
    });
  }

  // =========================
  // ADD COMMENT
  // =========================

  Future<void> addComment() async {
    final String content = commentController.text.trim();

    if (content.isEmpty) {
      showMessage('Komentar tidak boleh kosong!');
      return;
    }

    if (content.length < 3) {
      showMessage('Komentar minimal 3 karakter!');
      return;
    }

    if (content.length > 500) {
      showMessage('Komentar maksimal 500 karakter!');
      return;
    }

    setState(() {
      isSendingComment = true;
    });

    try {
      await ApiService.addComment(
        postId: post.id,
        author: 'Kaysan',
        content: content,
      );

      if (!mounted) return;

      commentController.clear();

      await loadComments();

      if (!mounted) return;

      showMessage('Komentar berhasil ditambahkan!');
    } catch (e) {
      if (!mounted) return;

      showMessage('Gagal menambahkan komentar');
    } finally {
      if (mounted) {
        setState(() {
          isSendingComment = false;
        });
      }
    }
  }

  // =========================
  // EDIT POST
  // =========================

  Future<void> editPost() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditPostScreen(post: post),
      ),
    );

    if (!mounted || result != true) return;

    try {
      final updatedPost = await ApiService.getPostById(post.id);

      if (!mounted) return;

      setState(() {
        post = updatedPost;
      });
    } catch (e) {
      if (!mounted) return;

      showMessage('Gagal memuat artikel terbaru');
    }
  }

  // =========================
  // DELETE POST
  // =========================

  Future<void> deletePost() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Artikel'),
          content: const Text(
            'Apakah kamu yakin ingin menghapus artikel ini?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      isDeletingPost = true;
    });

    try {
      await ApiService.deletePost(post.id);

      if (!mounted) return;

      showMessage('Artikel berhasil dihapus');

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isDeletingPost = false;
      });

      showMessage('Gagal menghapus artikel');
    }
  }

  // =========================
  // SHOW MESSAGE
  // =========================

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
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
    commentController.dispose();

    super.dispose();
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Artikel'),
        actions: [
          IconButton(
            onPressed: editPost,
            tooltip: 'Edit Artikel',
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: isDeletingPost ? null : deletePost,
            tooltip: 'Hapus Artikel',
            icon: isDeletingPost
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.delete),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================
            // GAMBAR ARTIKEL
            // =========================

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

            // =========================
            // DETAIL ARTIKEL
            // =========================

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
                      const Icon(
                        Icons.person_outline,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(post.author),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // =========================
                  // ISI ARTIKEL
                  // =========================

                  Text(
                    post.content,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // =========================
                  // LIKE & KOMENTAR
                  // =========================

                  Row(
                    children: [
                      IconButton(
                        onPressed: toggleLike,
                        tooltip: 'Sukai artikel',
                        icon: Icon(
                          post.isLiked
                              ? Icons.favorite
                              : Icons.favorite_border,
                        ),
                      ),

                      Text('${post.likes}'),

                      const SizedBox(width: 20),

                      const Icon(
                        Icons.comment_outlined,
                      ),

                      const SizedBox(width: 6),

                      Text(
                        '${comments.length} komentar',
                      ),
                    ],
                  ),

                  const Divider(
                    height: 35,
                  ),

                  // =========================
                  // KOMENTAR
                  // =========================

                  const Text(
                    'Komentar',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // =========================
                  // INPUT KOMENTAR
                  // =========================

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          minLines: 1,
                          maxLines: 4,
                          maxLength: 500,
                          decoration: const InputDecoration(
                            hintText: 'Tulis komentar...',
                            border: OutlineInputBorder(),
                            counterText: '',
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      IconButton(
                        onPressed:
                            isSendingComment ? null : addComment,
                        tooltip: 'Kirim komentar',
                        icon: isSendingComment
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.send,
                              ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // =========================
                  // LOADING KOMENTAR
                  // =========================

                  if (isLoadingComments)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    )

                  // =========================
                  // BELUM ADA KOMENTAR
                  // =========================

                  else if (comments.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'Belum ada komentar.',
                        ),
                      ),
                    )

                  // =========================
                  // DAFTAR KOMENTAR
                  // =========================

                  else
                    ...comments.map(
                      (comment) => CommentItem(
                        comment: comment,
                      ),
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