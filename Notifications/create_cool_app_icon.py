#!/usr/bin/env python3
import os
import math
from PIL import Image, ImageDraw, ImageFilter

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
    """Create a cool vocabulary app icon with the given size."""
    # Create a new image with a solid background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Define colors - more subdued palette
    primary_color = (41, 128, 185)  # Darker blue
    secondary_color = (142, 68, 173)  # Darker purple
    accent_color = (230, 126, 34)  # Subdued orange
    
    # Create a rounded rectangle background with gradient
    radius = size // 5
    
    # Draw background with gradient - more subtle
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
    
    # Add a subtle texture
    for i in range(0, size, max(2, size // 40)):
        opacity = int(10 + (i / size) * 20)  # Very subtle
        draw.line([(0, i), (size, i)], fill=(255, 255, 255, opacity), width=1)
    
    # Draw stacked cards effect
    card_margin = size // 10
    card_size = size - (2 * card_margin)
    card_offset = size // 20
    
    # Draw bottom card (slightly offset)
    draw.rounded_rectangle(
        [(card_margin + card_offset, card_margin + card_offset), 
         (card_margin + card_offset + card_size - card_offset, card_margin + card_offset + card_size - card_offset)],
        radius=radius // 2,
        fill=(255, 255, 255, 80)  # More transparent
    )
    
    # Draw middle card (slightly offset)
    draw.rounded_rectangle(
        [(card_margin + card_offset // 2, card_margin + card_offset // 2), 
         (card_margin + card_offset // 2 + card_size - card_offset // 2, card_margin + card_offset // 2 + card_size - card_offset // 2)],
        radius=radius // 2,
        fill=(255, 255, 255, 120)  # More transparent
    )
    
    # Draw top card
    draw.rounded_rectangle(
        [(card_margin, card_margin), 
         (card_margin + card_size, card_margin + card_size)],
        radius=radius // 2,
        fill=(255, 255, 255, 200)  # More transparent
    )
    
    # Draw a brain symbol instead of "V"
    center_x = card_margin + card_size // 2
    center_y = card_margin + card_size // 2
    
    # Size of the brain symbol
    symbol_size = int(card_size * 0.6)
    half_size = symbol_size // 2
    
    # Draw the brain outline
    brain_color = accent_color
    line_width = max(2, size // 40)
    
    # Draw the main brain shape
    # Left hemisphere
    left_x = center_x - half_size // 3
    draw.arc(
        [(left_x - half_size, center_y - half_size), 
         (left_x + half_size, center_y + half_size)],
        start=180, end=0, fill=brain_color, width=line_width
    )
    
    # Right hemisphere
    right_x = center_x + half_size // 3
    draw.arc(
        [(right_x - half_size, center_y - half_size), 
         (right_x + half_size, center_y + half_size)],
        start=180, end=0, fill=brain_color, width=line_width
    )
    
    # Connect the hemispheres at the top
    draw.line(
        [(left_x, center_y - half_size), (right_x, center_y - half_size)],
        fill=brain_color, width=line_width
    )
    
    # Add some brain folds (simplified)
    # Left hemisphere folds
    fold_length = half_size // 2
    for i in range(3):
        y_offset = -half_size // 2 + i * (half_size // 2)
        draw.arc(
            [(left_x - fold_length, center_y + y_offset - fold_length // 2),
             (left_x + fold_length, center_y + y_offset + fold_length // 2)],
            start=180, end=0, fill=brain_color, width=line_width
        )
    
    # Right hemisphere folds
    for i in range(3):
        y_offset = -half_size // 2 + i * (half_size // 2)
        draw.arc(
            [(right_x - fold_length, center_y + y_offset - fold_length // 2),
             (right_x + fold_length, center_y + y_offset + fold_length // 2)],
            start=180, end=0, fill=brain_color, width=line_width
        )
    
    # Add a subtle shadow effect
    shadow = img.copy()
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=size//50))
    shadow_img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow_img)
    shadow_draw.rounded_rectangle(
        [(0, 0), (size, size)],
        radius=radius,
        fill=(0, 0, 0, 30)  # Very subtle shadow
    )
    
    # Composite the final image
    final_img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    final_img.paste(shadow_img, (0, size//50), shadow_img)
    final_img.paste(img, (0, 0), img)
    
    return final_img

def create_contents_json(icon_dir):
    """Create a new Contents.json file with the correct filenames."""
    contents = {
        "images": [
            {
                "idiom": "iphone",
                "scale": "2x",
                "size": "20x20",
                "filename": "iphone_20pt@2x.png"
            },
            {
                "idiom": "iphone",
                "scale": "3x",
                "size": "20x20",
                "filename": "iphone_20pt@3x.png"
            },
            {
                "idiom": "iphone",
                "scale": "2x",
                "size": "29x29",
                "filename": "iphone_29pt@2x.png"
            },
            {
                "idiom": "iphone",
                "scale": "3x",
                "size": "29x29",
                "filename": "iphone_29pt@3x.png"
            },
            {
                "idiom": "iphone",
                "scale": "2x",
                "size": "40x40",
                "filename": "iphone_40pt@2x.png"
            },
            {
                "idiom": "iphone",
                "scale": "3x",
                "size": "40x40",
                "filename": "iphone_40pt@3x.png"
            },
            {
                "idiom": "iphone",
                "scale": "2x",
                "size": "60x60",
                "filename": "iphone_60pt@2x.png"
            },
            {
                "idiom": "iphone",
                "scale": "3x",
                "size": "60x60",
                "filename": "iphone_60pt@3x.png"
            },
            {
                "idiom": "ipad",
                "scale": "1x",
                "size": "20x20",
                "filename": "ipad_20pt@1x.png"
            },
            {
                "idiom": "ipad",
                "scale": "2x",
                "size": "20x20",
                "filename": "ipad_20pt@2x.png"
            },
            {
                "idiom": "ipad",
                "scale": "1x",
                "size": "29x29",
                "filename": "ipad_29pt@1x.png"
            },
            {
                "idiom": "ipad",
                "scale": "2x",
                "size": "29x29",
                "filename": "ipad_29pt@2x.png"
            },
            {
                "idiom": "ipad",
                "scale": "1x",
                "size": "40x40",
                "filename": "ipad_40pt@1x.png"
            },
            {
                "idiom": "ipad",
                "scale": "2x",
                "size": "40x40",
                "filename": "ipad_40pt@2x.png"
            },
            {
                "idiom": "ipad",
                "scale": "1x",
                "size": "76x76",
                "filename": "ipad_76pt@1x.png"
            },
            {
                "idiom": "ipad",
                "scale": "2x",
                "size": "76x76",
                "filename": "ipad_76pt@2x.png"
            },
            {
                "idiom": "ipad",
                "scale": "2x",
                "size": "83.5x83.5",
                "filename": "ipad_83.5pt@2x.png"
            },
            {
                "idiom": "ios-marketing",
                "scale": "1x",
                "size": "1024x1024",
                "filename": "ios-marketing_1024pt@1x.png"
            }
        ],
        "info": {
            "author": "xcode",
            "version": 1
        }
    }
    
    import json
    with open(os.path.join(icon_dir, "Contents.json"), 'w') as f:
        json.dump(contents, f, indent=2)

def main():
    # Directory for the app icon
    icon_dir = "Notifications/Assets.xcassets/AppIcon.appiconset"
    
    # Create the directory if it doesn't exist
    os.makedirs(icon_dir, exist_ok=True)
    
    # Generate icons for all required sizes
    for filename, size in ICON_SIZES.items():
        print(f"Generating {filename} ({size}x{size})...")
        icon = create_icon(size)
        icon.save(os.path.join(icon_dir, filename))
    
    # Create Contents.json
    create_contents_json(icon_dir)
    
    print("Cool app icon generation complete!")

if __name__ == "__main__":
    main() 