using Toybox.System;
using Toybox.Ant;
using Toybox.AntPlus;
using Toybox.Application.Properties as Properties;
using Toybox.Lang;

const retryTimes = 2;
const controllerId = 99;

class BikeLight {
    private var _controller;

    public var identifier;
    public var mode = 0;
    public var type;

    function initialize(controller) {
        _controller = controller;
    }

    function getCapableModes() {
        return _controller.capableModes;
    }

    function setMode(mode) {
        _controller.setMode(mode);
    }
}

class IndividualLightNetwork {
    private var _lightControllers = null;

    function initialize(listener) {
        var headlightDeviceNumber = 52019 /* Properties.getValue("HDN")*/;
        var taillightDeviceNumber = 2633 /* Properties.getValue("TDN")*/;
        var deviceNumbers = headlightDeviceNumber > 0 && taillightDeviceNumber > 0 ? [headlightDeviceNumber, taillightDeviceNumber]
            : headlightDeviceNumber > 0 ? [headlightDeviceNumber]
            : taillightDeviceNumber > 0 ? [taillightDeviceNumber]
            : [];
        var totalLights = deviceNumbers.size();
        if (totalLights == 0) {
            return;
        }

        _lightControllers = new [totalLights];
        for (var i = 0; i < totalLights; i++) {
            var deviceNumber = deviceNumbers[i];
            _lightControllers[i] = new LightController(
                i,
                deviceNumber == headlightDeviceNumber ? 0 /*LIGHT_TYPE_HEADLIGHT */ : 2 /* LIGHT_TYPE_TAILLIGHT */,
                deviceNumber,
                listener
            );
        }
    }

    function getBikeLights() {
        if (_lightControllers == null) {
            return null;
        }

        var lights = [];
        var totalLights = _lightControllers.size();
        for (var i = 0; i < totalLights; i++) {
            var lightController = _lightControllers[i];
            var light = lightController.light;
            if (lightController.state == 0 /* LIGHT_NETWORK_STATE_NOT_FORMED */) {
                continue;
            }

            lights.add(light);
        }

        return lights;
    }

    function getNetworkMode() {
        return 0 /* LIGHT_NETWORK_MODE_INDIVIDUAL */;
    }

    function restoreHeadlightsNetworkModeControl() {
    }

    function restoreTaillightsNetworkModeControl() {
    }

    function getBatteryStatus(identifier) {
        var lightController = _lightControllers != null && identifier < _lightControllers.size()
            ? _lightControllers[identifier]
            : null;
        if (lightController == null) {
            return;
        }

        // As getBatteryStatus is called every second by BikeLightsView, we use this opportunity to
        // check whether the channel is still alive.
        lightController.checkChannel();

        return !lightController.searching ? lightController.batteryStatus : null;
    }
}

class LightController {
    private var _channel;
    private var _lastMessageTime = 0;
    private var _listener;

    private var _retryTimes;
    private var _retry = false;
    private var _commandData = new [8];
    private var _commandSequenceNumber = 0;
    private var _lastCommandTime = 0;

    private var _lightType;
    private var _deviceNumber;
    private var _transmissionType;

    public var state = 0 /* LIGHT_NETWORK_STATE_NOT_FORMED */;
    public var searching = true;
    public var errorCode;
    public var light;
    public var batteryStatus;
    public var capableModes;
    public var lightIndex = 0;

    function initialize(identifier, lightType, deviceNumber, listener) {
        _lightType = lightType;
        _deviceNumber = 0xFFFF & deviceNumber;
        _transmissionType = (((deviceNumber >> 16) & 0x0F) << 4) | 0x05;
        _listener = listener;
        light = new BikeLight(self);
        light.identifier = identifier;
        batteryStatus = new AntPlus.BatteryStatus();
        open(false);
    }

    function checkChannel() {
        // In case the device goes to sleep for a longer period of time the channel will be closed by the system
        // and onMessage function won't be called anymore. In such case release the current channel and open
        // a new one. To detect a sleep we check whether the last message was received more than the value of
        // the option "searchTimeoutLowPriority" ago, which in our case is set to 15 seconds.
        if (_lastMessageTime > 0 && System.getTimer() - _lastMessageTime > 20000) {
            // Reset the channel and data
            close();
            open(false);
        }
    }

    function open(ignoreOpenError) {
        try {
            if (_channel == null) {
                _channel = new Ant.GenericChannel(
                    method(:onMessage),
                    new Ant.ChannelAssignment(0x00 /* Bidirectional Receive (Slave) */, 1 /* NETWORK_PLUS */));
                _channel.setDeviceConfig(new Ant.DeviceConfig({
                    :deviceNumber => _deviceNumber,                 // Device Number
                    :deviceType => 35,                              // Bike Light
                    :messagePeriod => 4084,                         // Channel Period
                    :transmissionType => _transmissionType,         // Transmission Type
                    :radioFrequency => 57                           // Ant+ Frequency
                }));
            }

            if (!_channel.open() && !ignoreOpenError) {
                errorCode = 6;
            }
        } catch(e instanceof Ant.UnableToAcquireChannelException) {
            errorCode = 5;
        }
    }

    function close() {
        errorCode = null;
        lightIndex = 0;
        state = 0;
        _lastMessageTime = 0;
        _lastCommandTime = 0;
        _retry = false;
        searching = true;
        if (_channel != null) {
            _channel.release();
            _channel = null;
        }
    }

    function onMessage(message) {
        _lastMessageTime = System.getTimer();
        var payload = message.getPayload();
        if (0x4E /* MSG_ID_BROADCAST_DATA */ == message.messageId) {
            if (searching) {
                searching = false;
            }

            if (_retry) {
                sendCommand();
                return;
            }

            // Each ANT+ controller that is connected to the main ANT+ bike light should send a message to the ANT+ bike light at least once every 30 seconds
            if (lightIndex > 0 && (System.getTimer() - _lastCommandTime) > 20000) {
                // If the ANT+ controller does not have any new commands or other messages to send within a given 30 second period, then 
                // the main light’s channel ID (page 18) should be sent instead
                requestPage(18);
                return;
            }

            var page = (payload[0] & 0xFF);
            if (page == 1) {
                decodePage1(payload);
            } else if (page == 2) {
                decodePage2(payload);
            }

            // The controller is initialized when it is connected to the light and data page 1 and 2 were retrieved
            if (state == 0 && lightIndex > 0 && capableModes != null) {
                state = 2;
                if (_listener != null) {
                    // In case a light is already initialized in BikeLightsView, we need to trigger a reset in order to add the second light
                    _listener.onLightNetworkStateUpdate(0 /* LIGHT_NETWORK_STATE_NOT_FORMED */);
                    _listener.onLightNetworkStateUpdate(2 /* LIGHT_NETWORK_STATE_FORMED */);
                }
            }

            // Page 2 is optional when the light is connected
            if (capableModes == null && lightIndex > 0) {
                requestPage(2);
                return;
            }

            if (light.type != null && capableModes != null && lightIndex == 0) {
                connect();
            }
        } else if (0x40 /* MSG_ID_CHANNEL_RESPONSE_EVENT */ == message.messageId) {
            //System.println("MESSAGE:" + payload);
            if (0x01 /* MSG_ID_RF_EVENT */ == (payload[0] & 0xFF)) {
                var eventCode = payload[1] & 0xFF;
                if (0x06 /* MSG_CODE_EVENT_TRANSFER_TX_FAILED */ == eventCode) {
                    System.println("MSG_CODE_EVENT_TRANSFER_TX_FAILED");
                    if (!_retry) { // First time
                        _retry = true;
                        _retryTimes = retryTimes;
                    } else {
                        _retryTimes--;
                        _retry = _retryTimes > 0;
                    }
                } else if (0x07 /* MSG_CODE_EVENT_CHANNEL_CLOSED */ == eventCode) {
                    System.println("MSG_CODE_EVENT_CHANNEL_CLOSED");
                    // Channel closed, re-open only when the channel was not manually closed
                    if (_channel != null) {
                        open(true);
                    }
                } else if (0x08 /* MSG_CODE_EVENT_RX_FAIL_GO_TO_SEARCH */ == eventCode) {
                    System.println("MSG_CODE_EVENT_RX_FAIL_GO_TO_SEARCH");
                    searching = true;
                }
            } else {
                //It is a channel response.
                //System.println("Data:" + payload);
            }
        }
    }

    function setMode(newMode) {
        var command = _commandData;
        command[0] = 34; // Page number
        command[1] = lightIndex; // Light index
        command[2] = light.type << 4; /// Light type
        _commandSequenceNumber = (_commandSequenceNumber + 1) % 255;
        command[3] = _commandSequenceNumber; // Sequence number
        command[4] = controllerId; // Controler id
        command[5] = 1 << 4;
        command[6] = newMode == 0 ? 1 /* Off */ : (newMode << 2);
        command[7] = 0xFF; // Beam adjustment
        //System.println("setMode=" + command);
        sendCommand();
    }

    private function requestPage(pageNumber) {
        var command = _commandData;
        command[0] = 70; // Page number
        command[1] = lightIndex; // Light index
        command[2] = 0xFF; // Reserved
        command[3] = 0; // Descriptor Byte 1
        command[4] = 0; // Descriptor Byte 2
        command[5] = 1; // Repeat once
        command[6] = pageNumber; // Requested Page Number
        command[7] = 1; // Command type
        //System.println("requestPage=" + command);
        sendCommand();
    }

    private function connect() {
        var command = _commandData;
        command[0] = 33; // Page number
        command[1] = 1; // Light index
        command[2] = 1; // # Secondary Lights
        command[3] = controllerId;
        // Try match the current mode
        var initialMode = light.mode == 0 ? 1 /* Off */
         : light.mode <= 5 ? 3 /* Steady beam */
         : 2; /* Flashing */
        command[4] = (_lightType << 5) | (initialMode << 3);
        command[5] = _deviceNumber & 0xFF;
        command[6] = (_deviceNumber >> 8) & 0xFF;
        command[7] = _transmissionType;
        System.println("connect=" + command);
        sendCommand();
    }

    private function sendCommand() {
        _lastCommandTime = System.getTimer();
        var message = new Ant.Message();
        message.setPayload(_commandData);
        _channel.sendAcknowledge(message);
    }

    private function decodePage1(payload) {
        lightIndex = payload[1];
        light.type = (payload[2] >> 2) & 0x07;
        batteryStatus.batteryStatus = (payload[2] >> 5) & 0x07;
        var oldMode = light.mode;
        light.mode = (payload[6] >> 2) & 0x3F;
        if (state == 2 && oldMode != light.mode && _listener != null) {
            _listener.onBikeLightUpdate(light);
        }

        //System.println("T=" + light.type + " BS=" + batteryStatus.batteryStatus + " M=" + light.mode + " I=" + lightIndex);
    }

    private function decodePage2(payload) {
        if (capableModes != null) {
            return;
        }

        var standardModes = (payload[6] << 8) | payload[5];
        capableModes = [0];
        for (var i = 1; i < 14; i++) {
            if (((standardModes >> i) & 0x01) == 1) {
                capableModes.add(i);
            }
        }

        var totalSupportedModes = (payload[2] >> 2) & 0x3F;
        var totalCustomModes = totalSupportedModes - (capableModes.size() - 1);
        for (var i = 0; i < totalCustomModes; i++) {
            capableModes.add(63 - i);
        }

        //System.println("CM=" + capableModes + " TM=" + totalSupportedModes);
    }
}