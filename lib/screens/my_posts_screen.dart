import 'package:flutter/material.dart';

import '../models/post.dart';
import '../services/api_service.dart';
import '../widgets/post_card.dart';
import 'detail_post_screen.dart';

class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({super.key});

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  List<Post> posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadMyPosts();
  }

  // =========================
  // LOAD POSTS DARI API
  // =========================

  Future<void> loadMyPosts() async {
    setState(() {
      isLoading = true;
    });   

    try {
      final allPosts = await ApiService.getPosts();
      setState(() {
        posts = allPosts.where((p) => p.author.contains('1')).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artikel Saya'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : posts.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.article_outlined,
                        size: 70,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Belum ada artikel',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadMyPosts,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];

                      return PostCard(
                        post: post,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetailPostScreen(post: post),
                            ),
                          );
                          loadMyPosts();
                        },
                        onLike: () {
                          setState(() {
                            post.isLiked = !post.isLiked;
                            post.likes += post.isLiked ? 1 : -1;
                          });
                        },
                      );
                    },
                  ),
                ),
    );
  }
}
