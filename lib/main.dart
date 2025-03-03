import 'package:flutter/material.dart';
import 'package:give_live_admin_dashboard/core/di/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth/login_screen/login_screen.dart';
import 'auth/view_model/auth_cubit.dart';
import 'home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
      url: "https://rcmumkmvatjdvwmxprjc.supabase.co",
      anonKey:
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJjbXVta212YXRqZHZ3bXhwcmpjIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTczNDc5MDg0NywiZXhwIjoyMDUwMzY2ODQ3fQ.6GzQ8eZ5kuQ8NMjef8THMMdaKMtgzcOm6YyAJq8B3Fo");
  await ServicesLocator.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> checkUser() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      return false; // لا يوجد مستخدم مسجل الدخول، انتقل إلى شاشة تسجيل الدخول
    }

    try {
      final response = await supabase
          .from("admins")
          .select("isadmin")
          .eq("uid", user.id)
          .single();

      return response['isadmin'] == true;
    } catch (e) {
      print("Error checking admin: $e");
      return false; // المستخدم ليس Admin أو حدث خطأ
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Dashboard',
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.dark,
      home: FutureBuilder<bool>(
        future: checkUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ); // عرض تحميل أثناء فحص الحساب
          }
          if (snapshot.hasError || !snapshot.data!) {
            return LoginScreen(); // في حال لم يكن المستخدم Admin أو حدث خطأ
          }
          return HomeScreen(); // المستخدم Admin، انتقل إلى الصفحة الرئيسية
        },
      ),
    );
  }
}
