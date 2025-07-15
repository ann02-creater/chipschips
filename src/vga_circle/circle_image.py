# Image specifications
width = 213
height = 160
center_x = 106
center_y = 80
radius = 40

# Color values in hex (12-bit RGB: 4-bit R, 4-bit G, 4-bit B)
WHITE = 0xFFF  # Background color
GREEN = 0x0F0  # Circle color

with open('circle_image.coe', 'w') as f:
    f.write('memory_initialization_radix=16;\n')
    f.write('memory_initialization_vector=\n')
    
    for y in range(height):
        for x in range(width):
            # Calculate distance from center using circle equation
            distance_squared = (x - center_x)**2 + (y - center_y)**2
            
            # Check if pixel is inside the circle using (x-cx)² + (y-cy)² ≤ r²
            if distance_squared <= radius**2:
                # Green pixel for circle
                pixel_value = GREEN
            else:
                # White pixel for background
                pixel_value = WHITE
            
            # Format as a 3-character hex string
            hex_pixel = f'{pixel_value:03X}'
            
            # Add comma after each pixel except the last one
            if y == height-1 and x == width-1:
                f.write(f'{hex_pixel};')
            else:
                f.write(f'{hex_pixel},')
            
            # Add newline at the end of each row
            if x == width-1:
                f.write('\n')
