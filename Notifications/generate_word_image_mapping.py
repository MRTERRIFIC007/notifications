#!/usr/bin/env python3
import os
import json
import sys

def generate_word_image_mapping(images_dir):
    """
    Generate a JSON mapping between words and their image filenames.
    """
    mapping = {}
    
    # Get all PNG files in the directory
    image_files = [f for f in os.listdir(images_dir) if f.endswith('.png')]
    
    # Create mapping
    for image_file in image_files:
        # Extract word from filename (remove .png extension)
        word = os.path.splitext(image_file)[0]
        
        # Skip default image
        if word == 'default':
            continue
            
        # Add to mapping
        mapping[word] = image_file
    
    return mapping

def main():
    if len(sys.argv) != 2:
        print("Usage: python generate_word_image_mapping.py <images_directory>")
        sys.exit(1)
    
    images_dir = sys.argv[1]
    
    if not os.path.isdir(images_dir):
        print(f"Error: {images_dir} is not a valid directory")
        sys.exit(1)
    
    # Generate mapping
    mapping = generate_word_image_mapping(images_dir)
    
    # Write to JSON file
    output_file = "word_image_mapping.json"
    with open(output_file, 'w') as f:
        json.dump(mapping, f, indent=2)
    
    print(f"Generated mapping for {len(mapping)} words in {output_file}")

if __name__ == "__main__":
    main() 