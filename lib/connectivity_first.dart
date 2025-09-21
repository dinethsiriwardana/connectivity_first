library offline_first;

// Export connectivity service
export 'src/services/connectivity_service.dart';

// Export connectivity bloc and related files
export 'src/bloc/connectivity/connectivity_bloc.dart';

// Export global connectivity manager
export 'src/services/global_connectivity_manager.dart';

// Export offline first provider widget
export 'src/widgets/connectivity_first_provider.dart';

/// Export offline first app widget
/// This widget provides a builder function that gives the current
/// connectivity status (online/offline) to build the UI accordingly.
/// It listens to connectivity changes and rebuilds the UI when the status changes.
export 'src/widgets/connectivity_first_app.dart';

// Export connectivity commands utility
export 'src/services/global_connectivity_manager.dart'
    show ConnectivityFirstCommand;
