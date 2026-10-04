import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:museum_learn/services/api_service.dart';

class EditArticlePage extends StatefulWidget {
  final Map<String, dynamic>? article;

  const EditArticlePage({
    super.key,
    this.article,
  });

  bool get isEdit => article != null;

  @override
  State<EditArticlePage> createState() => _EditArticlePageState();
}

class _EditArticlePageState extends State<EditArticlePage> {
  final _formKey = GlobalKey<FormState>();

  // =========================
  // CONTROLLER
  // =========================

  final TextEditingController titleController =
      TextEditingController();

  final TextEditingController contentController =
      TextEditingController();

  // =========================
  // DATA
  // =========================

  List<dynamic> categories = [];

  int? selectedCategoryId;

  // Untuk Flutter Web
  XFile? selectedImage;
  Uint8List? imageBytes;

  bool isLoading = false;
  bool isLoadingCategories = true;

  // Sementara menggunakan user ID 1
  final int userId = 1;

  @override
  void initState() {
    super.initState();

    loadCategories();

    if (widget.article != null) {
      loadArticleData();
    }
  }

  // =====================================================
  // LOAD CATEGORY
  // =====================================================

  Future<void> loadCategories() async {
    try {
      final data = await getCategories();

      if (!mounted) return;

      setState(() {
        categories = data;
        isLoadingCategories = false;
      });

      // Kalau sedang EDIT
      if (widget.article != null) {
        final categoryId =
            widget.article!['category_id'] ??
            widget.article!['categoryId'];

        if (categoryId != null) {
          setState(() {
            selectedCategoryId =
                int.tryParse(categoryId.toString());
          });
        }
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoadingCategories = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal mengambil kategori: $error',
          ),
        ),
      );
    }
  }

  // =====================================================
  // LOAD ARTICLE
  // =====================================================

  void loadArticleData() {
    final article = widget.article!;

    titleController.text =
        article['title']?.toString() ?? '';

    contentController.text =
        article['content']?.toString() ?? '';

    final categoryId =
        article['category_id'] ??
        article['categoryId'];

    if (categoryId != null) {
      selectedCategoryId =
          int.tryParse(categoryId.toString());
    }
  }

  // =====================================================
  // PICK IMAGE
  // =====================================================

  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();

      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (image == null) return;

      final Uint8List bytes =
          await image.readAsBytes();

      if (!mounted) return;

      setState(() {
        selectedImage = image;
        imageBytes = bytes;
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal memilih gambar: $error',
          ),
        ),
      );
    }
  }

  // =====================================================
  // SAVE ARTICLE
  // =====================================================

  Future<void> saveArticle() async {
    // Validasi form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Pastikan kategori dipilih
    if (selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Silakan pilih kategori artikel',
          ),
        ),
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      bool success;

      // =================================================
      // CREATE
      // =================================================

      if (!widget.isEdit) {
        success = await createPost(
          userId: userId,
          categoryId: selectedCategoryId!,
          title: titleController.text.trim(),
          content: contentController.text.trim(),
          status: 'published',
          image: selectedImage,
        );
      }

      // =================================================
      // UPDATE
      // =================================================

      else {
        final postId =
            widget.article!['id'];

        success = await updatePost(
          postId: int.parse(
            postId.toString(),
          ),
          categoryId: selectedCategoryId!,
          title: titleController.text.trim(),
          content: contentController.text.trim(),
          status: 'published',
          image: selectedImage,
        );
      }

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEdit
                  ? 'Artikel berhasil diperbarui'
                  : 'Artikel berhasil dibuat',
            ),
          ),
        );

        // Kembali ke Homepage
        // membawa nilai true agar Homepage
        // bisa melakukan refresh data
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Gagal menyimpan artikel',
            ),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Terjadi kesalahan: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // =====================================================
  // DISPOSE
  // =====================================================

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();

    super.dispose();
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // =================================================
      // APP BAR
      // =================================================

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

        title: Text(
          widget.isEdit
              ? 'Edit Artikel'
              : 'Buat Artikel',
          style: const TextStyle(
            color: Color(0xFF2F2F2F),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // =================================================
      // BODY
      // =================================================

      body: Form(
        key: _formKey,

        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              // ==========================================
              // JUDUL
              // ==========================================

              const Text(
                'Judul Artikel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2F2F2F),
                ),
              ),

              const SizedBox(height: 10),

              TextFormField(
                controller: titleController,

                decoration: InputDecoration(
                  hintText:
                      'Masukkan judul artikel',

                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                  ),

                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(14),

                    borderSide:
                        const BorderSide(
                      color: Color(0xFFB8923F),
                    ),
                  ),
                ),

                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Judul wajib diisi';
                  }

                  if (value.trim().length < 3) {
                    return 'Judul minimal 3 karakter';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 24),

              // ==========================================
              // KATEGORI
              // ==========================================

              const Text(
                'Kategori',

                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2F2F2F),
                ),
              ),

              const SizedBox(height: 10),

              if (isLoadingCategories)
                const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFB8923F),
                  ),
                )
              else
                DropdownButtonFormField<int>(
                  value: selectedCategoryId,

                  decoration: InputDecoration(
                    hintText:
                        'Pilih kategori',

                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),

                    focusedBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(14),

                      borderSide:
                          const BorderSide(
                        color: Color(0xFFB8923F),
                      ),
                    ),
                  ),

                  items:
                      categories
                          .map<
                              DropdownMenuItem<int>
                          >(
                    (category) {
                      return DropdownMenuItem<int>(
                        value: int.parse(
                          category['id'].toString(),
                        ),

                        child: Text(
                          category['title']
                              .toString(),
                        ),
                      );
                    },
                  ).toList(),

                  onChanged: (value) {
                    setState(() {
                      selectedCategoryId =
                          value;
                    });
                  },

                  validator: (value) {
                    if (value == null) {
                      return 'Pilih kategori';
                    }

                    return null;
                  },
                ),

              const SizedBox(height: 24),

              // ==========================================
              // GAMBAR
              // ==========================================

              const Text(
                'Gambar Artikel',

                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2F2F2F),
                ),
              ),

              const SizedBox(height: 10),

              GestureDetector(
                onTap: isLoading
                    ? null
                    : pickImage,

                child: Container(
                  width: double.infinity,
                  height: 220,

                  decoration: BoxDecoration(
                    color:
                        const Color(0xFFF8F3E7),

                    borderRadius:
                        BorderRadius.circular(18),

                    border: Border.all(
                      color:
                          const Color(0xFFE8E3D7),
                    ),
                  ),

                  child:
                      imageBytes != null

                          // =================================
                          // GAMBAR YANG BARU DIPILIH
                          // =================================
                          ? ClipRRect(
                              borderRadius:
                                  BorderRadius
                                      .circular(18),

                              child: Image.memory(
                                imageBytes!,
                                width:
                                    double.infinity,
                                height: 220,
                                fit: BoxFit.cover,
                              ),
                            )

                          // =================================
                          // BELUM MEMILIH GAMBAR
                          // =================================
                          : Column(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .center,

                              children: const [

                                Icon(
                                  Icons
                                      .add_photo_alternate_outlined,

                                  size: 50,

                                  color:
                                      Color(
                                    0xFFB8923F,
                                  ),
                                ),

                                SizedBox(height: 12),

                                Text(
                                  'Pilih Gambar',

                                  style: TextStyle(
                                    color:
                                        Color(
                                      0xFFB8923F,
                                    ),

                                    fontWeight:
                                        FontWeight
                                            .w600,
                                  ),
                                ),

                                SizedBox(height: 6),

                                Text(
                                  'Klik untuk memilih gambar',

                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        Color(
                                      0xFF85827A,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                ),
              ),

              const SizedBox(height: 24),

              // ==========================================
              // ISI ARTIKEL
              // ==========================================

              const Text(
                'Isi Artikel',

                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2F2F2F),
                ),
              ),

              const SizedBox(height: 10),

              TextFormField(
                controller:
                    contentController,

                maxLines: 10,

                decoration: InputDecoration(
                  hintText:
                      'Masukkan penjelasan artikel...',

                  alignLabelWithHint: true,

                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                  ),

                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(14),

                    borderSide:
                        const BorderSide(
                      color: Color(0xFFB8923F),
                    ),
                  ),
                ),

                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Isi artikel wajib diisi';
                  }

                  if (value.trim().length < 10) {
                    return 'Isi artikel minimal 10 karakter';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 32),

              // ==========================================
              // TOMBOL BUAT / SIMPAN
              // ==========================================

              SizedBox(
                width: double.infinity,
                height: 54,

                child: ElevatedButton(
                  onPressed:
                      isLoading
                          ? null
                          : saveArticle,

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFFD4AF5A),

                    foregroundColor:
                        Colors.white,

                    disabledBackgroundColor:
                        const Color(0xFFD4AF5A)
                            .withOpacity(0.6),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                  ),

                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,

                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          widget.isEdit
                              ? 'Simpan Perubahan'
                              : 'Buat Artikel',

                          style:
                              const TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}