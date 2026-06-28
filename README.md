# Manhwa Downloader 📚

A sleek, native Flutter application that allows you to download and read manhwa chapters offline, directly from your favorite scanlation sites (currently optimized for AsuraScans).

## Features

- **Blazing Fast Downloads:** Directly scrapes and downloads raw high-quality `.webp`/`.jpg` images without any slow conversions.
- **Offline E-Book Library:** Automatically fetches series cover art (via OpenGraph meta tags) and displays your downloaded manhwas in a beautiful, offline-ready Bookshelf GridView.
- **Native Image Reader:** A buttery-smooth, vertical-scrolling reader built with `ListView.builder`. Say goodbye to squished images and slow PDF rendering—enjoy perfect aspect ratios exactly as the authors intended.
- **Robust URL Parsing:** Paste any variation of a series URL (with or without chapter numbers, trailing slashes, etc.) and the app will smartly normalize it to fetch exactly what you need.
- **Safe Storage:** Downloads are securely stored in the app's internal documents directory, avoiding Android's strict scoped storage permission issues while keeping your gallery clean.

## Getting Started

### Prerequisites

- Flutter SDK (latest stable)
- Android Studio / VS Code with Flutter extension
- An Android Emulator or physical device

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/haridinesh00/Manhwa-Downloader.git
   ```
2. Navigate to the project directory:
   ```bash
   cd Manhwa-Downloader
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## Usage

1. Open the app and tap the **+** button on the Home Screen.
2. Enter the name of the Manhwa (e.g., `Sword Emperor`).
3. Paste the Target Base URL (e.g., `https://asurascans.com/comics/sword-emperor`).
4. Set the Start and End Chapters you wish to download.
5. Tap **Download Now** and let the app do the heavy lifting!
6. Once complete, tap the cover in your library to start reading offline.

## Disclaimer

This app is a personal project built for educational purposes. It scrapes publicly available data for personal offline reading. Please support the official creators and scanlation groups by visiting their websites when possible.

## License

MIT License
