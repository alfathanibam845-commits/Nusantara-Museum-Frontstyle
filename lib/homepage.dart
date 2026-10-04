import 'package:flutter/material.dart';

import 'package:museum_learn/services/api_service.dart';
import 'package:museum_learn/pages/edit_article_page.dart';
import 'package:museum_learn/pages/article_detail_page.dart';
import 'package:museum_learn/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // =====================================================
  // FUTURE DATA
  // =====================================================

  late Future<List<dynamic>> categoriesFuture;
  late Future<List<dynamic>> postsFuture;

  // =====================================================
  // CATEGORY TERPILIH
  // null = semua kategori
  // =====================================================

  int? selectedCategoryId;

  // =====================================================
  // INIT
  // =====================================================

  @override
  void initState() {
    super.initState();

    loadData();
  }

  // =====================================================
  // LOAD DATA
  // =====================================================

  void loadData() {
    categoriesFuture = getCategories();
    postsFuture = getPosts();
  }

  // =====================================================
  // REFRESH POSTS
  // =====================================================

  Future<void> refreshPosts() async {
    setState(() {
      postsFuture = getPosts();
    });

    await postsFuture;
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ===================================================
      // APP BAR
      // ===================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          'Home',
          style: TextStyle(
            color: Color(0xFF2F2F2F),
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          // ===============================================
          // BUAT ARTIKEL
          // ===============================================

          TextButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditArticlePage(),
                ),
              );

              if (result == true && mounted) {
                refreshPosts();
              }
            },

            icon: const Icon(
              Icons.add_rounded,
              color: Color(0xFFB8923F),
            ),

            label: const Text(
              'Buat Artikel',
              style: TextStyle(
                color: Color(0xFFB8923F),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // ===============================================
          // PROFILE
          // ===============================================

          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfilePage(
                    userId: 1,
                  ),
                ),
              );
            },

            icon: const Icon(
              Icons.person_outline_rounded,
              color: Color(0xFFB8923F),
            ),
          ),

          // ===============================================
          // NOTIFICATION
          // ===============================================

          IconButton(
            onPressed: () {},

            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFFB8923F),
            ),
          ),

          const SizedBox(width: 8),
        ],
      ),

      // ===================================================
      // BODY
      // ===================================================

      body: RefreshIndicator(
        color: const Color(0xFFB8923F),

        onRefresh: refreshPosts,

        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),

          padding: const EdgeInsets.all(24),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // =================================================
              // JUDUL
              // =================================================

              const Text(
                'Nusantara Museum',

                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2F2F2F),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Mengenal Sejarah dan Latar Belakang Nusantara Negara Indonesia',

                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF85827A),
                  fontFamily: 'Slabo 13px',
                ),
              ),

              const SizedBox(height: 30),

              // =================================================
              // DASHBOARD
              // =================================================

              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF5A),

                  borderRadius: BorderRadius.circular(22),
                ),

                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Icon(
                      Icons.dashboard_rounded,
                      size: 40,
                      color: Colors.white,
                    ),

                    SizedBox(height: 18),

                    Text(
                      'Dashboard',

                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: 6),

                    Text(
                      'Kelola aktivitasmu dengan mudah.',

                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // =================================================
              // KATEGORI
              // =================================================

              const Text(
                'Kategori',

                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2F2F2F),
                ),
              ),

              const SizedBox(height: 16),

              FutureBuilder<List<dynamic>>(
                future: categoriesFuture,

                builder: (context, snapshot) {
                  // ===========================================
                  // LOADING
                  // ===========================================

                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFB8923F),
                      ),
                    );
                  }

                  // ===========================================
                  // ERROR
                  // ===========================================

                  if (snapshot.hasError) {
                    return Container(
                      width: double.infinity,

                      padding: const EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF5F5),

                        borderRadius: BorderRadius.circular(14),
                      ),

                      child: Text(
                        'Gagal mengambil kategori\n${snapshot.error}',

                        style: const TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    );
                  }

                  // ===========================================
                  // DATA
                  // ===========================================

                  final categories = snapshot.data ?? [];

                  // ===========================================
                  // KOSONG
                  // ===========================================

                  if (categories.isEmpty) {
                    return const Text(
                      'Belum ada kategori',

                      style: TextStyle(
                        color: Color(0xFF85827A),
                      ),
                    );
                  }

                  // ===========================================
                  // CATEGORY BUTTON
                  // ===========================================

                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,

                    children: [
                      // =======================================
                      // SEMUA
                      // =======================================

                      InkWell(
                        borderRadius: BorderRadius.circular(20),

                        onTap: () {
                          setState(() {
                            selectedCategoryId = null;
                          });
                        },

                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),

                          decoration: BoxDecoration(
                            color: selectedCategoryId == null
                                ? const Color(0xFFD4AF5A)
                                : const Color(0xFFF8F3E7),

                            borderRadius:
                                BorderRadius.circular(20),

                            border: Border.all(
                              color: const Color(0xFFE8E3D7),
                            ),
                          ),

                          child: Text(
                            'Semua',

                            style: TextStyle(
                              color: selectedCategoryId == null
                                  ? Colors.white
                                  : const Color(0xFFB8923F),

                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      // =======================================
                      // KATEGORI DARI DATABASE
                      // =======================================

                      ...categories.map((category) {
                        final int categoryId =
                            int.tryParse(
                              category['id'].toString(),
                            ) ??
                            0;

                        final String categoryTitle =
                            category['title']?.toString() ??
                            'Tanpa Kategori';

                        final bool isSelected =
                            selectedCategoryId ==
                            categoryId;

                        return InkWell(
                          borderRadius: BorderRadius.circular(20),

                          onTap: () {
                            setState(() {
                              selectedCategoryId = categoryId;
                            });
                          },

                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),

                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFD4AF5A)
                                  : const Color(0xFFF8F3E7),

                              borderRadius:
                                  BorderRadius.circular(20),

                              border: Border.all(
                                color: const Color(0xFFE8E3D7),
                              ),
                            ),

                            child: Text(
                              categoryTitle,

                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFFB8923F),

                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),

              const SizedBox(height: 30),

              // =================================================
              // ARTIKEL
              // =================================================

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,

                children: [
                  Text(
                    selectedCategoryId == null
                        ? 'Artikel'
                        : 'Artikel Kategori',

                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2F2F2F),
                    ),
                  ),

                  IconButton(
                    onPressed: refreshPosts,

                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: Color(0xFFB8923F),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // =================================================
              // GET POSTS
              // =================================================

              FutureBuilder<List<dynamic>>(
                future: postsFuture,

                builder: (context, snapshot) {
                  // ===========================================
                  // LOADING
                  // ===========================================

                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(30),

                        child: CircularProgressIndicator(
                          color: Color(0xFFB8923F),
                        ),
                      ),
                    );
                  }

                  // ===========================================
                  // ERROR
                  // ===========================================

                  if (snapshot.hasError) {
                    return Container(
                      width: double.infinity,

                      padding: const EdgeInsets.all(20),

                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF5F5),

                        borderRadius:
                            BorderRadius.circular(16),
                      ),

                      child: Text(
                        'Gagal mengambil artikel\n${snapshot.error}',

                        style: const TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    );
                  }

                  // ===========================================
                  // DATA
                  // ===========================================

                  final allPosts = snapshot.data ?? [];

                  // ===========================================
                  // FILTER CATEGORY
                  // ===========================================

                  final filteredPosts =
                      selectedCategoryId == null
                          ? allPosts
                          : allPosts.where((post) {
                              final postCategoryId =
                                  post['category_id'] ??
                                  post['categoryId'];

                              if (postCategoryId == null) {
                                return false;
                              }

                              final parsedCategoryId =
                                  int.tryParse(
                                postCategoryId.toString(),
                              );

                              return parsedCategoryId ==
                                  selectedCategoryId;
                            }).toList();

                  // ===========================================
                  // EMPTY
                  // ===========================================

                  if (filteredPosts.isEmpty) {
                    return Container(
                      width: double.infinity,

                      padding: const EdgeInsets.all(30),

                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F3E7),

                        borderRadius:
                            BorderRadius.circular(18),

                        border: Border.all(
                          color: const Color(0xFFE8E3D7),
                        ),
                      ),

                      child: const Column(
                        children: [
                          Icon(
                            Icons.article_outlined,

                            size: 50,

                            color: Color(0xFFB8923F),
                          ),

                          SizedBox(height: 12),

                          Text(
                            'Belum ada artikel',

                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2F2F2F),
                            ),
                          ),

                          SizedBox(height: 5),

                          Text(
                            'Artikel yang dibuat akan muncul di sini.',

                            textAlign: TextAlign.center,

                            style: TextStyle(
                              color: Color(0xFF85827A),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                
                  // ARTICLE CARDS - RESPONSIVE////////////////////////////////////////
                 
                  return Wrap(
                   spacing: 15,
                   runSpacing: 18,
                     children: filteredPosts.map((post) {
                       return Container(
                        width: MediaQuery.of(context).size.width >= 1200
                           ? (MediaQuery.of(context).size.width - 84) / 3
                           : MediaQuery.of(context).size.width >= 700
                              ? (MediaQuery.of(context).size.width - 66) / 2
                              : MediaQuery.of(context).size.width - 48,
                    

                        child: _ArticleCard(
                          post: Map<String, dynamic>.from(post),

                          onDeleted: () {
                            refreshPosts();
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================
// ARTICLE CARD
// =====================================================

class _ArticleCard extends StatelessWidget {
  final Map<String, dynamic> post;

  final VoidCallback onDeleted;

  const _ArticleCard({
    required this.post,
    required this.onDeleted,
  });

  // =====================================================
  // DELETE CONFIRMATION
  // =====================================================

  Future<void> _deleteArticle(BuildContext context) async {
    final postId = post['id'];

    if (postId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'ID artikel tidak ditemukan',
          ),
        ),
      );

      return;
    }

    // ===================================================
    // KONFIRMASI
    // ===================================================

    final bool? confirmed = await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Hapus Artikel?',
          ),

          content: const Text(
            'Artikel ini akan dihapus dari database.',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },

              child: const Text(
                'Batal',

                style: TextStyle(
                  color: Color(0xFF85827A),
                ),
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },

              child: const Text(
                'Hapus',

                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    // ===================================================
    // DELETE DARI BACKEND
    // ===================================================

    try {
      final bool success = await deletePost(
        postId: int.parse(
          postId.toString(),
        ),
      );

      if (!context.mounted) {
        return;
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Artikel berhasil dihapus',
            ),
          ),
        );

        onDeleted();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Gagal menghapus artikel',
            ),
          ),
        );
      }
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Terjadi kesalahan: $error',
          ),
        ),
      );
    }
  }

  // =====================================================
  // BUILD CARD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    // ===================================================
    // DATA
    // ===================================================

    final String title =
        post['title']?.toString() ??
        'Tanpa Judul';

    final String? imageUrl =
        post['image_url']?.toString() ??
        post['imageUrl']?.toString();

    final String categoryId =
        (
          post['category_id'] ??
          post['categoryId'] ??
          ''
        ).toString();

    // ===================================================
    // CARD
    // ===================================================

    return Container(
      width: double.infinity,

      margin: const EdgeInsets.only(
        bottom: 18,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color: const Color(0xFFE8E3D7),
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),

            blurRadius: 10,

            offset: const Offset(
              0,
              4,
            ),
          ),
        ],
      ),

      clipBehavior: Clip.antiAlias,

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          // =================================================
          // IMAGE
          // =================================================

          if (imageUrl != null &&
              imageUrl.isNotEmpty)
            SizedBox(
              width: double.infinity,

              height: 220,

              child: Image.network(
                imageUrl,

                fit: BoxFit.cover,

                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return Container(
                    color: const Color(0xFFF8F3E7),

                    child: const Center(
                      child: Icon(
                        Icons.broken_image_outlined,

                        size: 50,

                        color: Color(0xFFB8923F),
                      ),
                    ),
                  );
                },

                loadingBuilder: (
                  context,
                  child,
                  loadingProgress,
                ) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFB8923F),
                    ),
                  );
                },
              ),
            )
          else
            Container(
              width: double.infinity,

              height: 160,

              color: const Color(0xFFF8F3E7),

              child: const Center(
                child: Icon(
                  Icons.image_outlined,

                  size: 55,

                  color: Color(0xFFB8923F),
                ),
              ),
            ),

          // =================================================
          // CARD CONTENT
          // =================================================

          Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                // =========================================
                // CATEGORY
                // =========================================

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),

                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F3E7),

                    borderRadius:
                        BorderRadius.circular(20),
                  ),

                  child: Text(
                    'Kategori $categoryId',

                    style: const TextStyle(
                      fontSize: 12,

                      color: Color(0xFFB8923F),

                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // =========================================
                // TITLE
                // =========================================

                Text(
                  title,

                  style: const TextStyle(
                    fontSize: 21,

                    fontWeight:
                        FontWeight.bold,

                    color: Color(0xFF2F2F2F),
                  ),
                ),

                const SizedBox(height: 20),

                // =========================================
                // DETAIL + DELETE
                // =========================================

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                  children: [
                    // =====================================
                    // DETAIL
                    // =====================================

                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,

                          MaterialPageRoute(
                            builder: (context) =>
                                ArticleDetailPage(
                              article: post,
                            ),
                          ),
                        );
                      },

                      icon: const Icon(
                        Icons.article_outlined,
                        size: 18,
                      ),

                      label: const Text(
                        'Detail',
                      ),

                      style:
                          OutlinedButton.styleFrom(
                        foregroundColor:
                            const Color(
                          0xFFB8923F,
                        ),

                        side:
                            const BorderSide(
                          color:
                              Color(0xFFD4AF5A),
                        ),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                        ),
                      ),
                    ),

                    // =====================================
                    // DELETE
                    // =====================================

                    OutlinedButton.icon(
                      onPressed: () {
                        _deleteArticle(context);
                      },

                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 18,
                      ),

                      label: const Text(
                        'Delete',
                      ),

                      style:
                          OutlinedButton.styleFrom(
                        foregroundColor:
                            Colors.red.shade400,

                        side:
                            BorderSide(
                          color:
                              Colors.red.shade200,
                        ),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}