import 'package:flutter/material.dart';

import 'package:museum_learn/services/api_service.dart';
import 'package:museum_learn/pages/edit_article_page.dart';

class ArticleDetailPage extends StatefulWidget {
  final Map<String, dynamic> article;

  const ArticleDetailPage({
    super.key,
    required this.article,
  });

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  late Map<String, dynamic> article;

  @override
  void initState() {
    super.initState();

    article = Map<String, dynamic>.from(widget.article);
  }

  // =====================================================
  // REFRESH DATA ARTIKEL
  // =====================================================

  Future<void> refreshArticle() async {
    try {
      final posts = await getPosts();

      final postId = article['id'];

      Map<String, dynamic>? updatedArticle;

      for (final post in posts) {
        if (post['id'].toString() == postId.toString()) {
          updatedArticle = Map<String, dynamic>.from(post);
          break;
        }
      }

      if (!mounted) return;

      if (updatedArticle != null) {
        setState(() {
          article = updatedArticle!;
        });
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal mengambil data artikel: $error',
          ),
        ),
      );
    }
  }

  // =====================================================
  // EDIT ARTIKEL
  // =====================================================

  Future<void> editArticle() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditArticlePage(
          article: article,
        ),
      ),
    );

    // ===================================================
    // KALAU UPDATE BERHASIL
    // ===================================================

    if (result == true) {
      await refreshArticle();
    }
  }

  @override
  Widget build(BuildContext context) {
    // =====================================================
    // DATA ARTIKEL
    // =====================================================

    final String title =
        article['title']?.toString() ?? 'Tanpa Judul';

    final String content =
        article['content']?.toString() ?? '';

    final String? imageUrl =
        article['image_url']?.toString() ??
        article['imageUrl']?.toString();

    final String categoryName =
        article['category_title']?.toString() ??
        article['categoryTitle']?.toString() ??
        article['category_name']?.toString() ??
        article['categoryName']?.toString() ??
        'Kategori';

    return Scaffold(
      backgroundColor: Colors.white,

      // =====================================================
      // APP BAR
      // =====================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },

          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF2F2F2F),
          ),
        ),

        title: const Text(
          'Detail Artikel',
          style: TextStyle(
            color: Color(0xFF2F2F2F),
            fontWeight: FontWeight.bold,
          ),
        ),

        // =================================================
        // TOMBOL EDIT
        // =================================================

        actions: [
          IconButton(
            onPressed: editArticle,

            icon: const Icon(
              Icons.edit_outlined,
              color: Color(0xFFB8923F),
            ),

            tooltip: 'Edit Artikel',
          ),

          const SizedBox(width: 8),
        ],
      ),

      // =====================================================
      // BODY
      // =====================================================

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // =================================================
            // GAMBAR
            // =================================================

            if (imageUrl != null &&
                imageUrl.isNotEmpty)
              SizedBox(
                width: double.infinity,
                height: 300,

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
                          size: 60,
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

            // =================================================
            // JIKA TIDAK ADA GAMBAR
            // =================================================

            else
              Container(
                width: double.infinity,
                height: 250,

                color: const Color(0xFFF8F3E7),

                child: const Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 65,
                    color: Color(0xFFB8923F),
                  ),
                ),
              ),

            // =================================================
            // CONTENT
            // =================================================

            Padding(
              padding: const EdgeInsets.all(24),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  // =========================================
                  // KATEGORI
                  // =========================================

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),

                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F3E7),

                      borderRadius:
                          BorderRadius.circular(20),

                      border: Border.all(
                        color: const Color(0xFFE8E3D7),
                      ),
                    ),

                    child: Text(
                      categoryName,

                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFB8923F),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // =========================================
                  // JUDUL
                  // =========================================

                  Text(
                    title,

                    style: const TextStyle(
                      fontSize: 28,
                      height: 1.2,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2F2F2F),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // =========================================
                  // GARIS EMAS
                  // =========================================

                  Container(
                    width: 50,
                    height: 4,

                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF5A),

                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // =========================================
                  // ISI ARTIKEL
                  // =========================================

                  Text(
                    content,

                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.7,
                      color: Color(0xFF5F5C56),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}