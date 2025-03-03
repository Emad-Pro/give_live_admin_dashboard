import 'package:flutter/material.dart';
import 'package:give_live_admin_dashboard/core/di/get_it.dart';
import 'package:give_live_admin_dashboard/home/widgets/build_drawer_buttons_widget.dart';

import '../../auth/login_screen/login_screen.dart';
import '../../auth/view_model/auth_cubit.dart';

class BuildDrawerHomeScreen extends StatelessWidget {
  const BuildDrawerHomeScreen({super.key, required this.buttons});
  final List<Widget> buttons;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.primary)),
      padding: const EdgeInsets.all(12.0),
      width: MediaQuery.sizeOf(context).width * 0.25,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 7),
                    itemCount: buttons.length,
                    itemBuilder: (context, index) {
                      return buttons[index];
                    },
                  ),
                ),
                BuildDrawerButtonsWidget(
                    title: "Logout",
                    isSelected: false,
                    onTap: () {
                      getIt<AuthCubit>().logout().then((onValue) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Logout Successfully"),
                        ));
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()));
                      });
                    },
                    icon: Icons.logout),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
