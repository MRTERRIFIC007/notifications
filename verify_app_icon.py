#!/usr/bin/env python3
import os
import json
from PIL import Image

def verify_app_icon():
    """Verify that the app icon is properly set up."""
    icon_dir = "Notifications/Assets.xcassets/AppIcon.appiconset"
    
    # Check if the directory exists
    if not os.path.isdir(icon_dir):
        print("❌ App icon directory not found!")
        return False
    
    # Check if Contents.json exists
    contents_path = os.path.join(icon_dir, "Contents.json")
    if not os.path.isfile(contents_path):
        print("❌ Contents.json not found!")
        return False
    
    # Read Contents.json
    try:
        with open(contents_path, 'r') as f:
            contents = json.load(f)
    except Exception as e:
        print(f"❌ Error reading Contents.json: {e}")
        return False
    
    # Check if images are defined
    if 'images' not in contents:
        print("❌ No images defined in Contents.json!")
        return False
    
    # Check each image entry
    missing_files = []
    for image in contents['images']:
        if 'filename' in image:
            filename = image['filename']
            file_path = os.path.join(icon_dir, filename)
            
            if not os.path.isfile(file_path):
                missing_files.append(filename)
            else:
                # Verify the image can be opened
                try:
                    img = Image.open(file_path)
                    # Get the expected size from the image definition
                    expected_size = image['size'].split('x')
                    expected_width = int(expected_size[0]) * int(image['scale'].replace('x', ''))
                    expected_height = int(expected_size[1]) * int(image['scale'].replace('x', ''))
                    
                    # Check if the image size matches the expected size
                    if img.width != expected_width or img.height != expected_height:
                        print(f"⚠️ Size mismatch for {filename}: Expected {expected_width}x{expected_height}, got {img.width}x{img.height}")
                except Exception as e:
                    print(f"⚠️ Error opening {filename}: {e}")
    
    if missing_files:
        print(f"❌ Missing files: {', '.join(missing_files)}")
        return False
    
    # Check Info.plist
    info_plist_path = "Notifications/Info.plist"
    if not os.path.isfile(info_plist_path):
        print("⚠️ Info.plist not found!")
    else:
        # Simple check for AppIcon string in Info.plist
        with open(info_plist_path, 'r') as f:
            info_plist = f.read()
            if "AppIcon" not in info_plist:
                print("⚠️ AppIcon not referenced in Info.plist!")
    
    print("✅ App icon verification complete!")
    print(f"📱 Found {len(contents['images'])} icon images")
    print("🎉 Your app icon is ready to use!")
    return True

if __name__ == "__main__":
    verify_app_icon() 
 