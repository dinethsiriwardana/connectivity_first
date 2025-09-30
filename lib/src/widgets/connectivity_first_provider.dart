import 'package:connectivity_first/src/bloc/connectivity/connectivity_bloc.dart';
import 'package:connectivity_first/src/bloc/connectivity_quality/connectivity_quality_bloc.dart';
import 'package:connectivity_first/src/services/global_connectivity_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConnectivityFirstProvider extends StatelessWidget {
  final Widget builder;
  final Function()? onConnectivityRestored;
  final Function()? onConnectivityLost;
  const ConnectivityFirstProvider({
    super.key,
    required this.builder,
    this.onConnectivityRestored,
    this.onConnectivityLost,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ConnectivityFirstBloc(),
        ),
        BlocProvider(
          create: (context) => ConnectivityQualityBloc(),
        ),
      ],
      child: ConnectivityFirstGlobalManager(
        onConnectivityRestored: onConnectivityRestored,
        onConnectivityLost: onConnectivityLost,
        child: builder,
      ),
    );
  }
}
