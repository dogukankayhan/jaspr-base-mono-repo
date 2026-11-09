#!/bin/sh

set -e

echo "=== Step 1: CD to repo ==="
cd $CI_PRIMARY_REPOSITORY_PATH

echo "=== Step 2: Install Flutter ==="
if [ ! -d "$HOME/flutter" ]; then
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
else
  echo "Flutter already exists, skipping clone"
fi
export PATH="$PATH:$HOME/flutter/bin"

echo "=== Step 3: Flutter precache ==="
flutter precache --ios

echo "=== Step 4: Flutter pub get ==="
flutter pub get

echo "=== Step 5: Install flutterfire CLI ==="
flutter pub global activate flutterfire_cli
export PATH="$PATH:$HOME/.pub-cache/bin"

echo "=== Step 6: Patch objectVersion for CocoaPods compatibility ==="
sed -i '' 's/objectVersion = 70;/objectVersion = 56;/' "$CI_PRIMARY_REPOSITORY_PATH/ios/Runner.xcodeproj/project.pbxproj"
echo "objectVersion: $(grep 'objectVersion' $CI_PRIMARY_REPOSITORY_PATH/ios/Runner.xcodeproj/project.pbxproj)"

echo "=== Step 8: Pod install ==="
cd ios && pod install --repo-update

echo "=== Done ==="
exit 0
