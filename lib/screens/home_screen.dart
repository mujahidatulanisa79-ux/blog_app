import 'package:flutter/material.dart';

import '../models/post.dart';
import '../services/api_service.dart';
import '../widgets/post_card.dart';
import '../widgets/search_bar.dart';
import 'create_post_screen.dart';
import 'detail_post_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // =========================================================
  // CONTROLLER
  // =========================================================

  final TextEditingController searchController =
      TextEditingController();

  // =========================================================
  // STATE
  // =========================================================

  String searchText = '';
  String selectedCategory = 'Semua';

  List<Post> posts = [];

  bool isLoading = true;
  String? errorMessage;

  // =========================================================
  // INIT
  // =========================================================

  @override
  void initState() {
    super.initState();
    loadPosts();
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // =========================================================
  // LOAD POSTS
  // =========================================================

  Future<void> loadPosts() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await ApiService.getPosts();

      if (!mounted) return;

      setState(() {
        posts = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        posts = [];
        isLoading = false;
        errorMessage = 'Gagal memuat artikel';
      });
    }
  }

  // =========================================================
  // FILTER POSTS
  // =========================================================

  List<Post> get filteredPosts {
    final keyword = searchText.trim().toLowerCase();

    return posts.where((post) {
      final matchesSearch =
          keyword.isEmpty ||
          post.title.toLowerCase().contains(keyword) ||
          post.content.toLowerCase().contains(keyword) ||
          post.categoryName.toLowerCase().contains(keyword);

      final matchesCategory =
          selectedCategory == 'Semua' ||
          post.categoryName.toLowerCase() ==
              selectedCategory.toLowerCase();

      return matchesSearch && matchesCategory;
    }).toList();
  }

  // =========================================================
  // CREATE ARTICLE
  // =========================================================

  Future<void> openCreatePost() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreatePostScreen(),
      ),
    );

    if (result == true && mounted) {
      await loadPosts();
    }
  }

  // =========================================================
  // DETAIL ARTICLE
  // =========================================================

  Future<void> openDetailPost(Post post) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPostScreen(
          post: post,
        ),
      ),
    );

    if (result == true && mounted) {
      await loadPosts();
    }
  }

  // =========================================================
  // LIKE ARTICLE
  // =========================================================

  void likePost(int postId) {
    setState(() {
      final index = posts.indexWhere(
        (post) => post.id == postId,
      );

      if (index == -1) return;

      final post = posts[index];

      post.isLiked = !post.isLiked;

      if (post.isLiked) {
        post.likes++;
      } else if (post.likes > 0) {
        post.likes--;
      }
    });
  }

  // =========================================================
  // BROMO
  // =========================================================

  void openBromoDetail() {
    showMountainDetail(
      title: 'Gunung Bromo',
      imagePath: 'assets/images/bromo.jpg',
      location: 'Jawa Timur',
      description:
          'Gunung Bromo merupakan salah satu gunung '
          'berapi terkenal di Jawa Timur. Gunung ini '
          'memiliki pemandangan alam yang indah dan '
          'menjadi salah satu destinasi wisata populer '
          'di Indonesia.\n\n'
          'Pemandangan matahari terbit, lautan pasir, '
          'dan kawasan pegunungan menjadi daya tarik '
          'utama bagi wisatawan.',
    );
  }

  // =========================================================
  // RINJANI
  // =========================================================

  void openRinjaniDetail() {
    showMountainDetail(
      title: 'Gunung Rinjani',
      imagePath: 'assets/images/rinjani.jpg',
      location: 'Lombok, NTB',
      description:
          'Gunung Rinjani merupakan salah satu gunung '
          'terkenal di Indonesia. Gunung ini berada di '
          'Pulau Lombok dan memiliki pemandangan alam '
          'yang sangat indah.\n\n'
          'Gunung Rinjani menjadi salah satu destinasi '
          'wisata yang banyak dikunjungi karena keindahan '
          'alam dan pemandangan pegunungannya.',
    );
  }

  // =========================================================
  // MOUNTAIN DETAIL
  // =========================================================

  void showMountainDetail({
    required String title,
    required String imagePath,
    required String location,
    required String description,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return MountainDetailDialog(
          title: title,
          imagePath: imagePath,
          location: location,
          description: description,
        );
      },
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final filtered = filteredPosts;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),

      // =======================================================
      // APP BAR
      // =======================================================

      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FC),
        elevation: 0,
        surfaceTintColor: Colors.transparent,

        title: const Text(
          'BlogApp',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 12,
            ),
            child: IconButton(
              onPressed: loadPosts,
              tooltip: 'Refresh',
              icon: const Icon(
                Icons.refresh_rounded,
                size: 30,
                color: Color(0xFF374151),
              ),
            ),
          ),
        ],
      ),

      // =======================================================
      // BODY
      // =======================================================

      body: RefreshIndicator(
        onRefresh: loadPosts,

        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),

          padding: const EdgeInsets.only(
            bottom: 40,
          ),

          children: [
            // =================================================
            // GREETING
            // =================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                0,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  const Text(
                    '👋 Halo!',

                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    'Temukan inspirasi baru hari ini',

                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // =================================================
            // HERO
            // =================================================

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),

              child: SizedBox(
                height: 190,

                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(24),

                  child: Stack(
                    fit: StackFit.expand,

                    children: [
                      Image.asset(
                        'assets/images/ijen.jpg',

                        fit: BoxFit.cover,

                        errorBuilder: (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return Container(
                            color:
                                const Color(0xFFB8D8F5),

                            child: const Center(
                              child: Icon(
                                Icons
                                    .image_not_supported_rounded,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),

                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin:
                                Alignment.centerLeft,
                            end:
                                Alignment.centerRight,
                            colors: [
                              Colors.black
                                  .withOpacity(0.72),
                              Colors.black
                                  .withOpacity(0.38),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),

                      Padding(
                        padding:
                            const EdgeInsets.all(20),

                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,

                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [
                            const Text(
                              'Jelajahi Indonesia',

                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),

                            const SizedBox(height: 7),

                            const SizedBox(
                              width: 250,

                              child: Text(
                                'Temukan cerita, informasi, dan inspirasi menarik dari berbagai tempat.',

                                maxLines: 3,

                                overflow:
                                    TextOverflow.ellipsis,

                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  height: 1.35,
                                ),
                              ),
                            ),

                            const SizedBox(height: 13),

                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedCategory =
                                      'Wisata';
                                });
                              },

                              child: Container(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 15,
                                  vertical: 9,
                                ),

                                decoration:
                                    BoxDecoration(
                                  color:
                                      const Color(
                                    0xFF2563EB,
                                  ),

                                  borderRadius:
                                      BorderRadius
                                          .circular(30),
                                ),

                                child: const Row(
                                  mainAxisSize:
                                      MainAxisSize.min,

                                  children: [
                                    Text(
                                      'Mulai Jelajah',

                                      style:
                                          TextStyle(
                                        color:
                                            Colors.white,
                                        fontSize: 13,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),

                                    SizedBox(width: 7),

                                    Icon(
                                      Icons
                                          .arrow_forward_rounded,
                                      color:
                                          Colors.white,
                                      size: 17,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // =================================================
            // SEARCH
            // =================================================

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
              ),

              child: Container(
                decoration:
                    BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                      BorderRadius.circular(18),

                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black
                              .withOpacity(0.05),
                      blurRadius: 15,
                      offset:
                          const Offset(0, 5),
                    ),
                  ],
                ),

                child: SearchBarWidget(
                  controller:
                      searchController,

                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 25),

            // =================================================
            // KATEGORI
            // =================================================

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
              ),

              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,

                children: [
                  const Text(
                    'Kategori',

                    style: TextStyle(
                      color:
                          Color(0xFF111827),
                      fontSize: 21,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      setState(() {
                        selectedCategory =
                            'Semua';
                      });
                    },

                    child: const Text(
                      'Lihat Semua',

                      style: TextStyle(
                        color:
                            Color(0xFF2563EB),
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 5),

            SizedBox(
              height: 48,

              child: ListView(
                scrollDirection:
                    Axis.horizontal,

                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),

                children: [
                  _buildCategoryChip(
                    label: 'Semua',
                    icon:
                        Icons.grid_view_rounded,
                  ),

                  _buildCategoryChip(
                    label: 'Wisata',
                    icon:
                        Icons.landscape_rounded,
                  ),

                  _buildCategoryChip(
                    label: 'Teknologi',
                    icon:
                        Icons.computer_rounded,
                  ),

                  _buildCategoryChip(
                    label: 'Pendidikan',
                    icon:
                        Icons.school_rounded,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // =================================================
            // DESTINASI
            // =================================================

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
              ),

              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,

                children: [
                  const Text(
                    'Destinasi Pilihan',

                    style: TextStyle(
                      color:
                          Color(0xFF111827),
                      fontSize: 21,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),

                  Icon(
                    Icons.landscape_rounded,
                    color:
                        Colors.grey.shade500,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            SizedBox(
              height: 225,

              child: ListView(
                scrollDirection:
                    Axis.horizontal,

                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),

                children: [
                  _buildMountainCard(
                    title:
                        'Gunung Bromo',

                    location:
                        'Jawa Timur',

                    imagePath:
                        'assets/images/bromo.jpg',

                    onTap:
                        openBromoDetail,
                  ),

                  const SizedBox(width: 14),

                  _buildMountainCard(
                    title:
                        'Gunung Rinjani',

                    location:
                        'Lombok, NTB',

                    imagePath:
                        'assets/images/rinjani.jpg',

                    onTap:
                        openRinjaniDetail,
                  ),
                ],
              ),
            ),

            // =================================================
            // ARTIKEL TERBARU
            // HANYA MUNCUL JIKA ADA DATA
            // =================================================

            if (isLoading)
              const Padding(
                padding:
                    EdgeInsets.symmetric(
                  vertical: 35,
                ),

                child: Center(
                  child:
                      CircularProgressIndicator(
                    color:
                        Color(0xFF2563EB),
                  ),
                ),
              ),

            if (!isLoading &&
                errorMessage == null &&
                filtered.isNotEmpty) ...[
              const SizedBox(height: 28),

              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                ),

                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,

                  children: [
                    const Text(
                      'Artikel Terbaru',

                      style: TextStyle(
                        color:
                            Color(0xFF111827),
                        fontSize: 21,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),

                    Text(
                      '${filtered.length} artikel',

                      style: TextStyle(
                        color:
                            Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              _buildPostList(filtered),
            ],

            // =================================================
            // FITUR BLOGAPP
            // =================================================

            const SizedBox(height: 32),

            _buildFeatureSection(),
          ],
        ),
      ),

      // =======================================================
      // FLOATING BUTTON
      // =======================================================

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed:
            openCreatePost,

        backgroundColor:
            const Color(0xFF2563EB),

        elevation: 7,

        icon: const Icon(
          Icons.add_rounded,
          color: Colors.white,
        ),

        label: const Text(
          'Buat Artikel',

          style: TextStyle(
            color: Colors.white,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat,
    );
  }

  // =========================================================
  // CATEGORY CHIP
  // =========================================================

  Widget _buildCategoryChip({
    required String label,
    required IconData icon,
  }) {
    final isSelected =
        selectedCategory == label;

    return Padding(
      padding:
          const EdgeInsets.only(
        right: 10,
      ),

      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedCategory = label;
          });
        },

        child: AnimatedContainer(
          duration:
              const Duration(
            milliseconds: 200,
          ),

          padding:
              const EdgeInsets.symmetric(
            horizontal: 16,
          ),

          decoration:
              BoxDecoration(
            color: isSelected
                ? const Color(
                    0xFF2563EB,
                  )
                : Colors.white,

            borderRadius:
                BorderRadius.circular(
              30,
            ),

            boxShadow: [
              if (!isSelected)
                BoxShadow(
                  color:
                      Colors.black
                          .withOpacity(0.04),
                  blurRadius: 8,
                  offset:
                      const Offset(0, 3),
                ),
            ],
          ),

          child: Row(
            children: [
              Icon(
                icon,
                size: 18,

                color: isSelected
                    ? Colors.white
                    : const Color(
                        0xFF475569,
                      ),
              ),

              const SizedBox(
                width: 7,
              ),

              Text(
                label,

                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : const Color(
                          0xFF334155,
                        ),

                  fontWeight:
                      isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // MOUNTAIN CARD
  // =========================================================

  Widget _buildMountainCard({
    required String title,
    required String location,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        width: 285,

        decoration:
            BoxDecoration(
          borderRadius:
              BorderRadius.circular(20),

          boxShadow: [
            BoxShadow(
              color:
                  Colors.black
                      .withOpacity(0.12),
              blurRadius: 15,
              offset:
                  const Offset(0, 7),
            ),
          ],
        ),

        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(20),

          child: Stack(
            fit: StackFit.expand,

            children: [
              Image.asset(
                imagePath,

                fit: BoxFit.cover,

                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return Container(
                    color:
                        Colors.grey.shade300,

                    child:
                        const Center(
                      child: Icon(
                        Icons
                            .image_not_supported,
                        size: 50,
                        color:
                            Colors.grey,
                      ),
                    ),
                  );
                },
              ),

              Container(
                decoration:
                    const BoxDecoration(
                  gradient:
                      LinearGradient(
                    begin:
                        Alignment.topCenter,
                    end:
                        Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black87,
                    ],
                  ),
                ),
              ),

              Positioned(
                left: 16,
                right: 16,
                bottom: 16,

                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .end,

                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [
                          Text(
                            title,

                            maxLines: 1,

                            overflow:
                                TextOverflow
                                    .ellipsis,

                            style:
                                const TextStyle(
                              color:
                                  Colors.white,
                              fontSize: 19,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),

                          const SizedBox(
                            height: 5,
                          ),

                          Row(
                            children: [
                              const Icon(
                                Icons
                                    .location_on_rounded,
                                color:
                                    Colors.white,
                                size: 15,
                              ),

                              const SizedBox(
                                width: 4,
                              ),

                              Expanded(
                                child:
                                    Text(
                                  location,

                                  maxLines:
                                      1,

                                  overflow:
                                      TextOverflow
                                          .ellipsis,

                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.white,
                                    fontSize:
                                        13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    Container(
                      width: 44,
                      height: 44,

                      decoration:
                          BoxDecoration(
                        color: Colors.white
                            .withOpacity(
                          0.88,
                        ),
                        shape:
                            BoxShape.circle,
                      ),

                      child:
                          const Icon(
                        Icons
                            .arrow_forward_rounded,
                        color:
                            Color(
                          0xFF1F2937,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // POST LIST
  // =========================================================

  Widget _buildPostList(
      List<Post> filtered) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
      ),

      child: Column(
        children:
            filtered.map((post) {
          return Padding(
            padding:
                const EdgeInsets.only(
              bottom: 12,
            ),

            child:
                PostCard(
              post: post,

              onTap: () {
                openDetailPost(post);
              },

              onLike: () {
                likePost(post.id);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  // =========================================================
  // FEATURE SECTION
  // =========================================================

  Widget _buildFeatureSection() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Padding(
            padding:
                EdgeInsets.symmetric(
              horizontal: 4,
            ),

            child: Text(
              'Jelajahi BlogApp',

              style:
                  TextStyle(
                color:
                    Color(0xFF111827),
                fontSize: 21,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // =================================================
          // STATISTIC CARD
          // =================================================

          Container(
            width: double.infinity,

            padding:
                const EdgeInsets.all(
              18,
            ),

            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFF2563EB,
              ),

              borderRadius:
                  BorderRadius.circular(
                22,
              ),

              boxShadow: [
                BoxShadow(
                  color:
                      const Color(
                    0xFF2563EB,
                  ).withOpacity(0.20),

                  blurRadius: 15,

                  offset:
                      const Offset(
                    0,
                    7,
                  ),
                ),
              ],
            ),

            child: Row(
              children: [
                Expanded(
                  child:
                      _buildStatistic(
                    icon:
                        Icons.article_rounded,
                    value:
                        '${posts.length}',
                    label:
                        'Artikel',
                  ),
                ),

                Container(
                  width: 1,
                  height: 45,
                  color: Colors.white
                      .withOpacity(0.25),
                ),

                Expanded(
                  child:
                      _buildStatistic(
                    icon:
                        Icons.category_rounded,
                    value:
                        '4',
                    label:
                        'Kategori',
                  ),
                ),

                Container(
                  width: 1,
                  height: 45,
                  color: Colors.white
                      .withOpacity(0.25),
                ),

                Expanded(
                  child:
                      _buildStatistic(
                    icon:
                        Icons.landscape_rounded,
                    value:
                        '2',
                    label:
                        'Destinasi',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // =================================================
          // FEATURE GRID
          // =================================================

          GridView.count(
            crossAxisCount: 2,

            crossAxisSpacing: 12,

            mainAxisSpacing: 12,

            shrinkWrap: true,

            physics:
                const NeverScrollableScrollPhysics(),

            childAspectRatio: 1.35,

            children: [
              _buildFeatureCard(
                icon:
                    Icons.edit_note_rounded,

                title:
                    'Tulis Artikel',

                description:
                    'Bagikan cerita dan pengetahuanmu.',

                onTap:
                    openCreatePost,
              ),

              _buildFeatureCard(
                icon:
                    Icons.explore_rounded,

                title:
                    'Eksplorasi',

                description:
                    'Temukan berbagai informasi menarik.',

                onTap: () {
                  setState(() {
                    selectedCategory =
                        'Semua';

                    searchText = '';

                    searchController
                        .clear();
                  });
                },
              ),

              _buildFeatureCard(
                icon:
                    Icons.favorite_rounded,

                title:
                    'Favorit',

                description:
                    'Lihat dan sukai artikel pilihanmu.',

                onTap:
                    _showFavoriteInfo,
              ),

              _buildFeatureCard(
                icon:
                    Icons
                        .tips_and_updates_rounded,

                title:
                    'Tips Menulis',

                description:
                    'Pelajari cara membuat artikel menarik.',

                onTap:
                    _showWritingTips,
              ),
            ],
          ),

          const SizedBox(height: 18),

          // =================================================
          // ABOUT BLOGAPP
          // =================================================

          Container(
            width: double.infinity,

            padding:
                const EdgeInsets.all(
              20,
            ),

            decoration:
                BoxDecoration(
              color: Colors.white,

              borderRadius:
                  BorderRadius.circular(
                22,
              ),

              border: Border.all(
                color:
                    const Color(
                  0xFFE5E7EB,
                ),
              ),

              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black
                          .withOpacity(0.03),

                  blurRadius: 10,

                  offset:
                      const Offset(
                    0,
                    4,
                  ),
                ),
              ],
            ),

            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,

                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFFEFF6FF,
                    ),

                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),

                  child:
                      const Icon(
                    Icons
                        .auto_stories_rounded,

                    color:
                        Color(
                      0xFF2563EB,
                    ),

                    size: 27,
                  ),
                ),

                const SizedBox(
                  width: 14,
                ),

                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [
                      Text(
                        'BlogApp',

                        style:
                            TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.w800,
                          color:
                              Color(
                            0xFF111827,
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 4,
                      ),

                      Text(
                        'Tempat berbagi cerita, informasi, dan inspirasi.',

                        style:
                            TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color:
                              Color(
                            0xFF6B7280,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // =================================================
          // FOOTER
          // =================================================

          Center(
            child: Text(
              'BlogApp • XI RPL',

              style: TextStyle(
                color:
                    Colors.grey.shade500,
                fontSize: 12,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 15),
        ],
      ),
    );
  }

  // =========================================================
  // STATISTIC ITEM
  // =========================================================

  Widget _buildStatistic({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,

          color:
              Colors.white,

          size: 24,
        ),

        const SizedBox(
          height: 6,
        ),

        Text(
          value,

          style:
              const TextStyle(
            color:
                Colors.white,
            fontSize: 20,
            fontWeight:
                FontWeight.w800,
          ),
        ),

        const SizedBox(
          height: 2,
        ),

        Text(
          label,

          style: TextStyle(
            color:
                Colors.white
                    .withOpacity(0.80),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // FEATURE CARD
  // =========================================================

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Material(
      color:
          Colors.white,

      borderRadius:
          BorderRadius.circular(
        20,
      ),

      child: InkWell(
        borderRadius:
            BorderRadius.circular(
          20,
        ),

        onTap:
            onTap,

        child: Container(
          padding:
              const EdgeInsets.all(
            16,
          ),

          decoration:
              BoxDecoration(
            borderRadius:
                BorderRadius.circular(
              20,
            ),

            border: Border.all(
              color:
                  const Color(
                0xFFE5E7EB,
              ),
            ),

            boxShadow: [
              BoxShadow(
                color:
                    Colors.black
                        .withOpacity(
                  0.04,
                ),

                blurRadius: 10,

                offset:
                    const Offset(
                  0,
                  4,
                ),
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Container(
                width: 44,
                height: 44,

                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFEFF6FF,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),

                child: Icon(
                  icon,

                  color:
                      const Color(
                    0xFF2563EB,
                  ),

                  size: 23,
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              Text(
                title,

                maxLines: 1,

                overflow:
                    TextOverflow.ellipsis,

                style:
                    const TextStyle(
                  color:
                      Color(
                    0xFF111827,
                  ),

                  fontSize: 16,

                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const SizedBox(
                height: 4,
              ),

              Expanded(
                child: Text(
                  description,

                  maxLines: 2,

                  overflow:
                      TextOverflow.ellipsis,

                  style: TextStyle(
                    color:
                        Colors.grey
                            .shade600,

                    fontSize: 12,

                    height: 1.3,
                  ),
                ),
              ),

              const SizedBox(
                height: 5,
              ),

              const Icon(
                Icons
                    .arrow_forward_rounded,

                color:
                    Color(
                  0xFF2563EB,
                ),

                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // FAVORITE INFO
  // =========================================================

  void _showFavoriteInfo() {
    showModalBottomSheet(
      context:
          context,

      backgroundColor:
          Colors.white,

      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(
            24,
          ),
        ),
      ),

      builder:
          (context) {
        return Padding(
          padding:
              const EdgeInsets.all(
            24,
          ),

          child: Column(
            mainAxisSize:
                MainAxisSize.min,

            children: [
              Container(
                width: 45,
                height: 5,

                decoration:
                    BoxDecoration(
                  color:
                      Colors.grey
                          .shade300,

                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              Container(
                width: 65,
                height: 65,

                decoration:
                    const BoxDecoration(
                  color:
                      Color(
                    0xFFFFEEF0,
                  ),

                  shape:
                      BoxShape.circle,
                ),

                child:
                    const Icon(
                  Icons
                      .favorite_rounded,

                  color:
                      Colors.redAccent,

                  size: 32,
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              const Text(
                'Artikel Favorit',

                style:
                    TextStyle(
                  fontSize: 22,
                  fontWeight:
                      FontWeight.w800,
                  color:
                      Color(
                    0xFF111827,
                  ),
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              Text(
                'Kamu bisa menyukai artikel menggunakan '
                'tombol hati pada setiap artikel.',

                textAlign:
                    TextAlign.center,

                style:
                    TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color:
                      Colors.grey
                          .shade600,
                ),
              ),

              const SizedBox(
                height: 22,
              ),

              SizedBox(
                width:
                    double.infinity,

                child:
                    ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                    );
                  },

                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        const Color(
                      0xFF2563EB,
                    ),

                    foregroundColor:
                        Colors.white,

                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 14,
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        14,
                      ),
                    ),
                  ),

                  child:
                      const Text(
                    'Mengerti',

                    style:
                        TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 8,
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================================================
  // WRITING TIPS
  // =========================================================

  void _showWritingTips() {
    showModalBottomSheet(
      context:
          context,

      backgroundColor:
          Colors.white,

      isScrollControlled:
          true,

      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(
            25,
          ),
        ),
      ),

      builder:
          (context) {
        return Padding(
          padding:
              const EdgeInsets.fromLTRB(
            24,
            18,
            24,
            30,
          ),

          child: Column(
            mainAxisSize:
                MainAxisSize.min,

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Center(
                child: Container(
                  width: 45,
                  height: 5,

                  decoration:
                      BoxDecoration(
                    color:
                        Colors.grey
                            .shade300,

                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 22,
              ),

              const Row(
                children: [
                  Icon(
                    Icons
                        .tips_and_updates_rounded,

                    color:
                        Color(
                      0xFF2563EB,
                    ),

                    size: 30,
                  ),

                  SizedBox(
                    width: 10,
                  ),

                  Text(
                    'Tips Menulis Artikel',

                    style:
                        TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.w800,
                      color:
                          Color(
                        0xFF111827,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 20,
              ),

              _buildTip(
                number: '01',
                title:
                    'Buat judul menarik',
                description:
                    'Gunakan judul yang singkat dan membuat pembaca penasaran.',
              ),

              _buildTip(
                number: '02',
                title:
                    'Gunakan bahasa sederhana',
                description:
                    'Tulis artikel dengan bahasa yang mudah dipahami.',
              ),

              _buildTip(
                number: '03',
                title:
                    'Buat paragraf singkat',
                description:
                    'Paragraf yang tidak terlalu panjang lebih nyaman dibaca.',
              ),

              _buildTip(
                number: '04',
                title:
                    'Berikan informasi bermanfaat',
                description:
                    'Pastikan artikel memberikan pengetahuan atau inspirasi.',
              ),

              const SizedBox(
                height: 10,
              ),

              SizedBox(
                width:
                    double.infinity,

                child:
                    ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                    );
                  },

                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        const Color(
                      0xFF2563EB,
                    ),

                    foregroundColor:
                        Colors.white,

                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 14,
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        14,
                      ),
                    ),
                  ),

                  child:
                      const Text(
                    'Mengerti',

                    style:
                        TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================================================
  // TIP ITEM
  // =========================================================

  Widget _buildTip({
    required String number,
    required String title,
    required String description,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 16,
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Container(
            width: 38,
            height: 38,

            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFEFF6FF,
              ),

              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),

            alignment:
                Alignment.center,

            child:
                Text(
              number,

              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF2563EB,
                ),

                fontSize: 12,

                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [
                Text(
                  title,

                  style:
                      const TextStyle(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        Color(
                      0xFF111827,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  description,

                  style:
                      TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color:
                        Colors.grey
                            .shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===================================================================
// MOUNTAIN DETAIL DIALOG
// ===================================================================

class MountainDetailDialog
    extends StatefulWidget {
  final String title;
  final String imagePath;
  final String location;
  final String description;

  const MountainDetailDialog({
    super.key,
    required this.title,
    required this.imagePath,
    required this.location,
    required this.description,
  });

  @override
  State<MountainDetailDialog>
      createState() =>
          _MountainDetailDialogState();
}

// ===================================================================
// MOUNTAIN DETAIL STATE
// ===================================================================

class _MountainDetailDialogState
    extends State<MountainDetailDialog> {
  final TextEditingController
      commentController =
      TextEditingController();

  final List<String> comments = [
    'Pemandangannya bagus banget!',
    'Saya ingin sekali berkunjung ke sini.',
  ];

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  // =========================================================
  // ADD COMMENT
  // =========================================================

  void addComment() {
    final comment =
        commentController.text.trim();

    if (comment.isEmpty) {
      return;
    }

    setState(() {
      comments.add(comment);
      commentController.clear();
    });

    FocusScope.of(
      context,
    ).unfocus();
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(
      BuildContext context) {
    return Dialog(
      insetPadding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 24,
      ),

      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          24,
        ),
      ),

      child: ConstrainedBox(
        constraints:
            const BoxConstraints(
          maxHeight: 700,
        ),

        child:
            SingleChildScrollView(
          padding:
              const EdgeInsets.all(
            16,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,

            children: [
              Align(
                alignment:
                    Alignment.topRight,

                child: IconButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                    );
                  },

                  icon:
                      const Icon(
                    Icons
                        .close_rounded,
                  ),
                ),
              ),

              ClipRRect(
                borderRadius:
                    BorderRadius.circular(
                  18,
                ),

                child:
                    Image.asset(
                  widget.imagePath,

                  width:
                      double.infinity,

                  height: 210,

                  fit: BoxFit.cover,

                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return Container(
                      height: 210,

                      color:
                          Colors.grey
                              .shade200,

                      child:
                          const Center(
                        child: Icon(
                          Icons
                              .image_not_supported,
                          size: 55,
                          color:
                              Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(
                height: 18,
              ),

              Text(
                widget.title,

                style:
                    const TextStyle(
                  fontSize: 26,
                  fontWeight:
                      FontWeight.w800,
                  color:
                      Color(
                    0xFF111827,
                  ),
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              Row(
                children: [
                  const Icon(
                    Icons
                        .location_on_rounded,

                    size: 18,

                    color:
                        Color(
                      0xFF2563EB,
                    ),
                  ),

                  const SizedBox(
                    width: 5,
                  ),

                  Text(
                    widget.location,

                    style:
                        TextStyle(
                      color:
                          Colors.grey
                              .shade700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 12,
              ),

              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFEFF6FF,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),

                child:
                    const Text(
                  'Wisata',

                  style:
                      TextStyle(
                    color:
                        Color(
                      0xFF2563EB,
                    ),

                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(
                height: 22,
              ),

              const Text(
                'Tentang',

                style:
                    TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              Text(
                widget.description,

                style:
                    TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color:
                      Colors.grey
                          .shade700,
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              const Divider(),

              const SizedBox(
                height: 18,
              ),

              Text(
                'Komentar (${comments.length})',

                style:
                    const TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const SizedBox(
                height: 14,
              ),

              ...comments.map(
                (comment) {
                  return Container(
                    width:
                        double.infinity,

                    margin:
                        const EdgeInsets
                            .only(
                      bottom: 10,
                    ),

                    padding:
                        const EdgeInsets
                            .all(
                      13,
                    ),

                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFFF5F6FA,
                      ),

                      borderRadius:
                          BorderRadius
                              .circular(
                        16,
                      ),
                    ),

                    child:
                        Row(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [
                        const CircleAvatar(
                          radius: 20,

                          backgroundColor:
                              Color(
                            0xFFE5E7EB,
                          ),

                          child:
                              Icon(
                            Icons.person,

                            color:
                                Color(
                              0xFF6B7280,
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        Expanded(
                          child:
                              Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [
                              const Text(
                                'Pengguna',

                                style:
                                    TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),

                              const SizedBox(
                                height: 4,
                              ),

                              Text(
                                comment,

                                style:
                                    TextStyle(
                                  color:
                                      Colors
                                          .grey
                                          .shade700,
                                  height:
                                      1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(
                height: 8,
              ),

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .end,

                children: [
                  Expanded(
                    child:
                        TextField(
                      controller:
                          commentController,

                      minLines: 1,
                      maxLines: 3,

                      decoration:
                          InputDecoration(
                        hintText:
                            'Tulis komentar...',

                        filled:
                            true,

                        fillColor:
                            const Color(
                          0xFFF5F6FA,
                        ),

                        contentPadding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),

                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            16,
                          ),

                          borderSide:
                              BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  Container(
                    width: 48,
                    height: 48,

                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFF2563EB,
                      ),

                      borderRadius:
                          BorderRadius.circular(
                        15,
                      ),
                    ),

                    child:
                        IconButton(
                      onPressed:
                          addComment,

                      icon:
                          const Icon(
                        Icons
                            .send_rounded,

                        color:
                            Colors.white,

                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 16,
              ),

              SizedBox(
                width:
                    double.infinity,

                child:
                    OutlinedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                    );
                  },

                  style:
                      OutlinedButton
                          .styleFrom(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 13,
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        14,
                      ),
                    ),
                  ),

                  child:
                      const Text(
                    'Tutup',
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