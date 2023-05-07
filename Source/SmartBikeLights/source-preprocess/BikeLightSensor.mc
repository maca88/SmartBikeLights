using Toybox.System;
using Toybox.Ant;
using Toybox.AntPlus;
using Toybox.Lang;

const unconnectedPages = [1, 2, 80, 81];
const mainConnectedPages = [1];

// Simulates a Bontrager Ion RT light to work with TransmitR MicroRemote and TransmitR Remote
(:highMemory)
class BikeLightSensor {

    // Channel related data
    private var _channel;
    private var _commandData = new [8];
    private var _deviceNumber;
    private var _transmissionType;
    private var _currentPageIndex = 0;
    private var _lastMessageTime = 0;
    private var _lightIndex = 0;
    private var _lastCommandId = 0xff;
    private var _errorCode;

    // Repeat message data
    private var _repeatPage;
    private var _repeatTimes = 0;
    private var _repeatDescriptor;
    private var _repeatAsAcknowledge;

    // Light related data
    private var _lightType = 0 /* Headlight */;
    /*
    Yellow light patterns of TransmitR Remote side buttons:
    - 1, 2, 3, 9 -> High steady
    - 4, 5 -> Low steady
    - 6 -> Slow flash
    - 7 -> Fast flash
    - 8 -> Random flash
    - 48 - 63 -> Off
    */
    private var _supportedModes = [1, 2, 3];
    private var _lightMode = 1;
    /*
    Light patterns of the TransmitR Remote center button:
    - 5 - 7 -> Flashig red
    - 4 -> Red steady
    - 1 -> 3 Green steady
    */
    private var _batteryLevel = 3 /* New */;
    private var _supportedStandardModes = 0;
    private var _manufacturerId = 81 /* Bontrager */;
    private var _modelNumber = 6 /* Ion RT */;
    private var _serialNumber = 123456789;
    private var _flashingMode = 3;
    private var _steadyMode = 1;

    // Controller related data
    private var _controllerIndex;
    private var _buttonIndex;
    private var _centralButtonIndex;
    private var _doubleClickDelay;
    private var _onLightModeChange;
    private var _onConnectedCallback;
    private var _secondClickMaxTime;
    private var _lastSingleClickAllLights;

    function initialize(deviceNumber, controllerIndex, buttonIndex, doubleClickDelay, onLightModeChange, onConnectedCallback) {
        _deviceNumber = 0xFFFF & deviceNumber;
        _controllerIndex = controllerIndex;
        _buttonIndex = buttonIndex;
        _doubleClickDelay = doubleClickDelay;
        _onLightModeChange = onLightModeChange;
        _onConnectedCallback = onConnectedCallback;
        _transmissionType = (((deviceNumber >> 16) & 0x0F) << 4) | 0x05;
        var supportedModes = _supportedModes;
        for (var i = 0; i < supportedModes.size(); i++) {
            var supportedMode = supportedModes[i];
            if (supportedMode > 14) {
                continue;
            }

            _supportedStandardModes |= (0x01 << supportedMode);
        }

        openMasterChannel(false);
    }

    function getLightMode() {
        return _lightMode;
    }

    function openMasterChannel(ignoreOpenError) {
        //System.println("open DN=" + _deviceNumber);
        try {
            if (_channel == null) {
                _channel = new Ant.GenericChannel(method(:onMasterMessage), new Ant.ChannelAssignment(0x10 /* Bidirectional Transmit (Master) */, 2 /* NETWORK_PRIVATE */));
                _channel.setDeviceConfig(new Ant.DeviceConfig({
                    :deviceNumber => _deviceNumber,                 // Device Number
                    :deviceType => 35,                              // Bike Light
                    :messagePeriod => 4084,                         // Channel Period
                    :transmissionType => _transmissionType,         // Transmission Type
                    :radioFrequency => 57,                          // Ant+ Frequency
                    // #include "./networkKeys"
                }));
            }

            if (!_channel.open() && !ignoreOpenError) {
                _errorCode = 8;
            }
        } catch (e instanceof Ant.UnableToAcquireChannelException) {
            _errorCode = 9;
        }
    }

    function closeMasterChannel() {
        if (_channel != null) {
            _channel.release();
            _channel = null;
        }

        _lightMode = _steadyMode;
        _lightIndex = 0;
        _lastMessageTime = 0;
        _lastCommandId = 0xff;
        _currentPageIndex = 0;
        _errorCode = null;
        _secondClickMaxTime = null;
        //System.println("closeMasterChannel");
    }

    function checkChannel() {
        if (_errorCode != null) {
            return _errorCode;
        }

        // In case the device goes to sleep for a longer period of time the channel will be closed by the system
        // and onMasterMessage function won't be called anymore. In such case release the current channel and open
        // a new one. To detect a sleep we check whether the last message was received in last 5 seconds. We should get
        // multiple messages per second.
        if (_lastMessageTime > 0 && System.getTimer() - _lastMessageTime > 5000) {
            // Reset the channel and data
            closeMasterChannel();
            openMasterChannel(false);
        }

        return _errorCode;
    }

    function setCentralButtonIndex(index) {
        _centralButtonIndex = index;
    }

    function onMasterMessage(message) {
        _lastMessageTime = System.getTimer();
        if (_channel == null || _errorCode != null) {
            return;
        }

        var payload = message.getPayload();
        var messageId = message.messageId;
        if (0x40 /* MSG_ID_CHANNEL_RESPONSE_EVENT */ == messageId) {
            var responseId = (payload[0] & 0xFF);
            if (0x01 /* MSG_ID_RF_EVENT */ == responseId) {
                var eventCode = payload[1] & 0xFF;
                if (0x03 /* MSG_CODE_EVENT_TX */ == eventCode || 0x05 /* MSG_CODE_EVENT_TRANSFER_TX_COMPLETED */ == eventCode) {
                    sendNextMasterPage();
                }
            }
        } else if (0x4E /* MSG_ID_BROADCAST_DATA */ == messageId || 0x4F /* MSG_ID_ACKNOWLEDGED_DATA */ == messageId) {
            processCommandMessage(payload, false);
        }

        if (_secondClickMaxTime != null && _secondClickMaxTime < System.getTimer()) {
            handleLightModeChange(_lightMode, _lastSingleClickAllLights, true);
        }
    }

    private function processCommandMessage(payload, sharedFormat) {
        //System.println("process data " + payload + " btx=" + _buttonIndex);
        var commandId = sharedFormat ? payload[1] : payload[0];
        var lightIndex = sharedFormat ? payload[0] : payload[1];
        if (commandId == 34 /* Light Settings */) {
            processPage34(payload, lightIndex);
        } else if (commandId == 33 /* Connect Command */) {
            processPage33(payload, lightIndex);
        } else if (commandId == 32 /* Disconnect Command */) {
            processPage32(payload, lightIndex);
        } else if (commandId == 70 /* Request Page */) {
            processPage70(payload, lightIndex);
        }
    }

    // Disconnect Command
    private function processPage32(payload, lightIndex) {
        // The main light should check the light index and if it is set to 0x01; then the main light shall return to the unconnected state.
        // Specifically it shall:
        // - Close its shared master channel
        // - Set its status to ‘unconnected’ in data page 1
        // - Set its light index to 0
        // - Stop transmitting data page 18 (Main light’s channel ID)

        // If the light index is set to 0x00 then the main light shall forward the command as a broadcast message on the shared
        // channel four times, and then return to the unconnected state as described above.
        if (lightIndex == 0) { // Applies to all lights
            _lightIndex = 0;
            //System.println("Disconnected - All");
        } else if (lightIndex == _lightIndex) {
            _lightIndex = 0;
            //System.println("Disconnected");
        } else if (_lightIndex == 1) {
            // Required by the specification but not needed in this case:
            // If the light index is set to a value other than 0x00 or 0x01 then the main light shall forward the command on the shared
            // channel as an acknowledged message. The command should be retried up to 4 times until an EVENT_TX_SUCCESS is
            // received. In this case the main light shall not change its own state
            // Not implemented

            // Once the command is forwarded on the shared channel, it will be received by one or all of the secondary lights depending
            // on the light index value. If the light index is zero, all secondary lights will receive the command. If the light index is any
            // other value, only the light with the index specified will receive the command. Any secondary ANT+ bike light that receives
            // this command shall:
            // - Close its shared slave channel
            // - Set its status to ‘unconnected’ in data page 1
            // - Set its light index to 0
            // - Stop transmitting data page 18 (Main light’s channel ID)
        }
    }

    // Connect Command
    private function processPage33(payload, lightIndex) {
        var connectSecondaryLight = _lightIndex == 1 && lightIndex != 1;
        var lightType = (payload[4] >> 5) & 0x07; // Light Type Setting
        if (
            // Connect command with light index 255 (0xFF) should be ignored by a connected light.
            (lightIndex == 0xFF && _lightIndex != 0) ||
            // A connected secondary light shall not apply connect commands of other lights
            (_lightIndex > 1 && lightIndex != _lightIndex) ||
            // The ANT+ bike light shall ignore any requests to set its light type to a type that it does not support.
            (!connectSecondaryLight && _lightType != lightType)
        ) {
            //System.println("invalid light index LT=" + lightType + " CSL=" + connectSecondaryLight);
            return;
        }


        if (connectSecondaryLight) {
            // Required by the specification but not needed in this case:
            // If the light index setting is 2 – 63, the connect command applies to the secondary light with the specified light
            // index. If this command is received by the main light, then it should be forwarded to the specified secondary light.
            return;
        }

        var oldLightIndex = _lightIndex;
        // Light index 255 (0xFF) should only be used when controlling an unconnected light e.g. to set the light type or light state
        // setting without changing the light index or affecting which channels the light has open.
        // A connected ANT+ bike light shall not change its light index.
        if (_lightIndex == 0 && lightIndex != 0xFF) {
            _lightIndex = lightIndex;
        }

        _lastCommandId = payload[3]; // Controller ID
        var lightStateSetting = (payload[4] >> 3) & 0x03; // Light State Setting
        var newLightMode = lightStateSetting == 2 /* Flasing */ ? _flashingMode
            : lightStateSetting == 3 /* Steady beam */ ? _steadyMode
            : 0 /* Off */;
        if (_lightMode != newLightMode) {
            setNewLightMode(newLightMode);
        }

        if (oldLightIndex != 0) { // The light is already connected
            //System.println("Already connected");
            return;
        }

        _currentPageIndex = 0; // Reset transmission pattern

        /* Below logic is required by the specification but not needed in this case
        if (_lightIndex == 1) {
            // If the light index setting is 1, the ANT+bike light is assigned as the main light for the network,
            // and should open a shared master channel
        } else {
            // Alternatively, if the light index setting is 2 – 63, the ANT+ bike light is assigned as a secondary light,
            // and should open a shared slave channel

            // When a secondary light opens the shared channel in response to a connect command, it shall immediately
            // send the shared format of data page 1 on the shared channel.
        }
        */

        //System.println("Connected " + " lm=" + newLightMode);
        // As connect command is issued multiple times, trigger the callback only after
        // the connect command want to turn off the light, which should be the last connect call
        if (_onConnectedCallback != null && newLightMode == 0) {
            _onConnectedCallback.invoke(_controllerIndex, _buttonIndex);
        }
    }

    // Light Settings
    private function processPage34(payload, lightIndex) {
        _lastCommandId = payload[3];
        //var sublightIndex = payload[2] & 0x03;
        if (lightIndex == 0) { // Applies to all lights
            // Required by the specification but not needed in this case:
            // The main light shall use a broadcast message to send this command on the shared channel when
            // the light index field is set to 0x00

            applyLightSettings(payload);
        } else if (lightIndex == _lightIndex) {
            applyLightSettings(payload);
        } else if (_lightIndex == 1) {
            // Required by the specification but not needed in this case:
            // An acknowledged message may be used when the light index is 2 – 63, and in this case
            // retries are permissible. Retry once in case the message fails to reach the destination.
        }
    }

    private function processPage70(payload, lightIndex) {
        _repeatTimes = payload[5] & 0x3F;
        _repeatAsAcknowledge = (payload[5] >> 6) & 0x01;
        _repeatDescriptor = payload[3];
        _repeatPage = payload[6];
        //System.println("RT=" + _repeatTimes + " ACK=" + _repeatAsAcknowledge + " RP=" + _repeatPage);
    }

    private function applyLightSettings(payload) {
        var beam = payload[6] & 0x03;
        var lightMode = (payload[6] >> 2) & 0x3F;
        var allLights = (payload[2] >> 3) & 0x01;
        //System.println("B=" + beam + " LM=" + lightMode + " AL=" + allLights);
        var newLightMode = null;
        if (beam == 1 /* OFF */) {
            newLightMode = 0;
        } else if (lightMode != 0 && _supportedModes.indexOf(lightMode) >= 0) {
            newLightMode = lightMode;
        }
        else {
            //System.println("WTF MODE=" + lightMode);
            return;
        }

        if (_lightMode != newLightMode) {
            //System.println("NEW MODE:" + newLightMode);
            setNewLightMode(newLightMode);
        }

        handleLightModeChange(newLightMode, allLights, false);
    }

    private function handleLightModeChange(newLightMode, allLights, secondClickTimeout) {
        if (allLights && _centralButtonIndex == null) {
            return;
        }

        var triggerId = newLightMode == 0 /* Off */
            ? 2 /* Press and hold */
            : 1 /* Single-click */;
        if (_secondClickMaxTime != null) {
            //System.println("diff=" + (_secondClickMaxTime - System.getTimer()));
            if (triggerId == 1 && _secondClickMaxTime > System.getTimer()) {
                triggerId = 3; // Double-click
                allLights = _lastSingleClickAllLights;
            }

            _secondClickMaxTime = null;
        }

        if (!secondClickTimeout && triggerId == 1 && _secondClickMaxTime == null && _doubleClickDelay > 0) {
            _secondClickMaxTime = System.getTimer() + _doubleClickDelay;
            _lastSingleClickAllLights = allLights;
            return;
        }

        _onLightModeChange.invoke(_controllerIndex, allLights ? _centralButtonIndex : _buttonIndex, triggerId);
    }

    private function setNewLightMode(newLightMode) {
        // As recommended, send data page 1 three times after an event to ensure that it is received quickly by the ANT+ controller
        _repeatPage = 1;
        _repeatTimes = 3; // Send three times data page 1
        _repeatDescriptor = 0xFF;
        _repeatAsAcknowledge = false;
        _lightMode = newLightMode;
    }

    private function sendNextMasterPage() {
        var pages = _lightIndex == 0
            ? unconnectedPages
            : mainConnectedPages;
        var pageNumber = pages[_currentPageIndex];
        _currentPageIndex = (_currentPageIndex + 1) % pages.size();
        if (_repeatTimes > 0) {
            _repeatTimes--;
            sendMessage(_commandData, _repeatPage, _repeatDescriptor, _repeatAsAcknowledge, false);
            if (_repeatTimes == 0 && _lightMode == 0) {
                // After holding the button for one second, the light will be turned off. When the light is off, single clicks won't work anymore. In order to avoid that,
                // turn the light back on so that single clicks and 1 sec hold will again work.
                _lightMode = _steadyMode;
            }

            return;
        }

        sendMessage(_commandData, pageNumber, 0xff, false, false);
    }

    private function sendMessage(data, pageNumber, descriptor1, sendAsAcknowledge, sharedFormat) {
        data[0] = sharedFormat ? _lightIndex : pageNumber;
        data[1] = sharedFormat ? pageNumber : _lightIndex;
        if (pageNumber == 1) {
            data[2] = (0x00 << 1); // Bike Radar Support
            data[2] |= (_lightType << 2); // Light Type
            data[2] |= (_batteryLevel << 5); // Battery Warnings
            data[3] = 0x00; // Number of Sub-lights
            data[4] = _lastCommandId; // Sequence Number of last received command
            data[5] = 0xFF /* Not supported */; // Beam Focus
            var beam = 0x00 /* Low Beam (Normal) */;
            data[6] = (beam << 1); // Beam
            data[6] |= (_lightMode << 2); // Current Mode Number
            data[7] = 0xFF /* Invalid */; // Light Intensity
        } else if (pageNumber == 2) {
            data[2] = 0x00; // Supports Auto Intensity Mode
            data[2] |= (0x00 << 1); // Supports High/Low Beam
            data[2] |= (_supportedModes.size() << 2); // # Supported Modes
            data[3] = 0x18 /* 200mAh units - 4800mAh */; // Battery Capacity
            data[4] = 0x04; // # Supported Secondary Lights.
            data[4] |= (0x00 /* Capable */ << 6); // Beam Focus Control
            data[4] |= (0x00 /* Incapable */ << 7); // Beam Intensity Control
            data[5] = _supportedStandardModes & 0xFF; // Supported Standard Modes Bit Field LSB
            data[6] = (_supportedStandardModes >> 8) & 0x7F; // Supported Standard Modes Bit Field MSB
            data[6] |= (0x00 << 7); /* Incapable */ // Synchronous Brake Light Support
            data[7] = 0x01 << _lightType; // Supported Light Types
        } else if (pageNumber == 5) {
            // Same as Flare RT is sending
            data[2] = _repeatDescriptor & 0x3F; // Mode Number
            data[2] |= (0x02 /* Defined */ << 6); // Pattern
            data[3] = 0x01 /* 10ms */; // Segment Time
            data[4] = 0x00 /* Default */; // Colour
            data[5] = 0x00; // Pattern Segment 0 - 3
            data[6] = 0x00; // Pattern Segment 4 - 7
            data[7] = 0x00; // Pattern Segment 8 - 11
        }else if (pageNumber == 80) {
            data[0] = 0x50; // Data Page Number
            data[1] = 0xFF; // Reserverd
            data[2] = 0xFF; // Reserverd
            data[3] = 1; // HW Revision
            data[4] = _manufacturerId & 0xFF; // Manufacturer ID LSB
            data[5] = (_manufacturerId >> 8) & 0xFF; // Manufacturer ID MSB
            data[6] = _modelNumber & 0xFF; // Model Number LSB
            data[7] = (_modelNumber >> 8) & 0xFF; // Model Number MSB
        } else if (pageNumber == 81) {
            data[0] = 0x51; // Data Page Number
            data[1] = 0xFF; // Reserverd
            data[2] = 0x14 /* Invalid */; // Supplemental SW Revision
            data[3] = 1; // SW version defined by manufacturer
            // The lowest 32 bits of the serial number.
            data[4] = _serialNumber & 0xFF;
            data[5] = (_serialNumber >> 8) & 0xFF;
            data[6] = (_serialNumber >> 16) & 0xFF;
            data[7] = (_serialNumber >> 24) & 0xFF;
        }

        //System.println(data);

        var message = new Ant.Message();
        message.setPayload(data);
        if (sendAsAcknowledge) {
            _channel.sendAcknowledge(message);
        } else {
            _channel.sendBroadcast(message);
        }
    }
}