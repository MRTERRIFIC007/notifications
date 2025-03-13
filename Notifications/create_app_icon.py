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
    """Create a vocabulary app icon with the given size."""
    # Create a new image with a gradient background
    img = Image.new('RGBA', (size, size), (255, 255, 255, 0))
    draw = ImageDraw.Draw(img)
    
    # Create a gradient background
    for y in range(size):
        # Gradient from blue to purple
        r = int(50 + (y / size) * 100)
        g = int(100 + (y / size) * 50)
        b = int(200 - (y / size) * 50)
        draw.line([(0, y), (size, y)], fill=(r, g, b))
    
    # Add a subtle pattern
    for i in range(0, size, 20):
        opacity = int(40 + (i / size) * 60)
        draw.line([(0, i), (size, i)], fill=(255, 255, 255, opacity), width=2)
    
    # Calculate dimensions for the card
    card_margin = size // 10
    card_width = size - (2 * card_margin)
    card_height = int(card_width * 0.7)  # 7:10 aspect ratio for the card
    
    # Draw a white card with shadow effect
    # First draw a blurred black rectangle for shadow
    shadow = Image.new('RGBA', (card_width, card_height), (0, 0, 0, 100))
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=size//30))
    img.paste(shadow, (card_margin + size//60, card_margin + size//30), shadow)
    
    # Draw the white card
    draw.rounded_rectangle(
        [(card_margin, card_margin), 
         (card_margin + card_width, card_margin + card_height)],
        radius=size//20,
        fill=(255, 255, 255, 230)
    )
    
    # Add a "W" letter for "Words" or "Vocabulary"
    try:
        # Try to load a font, fallback to default if not available
        font_size = size // 3
        font = ImageFont.truetype("Arial Bold.ttf", font_size)
    except IOError:
        # Use default font if custom font not available
        font_size = size // 4
        font = ImageFont.load_default()
    
    # Draw the "W" in the center of the card
    w_text = "W"
    
    # Use the newer method for getting text size
    if hasattr(font, "getbbox"):
        bbox = font.getbbox(w_text)
        w_width = bbox[2] - bbox[0]
        w_height = bbox[3] - bbox[1]
    else:
        # Fallback for older Pillow versions
        w_width, w_height = draw.textsize(w_text, font=font) if hasattr(draw, "textsize") else (font_size, font_size)
    
    w_position = (
        card_margin + (card_width - w_width) // 2,
        card_margin + (card_height - w_height) // 2
    )
    
    # Draw with a gradient color
    for i in range(font_size):
        y_pos = w_position[1] + i
        progress = i / font_size
        r = int(50 + progress * 150)
        g = int(50 + progress * 100)
        b = int(150 + progress * 50)
        draw.text((w_position[0], y_pos), w_text, font=font, fill=(r, g, b))
    
    # Add some decorative elements - small cards or flash cards in the background
    small_card_size = size // 6
    for i in range(3):
        angle = 30 * (i - 1)  # -30, 0, 30 degrees
        small_card = Image.new('RGBA', (small_card_size, small_card_size), (255, 255, 255, 180))
        small_card = small_card.rotate(angle, expand=True)
        
        # Position the small cards around the main card
        x_offset = size // 2 - small_card.width // 2
        y_offset = size - small_card.height - card_margin // 2
        
        img.paste(small_card, (x_offset, y_offset), small_card)
    
    # Add a subtle border to the entire icon
    draw.rounded_rectangle(
        [(0, 0), (size-1, size-1)],
        radius=size//10,
        outline=(255, 255, 255, 100),
        width=max(1, size//100)
    )
    
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
    
    print("App icon generation complete!")

if __name__ == "__main__":
    main() 