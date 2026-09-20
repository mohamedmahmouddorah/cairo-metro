##  Tech Stack & Key Features

## Architecture & State Management
* **GetX Paradigm**: Utilized for reactive state management (`GetxController`, `Obx`), clean dependency injection (`Get.find()`), and seamless navigation (`Get.to()`).
* **Clean Architecture**: Strict separation of concerns between **Core Services**, **Data Models**, and **Feature-Based Presentation Layers**.

## Location & Geospatial Services
* **Geolocator Integration**: Fetches real-time user GPS coordinates (Latitude & Longitude) with optimized permission handling.
* **Haversine Distance Formula**: Computes spatial distances to calculate the nearest metro station with $O(N)$ computational efficiency while preventing battery drain.

## Data Structures & Routing Engine
* **Graph-Based System (`GraphService`)**: Represents the Cairo Metro network as an adjacency-based directed graph.
* **Smart Route Optimization**: Computes optimal travel routes (Fastest Path & Minimum Transfers) across intersecting lines and Line 3 branches in $O(V + E)$ time complexity, dynamically calculating travel duration and ticket fares.

## Local Data Persistence
* **SharedPreferences**: Manages local data persistence for search history.
* **JSON Serialization**: Encodes and decodes trip models (`SearchHistory`) to support seamless history retrieval, instant re-querying, and individual or bulk item deletion.

## UI, Layouts & Responsiveness
* **Figma-Compliant Design System**: Fully implemented Dark Mode theme matching pixel-perfect Figma UI/UX specifications.
* **Interactive Metro Map**: Powered by `InteractiveViewer` to support smooth multi-touch zooming and panning.
* **Adaptive Responsiveness**: Built with `LayoutBuilder`, `Flexible`, and `SingleChildScrollView` to prevent `RenderFlex` overflows across all device screen sizes.
* **State Retention**: Utilizes `IndexedStack` inside the `BottomNavigationBar` to preserve screen state across tab switches without redundant rebuilds.
* **Direct Station Interaction**: Integrates `ModalBottomSheet` and dynamic `ActionChip` widgets to allow instant station selection (Start/Destination) directly from the map.
