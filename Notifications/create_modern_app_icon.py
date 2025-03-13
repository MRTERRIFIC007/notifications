#!/usr/bin/env python3
import os
import math
from PIL import Image, ImageDraw, ImageFont, ImageFilter

# Define icon sizes needed for iOS
ICON_SIZES = {
    # iPhone
    "iphone_20pt@2x.png": 40,
    "iphone_20pt@3x.png": 60,
    "iphone_29pt@2x.png": 58,
    "iphone_29pt@3x.png": 87,
    "iphone_40pt@2x.png": 80,
    "iphone_40pt@3x.png": 120,
    "iphone_60pt@2x.png": 120,
    "iphone_60pt@3x.png": 180,
    
    # iPad
    "ipad_20pt@1x.png": 20,
    "ipad_20pt@2x.png": 40,
    "ipad_29pt@1x.png": 29,
    "ipad_29pt@2x.png": 58,
    "ipad_40pt@1x.png": 40,
    "ipad_40pt@2x.png": 80,
    "ipad_76pt@1x.png": 76,
    "ipad_76pt@2x.png": 152,
    "ipad_83.5pt@2x.png": 167,
    
    # App Store
    "ios-marketing_1024pt@1x.png": 1024
}

def create_icon(size):
    """Create a modern vocabulary app icon with the given size."""
    # Create a new image with a solid background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Define colors
    primary_color = (52, 152, 219)  # Blue
    secondary_color = (155, 89, 182)  # Purple
    accent_color = (241, 196, 15)  # Yellow
    
    # Create a rounded rectangle background with gradient
    radius = size // 5
    
    # Draw background with gradient
    for y in range(size):
        # Calculate gradient color
        progress = y / size
        r = int(primary_color[0] * (1 - progress) + secondary_color[0] * progress)
        g = int(primary_color[1] * (1 - progress) + secondary_color[1] * progress)
        b = int(primary_color[2] * (1 - progress) + secondary_color[2] * progress)
        
        draw.line([(0, y), (size, y)], fill=(r, g, b))
    
    # Create a mask for rounded corners
    mask = Image.new('L', (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle([(0, 0), (size, size)], radius=radius, fill=255)
    
    # Apply the mask
    background = img.copy()
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    img.paste(background, (0, 0), mask)
    draw = ImageDraw.Draw(img)
    
    # Draw stacked cards effect
    card_margin = size // 10
    card_size = size - (2 * card_margin)
    card_offset = size // 20
    
    # Draw bottom card (slightly offset)
    draw.rounded_rectangle(
        [(card_margin + card_offset, card_margin + card_offset), 
         (card_margin + card_offset + card_size - card_offset, card_margin + card_offset + card_size - card_offset)],
        radius=radius // 2,
        fill=(255, 255, 255, 100)
    )
    
    # Draw middle card (slightly offset)
    draw.rounded_rectangle(
        [(card_margin + card_offset // 2, card_margin + card_offset // 2), 
         (card_margin + card_offset // 2 + card_size - card_offset // 2, card_margin + card_offset // 2 + card_size - card_offset // 2)],
        radius=radius // 2,
        fill=(255, 255, 255, 150)
    )
    
    # Draw top card
    draw.rounded_rectangle(
        [(card_margin, card_margin), 
         (card_margin + card_size, card_margin + card_size)],
        radius=radius // 2,
        fill=(255, 255, 255, 230)
    )
    
    # Draw a stylized "V" for Vocabulary
    # Calculate dimensions for the V
    v_width = int(card_size * 0.6)
    v_height = int(card_size * 0.6)
    v_thickness = max(2, size // 30)
    
    # Calculate center position
    center_x = card_margin + card_size // 2
    center_y = card_margin + card_size // 2
    
    # Draw the V
    points = [
        (center_x - v_width // 2, center_y - v_height // 2),  # Top left
        (center_x, center_y + v_height // 2),                 # Bottom center
        (center_x + v_width // 2, center_y - v_height // 2)   # Top right
    ]
    
    # Draw V with accent color
    draw.line([points[0], points[1]], fill=accent_color, width=v_thickness)
    draw.line([points[1], points[2]], fill=accent_color, width=v_thickness)
    
    # Add a dot above the V
    dot_radius = max(2, size // 25)
    dot_y_offset = v_height // 4
    draw.ellipse(
        [(center_x - dot_radius, center_y - v_height // 2 - dot_radius - dot_y_offset),
         (center_x + dot_radius, center_y - v_height // 2 + dot_radius - dot_y_offset)],
        fill=accent_color
    )
    
    # Add subtle shine effect
    shine_width = size // 3
    for i in range(shine_width):
        # Calculate opacity based on position
        opacity = int(200 * (1 - i / shine_width))
        # Draw diagonal line from top-left
        x1 = i
        y1 = 0
        x2 = 0
        y2 = i
        if x1 < size and y2 < size:
            draw.line([(x1, y1), (x2, y2)], fill=(255, 255, 255, opacity), width=1)
    
    return img

def update_contents_json(icon_dir):
    """Update the Contents.json file with the correct filenames."""
    contents_path = os.path.join(icon_dir, "Contents.json")
    
    # Read the existing Contents.json
    with open(contents_path, 'r') as f:
        contents = f.read()
    
    # Map of size strings to filename patterns
    size_to_filename = {
        # iPhone
        '"idiom" : "iphone", "scale" : "2x", "size" : "20x20"': 'iphone_20pt@2x.png',
        '"idiom" : "iphone", "scale" : "3x", "size" : "20x20"': 'iphone_20pt@3x.png',
        '"idiom" : "iphone", "scale" : "2x", "size" : "29x29"': 'iphone_29pt@2x.png',
        '"idiom" : "iphone", "scale" : "3x", "size" : "29x29"': 'iphone_29pt@3x.png',
        '"idiom" : "iphone", "scale" : "2x", "size" : "40x40"': 'iphone_40pt@2x.png',
        '"idiom" : "iphone", "scale" : "3x", "size" : "40x40"': 'iphone_40pt@3x.png',
        '"idiom" : "iphone", "scale" : "2x", "size" : "60x60"': 'iphone_60pt@2x.png',
        '"idiom" : "iphone", "scale" : "3x", "size" : "60x60"': 'iphone_60pt@3x.png',
        
        # iPad
        '"idiom" : "ipad", "scale" : "1x", "size" : "20x20"': 'ipad_20pt@1x.png',
        '"idiom" : "ipad", "scale" : "2x", "size" : "20x20"': 'ipad_20pt@2x.png',
        '"idiom" : "ipad", "scale" : "1x", "size" : "29x29"': 'ipad_29pt@1x.png',
        '"idiom" : "ipad", "scale" : "2x", "size" : "29x29"': 'ipad_29pt@2x.png',
        '"idiom" : "ipad", "scale" : "1x", "size" : "40x40"': 'ipad_40pt@1x.png',
        '"idiom" : "ipad", "scale" : "2x", "size" : "40x40"': 'ipad_40pt@2x.png',
        '"idiom" : "ipad", "scale" : "1x", "size" : "76x76"': 'ipad_76pt@1x.png',
        '"idiom" : "ipad", "scale" : "2x", "size" : "76x76"': 'ipad_76pt@2x.png',
        '"idiom" : "ipad", "scale" : "2x", "size" : "83.5x83.5"': 'ipad_83.5pt@2x.png',
        
        # App Store
        '"idiom" : "ios-marketing", "scale" : "1x", "size" : "1024x1024"': 'ios-marketing_1024pt@1x.png'
    }
    
    # Replace each occurrence with the filename
    for pattern, filename in size_to_filename.items():
        replacement = pattern + ',\n      "filename" : "' + filename + '"'
        contents = contents.replace(pattern, replacement)
    
    # Write the updated Contents.json
    with open(contents_path, 'w') as f:
        f.write(contents)

def main():
    # Directory for the app icon
    icon_dir = "Assets.xcassets/AppIcon.appiconset"
    
    # Create the directory if it doesn't exist
    os.makedirs(icon_dir, exist_ok=True)
    
    # Generate icons for all required sizes
    for filename, size in ICON_SIZES.items():
        print(f"Generating {filename} ({size}x{size})...")
        icon = create_icon(size)
        icon.save(os.path.join(icon_dir, filename))
    
    # Update Contents.json
    update_contents_json(icon_dir)
    
    print("Modern app icon generation complete!")

if __name__ == "__main__":
    main() 