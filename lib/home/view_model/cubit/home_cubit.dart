import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:give_live_admin_dashboard/screens/hospitals/HospitalsPage.dart';
import 'package:give_live_admin_dashboard/screens/hospitalsReview_page.dart';
import 'package:give_live_admin_dashboard/screens/hospitals_page.dart';
import 'package:give_live_admin_dashboard/screens/donors/view/donors_page.dart'; // New page import

import '../../widgets/build_drawer_buttons_widget.dart';

class HomeCubit extends Cubit<int> {
  HomeCubit() : super(0);

  List<Widget> getDrawerButtons(BuildContext context, int currentIndex) => [
        BuildDrawerButtonsWidget(
            icon: Icons.supervised_user_circle_sharp,
            title: "Manage Donors",
            onTap: () {
              context.read<HomeCubit>().togglePage(0);
            },
            isSelected: currentIndex == 0),
        BuildDrawerButtonsWidget(
            icon: Icons.local_hospital,
            title: "Manage Hospitals",
            onTap: () {
              context.read<HomeCubit>().togglePage(1);
            },
            isSelected: currentIndex == 1),
        BuildDrawerButtonsWidget(
            icon: Icons.local_hospital,
            title: "Verify Hospitals",
            onTap: () {
              context.read<HomeCubit>().togglePage(2);
            },
            isSelected: currentIndex == 2),
        BuildDrawerButtonsWidget(
            icon: Icons.reviews,
            title: "Reviews",
            onTap: () {
              context.read<HomeCubit>().togglePage(3);
            },
            isSelected: currentIndex == 3),
      ];

  Widget getPage(int index) {
    final List<Widget> pages = [
      DonorsPage(),
      HospitalsPage(),
      HospitalsAdminPage(),
      HospitalsListPage(), // New page for selecting a hospital
    ];
    return pages[index];
  }

  void togglePage(int index) {
    emit(index);
  }
}
