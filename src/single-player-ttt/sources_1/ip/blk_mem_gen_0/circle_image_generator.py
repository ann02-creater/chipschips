#!/usr/bin/env python3
"""
Generate a circle image COE file for FPGA Block RAM
Image size: 213x160 pixels
Circle: centered, with radius appropriate for clear visibility
"""

def generate_circle_coe(width=213, height=160, radius=50):
    """
    Generate COE file data for a circle image
    """
    # Calculate center of the image
    center_x = width // 2
    center_y = height // 2
    
    # Generate header
    lines = []
    lines.append("memory_initialization_radix=16;")
    lines.append("memory_initialization_vector=")
    
    # Generate pixel data
    for y in range(height):
        for x in range(width):
            # Calculate distance from center
            dx = x - center_x
            dy = y - center_y
            distance_squared = dx * dx + dy * dy
            
            # Check if pixel is inside circle
            if distance_squared <= radius * radius:
                # Inside circle - white pixel (FFF)
                pixel = "FFF"
            else:
                # Outside circle - black/transparent (000)
                pixel = "000"
            
            # Add pixel to output
            if y == height - 1 and x == width - 1:
                # Last pixel - no comma
                lines.append(pixel + ";")
            else:
                lines.append(pixel + ",")
    
    return lines

# Generate the COE file
if __name__ == "__main__":
    # Use radius of 50 pixels for a circle that's clearly visible but not too large
    # This gives a circle diameter of 100 pixels in a 213x160 cell
    coe_data = generate_circle_coe(radius=50)
    
    # Write to file
    with open("circle_image.coe", "w") as f:
        for line in coe_data:
            f.write(line + "\n")
    
    print(f"Generated circle_image.coe with {len(coe_data)-2} pixels")
    print(f"Image size: 213x160")
    print(f"Circle radius: 50 pixels")
    print(f"Circle diameter: 100 pixels")