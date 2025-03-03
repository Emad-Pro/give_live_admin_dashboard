import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:give_live_admin_dashboard/core/di/enum.dart';
import 'package:give_live_admin_dashboard/screens/donors/view_model/cubit/donors_cubit.dart';

import 'widget/donor_table.dart';

class DonorsPage extends StatelessWidget {
  const DonorsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DonorsCubit()..getDonors(),
      child: BlocBuilder<DonorsCubit, DonorsState>(
        builder: (context, state) {
          switch (state.getDonorState) {
            case RequestState.initial:
            case RequestState.loading:
              return const Center(child: CircularProgressIndicator());
            case RequestState.success:
              return DonorsTableScreen(
                donorData: state.donorData,
              );
            case RequestState.failure:
              return Center(child: Text("Check your internet connection"));
          }
        },
      ),
    );
  }
}
