using Toybox.AntPlus;

(:testNetwork)
module TestNetwork {

    var counter = 0;
    var mode = 0;
    var lastUpdate = 0;
    var updateBattery = 0;

    class TestLightNetwork extends AntPlus.LightNetwork {

        private var _view;
        private var _listener;
        private var _lights;
        private var _state = 0;
        private var _initialized = false;

        function initialize(view, listener) {
            LightNetwork.initialize(listener);
            _view = view.weak();
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
            return mode;
        }

        function update() {
            var delta = System.getTimer() - lastUpdate;
            lastUpdate = System.getTimer();
            if (delta < 1000) {
                return;
            }

            updateBattery += _lights.size();
            counter = (counter + 1) % 120;
            if (counter == 0) {
                _state = 0; /* LIGHT_NETWORK_STATE_NOT_FORMED */
                _listener.onLightNetworkStateUpdate(_state);
            } else if (!_initialized && _state == 0 && counter > 2) {
                _state = 2; /* LIGHT_NETWORK_STATE_FORMED */
                _listener.onLightNetworkStateUpdate(_state);
            }

            if (counter % 15 == 0) {
                mode = mode != null ? (mode + 1) % 4 : 0;
                mode = mode == 3 ? null : mode; // Simulate TRAIL mode that is not in the API
            }

            if (counter % 20 == 0) {
                _view.get().onShow(); // Simulate switching from garmin menu to data field screen
            }
        }

        function getManufacturerInfo(identifier) {
            return _lights[identifier].manufacturerInfo;
        }

        function getBatteryStatus(identifier) {
            return _lights[identifier].getBatteryStatus();
        }
    }

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
            if (updateBattery == 0) {
                return _batteryStatus;
            }

            updateBattery--;
            _batteryCounter++;
            if (_batteryCounter % 2 != 0) {
                return _batteryStatus;
            }

            _batteryStatus.batteryStatus = (_batteryStatus.batteryStatus % 6) + 1;
            if (_batteryStatus.batteryStatus == 1) {
                _listener.onBikeLightUpdate(self);
            }

            return _batteryStatus.batteryStatus == 6 ? null /* Simulate a disconnect */ : _batteryStatus;
        }
    }
}
