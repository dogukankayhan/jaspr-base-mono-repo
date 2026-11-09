#!/bin/bash

# Create/Empty global coverage file
mkdir -p coverage
rm -f coverage/lcov.info
touch coverage/lcov.info

# Find all package directories (excluding .dart_tool and root itself)
PACKAGES=$(find . -maxdepth 3 -name "pubspec.yaml" | grep -v "\.dart_tool" | sed 's/\/pubspec.yaml//')

for pkg in $PACKAGES; do
  # Skip workspace root
  if [ "$pkg" = "." ]; then
    continue
  fi

  echo "--------------------------------------------------"
  echo "Running tests with coverage in: $pkg"
  echo "--------------------------------------------------"
  
  # Run tests in a subshell to avoid changing directory in parent process
  (
    cd "$pkg" || exit 1
    if [ -d "test" ]; then
      flutter test --coverage --exclude-tags integration
    else
      echo "No test directory found in $pkg, skipping."
    fi
  )

  # Check if coverage file was generated
  if [ -f "$pkg/coverage/lcov.info" ]; then
    echo "Processing coverage for $pkg..."
    
    # Format relative path cleanly (remove leading ./)
    clean_pkg=$(echo "$pkg" | sed 's/^\.\///')
    
    # Prefix source files (SF:) with package path and append to global lcov
    # e.g., SF:lib/some_file.dart -> SF:packages/flutter_kit_network/lib/some_file.dart
    sed "s|^SF:|SF:${clean_pkg}/|g" "$pkg/coverage/lcov.info" >> coverage/lcov.info
    
    echo "Appended $pkg coverage to root."
  else
    echo "No coverage found for $pkg."
  fi
done

echo "--------------------------------------------------"
echo "Combined coverage generated at: coverage/lcov.info"
echo "--------------------------------------------------"
