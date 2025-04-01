import os
import json
import time
import glob
from PIL import Image, ImageFilter, ImageEnhance, ImageChops, ImageDraw

BASE_DIR = "/home/baiken80/.config/scripts/"

def get_pywal_colors():
    cache_file = os.path.expanduser("~/.cache/wal/colors.json")
    try:
        with open(cache_file, 'r') as f:
            colors = json.load(f)
        return colors['colors']
    except FileNotFoundError:
        print("Pywal cache not found. Using default blue color.")
        return None

def cleanup_old_images(directory, prefix, keep=5):
    """Remove old image files, keeping only the most recent ones."""
    files = glob.glob(os.path.join(directory, f"{prefix}_*.png"))
    files.sort(key=os.path.getmtime, reverse=True)
    for old_file in files[keep:]:
        os.remove(old_file)
        print(f"Removed old file: {old_file}")

def create_neon_arch_logo(input_path, output_dir, output_size=(800, 1050)):
    # Get pywal colors
    pywal_colors = get_pywal_colors()
    main_color = pywal_colors['color11'] if pywal_colors else "#0064FF"
    highlight_color = pywal_colors['color14'] if pywal_colors else "#64AFFF"

    # Convert hex to RGB
    main_rgb = tuple(int(main_color.lstrip('#')[i:i+2], 16) for i in (0, 2, 4))
    highlight_rgb = tuple(int(highlight_color.lstrip('#')[i:i+2], 16) for i in (0, 2, 4))

    # Open the original image
    original = Image.open(input_path).convert("RGBA")
    
    # Create a new transparent image
    neon = Image.new("RGBA", original.size, (0, 0, 0, 0))
    
    # Create the greatly enhanced neon glow
    base_glow = original.filter(ImageFilter.GaussianBlur(35))
    neon_glow = ImageChops.multiply(base_glow, Image.new("RGBA", base_glow.size, main_rgb + (255,)))
    neon_glow = ImageEnhance.Brightness(neon_glow).enhance(4.2)
    
    # Apply the neon glow multiple times
    for _ in range(9):
        neon = Image.alpha_composite(neon, neon_glow)
    
    # Create the core (glass tube effect)
    core = original.filter(ImageFilter.GaussianBlur(2))
    neon_core = ImageChops.multiply(core, Image.new("RGBA", core.size, highlight_rgb + (255,)))
    neon_core = ImageEnhance.Brightness(neon_core).enhance(2.5)
    
    # Composite the glow and core
    neon = Image.alpha_composite(neon, neon_core)
    
    # Add highlights to simulate glass reflection
    highlight = Image.new("RGBA", original.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(highlight)
    mask = original.split()[3]
    mask = mask.filter(ImageFilter.GaussianBlur(1))
    draw.bitmap((0, 0), mask, fill=highlight_rgb + (40,))
    highlight = highlight.filter(ImageFilter.GaussianBlur(1))
    
    # Composite the highlight
    neon = Image.alpha_composite(neon, highlight)
    
    # Enhance the overall brightness and contrast
    neon = ImageEnhance.Brightness(neon).enhance(1.35)
    neon = ImageEnhance.Contrast(neon).enhance(1.45)
    
    # Resize and position as before
    width_ratio = output_size[0] / neon.width
    height_ratio = output_size[1] / neon.height
    resize_ratio = min(width_ratio, height_ratio)
    new_size = (int(neon.width * resize_ratio), int(neon.height * resize_ratio))
    neon = neon.resize(new_size, Image.LANCZOS)
    final_image = Image.new("RGBA", output_size, (0, 0, 0, 0))
    paste_position = ((output_size[0] - neon.width) // 2, (output_size[1] - neon.height) // 2)
    final_image.paste(neon, paste_position, neon)
    
    # Save the result with a unique filename
    os.makedirs(output_dir, exist_ok=True)
    timestamp = int(time.time())
    output_filename = f"archlogo_{timestamp}.png"
    output_path = os.path.join(output_dir, output_filename)
    final_image.save(output_path, "PNG")
    print(f"Image saved to: {output_path}")
    
    # Create or update a symlink named 'archlogo_latest.png' pointing to the new file
    symlink_path = os.path.join(output_dir, "archlogo_latest.png")
    try:
        os.symlink(output_path, symlink_path)
    except FileExistsError:
        os.remove(symlink_path)
        os.symlink(output_path, symlink_path)
    print(f"Symlink created/updated: {symlink_path}")
    
    # Cleanup old images
    cleanup_old_images(output_dir, "archlogo", keep=5)

# Use the function
input_path = "/home/baiken80/.config/scripts/archlogo.png"  # Adjust this if your input file is in a different location
output_dir = "/home/baiken80/wallpaper/logo/"

create_neon_arch_logo(input_path, output_dir)
