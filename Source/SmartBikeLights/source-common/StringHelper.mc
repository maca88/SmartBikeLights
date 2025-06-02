(:touchScreen)
module StringHelper {

    public function getTextStack(text, maxHeight) {
        var stack = [];
        var totalLines = 1;
        var newLineIndex = text.find("\\n");
        while (newLineIndex != null) {
            totalLines++;
            stack.add([text.substring(0, newLineIndex), maxHeight]);
            text = text.substring(newLineIndex + 2, text.length());
            newLineIndex = text.find("\\n");
            if (newLineIndex == null) {
                stack.add([text, maxHeight]);
            }
        }

        if (stack.size() > 0) {
            for (var i = 0; i < stack.size(); i++) {
                stack[i][1] = stack[i][1] / totalLines; // update max height
            }
        } else {
            stack.add([text, maxHeight]);
        }

        return stack;
    }

    public function trimText(dc, stack, maxFont, maxWidth, fontTopPaddings, fontResult) {
        // 1. Check whether the text width is lower that the max
        //  1.a if not, check whether text can be displayed in two rows
        //    1.a.0 if not, lower the font and goto 1.
        //    1.a.1 if yes, split the text by the last space and goto 1. to check both splits
        //  1.b if yes, check whether the text height is lower that the max
        //    1.b.0 if not, lower the font and goto 1.
        //    1.b.1 if yes, return the result
        var result = [];
        var fontTopPadding = getFontTopPadding(maxFont, fontTopPaddings);
        while (stack.size() > 0) {
            var item = stack[0];
            var text = item[0];
            var maxHeight = item[1];
            var dim = dc.getTextDimensions(text, maxFont);
            if (dim[0] <= maxWidth && (dim[1] - fontTopPadding) <= maxHeight) {
                result.add(text);
                stack = stack.slice(1, null);
                continue;
            } else if (dim[0] > maxWidth) {
                var splitIndex = getTextSplitIndex(text.toCharArray());
                if (((dim[1] * 2) - fontTopPadding) <= maxHeight && splitIndex > 0) {
                  stack = stack.slice(1, null);
                  stack.add([text.substring(0, splitIndex), maxHeight / 2]);
                  stack.add([text.substring(splitIndex + 1, text.length()), maxHeight / 2]);
                  continue;
                }
            }

            if (maxFont == 0) {
                result.add(trimTextByWidth(dc, text, 0, maxWidth));
                stack = stack.slice(1, null);
            } else {
                maxFont--;
                fontTopPadding = getFontTopPadding(maxFont, fontTopPaddings);
            }
        }

        fontResult[0] = maxFont;

        return result;
    }

    public function getTextSplitIndex(chars) {
        var halfLength = chars.size() / 2;
        // Find the space index that is closest to halfLength
        var index = getLastSpaceIndex(chars, chars.size());
        var lastIndex;
        while (index > 0) {
            lastIndex = index;
            index = getLastSpaceIndex(chars, index);
            if ((halfLength - lastIndex).abs() < (halfLength - index).abs()) {
                return lastIndex;
            }
        }

        return index;
    }

    public function trimTextByWidth(dc, text, font, maxWidth) {
        if (text == null) {
            return null;
        }

        var width = dc.getTextWidthInPixels(text, font);
        while (width <= maxWidth) {
            return text; // Early exit
        }

        var chars = text.toCharArray();
        var index = getLastSpaceIndex(chars, text.length());
        while (width > maxWidth) {
            if (index < 0) {
                text = text.substring(0, text.length() - 1);
            } else {
                text = text.substring(0, index);
                index = getLastSpaceIndex(chars, index);
            }

            width = dc.getTextWidthInPixels(text, font);
        }

        return text;
    }

    public function getLastSpaceIndex(chars, startIndex) {
        for (var i = startIndex - 1; i >= 0; i--) {
            if (chars[i] == ' ') {
                return i;
            }
        }

        return -1;
    }

    public function getFontTopPadding(font, fontTopPaddings) {
        return ((fontTopPaddings >> (font * 7)) & 0x7F).toNumber();
    }
}