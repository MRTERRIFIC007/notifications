#!/usr/bin/env python3
import os
import json
import shutil
import sys

def create_image_asset(image_name, source_dir, assets_dir):
    """
    Create an image asset for a single image.
    """
    # Create the imageset directory
    imageset_dir = os.path.join(assets_dir, f"{image_name}.imageset")
    os.makedirs(imageset_dir, exist_ok=True)
    
    # Create the Contents.json file
    contents = {
        "images": [
            {
                "idiom": "universal",
                "filename": f"{image_name}.png",
                "scale": "1x"
            },
            {
                "idiom": "universal",
                "scale": "2x"
            },
            {
                "idiom": "universal",
                "scale": "3x"
            }
        ],
        "info": {
            "version": 1,
            "author": "xcode"
        }
    }
    
    with open(os.path.join(imageset_dir, "Contents.json"), "w") as f:
        json.dump(contents, f, indent=2)
    
    # Copy the image file
    source_file = os.path.join(source_dir, f"{image_name}.png")
    dest_file = os.path.join(imageset_dir, f"{image_name}.png")
    
    if os.path.exists(source_file):
        shutil.copy2(source_file, dest_file)
        return True
    else:
        print(f"Warning: Source file {source_file} does not exist")
        return False

def main():
    if len(sys.argv) != 3:
        print("Usage: python copy_images_to_assets.py <source_images_dir> <assets_dir>")
        sys.exit(1)
    
    source_dir = sys.argv[1]
    assets_dir = sys.argv[2]
    
    if not os.path.isdir(source_dir):
        print(f"Error: {source_dir} is not a valid directory")
        sys.exit(1)
    
    if not os.path.isdir(assets_dir):
        print(f"Error: {assets_dir} is not a valid directory")
        sys.exit(1)
    
    # Load the word-image mapping
    mapping_file = "word_image_mapping.json"
    if not os.path.exists(mapping_file):
        print(f"Error: {mapping_file} does not exist. Run generate_word_image_mapping.py first.")
        sys.exit(1)
    
    with open(mapping_file, "r") as f:
        mapping = json.load(f)
    
    # Create a default image if it doesn't exist
    default_source = os.path.join(source_dir, "default.png")
    if not os.path.exists(default_source):
        print("Warning: No default image found. Using a placeholder.")
        # Create a simple placeholder image or copy an existing one
        # For simplicity, we'll just use the first image as default
        first_image = list(mapping.values())[0] if mapping else None
        if first_image:
            shutil.copy2(os.path.join(source_dir, first_image), default_source)
    
    # Create the default image asset
    create_image_asset("default", source_dir, assets_dir)
    
    # Create image assets for each word
    success_count = 0
    for word, image_file in mapping.items():
        image_name = os.path.splitext(image_file)[0]
        if create_image_asset(image_name, source_dir, assets_dir):
            success_count += 1
    
    print(f"Successfully copied {success_count} of {len(mapping)} images to assets catalog")

if __name__ == "__main__":
    main() 