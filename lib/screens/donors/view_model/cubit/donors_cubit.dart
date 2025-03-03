import 'package:bloc/bloc.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/di/enum.dart';
import '../../view/widget/donor_table.dart';

part 'donors_state.dart';

class DonorsCubit extends Cubit<DonorsState> {
  DonorsCubit() : super(DonorsState());
  late DonorsDataSource donorsDataSource;
  getDonors() async {
    emit(state.copyWith(getDonorState: RequestState.loading));
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('UserAuth')
        .select()
        .order('created_at', ascending: false);
    donorsDataSource = DonorsDataSource(state.donorData);
    emit(state.copyWith(
        getDonorState: RequestState.success, donorData: response));
  }
}
