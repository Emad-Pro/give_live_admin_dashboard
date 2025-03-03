import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../screens/donors/view/donors_page.dart';
import '../../widgets/build_drawer_buttons_widget.dart';

class HomeCubit extends Cubit<int> {
  HomeCubit() : super(0);
  List<Widget> getDrawerButtons(BuildContext context, int currentIndex) => [
        BuildDrawerButtonsWidget(
            icon: Icons.supervised_user_circle_sharp,
            title: "Mange Donors",
            onTap: () {
              context.read<HomeCubit>().togglePage(0);
            },
            isSelected: currentIndex == 0),
        BuildDrawerButtonsWidget(
            icon: Icons.local_hospital,
            title: "Hospitals",
            onTap: () {
              context.read<HomeCubit>().togglePage(1);
            },
            isSelected: currentIndex == 1),
        BuildDrawerButtonsWidget(
            icon: Icons.history,
            title: "Donations History",
            onTap: () {
              context.read<HomeCubit>().togglePage(2);
            },
            isSelected: currentIndex == 2),
      ];
  Widget getPage(int index) {
    final List<Widget> pages = [
      DonorsPage(),
      Center(child: Text("Hospitals Page")),
      Center(child: Text("Donations History Page"))
    ];
    return pages[index];
  }

  void togglePage(int index) {
    emit(index);
  }
}
