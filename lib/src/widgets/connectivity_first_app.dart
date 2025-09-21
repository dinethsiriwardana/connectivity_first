import 'package:connectivity_first/src/bloc/connectivity/connectivity_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConnectivityFirstApp extends StatelessWidget {
  final Widget Function(bool isOnline) builder;

  const ConnectivityFirstApp({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityFirstBloc, ConnectivityFirstState>(
      builder: (context, state) {
        final isOnline = state.isOnline;
        return builder(isOnline);
      },
    );
  }
}
