#!/usr/bin/env python3
"""
Generate circle and X images COE file for FPGA Block RAM
Each image size: 213x160 pixels
Total memory: 68,160 pixels (2 images)
"""

def generate_circle_pixels(width=213, height=160, radius=50):
    """Generate pixel data for a circle"""
    pixels = []
    center_x = width // 2
    center_y = height // 2
    
    for y in range(height):
        for x in range(width):
            dx = x - center_x
            dy = y - center_y
            distance_squared = dx * dx + dy * dy
            
            if distance_squared <= radius * radius:
                pixels.append("FFF")  # White pixel (will be colored green in hardware)
            else:
                pixels.append("000")  # Transparent
    
    return pixels

def generate_x_pixels(width=213, height=160, thickness=8):
    """Generate pixel data for an X shape"""
    pixels = []
    center_x = width // 2
    center_y = height // 2
    
    # X should fit in same area as circle (diameter ~100 pixels)
    x_size = 50  # Half size from center, same as circle radius
    
    for y in range(height):
        for x in range(width):
            # Calculate relative position from center
            rel_x = x - center_x
            rel_y = y - center_y
            
            # Check if pixel is on either diagonal of the X
            # Using line equations: y = x and y = -x
            on_diagonal1 = abs(rel_y - rel_x) < thickness
            on_diagonal2 = abs(rel_y + rel_x) < thickness
            
            # Check if within X bounds
            within_bounds = (abs(rel_x) <= x_size) and (abs(rel_y) <= x_size)
            
            if within_bounds and (on_diagonal1 or on_diagonal2):
                pixels.append("FFF")  # White pixel (will be colored red in hardware)
            else:
                pixels.append("000")  # Transparent
    
    return pixels

def generate_dual_image_coe(width=213, height=160):
    """Generate COE file with both circle and X images"""
    lines = []
    lines.append("memory_initialization_radix=16;")
    lines.append("memory_initialization_vector=")
    
    # Generate circle pixels (first image)
    circle_pixels = generate_circle_pixels(width, height)
    
    # Generate X pixels (second image)
    x_pixels = generate_x_pixels(width, height)
    
    # Combine both images
    all_pixels = circle_pixels + x_pixels
    
    # Write all pixels to COE format
    for i, pixel in enumerate(all_pixels):
        if i == len(all_pixels) - 1:
            lines.append(pixel + ";")
        else:
            lines.append(pixel + ",")
    
    return lines

if __name__ == "__main__":
    # Generate the combined COE file
    coe_data = generate_dual_image_coe()
    
    # Write to file
    with open("dual_image.coe", "w") as f:
        for line in coe_data:
            f.write(line + "\n")
    
    print(f"Generated dual_image.coe with {len(coe_data)-2} pixels")
    print(f"Total size: 68,160 pixels (2 images of 213x160 each)")
    print(f"Circle image: addresses 0x00000 - 0x084FF")
    print(f"X image: addresses 0x08500 - 0x109FF")