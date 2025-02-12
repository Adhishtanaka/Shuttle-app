# Shuttle Tracking App

## Overview

This Flutter-based shuttle tracking application provides real-time tracking of shuttle buses, displaying their locations on Google Maps, and estimating arrival times for selected destinations.

| Student UI | Driver UI |
|------------|------------|
|  <img src="screenshot/s.gif" alt="Student UI" width="300"> |  <img src="screenshot/d.gif" alt="Student UI" width="300"> |

## Features

- **Real-time Shuttle Tracking**: Updates bus location every few seconds.
- **Firebase Integration**: Uses Firebase Realtime Database for location updates, and status tracking.
- **Google Maps Integration**: Displays shuttle location and routes using `google_maps_flutter`.
- **Polyline Routes**: Shows shuttle routes using `flutter_polyline_points`.
- **Estimated Arrival Time**: Calculates travel time to a selected destination using Google Distance Matrix API.

## Setup Instructions

1. **Clone the Repository**:
   ```sh
   git clone https://github.com/Adhishtanaka/Shuttle-app
   cd Shuttle-app
   ```
2. **Install Dependencies**:
   ```sh
   flutter pub get
   ```
3. **Setup Firebase**:
   - Add `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS) to their respective directories.
   - Enable Firebase Realtime Database.
4. **Setup Google Maps API**:
   - Enable Maps SDK & Distance Matrix API.
   - Store API key in `.env` file.
5. **Run the App**:
   ```sh
   flutter run
   ```

## Usage

### Student  

- Open the app & login to view the list of real-time location of the shuttles.
- Tap on the selected shuttle to see map
- in here you can select a pickup point and get the estimated arrival time.
- View detailed shuttle information in the `Details` screen.

### Driver

- Open the app & login to share location of your shuttle.
- you can also change status of ride as well
  
## Notes

- The Android folder was accidentally removed and is missing from the project.
- Ensure the `google-services.json` file is correctly placed before running the app.

## License

This project is licensed under the MIT License.



