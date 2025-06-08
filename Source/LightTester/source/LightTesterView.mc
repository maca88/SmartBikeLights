using Toybox.WatchUi;
using Toybox.AntPlus;
using Toybox.Graphics;
using Toybox.Application.Properties as Properties;

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
        _eventHandler.get().updateLight(light);
    }
}

class LightTesterView extends WatchUi.DataField {

    private var _lightNetwork;
    private var _lightNetworkListener;
    private var _networkState = 0;
    private var _updates = 0;

    function initialize() {
        DataField.initialize();
        _lightNetworkListener = new BikeLightNetworkListener(self);
        setupNetwork();
    }

    function onShow() {
        if (_lightNetwork == null) {
            setupNetwork();
        }
    }

    function onUpdate(dc) {
        if (_lightNetwork != null && _lightNetwork has :update) {
            _lightNetwork.update();
        }

        var width = dc.getWidth();
        var height = dc.getHeight();
        var bgColor = 0xFFFFFF; /* COLOR_WHITE */
        var fgColor = 0x000000; /* COLOR_BLACK */

        dc.setColor(fgColor, bgColor);
        dc.clear();
        dc.setColor(fgColor, -1 /* COLOR_TRANSPARENT */);

        var text = _networkState == 0 ? "No network"
            : _networkState == 1 ? "Forming network"
            : _networkState == 2 ? "Network formed"
            : "Network state: " + _networkState;

        height = height / 4;
        dc.drawText(width / 2, height, 2, text, 1 /* TEXT_JUSTIFY_CENTER */ | 4 /* TEXT_JUSTIFY_VCENTER */);
        var lights = _lightNetwork.getBikeLights();
        if (lights == null) {
            return;
        }

        height += dc.getFontHeight(2);

        dc.drawText(width / 2, height, 2, "Updates= " + _updates, 1 /* TEXT_JUSTIFY_CENTER */ | 4 /* TEXT_JUSTIFY_VCENTER */);
        height += dc.getFontHeight(2);

        for (var i = 0; i < lights.size(); i++) {
            var lightText = "L" + i + ": " + getLightInfo(lights[i], true);
            dc.drawText(width / 2, height, 0, lightText, 1 /* TEXT_JUSTIFY_CENTER */ | 4 /* TEXT_JUSTIFY_VCENTER */);
            height += dc.getFontHeight(0);
            //lightText = "L" + i + ": CM= " + lights[i].getCapableModes();
            //dc.drawText(width / 2, height, 0, lightText, 1 /* TEXT_JUSTIFY_CENTER */ | 4 /* TEXT_JUSTIFY_VCENTER */);
            //height += dc.getFontHeight(0);
        }
    }

    function onNetworkStateUpdate(networkState) {
        _networkState = networkState;
        System.println("Net ST=" + networkState + " MD=" + _lightNetwork.getNetworkMode() + " T=" + System.getTimer());
    }

    function updateLight(light) {
        _updates++;
        System.println("UPD: " + getLightInfo(light, true) + " T=" + System.getTimer());
    }

    private function getLightInfo(light, skipModes) {
        if (light == null) {
            System.println("NULL!");
            return;
        }

        var battery = _lightNetwork.getBatteryStatus(light.identifier);

        return "TY=" + light.type +
             " ID=" + light.identifier +
             " LM=" + light.mode +
             (skipModes ? "" : " CM=" + light.getCapableModes()) +
             " BS=" + (battery != null ? battery.batteryStatus : null);
    }

    (:testNetwork)
    private function setupNetwork() {
        _lightNetwork = new TestNetwork.TestLightNetwork(_lightNetworkListener);
    }

    (:deviceNetwork)
    private function setupNetwork() {
        _lightNetwork = new AntPlus.LightNetwork(_lightNetworkListener);
    }
}