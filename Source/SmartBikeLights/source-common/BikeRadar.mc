using Toybox.System;
using Toybox.Ant;
using Toybox.Application.Storage as Storage;

(:highMemory)
class RadarTarget {
    public var range = 0f;
    public var speed = 0f;
    public var threat = 0;
    public var threadSide = 0;
}

(:highMemory)
class BikeRadar {
    private var _channel;

    private var _totalTargets = 0;
    private var _targets = new [8];
    private var _lastMessageTime = 0;
    private var _searching = true;
    private var _errorCode;
    private var _deviceNumber;

    function initialize(deviceNumber) {
        // Fill targets
        for (var i = 0; i < _targets.size(); i++) {
            _targets[i] = new RadarTarget();
        }

        _deviceNumber = getDeviceNumber(deviceNumber);
        open(false);
    }

    function isConnected() {
        return !_searching;
    }

    function getRadarInfo() {
        return _targets.slice(0, _searching ? 0 : _totalTargets);
    }

    function updateDeviceNumber(deviceNumber) {
        var newDeviceNumber = getDeviceNumber(deviceNumber);
        if (_deviceNumber != newDeviceNumber) {
            close();
            open(false);
            _totalTargets = 0;
            _deviceNumber = newDeviceNumber;
        }
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
            _totalTargets = 0;
        }

        return _errorCode;
    }

    function open(ignoreOpenError) {
        if (_deviceNumber == null) {
            _errorCode = 10;
            return;
        }

        var transmissionType = (((_deviceNumber >> 16) & 0x0F) << 4) | 0x05;
        try {
            if (_channel == null) {
                _channel = new Ant.GenericChannel(
                    method(:onMessage),
                    new Ant.ChannelAssignment(0x00 /* Bidirectional Receive (Slave) */, 1 /* NETWORK_PLUS */));
                _channel.setDeviceConfig(new Ant.DeviceConfig({
                    :deviceNumber => _deviceNumber,
                    :deviceType => 40,                              // Bike Radar
                    :messagePeriod => 4084,                         // Channel period
                    :transmissionType => transmissionType,          // Transmission type
                    :radioFrequency => 57                           // Ant+ Frequency
                }));
            }

            if (!_channel.open() && !ignoreOpenError) {
                _errorCode = 11;
            }
        } catch(e instanceof Ant.UnableToAcquireChannelException) {
            _errorCode = 12;
        }
    }

    function close() {
        _errorCode = null;
        _lastMessageTime = 0;
        _searching = true;
        if (_channel != null) {
            _channel.release();
            _channel = null;
        }
    }

    function onMessage(message) {
        _lastMessageTime = System.getTimer();
        var payload = message.getPayload();
        if (0x4E /* MSG_ID_BROADCAST_DATA */ == message.messageId) {
            if (_searching) {
                _searching = false;
            }

            var page = (payload[0] & 0xFF);
            var totalTargets = decodePage(payload, page);
            if (totalTargets == null) {
                return;
            }

            if (page == 49 || totalTargets < 4 || _totalTargets < 4) {
                _totalTargets = totalTargets;
            }
        } else if (0x40 /* MSG_ID_CHANNEL_RESPONSE_EVENT */ == message.messageId) {
            if (0x01 /* MSG_ID_RF_EVENT */ == (payload[0] & 0xFF)) {
                if (0x07 /* MSG_CODE_EVENT_CHANNEL_CLOSED */ == (payload[1] & 0xFF)) {
                    //System.println("MSG_CODE_EVENT_CHANNEL_CLOSED");
                    // Channel closed, re-open only when the channel was not manually closed
                    if (_channel != null) {
                        _searching = true;
                        open(true);
                    }
                } else if (0x08 /* MSG_CODE_EVENT_RX_FAIL_GO_TO_SEARCH */ == (payload[1] & 0xFF)) {
                    //System.println("MSG_CODE_EVENT_RX_FAIL_GO_TO_SEARCH");
                    _searching = true;
                }
            } else {
                //It is a channel response.
                //System.println("Data:" + payload);
            }
        } else {
            //System.println("MSG:" + message.messageId);
        }
    }

    private function decodePage(payload, page) {
        if (page != 48 && page != 49) {
            return null;
        }

        var totalThreats = page == 49 ? 4 : 0;
        var startTargetIndex = page == 49 ? 4 : 0;
        var ranges = (payload[5] << 16) | (payload[4] << 8) | payload[3];
        var speeds = (payload[6] << 8) | payload[7];
        for (var i = 0; i < 4; i++) {
            var target = _targets[startTargetIndex + i];
            target.threat = (payload[1] >> (i * 2)) & 0x03;
            if (target.threat > 0) {
                totalThreats++;
            }

            target.threadSide = (payload[2] >> (i * 2)) & 0x03;
            target.range = ((ranges >> (i * 6)) & 0x3F) * 3.125f;
            target.speed = ((speeds >> (i * 4)) & 0x04) * 3.04f;
            //System.println("target " + (startTargetIndex + i) + " threat="  + target.threat + " threadSide="  + target.threadSide + " range="  + target.range + " speed="  + target.speed);
        }

        return totalThreats;
    }

    private function getDeviceNumber(deviceNumber) {
        return deviceNumber <= 0 ? Storage.getValue("RDN") : deviceNumber;
    }
}