using Toybox.Ant;

const maxReconnectRetries = 1;

(:background)
class TempeSensor {
    private var _channel;
    private var _onTemperatureReceived;

    // 0. Event count
    // 1. Low temp
    // 2. High temp
    // 3. Current temp
    // 4. Battery level
    // 5. Temperature offset
    public var data = new [6];

    function initialize(onTemperatureReceived) {
        _onTemperatureReceived = onTemperatureReceived;
    }

    function open() {
        if (_channel == null) {
            _channel = new Ant.GenericChannel(method(:onMessage), new Ant.ChannelAssignment(0x00 /* CHANNEL_TYPE_RX_NOT_TX */, 1 /* NETWORK_PLUS */));
            setChannelDeviceNumber();
        }

        return _channel.open();
    }

    function close() {
        var channel = _channel;
        if (channel != null) {
            _channel = null;
            channel.release();
        }
    }

    function onMessage(message) {
        if (_channel == null) {
            //System.println("Channel is closed!");
            return;
        }

        var payload = message.getPayload();
        var messageId = message.messageId;
        var localData = data; // To save some memory
        if (0x4E /* MSG_ID_BROADCAST_DATA */ == messageId) {
            var pageNumber = (payload[0] & 0xFF);
            if (pageNumber == 1) {
                var eventCount = payload[2];
                if (localData[0] == eventCount) {
                    return; // Do not process the same data again
                }

                // Event count
                localData[0] = eventCount;
                // 24 Hour Low
                var temp = ((payload[4] & 0xF0) << 4) | payload[3];
                localData[1] = (temp == 0x800 ? null
                    : (temp & 0x800) == 0x800 ? -(0xFFF - temp)
                    : temp) * 0.1f;
                // 24 Hour High
                temp = (payload[5] << 4) | (payload[4] & 0x0F);
                localData[2] = (temp == 0x800 ? null
                    : (temp & 0x800) == 0x800 ? -(0xFFF - temp)
                    : temp) * 0.1f;
                // Current Temp
                temp = (payload[7] << 8) | payload[6];
                localData[3] = (temp == 0x8000 ? null
                    : (temp & 0x8000) == 0x8000 ? -(0xFFFF - temp)
                    : temp) * 0.01f;

                _onTemperatureReceived.invoke(localData[3]);
            } else if (pageNumber == 82) {
                localData[4] = (payload[7] >> 4) & 0x07; // Battery status
            }
        } else if (0x40 /* MSG_ID_CHANNEL_RESPONSE_EVENT */ == messageId) {
            if (0x01 /* MSG_ID_RF_EVENT */ == (payload[0] & 0xFF)) {
                var eventCode = payload[1] & 0xFF;
                if (0x07 /* MSG_CODE_EVENT_CHANNEL_CLOSED */ == eventCode) {
                    // Channel closed, re-open only when the channel was not manually closed
                    _onTemperatureReceived.invoke(-99);
                } else if (0x08 /* MSG_CODE_EVENT_RX_FAIL_GO_TO_SEARCH */ == eventCode) {
                    //System.println("MSG_CODE_EVENT_RX_FAIL_GO_TO_SEARCH");
                } else if (0x06 /* MSG_CODE_EVENT_TRANSFER_TX_FAILED */ == eventCode) {
                    //System.println("Failed to send battery status page request");
                    // The battery status page request failed to be sent, try to resend it
                } else {
                    //System.println("e=" + eventCode);
                }
            }
        }
    }

    private function setChannelDeviceNumber() {
        _channel.setDeviceConfig(new Ant.DeviceConfig({
            :deviceNumber => 0,
            :deviceType => 25,        // Environment device
            :messagePeriod => 65535,  // Channel period
            :transmissionType => 0,   // Transmission type
            :radioFrequency => 57     // Ant+ Frequency
        }));
    }
}