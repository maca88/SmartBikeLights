using Toybox.Ant;
using Toybox.Sensor;
using Toybox.Lang;
using Toybox.Application.Storage as Storage;
using Toybox.System;

(:highMemory)
class BikeLightSensorDelegate extends Sensor.SensorDelegate {

    private var _view as Lang.WeakReference;
    private var _startScanTime as Lang.Number;
    private var _channel as Ant.GenericChannel or Null;
    private var _foundTaillightDeviceNumbers as Lang.Array<Lang.Number>;
    private var _foundHeadlightDeviceNumbers as Lang.Array<Lang.Number>;
    private var _registeredTaillightDeviceNumbers as Lang.Array<Lang.Number>;
    private var _registeredHeadlightDeviceNumbers as Lang.Array<Lang.Number>;

    function initialize(view) {
        SensorDelegate.initialize();
        _view = view.weak();
        _registeredTaillightDeviceNumbers = getArray("TDN");
        _registeredHeadlightDeviceNumbers = getArray("HDN");
        // As onScan and onPair methods are called within a different BikeLightSensorDelegate instance,
        // it is required to use the storage in order to preserve the light information (light type)
        _foundTaillightDeviceNumbers = getArray("FTDN");
        _foundHeadlightDeviceNumbers = getArray("FHDN");
    }

    function onPair(sensor as Sensor.SensorInfo) as Lang.Boolean {
        var message = sensor.data[:antMessage];
        var deviceNumber = message.deviceNumber;
        var key;
        var deviceNumbers;
        if (_foundHeadlightDeviceNumbers.indexOf(deviceNumber) < 0) {
            key = "TDN";
            deviceNumbers = _registeredTaillightDeviceNumbers;
        } else {
            key = "HDN";
            deviceNumbers = _registeredHeadlightDeviceNumbers;
        }

        deviceNumbers.add(deviceNumber);
        Storage.setValue(key, deviceNumbers);
        // As this delegate is running in a separate app instance, we cannot just recreate the
        // light network here. Instead, we need to use the storage in combination with onStorageChanged
        // to notify the main app instance to recreate the netowrk.
        Storage.setValue("RN", true);
        Sensor.notifyPairComplete(sensor);
        return true;
    }

    function onUnpair(sensor as Sensor.SensorInfo) as Lang.Boolean {
        var message = sensor.data[:antMessage];
        var deviceNumber = message.deviceNumber;
        var key;
        var deviceNumbers;
        if (_registeredHeadlightDeviceNumbers.indexOf(deviceNumber) < 0) {
            key = "TDN";
            deviceNumbers = _registeredTaillightDeviceNumbers;
        } else {
            key = "HDN";
            deviceNumbers = _registeredHeadlightDeviceNumbers;
        }

        deviceNumbers.remove(deviceNumber);
        Storage.setValue(key, deviceNumbers);
        // As this delegate is running in a separate app instance, we cannot just recreate the
        // light network here. Instead, we need to use the storage in combination with onStorageChanged
        // to notify the main app instance to recreate the netowrk.
        Storage.setValue("RN", true);
        Sensor.notifyUnpairComplete(sensor);
        return true;
    }

    function onScan() as Lang.Boolean {
        System.println("onScan timer=" + System.getTimer());
        Storage.deleteValue("FTDN");
        Storage.deleteValue("FHDN");
        try {
            _startScanTime = System.getTimer();
            return openChannel();
        } catch (e instanceof Ant.UnableToAcquireChannelException) {
            return false;
        }
    }

    function pairingRequired() as $.Toybox.Lang.Boolean {
        return true;
        // Uncomment the code once Edge 1040 will not reboot anymore when returning false
        /*
        return _view.stillAlive()
            ? _view.get().usesIndividualNetwork()
            : false;*/
    }

    function onMessage(message) {
        var payload = message.getPayload();
        var messageId = message.messageId;
        if (Ant.MSG_ID_BROADCAST_DATA == messageId) {
            var pageNumber = (payload[0] & 0xFF);
            if (message.deviceNumber == null || pageNumber != 1) {
                return;
            }

            if ((System.getTimer() - _startScanTime) > 10000) {
                completeScanning();
                return;
            }

            var deviceNumber = message.deviceNumber;
            var isHeadlight = ((payload[2] >> 2) & 0x07) == 0;
            var foundDeviceNumbers = isHeadlight ? _foundHeadlightDeviceNumbers : _foundTaillightDeviceNumbers;
            var registeredDeviceNumbers = isHeadlight ? _registeredHeadlightDeviceNumbers : _registeredTaillightDeviceNumbers;
            if (foundDeviceNumbers.indexOf(deviceNumber) >= 0 || registeredDeviceNumbers.indexOf(deviceNumber) >= 0) {
                if (!openChannel()) {
                    completeScanning();
                }

                return;
            }

            foundDeviceNumbers.add(deviceNumber);
            Storage.setValue(isHeadlight ? "FHDN" : "FTDN", foundDeviceNumbers);

            var sensorInfo = new Sensor.SensorInfo();
            sensorInfo.enabled = true;
            sensorInfo.name = WatchUi.loadResource(Rez.Strings.ShortAppName) + (isHeadlight ? " HL " : " TL ") + deviceNumber;
            sensorInfo.technology = Sensor.SENSOR_TECHNOLOGY_ANT;
            sensorInfo.type = Sensor.SENSOR_GENERIC;
            sensorInfo.data = {
                :antMessage => message
            };

            Sensor.notifyNewSensor(sensorInfo, false);
            //Sensor.notifyError("DN: " + deviceNumber);

            // It is requried to re-open the channel to find more than one sensor
            if (!openChannel()) {
                completeScanning();
            }

        } else if (Ant.MSG_ID_CHANNEL_RESPONSE_EVENT == messageId) {
            var responseId = payload[0] & 0xFF;
            if (responseId == Ant.MSG_ID_RF_EVENT) {
                var messageCode = payload[1] & 0xFF;
                //System.println("MessageCode=" + messageCode);
                if (messageCode == Ant.MSG_CODE_EVENT_RX_FAIL_GO_TO_SEARCH ||
                    messageCode == Ant.MSG_CODE_EVENT_RX_SEARCH_TIMEOUT ||
                    messageCode == Ant.MSG_CODE_EVENT_CONNECTION_REJECTED) {
                    completeScanning();
                }
            }
        }
    }

    private function completeScanning() {
        _channel.release();
        Sensor.notifyScanComplete();
        //System.println("notifyScanComplete timer=" + System.getTimer());
    }

    private function openChannel() as Lang.Boolean {
        if (_channel != null) {
            _channel.release();
        }

        _channel = new Ant.GenericChannel(
            method(:onMessage),
            new Ant.ChannelAssignment(Ant.CHANNEL_TYPE_RX_NOT_TX, Ant.NETWORK_PLUS));
        _channel.setDeviceConfig(new Ant.DeviceConfig({
            :deviceNumber => 0,               // Device Number
            :deviceType => 35,                // Bike Light
            :messagePeriod => 4084,           // Channel Period
            :transmissionType => 0,           // Transmission Type
            :radioFrequency => 57,            // Ant+ Frequency
            :searchThreshold => 0,            // Pair to all transmitting sensors
            :searchTimeoutLowPriority => 4    // Timeout in 10s
        }));

        return _channel.open();
    }

    private function getArray(key)  as Lang.Array<Lang.Number> {
        var array = Storage.getValue(key) as Lang.Array<Lang.Number> or Null;
        return array != null ? array : [];
    }
}