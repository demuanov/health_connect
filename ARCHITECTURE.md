# Health Connect Flutter Project - Reorganized Structure

This Flutter project has been completely reorganized to follow best practices and improve maintainability. The project demonstrates integration with health data platforms (iOS HealthKit and Android Health Connect).

## 📁 New Project Structure

```
lib/
├── main.dart                           # App entry point
├── core/                              # Core utilities and shared components
│   ├── core.dart                      # Barrel export file
│   ├── constants/
│   │   └── health_data_types.dart     # Platform-specific health data types
│   ├── enums/
│   │   └── app_state.dart             # App state definitions
│   └── utils/
│       └── health_utils.dart          # Health data utility functions
└── features/                          # Feature-based organization
    └── health/                        # Health feature module
        ├── health.dart                # Barrel export file
        ├── data/
        │   └── health_service.dart    # Health data service layer
        ├── domain/
        │   └── models/
        │       └── health_summary.dart # Health data models
        └── presentation/
            ├── screens/
            │   ├── main_health_screen.dart     # Main app screen
            │   └── health_data_screen.dart     # Health data display screen
            └── widgets/
                ├── health_card_widget.dart      # Health metric card widget
                ├── health_data_list_widget.dart # Health data list widget
                └── health_detail_bottom_sheet.dart # Detail view widget
```

## 🏗 Architecture Overview

### Clean Architecture Layers

1. **Core Layer** (`lib/core/`)
   - Contains shared utilities, constants, and enums
   - Platform-agnostic code that can be reused across features

2. **Feature Layer** (`lib/features/`)
   - Organized by business features (health)
   - Each feature follows clean architecture principles:
     - **Data Layer**: Service classes and data sources
     - **Domain Layer**: Business models and entities
     - **Presentation Layer**: UI components (screens and widgets)

### Key Components

#### Health Service (`HealthService`)
- Singleton service managing all health data operations
- Handles permissions, data fetching, and CRUD operations
- Abstracts platform-specific health API calls
- Provides clean interface for UI components

#### App State Management (`AppState`)
- Centralized state definitions using enum
- Follows camelCase naming convention
- Clear state descriptions for better debugging

#### Health Data Models (`HealthSummary`)
- Rich data models for health metrics aggregation
- Includes fitness scoring and health calculations
- Type-safe data structures

#### Reusable Widgets
- `HealthCardWidget`: Displays individual health metrics
- `HealthDataListWidget`: Shows list of health data points
- `HealthDetailBottomSheet`: Detailed view of health data

## 📊 Health Data Types Support

### iOS (via HealthKit)
- Steps, Heart Rate, Blood Pressure, Weight, Height
- Sleep data, Workout data, Nutrition data
- Body measurements, Vital signs
- Apple-specific metrics (Apple Watch data)

### Android (via Health Connect)
- Steps, Heart Rate, Blood Pressure, Weight, Height  
- Sleep sessions, Workout data, Nutrition data
- Body composition, Respiratory data
- Google Health Connect integration

## 🚀 Usage Examples

### Basic Health Data Fetching
```dart
// Initialize the service
final healthService = HealthService();
await healthService.initialize();

// Request permissions
final authorized = await healthService.requestPermissions();

// Fetch recent health data
final healthData = await healthService.fetchHealthData(
  startTime: DateTime.now().subtract(Duration(days: 1)),
  endTime: DateTime.now(),
);
```

### Using Health Summary Model
```dart
// Create summary from health data points
final summary = HealthSummary.fromHealthDataPoints(
  DateTime.now(),
  healthDataPoints,
);

// Get fitness score (0-100)
final score = summary.fitnessScore;
print('Fitness Score: $score');
```

## 🎯 Benefits of New Structure

### Maintainability
- **Separation of Concerns**: Each layer has a specific responsibility
- **Feature-based Organization**: Related code is grouped together
- **Single Responsibility**: Each class has a focused purpose

### Scalability
- **Modular Architecture**: Easy to add new health-related features
- **Clean Interfaces**: Well-defined contracts between layers
- **Reusable Components**: Widgets and services can be shared

### Testability
- **Dependency Injection**: Services can be easily mocked
- **Clear Boundaries**: Each layer can be tested independently
- **Pure Functions**: Utility functions are stateless and testable

### Developer Experience
- **Barrel Exports**: Simplified import statements
- **Type Safety**: Comprehensive type definitions
- **Documentation**: Well-documented code with clear naming

## 🔧 Development Guidelines

### Adding New Health Features
1. Create new files in appropriate layer directories
2. Follow existing naming conventions
3. Use barrel exports for clean imports
4. Add comprehensive documentation

### Widget Development
- Keep widgets focused and reusable
- Use proper state management
- Follow Material Design guidelines
- Include accessibility features

### Service Layer
- Maintain singleton pattern for services
- Handle errors gracefully
- Provide clear API contracts
- Include proper logging

## 📱 Platform Compatibility

- **iOS**: Requires iOS 13.0+ for HealthKit integration
- **Android**: Requires Health Connect app installation
- **Web**: Limited health data access (demonstration only)
- **Desktop**: No health data integration available

## 🔐 Privacy & Permissions

The app requests the following permissions:
- **Activity Recognition**: For step counting and movement data
- **Location**: For workout distance tracking  
- **Health Data Access**: Platform-specific health permissions
- **Background Processing**: For continuous health monitoring

## 🤝 Contributing

When contributing to this project:
1. Follow the established folder structure
2. Maintain clean architecture principles
3. Add tests for new functionality
4. Update documentation as needed
5. Use consistent code formatting

---

This reorganized structure provides a solid foundation for building complex health applications while maintaining code quality and developer productivity.