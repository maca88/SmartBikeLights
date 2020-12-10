using Toybox.Lang;

(:noPolygons)
public function parsePolygons(chars, index, filterResult) {
    throw new Lang.Exception();
}

(:polygons)
public function parsePolygons(chars, index, filterResult) {
    filterResult[1] = null; /* Filter operator */
    // The first value represents the total number of polygons
    var data = new [parseNumber(chars, index, filterResult) * 8];
    var dataIndex = 0;
    index = filterResult[0] + 1;
    while (dataIndex < data.size()) {
        data[dataIndex] = parseNumber(chars, index, filterResult);
        dataIndex++;
        index = filterResult[0] + 1;
    }

    return data;
}

(:noPolygons)
public function isInsideAnyPolygon(activityInfo, filterValue) {
    throw new Lang.Exception();
}

(:polygons)
public function isInsideAnyPolygon(activityInfo, filterValue) {
    if (activityInfo.currentLocation == null) {
        return false;
    }

    var position = activityInfo.currentLocation.toDegrees();
    for (var i = 0; i < filterValue.size(); i += 8) {
        if ($.isPointInPolygon(position[1] /* Longitude */, position[0] /* Latitude  */, filterValue, i)) {
            return true;
        }
    }

    return false;
}

// Code ported from https://stackoverflow.com/a/14998816
(:polygons)
public function isPointInPolygon(x, y, points, index) {
    var result = false;
    var pointX;
    var lastPointX;
    var pointY;
    var lastPointY;
    var to = index + 8;
    var j = to - 2;
    for (var i = index; i < to; i += 2) {
        pointY = points[i];
        pointX = points[i + 1];
        lastPointY = points[j];
        lastPointX = points[j + 1];
        if (pointY < y && lastPointY >= y || lastPointY < y && pointY >= y)
        {
            if ((pointX + (y - pointY) / (lastPointY - pointY) * (lastPointX - pointX)) < x) {
                result = !result;
            }
        }

        j = i;
    }

    return result;
}