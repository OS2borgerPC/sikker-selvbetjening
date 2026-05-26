#!/bin/bash
set -e

# Verify we're running from the root repository directory
if [ ! -d "features" ] || [ ! -d "system_files" ] || [ ! -d "build_files" ]; then
    echo "❌ Error: Run this script from the repository root (sikker-selvbetjening/)."
    exit 1
fi

echo "🚀 Populating feature folders from legacy system_files and build_files..."
echo "------------------------------------------------------------"

# Find all files inside the features directory
find features -type f | while read -r target_file; do
    
    # Match 1: The file belongs under a 'system_files' marker
    if [[ "$target_file" == *"system_files"* ]]; then
        rel_path="${target_file#*system_files/}"
        source_file="system_files/$rel_path"
        
        if [ -f "$source_file" ]; then
            echo "📄 File content -> $target_file"
            cp "$source_file" "$target_file"
        else
            echo "⚠️  Warning: Missing legacy system file -> $source_file"
        fi

    # Match 2: The file belongs under a 'build_files' marker
    elif [[ "$target_file" == *"build_files"* ]]; then
        rel_path="${target_file#*build_files/}"
        source_file="build_files/$rel_path"
        
        if [ -f "$source_file" ]; then
            echo "⚙️  Build script -> $target_file"
            cp "$source_file" "$target_file"
        else
            echo "⚠️  Warning: Missing legacy build file -> $source_file"
        fi
    fi
done

echo "------------------------------------------------------------"
echo "🎉 Done! All your empty placeholders are now replaced with real contents."