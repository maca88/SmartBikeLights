using Toybox.Math;

// The source from this file was ported from: https://www.esrl.noaa.gov/gmd/grad/solcalc/main.js
// which is used for the NOAA Solar Calculator: https://www.esrl.noaa.gov/gmd/grad/solcalc/

function getJD(year, month, day) {
    if (month <= 2) {
        year -= 1;
        month += 12;
    }

    var a = Math.floor(year / 100);
    var b = 2 - a + Math.floor(a / 4);
    return Math.floor(365.25 * (year + 4716)) + Math.floor(30.6001 * (month + 1)) + day + b - 1524.5;
}

function calcSunriseSetUTC(rise, jd, latitude, longitude) {
    var t = (jd - 2451545.0) / 36525.0;
    var eqTime = calcEquationOfTime(t);
    var solarDec = calcSunDeclination(t);
    var hourAngle = calcHourAngleSunrise(latitude, solarDec);
    if (!rise) {
        hourAngle = -hourAngle;
    }

    var delta = longitude + radToDeg(hourAngle);
    return 720 - (4.0 * delta) - eqTime; // timeUTC in minutes
}

function calcEquationOfTime(t) {
    var epsilon = calcObliquityCorrection(t);
    var l0 = calcGeomMeanLongSun(t);
    var e = 0.016708634 - t * (0.000042037 + 0.0000001267 * t); // unitless
    var m = calcGeomMeanAnomalySun(t);

    var y = Math.tan(degToRad(epsilon)/2.0);
    y *= y;

    var sin2l0 = Math.sin(2.0 * degToRad(l0));
    var sinm   = Math.sin(degToRad(m));
    var cos2l0 = Math.cos(2.0 * degToRad(l0));
    var sin4l0 = Math.sin(4.0 * degToRad(l0));
    var sin2m  = Math.sin(2.0 * degToRad(m));

    var eTime = y * sin2l0 - 2.0 * e * sinm + 4.0 * e * y * sinm * cos2l0 - 0.5 * y * y * sin4l0 - 1.25 * e * e * sin2m;
    return radToDeg(eTime) * 4.0; // in minutes of time
}

function calcSunDeclination(t) {
    var e = calcObliquityCorrection(t);
    var lambda = calcSunApparentLong(t);
    var sint = Math.sin(degToRad(e)) * Math.sin(degToRad(lambda));
    return radToDeg(Math.asin(sint)); // in degrees
}

function calcHourAngleSunrise(lat, solarDec) {
    var latRad = degToRad(lat);
    var sdRad  = degToRad(solarDec);
    var haArg = (Math.cos(degToRad(90.833)) / (Math.cos(latRad) * Math.cos(sdRad)) - Math.tan(latRad) * Math.tan(sdRad));
    return Math.acos(haArg); // in radians (for sunset, use -HA)
}

function calcSunApparentLong(t) {
    var o = calcGeomMeanLongSun(t) + calcSunEqOfCenter(t); // in degrees
    var omega = 125.04 - 1934.136 * t;
    return o - 0.00569 - 0.00478 * Math.sin(degToRad(omega)); // in degrees
}

function calcSunEqOfCenter(t) {
    var m = calcGeomMeanAnomalySun(t);
    var mrad = degToRad(m);
    var sinm = Math.sin(mrad);
    var sin2m = Math.sin(mrad + mrad);
    var sin3m = Math.sin(mrad + mrad + mrad);
    return sinm * (1.914602 - t * (0.004817 + 0.000014 * t)) + sin2m * (0.019993 - 0.000101 * t) + sin3m * 0.000289; // in degrees
}

function calcObliquityCorrection(t) {
    var e0 = calcMeanObliquityOfEcliptic(t);
    var omega = 125.04 - 1934.136 * t;
    return e0 + 0.00256 * Math.cos(degToRad(omega)); // in degrees
}

function calcMeanObliquityOfEcliptic(t) {
    var seconds = 21.448 - t * (46.8150 + t * (0.00059 - t * 0.001813));
    return 23.0 + (26.0 + (seconds / 60.0)) / 60.0; // in degrees
}

function calcGeomMeanLongSun(t) {
    var L0 = 280.46646 + t * (36000.76983 + t * 0.0003032);
    while (L0 > 360.0) {
        L0 -= 360.0;
    }

    while (L0 < 0.0) {
        L0 += 360.0;
    }

    return L0; // in degrees
}

function calcGeomMeanAnomalySun(t) {
    return 357.52911 + t * (35999.05029 - 0.0001537 * t); // in degrees
}

function degToRad(angleDeg) {
    return Math.PI * angleDeg / 180.0;
}

function radToDeg(angleRad) {
    return 180.0 * angleRad / Math.PI;
}