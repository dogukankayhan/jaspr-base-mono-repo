#!/bin/bash
# Copies the correct GoogleService-Info.plist based on the active flavor/scheme

# Determine flavor from scheme name
SCHEME="${SCHEME:-$CONFIGURATION}"

if [[ "$SCHEME" == *"Dev"* ]] || [[ "$SCHEME" == *"dev"* ]]; then
  FLAVOR="dev"
elif [[ "$SCHEME" == *"Staging"* ]] || [[ "$SCHEME" == *"staging"* ]]; then
  FLAVOR="staging"
else
  FLAVOR="prod"
fi

SOURCE="${SRCROOT}/config/${FLAVOR}/GoogleService-Info.plist"

if [ -n "${CODESIGNING_FOLDER_PATH}" ]; then
  DESTINATION="${CODESIGNING_FOLDER_PATH}/GoogleService-Info.plist"
else
  DESTINATION="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"
fi

if [ -f "$SOURCE" ]; then
  cp "$SOURCE" "$DESTINATION"
  echo "✅ Copied GoogleService-Info.plist for flavor: $FLAVOR to $DESTINATION"
else
  echo "⚠️ GoogleService-Info.plist not found at: $SOURCE — Firebase disabled, skipping."
  exit 0
fi
