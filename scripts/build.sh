#!/bin/bash

echo "Build options:"
PS3='Please select the platform: '
OPT=("Android" "iOS" "MacOS" "All" "Quit")
OUTPUT_DIR="../nahpu-releases"
APK_PATH="$OUTPUT_DIR/nahpu_beta_android.apk"

create_output_dir() {
    if [ ! -d $OUTPUT_DIR ]; then
        mkdir $OUTPUT_DIR
    fi
}

copy_apk() {
    create_output_dir
    # Remove any previous APK
    if [ -f $APK_PATH ]; then
        echo "Removing previous APK"
        rm $APK_PATH
    fi
    # Copy APK to output directory
    if [ -f "build/app/outputs/apk/release/app-release.apk" ]; then
        echo "Copying APK to $OUTPUT_DIR"
        cp build/app/outputs/apk/release/app-release.apk $APK_PATH
    fi
}

select os in "${OPT[@]}"

do
    case $os in
        "Android")
            echo "Building for Android..."
            flutter build apk --release
            copy_apk
            break
            ;;
        "iOS")
            echo "Building for iOS..."
            flutter build ios --release
            break
            ;;
        "MacOS")
            echo "Building for MacOS..."
            flutter build macos --release
            break
            ;;
        "All")
            echo "Building for all platforms..."
            echo "Building for Android..."
            flutter build apk --release
            echo "Building for iOS..."
            flutter build ios --release
            echo "Building for MacOS..."
            flutter build macos --release
            copy_apk
            break
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $os";;
    esac
done