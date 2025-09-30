// Export connectivity service
export 'src/services/connectivity_service.dart';

// Export connectivity quality service
export 'src/services/connectivity_quality_service.dart';

// Export connectivity bloc and related files
export 'src/bloc/connectivity/connectivity_bloc.dart';

// Export connectivity quality bloc and related files
export 'src/bloc/connectivity_quality/connectivity_quality_bloc.dart';
export 'src/bloc/connectivity_quality/connectivity_quality_state.dart';
export 'src/bloc/connectivity_quality/connectivity_quality_event.dart';

// Export global connectivity manager
export 'src/services/global_connectivity_manager.dart';

// Export offline first provider widget
export 'src/widgets/connectivity_first_provider.dart';

/// Export offline first app widget
/// This widget provides a builder function that gives the current
/// connectivity status (online/offline) and quality to build the UI accordingly.
/// It listens to connectivity changes and rebuilds the UI when the status changes.
export 'src/widgets/connectivity_first_app.dart';

// Export connectivity commands utility
export 'src/services/global_connectivity_manager.dart'
    show ConnectivityFirstCommand, ConnectivityQualityCommand;

// Export WASM-compatible logger utility
export 'src/utils/connectivity_logger.dart';
