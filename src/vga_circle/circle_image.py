import numpy as np

width = 206
height = 150
center_x = width // 2
center_y = height // 2
radius = 60

with open('circle_image.coe', 'w') as f:
    f.write('memory_initialization_radix=16;\n')
    f.write('memory_initialization_vector=\n')
    
    for y in range(height):
        for x in range(width):
            distance = np.sqrt((x - center_x)**2 + (y - center_y)**2)
            
            # 12-bit RGB (4-bit R, 4-bit G, 4-bit B)
            if distance <= radius:
                # White pixel (FFF in hex)
                pixel_value = 0xFFF
            else:
                # Black pixel (000 in hex)
                pixel_value = 0x000
            
            # Format as a 3-character hex string
            hex_pixel = f'{pixel_value:03X}'
            
            if y == height-1 and x == width-1:
                f.write(f'{hex_pixel};')
            else:
                f.write(f'{hex_pixel},')
            
            if x == width-1:
                f.write('\n')
