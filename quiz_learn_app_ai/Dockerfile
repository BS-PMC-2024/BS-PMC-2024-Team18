# Use an official Flutter image as a base
FROM cirrusci/flutter:stable

# Set the working directory
WORKDIR /app

# Copy pubspec.yaml and pubspec.lock to cache dependencies
COPY pubspec.* ./

# Install Flutter packages
RUN flutter pub get

# Copy the entire project
COPY . .

# Build APK
RUN flutter build apk
