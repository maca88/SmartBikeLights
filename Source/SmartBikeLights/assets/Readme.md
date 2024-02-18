# How to create BM fonts:

## Battery:

1. Export with [FontBuilder](https://github.com/andryblack/fontbuilder/releases/tag/latest) by using 1px paddings, 72 DPI, Size 16/24/48, no smoothing, ForeceFreetypeAutohinting
2. Add the missing line "chars count=7" after "page" line
3. Use GIMP to change the backgound color to black and replace the charge icon by pasting the SVG (GIMP does fo smoothing when pasting)
4. Compress the final image with https://tinypng.com/

## Lights

1. Use [BMFont](https://www.angelcode.com/products/bmfont/) with "Font smoothing", "Clear type" enabled and zero paddings/spacings