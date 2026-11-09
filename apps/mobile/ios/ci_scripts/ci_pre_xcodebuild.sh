#!/bin/sh

set -e

FLUTTER_DIR="$HOME/flutter"
REPO="$CI_PRIMARY_REPOSITORY_PATH"

export PATH="$PATH:$FLUTTER_DIR/bin"

# Write .xcode.env.local so Flutter build phases find the SDK
echo "FLUTTER_ROOT=$FLUTTER_DIR" > "$REPO/ios/Flutter/.xcode.env.local"

# Detect flavor from Xcode scheme
if echo "$CI_XCODE_SCHEME" | grep -qi "prod"; then
  FLAVOR="prod"
  FLUTTER_TARGET="$REPO/lib/main_prod.dart"
else
  FLAVOR="staging"
  FLUTTER_TARGET="$REPO/lib/main_staging.dart"
fi

# Patch Generated.xcconfig with correct paths for this runner
cat > "$REPO/ios/Flutter/Generated.xcconfig" << EOF
// This is a generated file; do not edit or check into version control.
FLUTTER_ROOT=$FLUTTER_DIR
FLUTTER_APPLICATION_PATH=$REPO
DEVELOPMENT_TEAM=YOUR_DEVELOPMENT_TEAM_ID
COCOAPODS_PARALLEL_CODE_SIGN=true
FLUTTER_TARGET=$FLUTTER_TARGET
FLUTTER_BUILD_DIR=build
FLUTTER_BUILD_NAME=1.0.0
FLUTTER_BUILD_NUMBER=1
EXCLUDED_ARCHS[sdk=iphonesimulator*]=i386
EXCLUDED_ARCHS[sdk=iphoneos*]=armv7
DART_OBFUSCATION=false
TRACK_WIDGET_CREATION=false
TREE_SHAKE_ICONS=false
PACKAGE_CONFIG=$REPO/.dart_tool/package_config.json
FLAVOR=$FLAVOR
EOF

flutter --version
echo "Generated.xcconfig updated with CI paths"

exit 0
