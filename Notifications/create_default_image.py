#!/usr/bin/env python3
from PIL import Image, ImageDraw, ImageFont
import os
import sys

def create_default_image(output_path, size=(300, 300)):
    """
    Create a simple default image with text 'No Image Available'
    """
    # Create a blank image with white background
    image = Image.new('RGB', size, color=(255, 255, 255))
    draw = ImageDraw.Draw(image)
    
    # Draw a border
    border_width = 2
    draw.rectangle(
        [(border_width, border_width), 
         (size[0] - border_width, size[1] - border_width)],
        outline=(200, 200, 200),
        width=border_width
    )
    
    # Add text
    try:
        # Try to use a system font
        font = ImageFont.truetype("Arial", 24)
    except IOError:
        # Fallback to default font
        font = ImageFont.load_default()
    
    text = "No Image Available"
    
    # Handle different Pillow versions for text size calculation
    try:
        # Newer Pillow versions
        text_bbox = font.getbbox(text)
        text_width = text_bbox[2] - text_bbox[0]
        text_height = text_bbox[3] - text_bbox[1]
    except AttributeError:
        try:
            # Older Pillow versions
            text_width, text_height = draw.textsize(text, font=font)
        except AttributeError:
            # Fallback
            text_width, text_height = 150, 24  # Approximate size
    
    # Center the text
    position = ((size[0] - text_width) // 2, (size[1] - text_height) // 2)
    
    # Draw the text
    draw.text(position, text, fill=(100, 100, 100), font=font)
    
    # Save the image
    image.save(output_path, 'PNG')
    print(f"Created default image at {output_path}")

def main():
    if len(sys.argv) != 2:
        print("Usage: python create_default_image.py <output_directory>")
        sys.exit(1)
    
    output_dir = sys.argv[1]
    
    if not os.path.isdir(output_dir):
        print(f"Error: {output_dir} is not a valid directory")
        sys.exit(1)
    
    output_path = os.path.join(output_dir, "default.png")
    create_default_image(output_path)

if __name__ == "__main__":
    main() 