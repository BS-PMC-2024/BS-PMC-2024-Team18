FROM debian:latest


# Meta

LABEL org.opencontainers.image.title="Flutter Builder"
LABEL org.opencontainers.image.authors="zekfad@null.moe"
LABEL org.opencontainers.image.licenses="ISC"
LABEL org.opencontainers.image.source="https://github.com/Zekfad/flutter_builder"
LABEL org.opencontainers.image.url="https://github.com/Zekfad/flutter_builder/tree/master/builder"
LABEL org.opencontainers.image.description="Flutter Builder"

# Env

WORKDIR /root
ENV FLUTTER_VERSION="stable"
ENV ANDROID_SDK_ROOT="/root/android-sdk"
ENV FLUTTER_SDK_ROOT="/root/flutter-sdk"
ENV ANDROID_HOME="$ANDROID_SDK_ROOT"
ENV PATH="$PATH:$FLUTTER_SDK_ROOT/bin"
ENV PATH="$PATH:$FLUTTER_SDK_ROOT/bin/cache/dart-sdk/bin"
ENV PATH="$PATH:$ANDROID_SDK_ROOT/cmdline-tools"
ENV PATH="$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin"
ENV PATH="$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/lib"
ENV PATH="$PATH:$ANDROID_SDK_ROOT/platform-tools"
ENV PATH="$PATH:$ANDROID_SDK_ROOT/platforms"


# Install dependencies

RUN apt-get update
RUN apt-get install -y bash curl file git unzip xz-utils zip software-properties-common gnupg


# Install Flutter SDK

RUN git clone https://github.com/flutter/flutter.git -b $FLUTTER_VERSION $FLUTTER_SDK_ROOT

RUN flutter precache \
	&& flutter config --no-analytics
	# && flutter update-packages


# Add Adoptium repository

RUN curl -s -L https://packages.adoptium.net/artifactory/api/gpg/key/public \
	| gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/adoptium.gpg --import \
	&& chmod 644 /etc/apt/trusted.gpg.d/adoptium.gpg

RUN echo "deb [signed-by=/etc/apt/trusted.gpg.d/adoptium.gpg] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" \
	| tee /etc/apt/sources.list.d/adoptium.list
RUN apt-get update


# Install Java SDK

ENV JAVA_VERSION="17"

# RUN apt-get install -y openjdk-$JAVA_VERSION-jdk
RUN apt-get install -y temurin-$JAVA_VERSION-jdk


# Install Android SDK

ENV ANDROID_SDK_URL="https://dl.google.com/android/repository/commandlinetools-linux-11479570_latest.zip"
RUN curl -Lo android_tools.zip $ANDROID_SDK_URL \
	&& unzip -q -d $ANDROID_SDK_ROOT android_tools.zip \
	&& rm -f android_tools.zip \
	&& mkdir -p $ANDROID_SDK_ROOT/cmdline-tools/latest \
	&& mv $ANDROID_SDK_ROOT/cmdline-tools/bin $ANDROID_SDK_ROOT/cmdline-tools/latest \
	&& mv $ANDROID_SDK_ROOT/cmdline-tools/lib $ANDROID_SDK_ROOT/cmdline-tools/latest

# Install Android SDK packages

# ENV ANDROID_PLATFORMS="\"platforms;android-28\" \"platforms;android-29\" \"platforms;android-30\" \"platforms;android-31\""
# ENV ANDROID_BUILD_TOOLS="\"build-tools;28.0.3\" \"build-tools;29.0.3\" \"build-tools;30.0.3\" \"build-tools;31.0.0\""
ENV ANDROID_PLATFORMS="\"platforms;android-34\""
ENV ANDROID_BUILD_TOOLS="\"build-tools;30.0.3\" \"build-tools;34.0.0\""
ENV ANDROID_NDK="\"ndk;26.3.11579264\""

RUN yes "y" | eval "sdkmanager $ANDROID_BUILD_TOOLS"
RUN yes "y" | eval "sdkmanager $ANDROID_PLATFORMS"
RUN yes "y" | eval "sdkmanager $ANDROID_NDK"
RUN yes "y" | sdkmanager "emulator"
RUN yes "y" | sdkmanager "platform-tools"
RUN yes "y" | sdkmanager "tools"

RUN sdkmanager --list_installed


# Accept Android Licenses

RUN yes "y" | flutter doctor --android-licenses

RUN flutter doctor