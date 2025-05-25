import Toybox.Activity;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;

class SunsetDataFieldView extends WatchUi.SimpleDataField {

    private var _todayMoment;
    private var _sunsetTime;
    private var _sunriseTime;

    function initialize() {
        SimpleDataField.initialize();
        label = "Sunset";
        // In order to avoid calling Gregorian.utcInfo every second, calcualate Unix Timestamp of today
        var now = Time.now();
        var time = Gregorian.utcInfo(now, Time.FORMAT_SHORT);
        _todayMoment = now.value() - ((time.hour * 3600) + (time.min * 60) + time.sec);
    }


    function compute(activityInfo as Activity.Info) {
        var value = (Time.now().value() - _todayMoment) % 86400;
        if (_sunsetTime == null && activityInfo.currentLocation != null) {
            var position = activityInfo.currentLocation.toDegrees();
            var time = Gregorian.utcInfo(Time.now(), Time.FORMAT_SHORT);
            _sunriseTime = getSunriseSet(true, time, position);
            _sunsetTime = getSunriseSet(false, time, position);
        }

        return value;
    }

    // The below source code was ported from: https://www.esrl.noaa.gov/gmd/grad/solcalc/main.js
    // which is used for the NOAA Solar Calculator: https://www.esrl.noaa.gov/gmd/grad/solcalc/
    protected function getSunriseSet(rise, time, position) {
        var month = time.month;
        var year = time.year;
        if (month <= 2) {
            year -= 1;
            month += 12;
        }

        var a = Math.floor(year / 100);
        var b = 2 - a + Math.floor(a / 4);
        var jd = Math.floor(365.25 * (year + 4716)) + Math.floor(30.6001 * (month + 1)) + time.day + b - 1524.5;
        var t = (jd - 2451545.0) / 36525.0;
        var omega = degToRad(125.04 - 1934.136 * t);
        var l1 = 280.46646 + t * (36000.76983 + t * 0.0003032);
        while (l1 > 360.0) {
            l1 -= 360.0;
        }

        while (l1 < 0.0) {
            l1 += 360.0;
        }

        var l0 = degToRad(l1);
        var e = 0.016708634 - t * (0.000042037 + 0.0000001267 * t); // unitless
        var mrad = degToRad(357.52911 + t * (35999.05029 - 0.0001537 * t));
        var ec = degToRad((23.0 + (26.0 + ((21.448 - t * (46.8150 + t * (0.00059 - t * 0.001813))) / 60.0)) / 60.0) + 0.00256 * Math.cos(omega));
        var y = Math.tan(ec/2.0);
        y *= y;
        var sinm = Math.sin(mrad);
        var eqTime = (180.0 * (y * Math.sin(2.0 * l0) - 2.0 * e * sinm + 4.0 * e * y * sinm * Math.cos(2.0 * l0) - 0.5 * y * y * Math.sin(4.0 * l0) - 1.25 * e * e * Math.sin(2.0 * mrad)) / 3.141593) * 4.0; // in minutes of time
        var sunEq = sinm * (1.914602 - t * (0.004817 + 0.000014 * t)) + Math.sin(mrad + mrad) * (0.019993 - 0.000101 * t) + Math.sin(mrad + mrad + mrad) * 0.000289; // in degrees
        var latRad = degToRad(position[0].toFloat() /* latitude */);
        var sdRad  = degToRad(180.0 * (Math.asin(Math.sin(ec) * Math.sin(degToRad((l1 + sunEq) - 0.00569 - 0.00478 * Math.sin(omega))))) / 3.141593);
        var hourAngle = Math.acos((Math.cos(degToRad(90.833)) / (Math.cos(latRad) * Math.cos(sdRad)) - Math.tan(latRad) * Math.tan(sdRad))); // in radians (for sunset, use -HA)
        if (!rise) {
            hourAngle = -hourAngle;
        }

        return getSecondsOfDay((720 - (4.0 * (position[1].toFloat() /* longitude */ + (180.0 * hourAngle / 3.141593))) - eqTime) * 60); // timeUTC in seconds
    }

    private function getSecondsOfDay(value) {
        value = value.toNumber();
        return value == null ? null : (value < 0 ? value + 86400 : value) % 86400;
    }

    private function degToRad(angleDeg) {
        return 3.141593 * angleDeg / 180.0;
    }
}