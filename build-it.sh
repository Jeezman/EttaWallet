#!/bin/bash

BUILDER_IMAGE="reactnativecommunity/react-native-android@sha256:738a5a2fb9ef1be3f07c1c3251bd6afd6370a4c75f044ca1ed62fa26814c0436"
CONTAINER_NAME="etta_builder_container"
ETTA_PATH=/etta-releases/EttaWallet

LOCAL_GRADLE_CACHE="$HOME/.gradle"

mkdir -p $LOCAL_GRADLE_CACHE

docker run --rm -it --name $CONTAINER_NAME \
   --memory 4g \
   -v "$(pwd)":$ETTA_PATH \
   -v "$LOCAL_GRADLE_CACHE":/root/.gradle \
   $BUILDER_IMAGE bash -c \
    'echo -e "\n\n********************************\n*** Building EttaWallet...\n********************************\n" && \
      echo "Installing dependencies and building the project..." && \
      cd /etta-releases/EttaWallet && \
      yarn install --frozen-lockfile && \
      echo "Moving to Android directory to clean and build..." && \
      cd /etta-releases/EttaWallet/android && \
      echo "Ensuring proper gradlew permissions..." && \
      chmod +x ./gradlew && \
      ./gradlew stop && \
      ./gradlew clean && \
      ./gradlew app:assembleRelease \
        -Dorg.gradle.daemon=false \
        -Dorg.gradle.jvmargs="-Xmx2048m -XX:MaxMetaspaceSize=512m -XX:+HeapDumpOnOutOfMemoryError" \
        -Dorg.gradle.configureondemand=true && \
      echo "Build completed successfully." && \
      echo -e "\n\n********************************\n**** APKs and SHA256 Hashes\n********************************\n" && \
      cd /etta-releases/EttaWallet && \
      for f in android/app/build/outputs/apk/release/*.apk; do
          RENAMED_FILENAME=$(echo $f | sed -e "s/app-/ettaln-/" -e "s/-release-unsigned//")
          mv $f $RENAMED_FILENAME
          sha256sum $RENAMED_FILENAME
      done && \
      echo -e "\n" '
