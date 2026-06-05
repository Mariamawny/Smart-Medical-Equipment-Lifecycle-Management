// ignore_for_file: unused_import, deprecated_member_use

import 'package:ed_app/Screens/dashboard.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();

    // مقاسات الشاشة
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // حجم اللوجو أصغر
    final logoSize = screenWidth * 0.045;

    // ابعاد البوكس (طول أكبر)
    final loginBoxWidth = screenWidth > 600
        ? screenWidth * 0.40
        : screenWidth * 0.85;
    final loginBoxHeight = screenHeight * 0.72;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeight * 0.10),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          title: const SizedBox(),

          flexibleSpace: Padding(
            padding: EdgeInsets.only(
              top: screenHeight * 0.03,
              left: 16,
              right: 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // لوجو + عنوان
                Row(
                  children: [
                    Container(
                      width: logoSize,
                      height: logoSize,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0E4F87),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0E4F87).withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '⚕️',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.015),
                    const Text(
                      'ED Ventilator Maintenance System',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),

                // شمس + تاريخ
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.wb_sunny,
                        color: Colors.orange,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${now.day}-${now.month}-${now.year}",
                      style: const TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8F4F8), Color(0xFFD7F1FF), Color(0xFFC5E8F7)],
          ),
        ),

        child: Center(
          child: Container(
            width: loginBoxWidth,
            height: loginBoxHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),

            child: Column(
              children: [
                const SizedBox(height: 32),
                const Text(
                  'Staff Login',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0E4F87),
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Enter your credentials to access the system',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),

                const SizedBox(height: 20),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Staff ID',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Staff ID TextField
                        Container(
                          width: loginBoxWidth - 80,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: const Color.fromARGB(255, 22, 62, 95),
                                  width: 1.2,
                                ),
                              ),
                              hintText: 'Enter Staff ID',
                              hintStyle: TextStyle(color: Colors.grey.shade500),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        const Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),




                        const SizedBox(height: 8),





                        // Password TextField
                        Container(
                          width: loginBoxWidth - 80,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextField(
                            obscureText: true,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: const Color.fromARGB(255, 22, 62, 95),
                                  width: 1.2,
                                ),
                              ),
                              hintText: 'Enter Password',
                              hintStyle: TextStyle(color: Colors.grey.shade500),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

             

                SizedBox(
                  width: loginBoxWidth - 80,
                  height: 45,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/Dashboard');
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (states) {
                          if (states.contains(MaterialState.pressed)) {
                            return const Color(0xFF063B5C);
                          }
                          return const Color(0xFF0E4F87);
                        },
                      ),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
