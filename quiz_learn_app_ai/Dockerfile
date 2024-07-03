FROM cirrusci/flutter:stable

WORKDIR /app

COPY . .

RUN flutter pub get
RUN flutter build apk --release

# This step is to make the APK accessible
RUN mkdir /output && cp build/app/outputs/flutter-apk/app-release.apk /output/
