// <GlobalFilters>#<HeadlightModes>#<HeadlightFilters>#<TaillightModes>#<TaillightFilters>
public function parseConfiguration(value) {
    if (value == null || value.length() == 0) {
        return new [7];
    }

    var filterResult = [0 /* next index */, 0 /* operator type */];
    var chars = value.toCharArray();
    return [
        parseFilters(chars, 0, false, filterResult),                      // Global filter
        parseLong(chars, filterResult[0] + 1, filterResult),              // Headlight modes
        parseFilters(chars, filterResult[0] + 1, true, filterResult),     // Headlight filters
        parseLong(chars, filterResult[0] + 1, filterResult),              // Taillight modes
        parseFilters(chars, filterResult[0] + 1, true, filterResult),     // Taillight filters
        parseLightButtons(chars, filterResult[0] + 1, filterResult),      // Headlight panel/settings buttons
        parseLightButtons(chars, filterResult[0] + 1, filterResult)       // Taillight panel/settings buttons
    ];
}

(:noLightButtons)
public function parseLightButtons(chars, i, filterResult) {
    return null;
}

// <TotalButtons>:<LightName>|[<Button>| ...]
// <Button> := <ModeTitle>:<LightMode>
// Example: 6:Ion Pro RT|Off:0|High:1|Medium:2|Low:5|Night Flash:62|Day Flash:63
(:settings)
public function parseLightButtons(chars, i, filterResult) {
    var totalButtons = parseNumber(chars, i, filterResult);
    if (totalButtons == null) {
        return null;
    }

    var data = new [1 + (2 * totalButtons)];
    data[0] = parseTitle(chars, filterResult[0] + 1, filterResult);
    i = filterResult[0];
    var dataIndex = 1;

    for (var j = 0; j < totalButtons; j++) {
        data[dataIndex] = parseTitle(chars, filterResult[0] + 1, filterResult);
        data[dataIndex + 1] = parseNumber(chars, filterResult[0] + 1, filterResult);
        dataIndex += 2;
    }

    return data;
}

// <TotalButtons>,<TotalButtonGroups>:<LightName>|[<ButtonGroup>| ...]
// <ButtonGroup> := <ButtonsNumber>,[<Button>, ...]
// <Button> := <ModeTitle>:<LightMode>
// Example: 7,6:Ion Pro RT|2,:-1,Off:0|1,High:1|1,Medium:2|1,Low:5|1,Night Flash:62|1,Day Flash:63
(:touchScreen)
public function parseLightButtons(chars, i, filterResult) {
    var totalButtons = parseNumber(chars, i, filterResult);
    if (totalButtons == null) {
        return null;
    }

    var totalButtonGroups = parseNumber(chars, filterResult[0] + 1, filterResult);
    // [:TotalButtonGroups:, :LightName:, :LightNameX:, :LightNameY:, :BatteryX:, :BatteryY:, (<ButtonGroup>)+]
    // <ButtonGroup> := [:NumberOfButtons:, :Mode:, :TitleX:, :TitleFont:, (<TitlePart>)+, :ButtonLeftX:, :ButtonTopY:, :ButtonWidth:, :ButtonHeight:){:NumberOfButtons:} ]
    // <TitlePart> := [(:Title:, :TitleY:)+]
    var data = new [6 + (8 * totalButtons) + totalButtonGroups];
    data[0] = totalButtonGroups;
    data[1] = parseTitle(chars, filterResult[0] + 1, filterResult);
    i = filterResult[0];
    var dataIndex = 6;

    while (i < chars.size()) {
        var char = chars[i];
        if (char == '#') {
            break;
        }

        if (char == '|') {
            var numberOfButtons = parseNumber(chars, filterResult[0] + 1, filterResult); // Number of buttons in the group
            data[dataIndex] = numberOfButtons;
            dataIndex++;
            for (var j = 0; j < numberOfButtons; j++) {
                data[dataIndex + 1] = parseTitle(chars, filterResult[0] + 1, filterResult); // Will be transformed to titleX later
                data[dataIndex] = parseNumber(chars, filterResult[0] + 1, filterResult);
                dataIndex += 8;
            }

            i = filterResult[0];
        } else {
            return null;
        }
    }

    return data;
}

// <TotalFilters>,<TotalGroups>|[<FilterGroup>| ...]
// <FilterGroup> := <GroupName>:<FiltersNumber>(?:<LightMode>)[<Filter>, ...]
// <Filter> := <FilterType><FilterOperator><FilterValue>
public function parseFilters(chars, i, lightMode, filterResult) {
    var totalFilters = parseNumber(chars, i, filterResult);
    if (totalFilters == null) {
        return null;
    }

    var groupDataLength = lightMode ? 3 : 2;
    var totalGroups = parseNumber(chars, filterResult[0] + 1, filterResult);
    var data = new [(totalFilters * 3) + totalGroups * groupDataLength];
    i = filterResult[0];
    var dataIndex = 0;

    while (i < chars.size()) {
        var charNumber = chars[i].toNumber();
        if (charNumber == 35 /* # */) {
            break;
        }

        if (charNumber == 124 /* | */) {
            data[dataIndex] = parseTitle(chars, i + 1, filterResult); // Group title
            data[dataIndex + 1] = parseNumber(chars, filterResult[0] + 1, filterResult); // Number of filters in the group
            if (lightMode) {
                data[dataIndex + 2] = parseNumber(chars, filterResult[0] + 1 /* Skip : */, filterResult); // The light mode id
            }

            dataIndex += groupDataLength;
            i = filterResult[0];
        } else if (charNumber >= 65 /* A */ && charNumber <= 90 /* Z */) {
            var filterValue = charNumber == 70 /* F */ ? parsePolygons(chars, i + 1, filterResult)
                : charNumber == 69 /* E */ ? parseTimespan(chars, i + 1, filterResult)
                : parseGenericFilter(chars, i + 1, filterResult);

            data[dataIndex] = chars[i]; // Filter type
            data[dataIndex + 1] = filterResult[1]; // Filter operator
            data[dataIndex + 2] = filterValue; // Filter value
            dataIndex += 3;
            i = filterResult[0];
        } else {
            i++;
        }
    }

    return data;
}

// E<?FromType><FromValue>,<?ToType><ToValue> (Es45,r-45 E35645,8212)
public function parseTimespan(chars, index, filterResult) {
    var data = new [4];
    filterResult[1] = null; /* Filter operator */
    parseTimespanPart(chars, index, filterResult, data, 0);
    parseTimespanPart(chars, filterResult[0] + 1 /* Skip , */, filterResult, data, 2);

    return data;
}

public function parseGenericFilter(chars, index, filterResult) {
    filterResult[1] = chars[index]; // Filter operator

    return parseNumber(chars, index + 1, filterResult);
}

public function parseTimespanPart(chars, index, filterResult, data, dataIndex) {
    var char = chars[index];
    var type = char == 's' ? 2 /* Sunset */
        : char == 'r' ? 1 /* Sunrise */
        : 0; /* Total minutes of the day */
    if (type != 0) {
        index++;
    }

    data[dataIndex] = type;
    data[dataIndex + 1] = parseNumber(chars, index, filterResult);
}

public function parseLong(chars, index, resultIndex) {
    var left = parseNumber(chars, index, resultIndex);
    if (left == null) {
        return null;
    }

    var right = parseNumber(chars, resultIndex[0] + 1, resultIndex);
    return (left.toLong() << 32) | right;
}

public function parseNumber(chars, index, resultIndex) {
    var stringValue = null;
    var i;
    var isFloat = false;
    for (i = index; i < chars.size(); i++) {
        var char = chars[i];
        var charNumber = char.toNumber();
        if (charNumber == 46 /* . */) {
            isFloat = true;
        } else if (charNumber != 45 /* - */ && (charNumber > 57 /* 9 */ || charNumber < 48 /* 0 */)) {
            break;
        }

        stringValue = stringValue == null ? char.toString() : stringValue + char;
    }

    resultIndex[0] = i;
    return stringValue == null ? null
        : isFloat ? stringValue.toFloat()
        : stringValue.toNumber();
}

public function parseTitle(chars, index, resultIndex) {
    var stringValue = null;
    var i;
    for (i = index; i < chars.size(); i++) {
        var char = chars[i];
        if (char == ':' || char == '|') {
            break;
        }

        stringValue = stringValue == null ? char.toString() : stringValue + char;
    }

    resultIndex[0] = i;
    return stringValue;
}