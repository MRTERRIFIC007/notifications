#!/usr/bin/env ruby
require 'xcodeproj'

# Open the project
project_path = 'Notifications.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find the main app target and widget target
app_target = project.targets.find { |t| t.name == 'Notifications' }
widget_target = project.targets.find { |t| t.name == 'WordWidget' }

# Function to add UIKit framework to a target if it's missing
def ensure_uikit_framework(target)
  return if target.nil?
  
  # Check if UIKit is already added
  frameworks_build_phase = target.frameworks_build_phase
  uikit_file_ref = nil
  
  # Look for UIKit in existing frameworks
  has_uikit = frameworks_build_phase.files.any? do |build_file|
    next if build_file.file_ref.nil?
    build_file.file_ref.path == 'UIKit.framework'
  end
  
  # If UIKit is not found, add it
  unless has_uikit
    puts "Adding UIKit framework to target: #{target.name}"
    
    # Find or create UIKit framework reference
    uikit_file_ref = target.project.frameworks_group.files.find { |file| file.path == 'UIKit.framework' }
    
    if uikit_file_ref.nil?
      uikit_file_ref = target.project.frameworks_group.new_reference('UIKit.framework', :sdk_root)
      uikit_file_ref.name = 'UIKit.framework'
      uikit_file_ref.source_tree = 'SDKROOT'
    end
    
    # Add framework to target
    frameworks_build_phase.add_file_reference(uikit_file_ref)
  else
    puts "UIKit framework already exists in target: #{target.name}"
  end
end

# Add UIKit to both targets
ensure_uikit_framework(app_target)
ensure_uikit_framework(widget_target)

# Save the project
project.save
puts "Project saved successfully!"
