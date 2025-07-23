# Block Memory Generator IP Configuration Guide

## Overview
This document describes how to configure the Block Memory Generator IP for the 2-player Tic-Tac-Toe game.

## IP Configuration Steps in Vivado

1. **Open IP Catalog**
   - In Vivado, go to IP Catalog
   - Search for "Block Memory Generator"
   - Double-click to open configuration

2. **Basic Settings**
   - Component Name: `blk_mem_gen_0`
   - Memory Type: **Single Port ROM**
   - Enable Port Type: **Always Enabled**

3. **Port A Options**
   - Write Width: 12
   - Read Width: 12
   - Write Depth: 68160
   - Read Depth: 68160
   - Operating Mode: Write First
   - Enable Port Type: Always Enabled

4. **Memory Initialization**
   - Load Init File: **Check this box**
   - COE File: Browse and select `dual_image.coe`
   - Fill Remaining Memory Locations: 0

5. **Important Address Configuration**
   - The IP will automatically calculate the address width
   - Should be **17 bits** for 68,160 locations
   - Verify: Address Width = ceil(log2(68160)) = 17

## Memory Layout
- Total Size: 68,160 pixels (12-bit each)
- Circle Image: Address 0x00000 - 0x084FF (34,080 pixels)
- X Image: Address 0x08500 - 0x109FF (34,080 pixels)

## Files to Delete
The following files are no longer needed and should be deleted:
- `circle_image.coe` (replaced by dual_image.coe)
- `circle_image_generator.py` (replaced by dual_image_generator.py)

## Verification
After IP generation, verify:
1. Check that `blk_mem_gen_0.v` has 17-bit address input
2. Ensure the data output is 12 bits wide
3. Confirm the COE file was loaded correctly

## Troubleshooting
If the Block Memory Generator doesn't accept 17-bit addresses:
1. Make sure Write/Read Depth is set to exactly 68160
2. Try regenerating the IP from scratch
3. Check that the COE file has exactly 68,160 entries