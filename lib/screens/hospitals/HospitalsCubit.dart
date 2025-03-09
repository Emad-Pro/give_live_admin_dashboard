import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:give_live_admin_dashboard/core/di/enum.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HospitalsCubit extends Cubit<HospitalsState> {
  HospitalsCubit() : super(HospitalsState.initial());

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> getHospitals() async {
    emit(state.copyWith(getHospitalState: RequestState.loading));

    _supabase.from('HospitalAuth').stream(primaryKey: ["id"]).listen((data) {
      emit(state.copyWith(
          getHospitalState: RequestState.success, hospitalData: data));
    });
  }
}

class HospitalsState {
  final RequestState getHospitalState;
  final List<Map<String, dynamic>> hospitalData;

  HospitalsState({required this.getHospitalState, required this.hospitalData});

  factory HospitalsState.initial() => HospitalsState(
        getHospitalState: RequestState.initial,
        hospitalData: [],
      );

  HospitalsState copyWith({
    RequestState? getHospitalState,
    List<Map<String, dynamic>>? hospitalData,
  }) {
    return HospitalsState(
      getHospitalState: getHospitalState ?? this.getHospitalState,
      hospitalData: hospitalData ?? this.hospitalData,
    );
  }
}
