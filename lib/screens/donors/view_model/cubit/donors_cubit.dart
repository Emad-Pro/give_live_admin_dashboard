import 'package:bloc/bloc.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/di/enum.dart';
import '../../view/widget/donor_table.dart';

part 'donors_state.dart';

class DonorsCubit extends Cubit<DonorsState> {
  DonorsCubit() : super(DonorsState());
  late DonorsDataSource donorsDataSource;
  void getDonors() {
    final supabase = Supabase.instance.client;
    emit(state.copyWith(getDonorState: RequestState.loading));
    supabase
        .from('UserAuth')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .listen((data) {
          donorsDataSource = DonorsDataSource(data);
          emit(state.copyWith(
            getDonorState: RequestState.success,
            donorData: data,
          ));
        });
  }
}
