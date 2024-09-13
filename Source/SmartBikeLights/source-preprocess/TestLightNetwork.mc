// #if ANT_NETWORK == "TestNetwork.TestLightNetwork"
// #include HEADER
using Toybox.AntPlus;
using Toybox.System;

(:glance :highMemory)
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

(:glance)
module TestNetwork {

    var counter = 0;
    var mode = 0;
    var lastUpdate = 0;

    class TestLightNetwork {

        private var _listener;
        private var _lights;
        private var _state = 0;
        private var _initialized = false;

        function initialize(listener) {
            _listener = listener;
            _lights = [
                new TestBikeLight(0, 0 /* LIGHT_TYPE_HEADLIGHT */, [0, 1, 2, 5, 63, 62], 81 /* Bontrager */, 6 /* ION PRO RT */, 3288461872l),
                new TestBikeLight(1, 2 /* LIGHT_TYPE_TAILLIGHT */, [0, 1, 5, 7, 8, 63], 81 /* Bontrager */, 1 /* Flare RT */, 2368328293l)
                //new TestBikeLight(2, 2 /* LIGHT_TYPE_TAILLIGHT */, [0, 4, 5, 7, 6], 1 /* Garmin */, 1 /* Varia 515 */, 2368328294)
                //new TestBikeLight(0, 0 /* LIGHT_TYPE_HEADLIGHT */, [0, 2, 3, 4, 8], 108 /* Giant */, 6 /* Recon HL1800 */, 1234554)
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

            for (var i = 0; i < _lights.size(); i++) {
                var light = _lights[i];
                if (light.hasChanges) {
                    light.hasChanges = false;
                    _listener.onBikeLightUpdate(light);
                }
            }

            counter = (counter + 1) % 120;
            if (counter == 0) {
                _state = 0; /* LIGHT_NETWORK_STATE_NOT_FORMED */
                _listener.onLightNetworkStateUpdate(_state);
            } else if (!_initialized && _state == 0 && counter > 1) {
                _state = 2; /* LIGHT_NETWORK_STATE_FORMED */
                _listener.onLightNetworkStateUpdate(_state);
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
            return _lights[identifier].batteryStatus;
        }

        function restoreHeadlightsNetworkModeControl() {
        }

        function restoreTaillightsNetworkModeControl() {
        }
    }

    class TestBikeLight {

        private var _modes;

        public var hasChanges = false;
        public var batteryStatus = new AntPlus.BatteryStatus();
        public var manufacturerInfo = new AntPlus.ManufacturerInfo();
        public var productInfo = new AntPlus.ProductInfo();
        public var identifier;
        public var type;
        public var mode;

        function initialize(id, lightType, modes, manufacturerId, modelNumber, serial) {
            identifier = id;
            type = lightType;
            mode = 0;
            _modes = modes;
            batteryStatus.batteryStatus = 1;
            manufacturerInfo.manufacturerId = manufacturerId;
            manufacturerInfo.modelNumber = modelNumber;
            productInfo.serial = serial;
        }

        function getCapableModes() {
            return _modes;
        }

        function setMode(value) {
            mode = value;
            hasChanges = true;
        }
    }
}
// #endif