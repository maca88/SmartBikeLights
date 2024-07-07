# How to create BM fonts:

## Battery:

1. Export with [FontBuilder](https://github.com/andryblack/fontbuilder/releases/tag/latest) by using 1px paddings, 72 DPI, Size 16/24/48, no smoothing, ForeceFreetypeAutohinting, box layout with power of two image
2. Add the missing line "chars count=7" after "page" line
3. Use GIMP to change the backgound color to black and replace the charge icon by pasting the SVG (GIMP does fo smoothing when pasting)
  - Before importing the charge icon to GIMP change the svg fill to white: `fill="#FFFFFF"`
4. Compress the final image with https://tinypng.com/

## Lights

1. Use [BMFont](https://www.angelcode.com/products/bmfont/) with:
- "Font smoothing", "TrueType hinting" and "Render from TrueType outline" enabled
- Zero paddings
- 1 spacings