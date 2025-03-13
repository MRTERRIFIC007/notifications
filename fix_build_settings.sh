#!/bin/bash

# This script will fix the build settings to avoid the "Multiple commands produce" error

# Find the project.pbxproj file
PROJECT_FILE="Notifications.xcodeproj/project.pbxproj"

# Create a backup
cp "$PROJECT_FILE" "$PROJECT_FILE.backup"

# Use sed to modify the build settings
# This will ensure that each target only processes its own resources
sed -i '' 's/COPY_PHASE_STRIP = NO;/COPY_PHASE_STRIP = NO; SKIP_INSTALL = YES;/g' "$PROJECT_FILE"
sed -i '' 's/ALWAYS_SEARCH_USER_PATHS = NO;/ALWAYS_SEARCH_USER_PATHS = NO; SKIP_INSTALL = YES;/g' "$PROJECT_FILE"

echo "Build settings updated successfully!"
