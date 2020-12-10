using Toybox.AntPlus;

(:testNetwork)
class TestLightNetwork extends AntPlus.LightNetwork {

    private var _listener;
    private var _lights;
    private var _counter = 0;
    private var _state = 0;
    private var _mode = 0;

    function initialize(listener) {
        LightNetwork.initialize(listener);
        _listener = listener;
        _lights = [
            new TestBikeLight(0, 0 /* LIGHT_TYPE_HEADLIGHT */, [0, 1, 2, 5, 63, 62], listener, 81 /* Bontrager */, 6 /* ION PRO RT */),
            new TestBikeLight(1, 2 /* LIGHT_TYPE_TAILLIGHT */, [0, 1, 5, 7, 8, 63], listener, 81 /* Bontrager */, 1 /* Flare RT */)
        ];
    }

    function getBikeLights() {
        return _lights;
    }

    function getNetworkMode() {
        return _mode;
    }

    function update() {
        _counter = (_counter + 1) % 120;
        if (_counter == 0) {
            _state = 0; /* LIGHT_NETWORK_STATE_NOT_FORMED */
            _listener.onLightNetworkStateUpdate(_state);
        } else if (_state == 0 && _counter > 2) {
            _state = 2; /* LIGHT_NETWORK_STATE_FORMED */
            _listener.onLightNetworkStateUpdate(_state);
        }

        if (_counter % 60 == 0) {
            _mode = _mode != null ? (_mode + 1) % 4 : 0;
            _mode = _mode == 3 ? null : _mode; // Simulate TRAIL mode that is not in the API
        }
    }

    function getManufacturerInfo(identifier) {
        return _lights[identifier].manufacturerInfo;
    }

    function getBatteryStatus(identifier) {
        return _lights[identifier].getBatteryStatus();
    }
}

(:testNetwork)
class TestBikeLight extends AntPlus.BikeLight {

    private var _modes;
    private var _batteryStatus = new AntPlus.BatteryStatus();
    private var _batteryCounter = 0;
    private var _listener;

    public var manufacturerInfo = new AntPlus.ManufacturerInfo();

    function initialize(id, lightType, modes, listener, manufacturerId, modelNumber) {
        BikeLight.initialize();
        identifier = id;
        type = lightType;
        mode = 0;
        _modes = modes;
        _listener = listener;
        _batteryStatus.batteryStatus = 1;
        manufacturerInfo.manufacturerId = manufacturerId;
        manufacturerInfo.modelNumber = modelNumber;
    }

    function getCapableModes() {
        return _modes;
    }

    function setMode(value) {
        mode = value;
        _listener.onBikeLightUpdate(self);
    }

    function getBatteryStatus() {
        _batteryCounter++;
        if (_batteryCounter % 16 != 0) {
            return _batteryStatus;
        }

        _batteryStatus.batteryStatus  = (_batteryStatus.batteryStatus % 5) + 1;
        return _batteryStatus;
    }
}