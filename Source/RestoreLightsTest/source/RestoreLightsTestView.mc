using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.AntPlus;

class BikeLightNetworkListener extends AntPlus.LightNetworkListener {
    private var _eventHandler;

    function initialize(eventHandler) {
        LightNetworkListener.initialize();
        _eventHandler = eventHandler.weak();
    }

    function onLightNetworkStateUpdate(state) {
        if (_eventHandler.stillAlive()) {
            _eventHandler.get().onNetworkStateUpdate(state);
        }
    }

    function onBikeLightUpdate(light) {
        if (_eventHandler.stillAlive()) {
            _eventHandler.get().onLightUpdate(light);
        }
    }
}

var timeout = 10; // 10 seconds

class RestoreLightsTestView extends WatchUi.DataField {
    private var _lightNetworkListener;
    private var _lightNetwork;
    private var _text = "Please wait...";
    private var _lightNetworkModes = {};
    private var _networkModesInitialized = false;
    private var _networkModesTimeout = 2;
    private var _state = 0;
    private var _restoreTimeout;

    function initialize() {
        DataField.initialize();
        _lightNetworkListener = new BikeLightNetworkListener(self);
        _lightNetwork = new AntPlus.LightNetwork(_lightNetworkListener);
    }

    function onLayout(dc) {
    }

    function compute(activityInfo) {
        if (_state == 2 /* Timer started */) {
            if (_networkModesTimeout == 0 && findAndStoreLightModes()) {
                System.println("Lights were turned on. lightModes=" + _lightNetworkModes + " timer=" + System.getTimer());
                _networkModesInitialized = true;
                turnOffLights();
            } else {
                _networkModesTimeout--;
            }

            return;
        }

        if (_state != 4 /* Restoring lights */) {
            return;
        }

        // Check whether the light modes were restored to the original modes
        if (areLightsRestored()) {
            _state = 5; /* Successful restore */
            _text = "Successful restore, stop timer";
            System.println("Successful restore timer=" + System.getTimer());
            return;
        }

        _restoreTimeout--;
        if (_restoreTimeout <= 0) {
            _state = 6;
            _text = "Restore failed";
            System.println(_text + " timer=" + System.getTimer());
        }
    }
    
    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc) {
        var bgColor = getBackgroundColor();
        var fgColor = Graphics.COLOR_BLACK;
        if (bgColor == Graphics.COLOR_BLACK) {
            fgColor = Graphics.COLOR_WHITE;
        }

        dc.setColor(fgColor, bgColor);
        dc.clear();

        var height = dc.getHeight();
        var width = dc.getWidth();
        dc.drawText(width / 2, height / 2, 2, _text, 1 /* TEXT_JUSTIFY_CENTER */ | 4 /* TEXT_JUSTIFY_VCENTER */);
    }

    function onTimerStart() {
        System.println("Timer started timer=" + System.getTimer());
        if (_networkModesInitialized) {
            turnOffLights();
        } else {
            // The first time we have to wait the light network to setup the light modes
            _state = 2; /* Timer started */
            _text = "Please wait...";
            System.println("Waiting for the lights to be turned on... timer=" + System.getTimer());
        }
    }

    function onTimerStop() {
        System.println("Timer stopped timer=" + System.getTimer());
        if (_state == 5 /* Successful restore */) {
            // Reset the state to start again
            _state = 1; /* Network formed */
            _text = "Start timer again";
        }
    }

    function onNetworkStateUpdate(networkState) {
        if (_state > 0 || networkState != 2 /* LIGHT_NETWORK_STATE_FORMED */) {
            return;
        }

        System.println("Network formed timer=" + System.getTimer());
        _state = 1; /* Network formed */
        _text = "Start timer";
    }

    function onLightUpdate(light) {
        System.println("Light update id=" + light.identifier + " type=" + light.type + " mode=" + light.mode + " timer=" + System.getTimer());
        if (_state == 3 /* Turning light off */ && areLightsTurnedOff()) {
            System.println("Lights were turned off timer=" + System.getTimer());
            restoreLights();
        }
    }

    private function turnOffLights() {
        _state = 3; /* Turning light off */
        _text = "Turning lights off...";
        System.println(_text + " timer=" + System.getTimer());
        var lights = _lightNetwork.getBikeLights();
        for (var i = 0; i < lights.size(); i++) {
            var light = lights[i];
            light.setMode(0);
        }
    }

    private function findAndStoreLightModes() {
        var lights = _lightNetwork.getBikeLights();
        for (var i = 0; i < lights.size(); i++) {
            var light = lights[i];
            if (light.mode != 0 && !_lightNetworkModes.hasKey(light.identifier)) {
                // Save the light mode set by the network in order to check later whether the modes were restored
                _lightNetworkModes.put(light.identifier, light.mode);
            }
        }

        return lights.size() == _lightNetworkModes.size();
    }

    private function areLightsRestored() {
        var lights = _lightNetwork.getBikeLights();
        for (var i = 0; i < lights.size(); i++) {
            var light = lights[i];
            if (_lightNetworkModes[light.identifier] != light.mode) {
                return false;
            }
        }

        return true;
    }

    private function areLightsTurnedOff() {
        var lights = _lightNetwork.getBikeLights();
        for (var i = 0; i < lights.size(); i++) {
            var light = lights[i];
            if (light.mode != 0) {
                return false;
            }
        }

        return true;
    }

    private function restoreLights() {
        _state = 4; /* Restoring lights */
        _text = "Restoring lights...";
        System.println(_text + " timer=" + System.getTimer());
        _restoreTimeout = timeout;
        _lightNetwork.restoreHeadlightsNetworkModeControl();
        _lightNetwork.restoreTaillightsNetworkModeControl();
    }
}
