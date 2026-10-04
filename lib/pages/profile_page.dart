import 'package:flutter/material.dart';
import 'package:museum_learn/services/api_service.dart';

class ProfilePage extends StatefulWidget {
  final int userId;

  const ProfilePage({
    super.key,
    required this.userId, 
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // =====================================================
  // PROFILE FUTURE
  // =====================================================

  late Future<Map<String, dynamic>> profileFuture;

  // =====================================================
  // INIT STATE
  // =====================================================

  @override
  void initState() {
    super.initState();

    // WAJIB DIISI SEBELUM BUILD
    profileFuture = getProfile(
      userId: widget.userId,
    );
  }

  // =====================================================
  // LOAD ULANG PROFILE
  // =====================================================

  void loadProfile() {
    setState(() {
      profileFuture = getProfile(
        userId: widget.userId,
      );
    });
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

        title: const Text(
          'Profile',

          style: TextStyle(
            color: Color(0xFF2F2F2F),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // =================================================
      // BODY
      // =================================================

      body: FutureBuilder<Map<String, dynamic>>(
        future: profileFuture,

        builder: (context, snapshot) {
          // =================================================
          // LOADING
          // =================================================

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFB8923F),
              ),
            );
          }

          // =================================================
          // ERROR
          // =================================================

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),

                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [
                    // ICON
                    const Icon(
                      Icons.error_outline_rounded,

                      size: 60,

                      color: Colors.redAccent,
                    ),

                    const SizedBox(height: 20),

                    // TITLE
                    const Text(
                      'Gagal mengambil data profile',

                      textAlign: TextAlign.center,

                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2F2F2F),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ERROR
                    Text(
                      snapshot.error.toString(),

                      textAlign: TextAlign.center,

                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.redAccent,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // RETRY
                    ElevatedButton.icon(
                      onPressed: loadProfile,

                      icon: const Icon(
                        Icons.refresh_rounded,
                      ),

                      label: const Text(
                        'Coba Lagi',
                      ),

                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFD4AF5A),

                        foregroundColor: Colors.white,

                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // =================================================
          // DATA KOSONG
          // =================================================

          if (!snapshot.hasData ||
              snapshot.data == null) {
            return const Center(
              child: Text(
                'Data profile tidak ditemukan',

                style: TextStyle(
                  color: Color(0xFF85827A),
                ),
              ),
            );
          }

          // =================================================
          // DATA PROFILE
          // =================================================

          final profile = snapshot.data!;

          final String username =
              profile['username']?.toString() ??
                  'Tidak diketahui';

          final String email =
              profile['email']?.toString() ??
                  'Tidak diketahui';

          final String role =
              profile['role']?.toString() ??
                  'user';

          // =================================================
          // TAMPILKAN PROFILE
          // =================================================

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),

            child: Column(
              children: [
                // =================================================
                // FOTO / ICON PROFILE
                // =================================================

                Container(
                  width: 110,
                  height: 110,

                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F3E7),

                    shape: BoxShape.circle,

                    border: Border.all(
                      color: const Color(0xFFD4AF5A),
                      width: 2,
                    ),
                  ),

                  child: const Icon(
                    Icons.person_rounded,

                    size: 60,

                    color: Color(0xFFB8923F),
                  ),
                ),

                const SizedBox(height: 20),

                // =================================================
                // USERNAME
                // =================================================

                Text(
                  username,

                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2F2F2F),
                  ),
                ),

                const SizedBox(height: 6),

                // =================================================
                // ROLE
                // =================================================

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),

                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F3E7),

                    borderRadius:
                        BorderRadius.circular(20),
                  ),

                  child: Text(
                    role.toUpperCase(),

                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFB8923F),
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                // =================================================
                // INFORMASI PROFILE
                // =================================================

                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius:
                        BorderRadius.circular(18),

                    border: Border.all(
                      color: const Color(0xFFE8E3D7),
                    ),

                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withOpacity(0.04),

                        blurRadius: 10,

                        offset:
                            const Offset(0, 4),
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      // =================================================
                      // JUDUL
                      // =================================================

                      const Text(
                        'Informasi Profile',

                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2F2F2F),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // =================================================
                      // USERNAME
                      // =================================================

                      _ProfileInfoItem(
                        icon: Icons.person_outline_rounded,
                        title: 'Username',
                        value: username,
                      ),

                      const SizedBox(height: 18),

                      // =================================================
                      // EMAIL
                      // =================================================

                      _ProfileInfoItem(
                        icon: Icons.email_outlined,
                        title: 'Email',
                        value: email,
                      ),

                      const SizedBox(height: 18),

                      // =================================================
                      // ROLE
                      // =================================================

                      _ProfileInfoItem(
                        icon: Icons.admin_panel_settings_outlined,
                        title: 'Role',
                        value: role,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// =====================================================
// PROFILE INFO ITEM
// =====================================================

class _ProfileInfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ProfileInfoItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        // =================================================
        // ICON
        // =================================================

        Container(
          width: 42,
          height: 42,

          decoration: BoxDecoration(
            color: const Color(0xFFF8F3E7),

            borderRadius:
                BorderRadius.circular(12),
          ),

          child: Icon(
            icon,

            color: const Color(0xFFB8923F),

            size: 22,
          ),
        ),

        const SizedBox(width: 14),

        // =================================================
        // TEXT
        // =================================================

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                title,

                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF85827A),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                value,

                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2F2F2F),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}