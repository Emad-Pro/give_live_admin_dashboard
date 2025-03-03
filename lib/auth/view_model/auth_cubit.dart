import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  final supabase = Supabase.instance.client;

  Future<void> signUpAdmin(
      {required String email,
      required String password,
      required String fullName}) async {
    emit(AuthLoading());
    try {
      print(email);
      final response = await supabase.auth.signUp(
        data: {'roule': 'admin'},
        email: email,
        password: password,
      );
      if (response.user != null) {
        await supabase.from('admins').insert({
          'email': email,
          'fullname': fullName,
          'password': password,
          'uid': response.user!.id,
          'isadmin': true, // تعيين المستخدم كمشرف
        });
        emit(AuthSuccess());
      } else {
        emit(AuthFailure("Faild to sign up"));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  // تسجيل الدخول كمشرف
  Future<void> loginAdmin(String email, String password) async {
    emit(AuthLoading());
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        emit(AuthFailure("Faild to login"));
        return;
      }

      final userId = response.user!.id;
      final userData =
          await supabase.from('admins').select().eq('uid', userId).single();

      if (userData['isadmin'] == true) {
        emit(AuthSuccess());
      } else {
        await supabase.auth.signOut();
        emit(AuthFailure("You are not admin"));
      }
    } catch (e) {
      emit(AuthFailure("You are not admin"));
    }
  }

  // تسجيل الخروج
  Future<void> logout() async {
    await supabase.auth.signOut();
    emit(AuthInitial());
  }
}
