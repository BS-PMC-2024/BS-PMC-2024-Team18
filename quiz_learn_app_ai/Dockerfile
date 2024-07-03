# Use the cirrusci/flutter:stable image as base
FROM cirrusci/flutter:stable

# Set working directory
WORKDIR /app

# Copy pubspec.yaml and pubspec.lock
COPY pubspec.* ./

# Install Flutter dependencies
RUN flutter pub get

# Copy the entire project
COPY . .

# Build APK
RUN flutter build apk

# Make the APK accessible outside the container
RUN mkdir /output
RUN cp build/app/outputs/flutter-apk/app-release.apk /output/app-release.apk
