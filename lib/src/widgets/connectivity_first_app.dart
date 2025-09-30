import 'package:connectivity_first/src/bloc/connectivity/connectivity_bloc.dart';
import 'package:connectivity_first/src/bloc/connectivity_quality/connectivity_quality_bloc.dart';
import 'package:connectivity_first/src/bloc/connectivity_quality/connectivity_quality_state.dart';
import 'package:connectivity_first/src/services/connectivity_quality_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConnectivityFirstApp extends StatelessWidget {
  final Widget Function(bool isOnline, ConnectionQuality quality) builder;

  const ConnectivityFirstApp({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityFirstBloc, ConnectivityFirstState>(
      builder: (context, connectivityState) {
        return BlocBuilder<ConnectivityQualityBloc, ConnectivityQualityState>(
          builder: (context, qualityState) {
            final isOnline = connectivityState.isOnline;
            final quality = qualityState.quality;
            return builder(isOnline, quality);
          },
        );
      },
    );
  }
}
