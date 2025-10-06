import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'config.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  bool _obscure = true;
  bool isLoading = false;

  final String apiUrl = Config.signupUrl;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  double _responsiveFont(double base, double width) {
    if (width < 360) return base * 0.88;
    if (width > 600) return base * 1.05;
    return base;
  }

  Future<void> signupAPI() async {
    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "first_name": _firstName.text.trim(),
          "last_name": _lastName.text.trim(),
          "phone": _phone.text.trim(),
          "password": _password.text,
        }),
      );

      final body = jsonDecode(response.body);

      setState(() => isLoading = false);

      if (response.statusCode == 201) {
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
          SnackBar(content: Text(body["message"] ?? "تم إنشاء الحساب بنجاح")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainApp()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body["detail"] ?? "حدث خطأ أثناء التسجيل")),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل الاتصال بالسيرفر: $e")),
      );
    }
  }

  void _checkSignup() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_password.text != _confirmPassword.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("كلمة المرور غير متطابقة")),
        );
        return;
      }
      signupAPI();
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
                              'إنشاء حساب جديد',
                              style: TextStyle(fontSize: titleFont, fontWeight: FontWeight.bold, color: AppColors.dark),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('عندك حساب؟', style: TextStyle(fontSize: subtitleFont, color: AppColors.dark)),
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    'سجّل الدخول',
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
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _firstName,
                                        textAlign: TextAlign.right,
                                        decoration: InputDecoration(
                                          hintText: 'الاسم الأول',
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.grey.shade300)),
                                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: AppColors.primary)),
                                        ),
                                        validator: (v) => v == null || v.isEmpty ? 'أدخل الاسم الأول' : null,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _lastName,
                                        textAlign: TextAlign.right,
                                        decoration: InputDecoration(
                                          hintText: 'الاسم الأخير',
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.grey.shade300)),
                                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: AppColors.primary)),
                                        ),
                                        validator: (v) => v == null || v.isEmpty ? 'أدخل الاسم الأخير' : null,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 14),

                                TextFormField(
                                  controller: _phone,
                                  keyboardType: TextInputType.phone,
                                  textAlign: TextAlign.right,
                                  decoration: InputDecoration(
                                    hintText: 'رقم الموبايل',
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.grey.shade300)),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: AppColors.primary)),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) return 'أدخل رقم الموبايل';
                                    if (!RegExp(r'^[0-9]{10,13}$').hasMatch(v.trim())) return 'رقم الموبايل غير صحيح';
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 14),

                                TextFormField(
                                  controller: _password,
                                  obscureText: _obscure,
                                  textAlign: TextAlign.right,
                                  decoration: InputDecoration(
                                    hintText: 'كلمة المرور',
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off, color: AppColors.dark),
                                      onPressed: () => setState(() => _obscure = !_obscure),
                                    ),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.grey.shade300)),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: AppColors.primary)),
                                  ),
                                  validator: (v) => v == null || v.length < 6 ? 'كلمة المرور 6 أحرف على الأقل' : null,
                                ),

                                const SizedBox(height: 14),

                                TextFormField(
                                  controller: _confirmPassword,
                                  obscureText: true,
                                  textAlign: TextAlign.right,
                                  decoration: InputDecoration(
                                    hintText: 'تأكيد كلمة المرور',
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.grey.shade300)),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: AppColors.primary)),
                                  ),
                                  validator: (v) => v != _password.text ? 'كلمة المرور غير متطابقة' : null,
                                ),

                                const SizedBox(height: 20),

                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : _checkSignup,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                    ),
                                    child: isLoading
                                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2))
                                        : Text('إنشاء حساب', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600, fontSize: _responsiveFont(16, maxW))),
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
              ),
            );
          }),
        ),
      ),
    );
  }
}