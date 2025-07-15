import numpy as np

size = 146
center = size // 2  # 73
radius = 60

with open('circle_image.coe', 'w') as f:
    f.write('memory_initialization_radix=2;\n')
    f.write('memory_initialization_vector=\n')
    
    for y in range(size):
        for x in range(size):
            distance = np.sqrt((x - center)**2 + (y - center)**2)
            pixel = '1' if distance <= radius else '0'
            
            if y == size-1 and x == size-1:
                f.write(f'{pixel};')
            else:
                f.write(f'{pixel},')
            
            if x == size-1:
                f.write('\n')