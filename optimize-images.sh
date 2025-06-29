#!/bin/bash

# Image Optimization Script for Lindy GEO Website
# This script optimizes images for web performance
# Requires: ImageMagick (convert) or webp tools

echo "🖼️  Starting image optimization for Lindy GEO website..."

# Create optimized directory if it doesn't exist
mkdir -p optimized

# Function to optimize PNG to WebP
optimize_png_to_webp() {
    local input=$1
    local output_name=$(basename "$input" .png)
    
    if command -v cwebp &> /dev/null; then
        echo "Converting $input to WebP..."
        cwebp -q 85 -m 6 "$input" -o "optimized/${output_name}.webp"
    elif command -v convert &> /dev/null; then
        echo "Converting $input to WebP using ImageMagick..."
        convert "$input" -quality 85 -define webp:method=6 "optimized/${output_name}.webp"
    else
        echo "⚠️  No WebP conversion tool found. Copying original..."
        cp "$input" "optimized/"
    fi
}

# Function to optimize JPG to WebP
optimize_jpg_to_webp() {
    local input=$1
    local output_name=$(basename "$input" .jpg)
    
    if command -v cwebp &> /dev/null; then
        echo "Converting $input to WebP..."
        cwebp -q 80 -m 6 "$input" -o "optimized/${output_name}.webp"
    elif command -v convert &> /dev/null; then
        echo "Converting $input to WebP using ImageMagick..."
        convert "$input" -quality 80 -define webp:method=6 "optimized/${output_name}.webp"
    else
        echo "⚠️  No WebP conversion tool found. Copying original..."
        cp "$input" "optimized/"
    fi
}

# Function to create responsive versions
create_responsive_versions() {
    local input=$1
    local output_name=$(basename "$input" | cut -d. -f1)
    local extension="${input##*.}"
    
    if command -v convert &> /dev/null; then
        echo "Creating responsive versions for $input..."
        # Create different sizes for responsive images
        convert "$input" -resize 1920x1080^ -quality 85 "optimized/${output_name}-1920w.${extension}"
        convert "$input" -resize 1280x720^ -quality 85 "optimized/${output_name}-1280w.${extension}"
        convert "$input" -resize 768x432^ -quality 85 "optimized/${output_name}-768w.${extension}"
        convert "$input" -resize 480x270^ -quality 85 "optimized/${output_name}-480w.${extension}"
    else
        echo "⚠️  ImageMagick not found. Cannot create responsive versions."
    fi
}

# Function to optimize favicon
optimize_favicon() {
    if command -v convert &> /dev/null; then
        echo "Optimizing favicon..."
        # Create proper favicon sizes
        convert "favicon.png" -resize 32x32 "optimized/favicon-32x32.png"
        convert "favicon.png" -resize 16x16 "optimized/favicon-16x16.png"
        convert "favicon.png" -resize 180x180 "optimized/apple-touch-icon.png"
        convert "favicon.png" -resize 192x192 "optimized/android-chrome-192x192.png"
        convert "favicon.png" -resize 512x512 "optimized/android-chrome-512x512.png"
    else
        echo "⚠️  Cannot optimize favicon without ImageMagick"
    fi
}

# Optimize main images
echo "📸 Optimizing main images..."

# Large images that need optimization
large_images=("GENAI.jpg" "genaibg.jpg" "GEOKING.jpg" "howtogetcitedbyai.jpg" "abstract-expressionism-thumb.jpg")

for img in "${large_images[@]}"; do
    if [ -f "$img" ]; then
        echo "Processing $img..."
        optimize_jpg_to_webp "$img"
        create_responsive_versions "$img"
    fi
done

# Optimize PNG images
png_images=("lindygeo.png" "lindygeot.png")

for img in "${png_images[@]}"; do
    if [ -f "$img" ]; then
        echo "Processing $img..."
        optimize_png_to_webp "$img"
        create_responsive_versions "$img"
    fi
done

# Optimize favicon
if [ -f "favicon.png" ]; then
    optimize_favicon
fi

echo "✅ Image optimization complete!"
echo "📊 Original vs Optimized sizes:"
echo "Original images:"
du -h *.jpg *.png 2>/dev/null | sort -hr

if [ -d "optimized" ]; then
    echo "Optimized images:"
    du -h optimized/* 2>/dev/null | sort -hr
fi

echo ""
echo "🔧 To use optimized images:"
echo "1. Install ImageMagick: brew install imagemagick"
echo "2. Install WebP tools: brew install webp"
echo "3. Run this script: ./optimize-images.sh"
echo "4. Update HTML to use responsive images and WebP format" 