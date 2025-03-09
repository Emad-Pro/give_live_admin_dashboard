import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:give_live_admin_dashboard/core/di/enum.dart';
import 'package:give_live_admin_dashboard/screens/hospitals/HospitalsCubit.dart';
import 'package:give_live_admin_dashboard/screens/hospitals/HospitalsTableScreen.dart';

class HospitalsPage extends StatelessWidget {
  const HospitalsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HospitalsCubit()..getHospitals(),
      child: BlocBuilder<HospitalsCubit, HospitalsState>(
        builder: (context, state) {
          switch (state.getHospitalState) {
            case RequestState.initial:
            case RequestState.loading:
              return const Center(child: CircularProgressIndicator());
            case RequestState.success:
              return HospitalsTableScreen(
                hospitalData: state.hospitalData,
              );
            case RequestState.failure:
              return Center(child: Text("Check your internet connection"));
          }
        },
      ),
    );
  }
}
