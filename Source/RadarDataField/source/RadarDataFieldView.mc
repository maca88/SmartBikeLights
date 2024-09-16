import Toybox.Activity;
import Toybox.Lang;
import Toybox.AntPlus;
import Toybox.Time;
import Toybox.WatchUi;

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


class RadarDataFieldView extends WatchUi.DataField {

    private var _bikeRadar;
    private var _listener;
    private var _lastPlayToneTime = 0;

    private var _totalVehicles = 0;

    function initialize() {
        DataField.initialize();
        _listener = new RadarListener(self);
        _bikeRadar = new AntPlus.BikeRadar(_listener);
    }

    // Called by the system and its main purpuse is to draw elements to the screen
    function onUpdate(dc) {
        // Make background yellow in case more than one vehicle is approaching
        var bgColor = _totalVehicles > 0 ? Graphics.COLOR_YELLOW : getBackgroundColor();
        var fgColor = Graphics.COLOR_BLACK;
        if (bgColor == Graphics.COLOR_BLACK) {
            fgColor = Graphics.COLOR_WHITE;
        }

        dc.setColor(fgColor, bgColor);
        dc.clear();
    }

    // Called everytime a target (vehicle) is updated (e.g. speed, distance, threat)
    function onBikeRadarUpdate(targets) {
        var totalVehicles = 0;
        for (var i = 0; i < targets.size(); i++) {
            // https://developer.garmin.com/connect-iq/api-docs/Toybox/AntPlus/RadarTarget.html
            var target = targets[i];
            // Count only vehicles that are actually approaching
            if (target.threat > AntPlus.THREAT_LEVEL_NO_THREAT) {
                totalVehicles++;
            }
        }

        _totalVehicles = totalVehicles;
        // Play a tone in case more than one vehicle is approaching and the last tone was played more than two seconds ago
        if (_totalVehicles > 0 && (System.getTimer() - _lastPlayToneTime) > 2000) {
            // https://developer.garmin.com/connect-iq/api-docs/Toybox/Attention.html#Tone-module
            Attention.playTone(Attention.TONE_ALERT_HI);
            _lastPlayToneTime = System.getTimer();
        }
    }
}