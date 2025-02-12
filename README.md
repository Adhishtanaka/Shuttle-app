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
   git clone https://github.com/Adhishtanaka/Shuttle-app.git
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

## Contributors

<table>
  <tr>
    <td align="center">
       <img src="https://github.com/tdulshan3.png" width="80px;" alt="Thusara Dulshan"/><br />
       <a href="https://github.com/tdulshan3"><sub><b>Thusara Dulshan</b></sub></a>
    </td>
    <td align="center">
       <img src="https://github.com/TanujMalinda.png" width="80px;" alt="Tanuj Malinda"/><br />
       <a href="https://github.com/TanujMalinda"><sub><b>Tanuj Malinda</b></sub></a>
    </td>
      <td align="center">
       <img src="https://github.com/dilinamewan.png" width="80px;" alt="Dilina Mewan"/><br />
       <a href="https://github.com/dilinamewan"><sub><b>Dilina Mewan</b></sub></a>
    </td>
       </tr>
      <tr>
  <td align="center">
       <img src="https://github.com/Adhishtanaka.png" width="80px;" alt="Adhishtanaka"/><br />
       <a href="https://github.com/Adhishtanaka"><sub><b>Adhishtanaka Kulasooriya</b></sub></a>
    </td>
    <td align="center">
       <img src="https://github.com/Siluni28270.png" width="80px;" alt="Siluni"/><br />
       <a href="https://github.com/Siluni28270"><sub><b>Siluni Sadanima</b></sub></a>
    </td>
       <td align="center">
       <img src="https://github.com/Madharaa.png" width="80px;" alt="Madara"/><br />
       <a href="https://github.com/Madharaa"><sub><b>Madhara Dulanjali</b></sub></a>
    </td>
  </tr>
</table>

If you find any bugs or want to suggest improvements, feel free to open an issue or pull request on the [GitHub repository](https://github.com/Adhishtanaka/Shuttle-app/pulls).

## License
This project is licensed under the MIT License. See [MIT License](LICENSE) for details.

Made with ❤️ using Flutter.



