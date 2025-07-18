

import numpy as np

def create_circle_coe(width=640, height=480, radius=100, filename="/Users/songhaewon/Downloads/25-summar/circle_image.coe"):
    """
    Generates a .coe file for a black circle on a white background.
    Color format: 12-bit RGB (4-bit R, 4-bit G, 4-bit B).
    """
    # Define colors
    white = 0xFFF  # R=F, G=F, B=F
    black = 0x000  # R=0, G=0, B=0

    # Create an empty image with a white background
    image_data = np.full(height * width, white, dtype=np.int32)

    # Center of the image
    cx, cy = width // 2, height // 2

    # Draw the circle
    for y in range(height):
        for x in range(width):
            if (x - cx)**2 + (y - cy)**2 < radius**2:
                image_data[y * width + x] = black

    # Write to .coe file
    with open(filename, "w") as f:
        f.write("memory_initialization_radix=16;\n")
        f.write("memory_initialization_vector=\n")
        for i, pixel in enumerate(image_data):
            f.write(f"{pixel:03X}")
            if i == len(image_data) - 1:
                f.write(";")
            else:
                f.write(",\n")
    print(f"Successfully created '{filename}' with a circle image.")

if __name__ == "__main__":
    create_circle_coe()

