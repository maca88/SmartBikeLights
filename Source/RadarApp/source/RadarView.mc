import Toybox.Activity;
import Toybox.Lang;
import Toybox.AntPlus;
import Toybox.Time;
import Toybox.WatchUi;

class BikeLightNetworkListener extends AntPlus.LightNetworkListener {
    private var _eventHandler;

    function initialize(eventHandler) {
        LightNetworkListener.initialize();
        _eventHandler = eventHandler.weak();
    }

    function onLightNetworkStateUpdate(state) {
        _eventHandler.get().onNetworkStateUpdate(state);
    }

    function onBikeLightUpdate(light) {
    }
}

class RadarListener extends AntPlus.BikeRadarListener {
    private var _eventHandler;

    function initialize(eventHandler) {
        BikeRadarListener.initialize();
        _eventHandler = eventHandler.weak();
    }

    function onBikeRadarUpdate(targets) {
        _eventHandler.get().onBikeRadarUpdate(targets);
    }
}

const lightMode = 6; /* Night Flash */

class RadarView extends WatchUi.View {

    private var _bikeRadar;
    private var _lightNetwork;
    private var _radarListener;
    private var _lightListener;
    private var _lastPlayToneTime = 0;
    private var _lastOnUpdateCall = 0;
    private var _lastLightModeSetTime = 0;
    private var _totalVehicles = 0;
    private var _minTargetDistance = null;
    private var _showBatteryTime = 10000;
    private var _timer;
    private var _lightNetworkState = AntPlus.LIGHT_NETWORK_STATE_NOT_FORMED;

    function initialize() {
        View.initialize();
        _radarListener = new RadarListener(self);
        _lightListener = new BikeLightNetworkListener(self);
    }

    function onShow() {
        _lightNetwork = null;
        _bikeRadar = null;
        _lightNetwork = new AntPlus.LightNetwork(_lightListener);
        _bikeRadar = new AntPlus.BikeRadar(_radarListener);
        if (_timer == null) {
            _timer = new Timer.Timer();
            _timer.start(method(:requestUiUpdate) as Method() as Void, 1000, true);
        }
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
        if (_timer != null) {
            _timer.stop();
            _timer = null;
        }

        _lightNetwork = null;
        _bikeRadar = null;
    }

    function requestUiUpdate() {
        WatchUi.requestUpdate();
    }

    // Called by the system and its main purpuse is to draw elements to the screen
    function onUpdate(dc) {
        var timer = System.getTimer();
        var lastOnUpdateCall = _lastOnUpdateCall;
        _lastOnUpdateCall = timer;

        var radarNotConnected = _lightNetworkState != AntPlus.LIGHT_NETWORK_STATE_FORMED;
        var bgColor = radarNotConnected ? Graphics.COLOR_DK_GRAY // Gray background if the radar is not connected
            : _totalVehicles > 0 ? Graphics.COLOR_YELLOW // Yellow background if more than one vehicle is approaching
            : Graphics.COLOR_WHITE;
        var fgColor = Graphics.COLOR_BLACK;
        if (bgColor == Graphics.COLOR_BLACK) {
            fgColor = Graphics.COLOR_WHITE;
        }

        dc.setColor(fgColor, bgColor);
        dc.clear();

        if (radarNotConnected) {
            return;
        }

        // Make sure that the light is in the correct mode
        var lights = _lightNetwork.getBikeLights();
        if (lights != null && lights.size() > 0 && (timer - _lastLightModeSetTime) > 5000) {
            var light = lights[0];
            if (light.mode != lightMode) {
                light.setMode(lightMode);
                _lastLightModeSetTime = timer;
            }
        }

        // Show the battery at startup
        var batteryStatus = _bikeRadar.getBatteryStatus(null);
        if (_showBatteryTime > 0 && batteryStatus != null) {
            drawBattery(dc, fgColor, bgColor, batteryStatus.batteryStatus);
            var diff = timer - lastOnUpdateCall;
            _showBatteryTime -= (diff > 2000 ? 0 : diff);
            return;
        }

        var text = _totalVehicles == 0
            ? ""
            : _totalVehicles.toString() + " / " + _minTargetDistance.format("%.f") + "m";

        dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2, Graphics.FONT_LARGE, text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // Called everytime a target (vehicle) is updated (e.g. speed, distance, threat)
    function onBikeRadarUpdate(targets) {
        var totalVehicles = 0;
        var minTargetDistance = null;
        for (var i = 0; i < targets.size(); i++) {
            // https://developer.garmin.com/connect-iq/api-docs/Toybox/AntPlus/RadarTarget.html
            var target = targets[i];
            // Count only vehicles that are actually approaching
            if (target.threat <= AntPlus.THREAT_LEVEL_NO_THREAT) {
                continue;
            }

            totalVehicles++;
            if (minTargetDistance == null || target.range < minTargetDistance) {
                minTargetDistance = target.range;
            }
        }

        _totalVehicles = totalVehicles;
        _minTargetDistance = minTargetDistance;
        // Play a tone in case more than one vehicle is approaching and the last tone was played more than two seconds ago
        if (_totalVehicles > 0 && (System.getTimer() - _lastPlayToneTime) > 2000) {
            // https://developer.garmin.com/connect-iq/api-docs/Toybox/Attention.html#Tone-module
            Attention.playTone(Attention.TONE_ALERT_HI);
            _lastPlayToneTime = System.getTimer();
        }
    }

    function onNetworkStateUpdate(state) {
        _lightNetworkState = state;
    }

    private function drawBattery(dc, fgColor, bgColor, batteryStatus) {
        var batteryWidth = 72;
        var batteryHeight = batteryWidth / 2;
        var barWidth = batteryWidth / 5 - 2;
        var barHeight = batteryHeight - 7;
        var topHeight = batteryHeight - batteryHeight / 3;
        var x = (dc.getWidth() / 2) - batteryWidth / 2;
        var y = dc.getHeight() / 2;
        var color = batteryStatus == 5 /* BATT_STATUS_CRITICAL */ ? 0xFF0000 /* COLOR_RED */
            : batteryStatus > 2 /* BATT_STATUS_GOOD */ ? 0xFF5500 /* COLOR_ORANGE */
            : 0x00AA00; /* COLOR_DK_GREEN */
        dc.setPenWidth(2);
        dc.drawRectangle(x, y, batteryWidth + 3, batteryHeight);
        dc.drawRectangle(x + batteryWidth + 2, y + batteryHeight / 6, batteryHeight / 4, topHeight);
        dc.setColor(color, bgColor);

        for (var i = 0; i < (6 - batteryStatus); i++) {
            dc.fillRectangle(x + 3 + (barWidth + 2) * i, y + 3, barWidth, barHeight);
        }

        dc.setColor(fgColor, bgColor);
    }
}