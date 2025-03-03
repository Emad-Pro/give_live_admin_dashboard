import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'view_model/cubit/home_cubit.dart';
import 'widgets/build_drawer_home.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  padding: const EdgeInsets.all(12.0),
                  child: Row(children: [
                    Row(
                      children: [
                        Image.asset(
                          "assets/logo/app_logo.png",
                          width: 50,
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          "Give Life",
                          style: TextStyle(fontSize: 22),
                        ),
                      ],
                    ),
                    Spacer(),
                    CircleAvatar(child: Icon(Icons.admin_panel_settings_sharp))
                  ])),
              Expanded(
                child: Row(
                  children: [
                    BlocBuilder<HomeCubit, int>(
                      builder: (context, currentIndex) {
                        return BuildDrawerHomeScreen(
                          buttons: context
                              .read<HomeCubit>()
                              .getDrawerButtons(context, currentIndex),
                        );
                      },
                    ),
                    Expanded(
                      child: BlocBuilder<HomeCubit, int>(
                        builder: (context, currentIndex) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            padding: const EdgeInsets.all(12.0),
                            child:
                                context.read<HomeCubit>().getPage(currentIndex),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
