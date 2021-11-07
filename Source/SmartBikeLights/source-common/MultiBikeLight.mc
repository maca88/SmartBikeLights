using Toybox.AntPlus;

(:highMemory)
class MultiBikeLight extends AntPlus.BikeLight {

    private var _lights;
    private var _capableModes;
    private var _batteryStatus;

    function initialize(light, light2) {
        _lights = [light, light2];
        _batteryStatus = new AntPlus.BatteryStatus();
        type = light.type;
        mode = light.mode;
        identifier = light.identifier;
        calculateCapableModes();
    }

    function getCapableModes() {
        return _capableModes;
    }

    function setMode(lightMode) {
        if (_capableModes.indexOf(lightMode) < 0) {
            return;
        }

        for (var i = 0; i < _lights.size(); i++) {
            _lights[i].setMode(lightMode);
        }
    }

    function addLight(light) {
        _lights.add(light);
        calculateCapableModes();
    }

    function updateLight(light, nextMode) {
        var allUpdated = true;
        var lightIndex = -1;
        for (var i = 0; i < _lights.size(); i++) {
            if (_lights[i].identifier == light.identifier) {
                _lights[i] = light;
                lightIndex = i;
            }

            allUpdated &= _lights[i].mode == light.mode;
        }

        if (_capableModes.indexOf(light.mode) >= 0) {
            mode = light.mode;
            if (allUpdated || nextMode == null) {
                return self;
            }
        }

        // Return a light with a different identifier so that BikeLightsView.updateLight will skip further processing
        return _lights[1];
    }

    function getBatteryStatus(lightNetwork) {
        // Return null if any of the lights is disconnected, otherwise return the lowest battery value
        var batteryStatus = 1 /* NEW */;
        for (var i = 0; i < _lights.size(); i++) {
            var status = lightNetwork.getBatteryStatus(_lights[i].identifier);
            if (status == null) { // Disconnected
                return null;
            }

            if (status.batteryStatus > batteryStatus) {
                batteryStatus = status.batteryStatus;
            }
        }

        _batteryStatus.batteryStatus = batteryStatus;

        return _batteryStatus;
    }

    private function calculateCapableModes() {
        var combinedModes = null;
        // Find modes that all lights supports
        for (var i = 0; i < _lights.size(); i++) {
            var capableModes = _lights[i].getCapableModes();
            if (capableModes == null) {
                capableModes = [0];
            }

            if (combinedModes == null) {
                combinedModes = capableModes.slice(0, null);
                continue;
            }

            for (var j = 0; j < combinedModes.size();) {
                var mode = combinedModes[j];
                if (capableModes.indexOf(mode) < 0) {
                    combinedModes.remove(mode);
                } else {
                    j++;
                }
            }
        }

        _capableModes = combinedModes;
    }
}