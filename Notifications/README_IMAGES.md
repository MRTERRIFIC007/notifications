# Word Images Integration Guide

This document explains how to integrate and use the word images feature in the app.

## Overview

The app now supports displaying images for words in the Flash Cards feature. Each word can have an associated image that will be displayed on the flash card.

## Image Requirements

- Images should be in PNG format
- Image filenames should match the word they represent (e.g., "apple.png" for the word "apple")
- A default image named "default.png" is used when a specific word image is not found

## How to Add Images

1. Place all your word images in a directory (e.g., `/Users/mrterrific/Downloads/images/`)
2. Run the provided scripts to generate the necessary files:

```bash
# Generate the word-image mapping JSON file
python3 Notifications/generate_word_image_mapping.py /path/to/your/images

# Create a default image if you don't have one
python3 Notifications/create_default_image.py /path/to/your/images

# Copy the images to the asset catalog
python3 Notifications/copy_images_to_assets.py /path/to/your/images Notifications/Assets.xcassets
```

3. Make sure the `word_image_mapping.json` file is included in your Xcode project

## How It Works

1. The `WordImageManager` class loads the word-image mapping from the JSON file
2. When a word is displayed in the Flash Cards feature, the manager looks up the corresponding image
3. If an image is found, it is displayed; otherwise, the default image is shown

## Using the WordImageManager in Your Code

```swift
// Get an image for a word
let image = WordImageManager.shared.getImage(for: "apple")

// Check if a word has an image
let hasImage = WordImageManager.shared.hasImage(for: "apple")

// Using the Word extension
let word = Word(word: "apple", meaning: "A fruit")
let image = word.image
let hasImage = word.hasImage
```

## Troubleshooting

- If images are not displaying, check that the `word_image_mapping.json` file is included in your Xcode project
- Verify that the images are properly added to the asset catalog
- Check the console for any error messages from the `WordImageManager`

## Performance Considerations

- The app loads all image mappings at startup, but only loads the actual images when needed
- For large image collections, consider implementing pagination or lazy loading
