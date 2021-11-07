using Toybox.AntPlus;

(:testNetwork :highMemory)
module TestAntPlus {
    class BikeRadar {
        private var target;

        function initialize(listener) {
            target = new RadarTarget();
        }

        function getRadarInfo() {
            return [target];
        }
    }

    class RadarTarget {
        public var speed = 0;
        public var range = 100;
        public var threat = 0;

        function initialize() {
        }
    }
}

(:testNetwork)
module TestNetwork {

    var counter = 0;
    var mode = 0;
    var lastUpdate = 0;
    var updateBattery = 0;

    class TestLightNetwork extends AntPlus.LightNetwork {

        private var _listener;
        private var _lights;
        private var _state = 0;
        private var _initialized = false;

        function initialize(listener) {
            LightNetwork.initialize(listener);
            _listener = listener;
            _lights = [
                new TestBikeLight(0, 0 /* LIGHT_TYPE_HEADLIGHT */, [0, 1, 2, 5, 63, 62], listener, 81 /* Bontrager */, 6 /* ION PRO RT */, 3288461872),
                new TestBikeLight(1, 2 /* LIGHT_TYPE_TAILLIGHT */, [0, 1, 5, 7, 8, 63], listener, 81 /* Bontrager */, 1 /* Flare RT */, 2368328293)
                //new TestBikeLight(2, 2 /* LIGHT_TYPE_TAILLIGHT */, [0, 4, 5, 7, 6], listener, 1 /* Garmin */, 1 /* Varia 515 */, 2368328294)
            ];
            lastUpdate = System.getTimer();
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
                return null;
            }

            updateBattery += _lights.size();
            counter = (counter + 1) % 120;
            if (counter == 0) {
                _state = 0; /* LIGHT_NETWORK_STATE_NOT_FORMED */
                _listener.onLightNetworkStateUpdate(_state);
            } else if (!_initialized && _state == 0 && counter > 1) {
                _state = 2; /* LIGHT_NETWORK_STATE_FORMED */
                _listener.onLightNetworkStateUpdate(_state);
            }

            if (counter % 50 == 0) {
                mode = mode != null ? (mode + 1) % 4 : 0;
                mode = mode == 3 ? null : mode; // Simulate TRAIL mode that is not in the API
            }

            return null;
        }
        
        function getProductInfo(identifier) {
            return _lights[identifier].productInfo;
        }

        function getManufacturerInfo(identifier) {
            return _lights[identifier].manufacturerInfo;
        }

        function getBatteryStatus(identifier) {
            return _lights[identifier].updateAndGetBatteryStatus();
        }
    }

    class TestBikeLight extends AntPlus.BikeLight {

        private var _modes;
        private var _batteryStatus = new AntPlus.BatteryStatus();
        private var _batteryCounter = 0;
        private var _listener;

        public var manufacturerInfo = new AntPlus.ManufacturerInfo();
        public var productInfo = new AntPlus.ProductInfo();

        function initialize(id, lightType, modes, listener, manufacturerId, modelNumber, serial) {
            BikeLight.initialize();
            identifier = id;
            type = lightType;
            mode = 0;
            _modes = modes;
            _listener = listener;
            _batteryStatus.batteryStatus = 1;
            manufacturerInfo.manufacturerId = manufacturerId;
            manufacturerInfo.modelNumber = modelNumber;
            productInfo.serial = serial;
        }

        function getCapableModes() {
            return _modes;
        }

        function setMode(value) {
            mode = value;
            _listener.onBikeLightUpdate(self);
        }

        function updateAndGetBatteryStatus() {
            if (updateBattery == 0) {
                return _batteryStatus;
            }
            
            return _batteryStatus;

            updateBattery--;
            _batteryCounter++;
            if (_batteryCounter % 4 != 0) {
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
