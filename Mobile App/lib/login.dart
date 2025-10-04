import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'signup.dart';
import 'config.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _obscure = true;
  bool isLoading = false;

  final String apiUrl = Config.loginUrl;

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  double _responsiveFont(double base, double width) {
    if (width < 360) return base * 0.88;
    if (width > 600) return base * 1.05;
    return base;
  }

  Future<void> loginAPI({required String phone, required String password}) async {
    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phone, "password": password}),
      );

      final body = jsonDecode(response.body);

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        if (body is Map && body.containsKey("data")) {
          final data = body["data"];
          if (data is Map) {
            if (data.containsKey("phone")) await prefs.setString("phone", data["phone"].toString());
            if (data.containsKey("token")) await prefs.setString("token", data["token"].toString());
            if (data.containsKey("first_name")) await prefs.setString("first_name", data["first_name"].toString());
            if (data.containsKey("last_name")) await prefs.setString("last_name", data["last_name"].toString());
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body["message"] ?? "تم تسجيل الدخول بنجاح")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainApp()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body["detail"] ?? "هناك مشكلة في تسجيل الدخول")),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل الاتصال بالسيرفر: $e")),
      );
    }
  }

  void _checkLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      loginAPI(phone: _phone.text.trim(), password: _password.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: LayoutBuilder(builder: (context, constraints) {
            final maxW = constraints.maxWidth;
            final titleFont = _responsiveFont(26, maxW);
            final subtitleFont = _responsiveFont(14, maxW);
            final cardWidth = maxW > 500 ? 480.0 : maxW * 0.94;

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 24),
                            onPressed: () => Navigator.maybePop(context),
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      Center(
                        child: Column(
                          children: [
                            Text(
                              'أهلاً! سجّل الدخول',
                              style: TextStyle(fontSize: titleFont, fontWeight: FontWeight.bold, color: AppColors.dark),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('ليس لديك حساب؟', style: TextStyle(fontSize: subtitleFont, color: AppColors.dark)),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const SignUpPage()),
                                    );
                                  },
                                  child: Text(
                                    'افتح حساب جديد',
                                    style: TextStyle(fontSize: subtitleFont, color: AppColors.primary, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      Center(
                        child: Container(
                          width: cardWidth,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 6))],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text('الموبايل *', style: TextStyle(fontSize: _responsiveFont(14, maxW), color: AppColors.dark)),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _phone,
                                  keyboardType: TextInputType.phone,
                                  textAlign: TextAlign.right,
                                  decoration: InputDecoration(
                                    hintText: 'أدخل رقم الموبايل',
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    prefixIcon: const Icon(Icons.phone_android_outlined),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.grey.shade300)),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: AppColors.primary)),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) return 'الرجاء إدخال رقم الموبايل';
                                    if (!RegExp(r'^[0-9]{10,13}$').hasMatch(v.trim())) return 'أدخل رقم موبايل صحيح (10-13 رقم)';
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 14),

                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text('كلمة المرور *', style: TextStyle(fontSize: _responsiveFont(14, maxW), color: AppColors.dark)),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _password,
                                  obscureText: _obscure,
                                  textAlign: TextAlign.right,
                                  decoration: InputDecoration(
                                    hintText: 'أدخل كلمة المرور',
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off, color: AppColors.dark),
                                      onPressed: () => setState(() => _obscure = !_obscure),
                                    ),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.grey.shade300)),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: AppColors.primary)),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'الرجاء إدخال كلمة المرور';
                                    if (v.length < 6) return 'كلمة المرور يجب أن تكون 6 حروف على الأقل';
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 20),

                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : _checkLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                    ),
                                    child: isLoading
                                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2))
                                        : Text('تسجيل الدخول', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600, fontSize: _responsiveFont(16, maxW))),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      Expanded(child: Container()),

                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Center(
                          child: Text('© 2025 جميع الحقوق محفوظة', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                        ),
                      ),
                    ],
                  ),
                ),
              ));
            }),
        ),
      ),
    );
  }
}