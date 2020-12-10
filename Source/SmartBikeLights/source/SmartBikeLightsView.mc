using Toybox.WatchUi;
using Toybox.AntPlus;
using Toybox.Time;
using Toybox.Lang;
using Toybox.Time.Gregorian;
using Toybox.Application.Properties as Properties;

class BikeLightNetworkListener extends AntPlus.LightNetworkListener {
    private var _eventHandler;

    function initialize(eventHandler) {
        LightNetworkListener.initialize();
        _eventHandler = eventHandler.weak();
    }

    function onLightNetworkStateUpdate(state) {
        if (_eventHandler.stillAlive()) {
            _eventHandler.get().onNetworkStateUpdate(state);
        }
    }

    function onBikeLightUpdate(light) {
        if (_eventHandler.stillAlive()) {
            _eventHandler.get().onLightUpdate(light);
        }
    }
}

const lightModeCharacters = [
    "S", /* High steady beam */
    "M", /* Medium steady beam */
    "s", /* Low steady beam */
    "F", /* High flash */
    "m", /* Medium flash */
    "f"  /* Low flash */
];

const controlModes = [
    "S", /* SMART */
    "N", /* NETWORK */
    "M"  /* MANUAL */
];

const networkModes = [
    "INDV", /* LIGHT_NETWORK_MODE_INDIVIDUAL */
    "AUTO", /* LIGHT_NETWORK_MODE_AUTO */
    "HIVI"  /* LIGHT_NETWORK_MODE_HIGH_VIS */
];

class SmartBikeLightsView extends WatchUi.DataField {

    // Fonts
    private var _lightsFont;
    private var _batteryFont;
    private var _controlModeFont;

    // Fields related to lights and their network
    private var _lightNetwork;
    private var _lightNetworkListener;
    private var _networkMode;
    private var _networkState;
    private var _initializedLights = 0;
    // Every light occupies 5 elements:
    // 1. BikeLight instance
    // 2. Light text (S>)
    // 3. Light mode
    // 4. An integer that represents headlight modes
    // 5. Light control mode:  0 SMART, 1 NETWORK, 2 MANUAL
    // 6. Header text (AUTO/HIVIS/SPEED)
    // 7. Fit field
    // In case of two lights the first one will always be a headlight
    private var _lightsData = new [14];

    private var _errorCode;

    // Settings
    private var _monochrome;
    private var _titleTopPadding;
    private var _titleFont;
    private var _activityColor;

    // Pre-calculated positions
    private var _isFullScreen;
    private var _fieldWidth;
    private var _batteryWidth;
    private var _batteryY;
    private var _lightY;
    private var _titleY;

    // Parsed filters
    private var _globalFilters;
    private var _headlightFilters;
    private var _taillightFilters;

    // Fit fields
    private var _headlightFitField;
    private var _taillightFitField;

    // Pre-calculated light panel values
    (:touchScreen) private var _headlightPanel;
    (:touchScreen) private var _taillightPanel;
    (:touchScreen) private var _panelInitialized = false;

    // Fields used to evaluate filters
    private var _lastSpeed;
    private var _acceleration;
    private var _sunsetTime;
    private var _sunriseTime;
    private var _todayMoment;

    // Used as an out parameter for getting the group filter title
    private var _titleResult = [null];

    function initialize() {
        DataField.initialize();
        _lightsFont = getFont(:lightsFont);
        _batteryFont = getFont(:batteryFont);
        _controlModeFont = getFont(:controlModeFont);
        _lightNetworkListener = new BikeLightNetworkListener(self);

        var settings = WatchUi.loadResource(Rez.JsonData.Settings);
        _monochrome = !settings[0];
        _titleFont = settings[1];
        _titleTopPadding = settings[2];

        // In order to avoid calling Gregorian.utcInfo every second, calcualate Unix Timestamp of today
        var now = Time.now();
        var time = Gregorian.utcInfo(now, Time.FORMAT_SHORT);
        _todayMoment = now.value() - ((time.hour * 3600) + (time.min * 60) + time.sec);
        onSettingsChanged();
    }

    // Called from SmartBikeLightsApp.onSettingsChanged()
    function onSettingsChanged() {
        if (_errorCode == 3 || _errorCode == 4) {
            _errorCode = null;
        } else if (_errorCode != null) {
            return;
        }

        _activityColor = Properties.getValue("AC");
        try {
            var configuration = parseConfiguration(Properties.getValue("LC"));
            var lightsData = _lightsData;
            _globalFilters = configuration[0];
            _headlightFilters = configuration[2];
            _taillightFilters = configuration[4];
            if (self has :onTap) {
                _panelInitialized = false;
                _headlightPanel = configuration[5];
                _taillightPanel = configuration[6];
            }

            var headlightModes = configuration[1]; // Headlight modes
            if (!validateLightModes(lightsData[0], headlightModes == null ? _taillightFilters : _headlightFilters) ||
                !validateLightModes(lightsData[7], _taillightFilters)) {
                return;
            }

            var index = headlightModes == null ? 3 : 10;
            lightsData[3] = headlightModes;
            lightsData[index] = configuration[3]; // Taillight modes
        } catch (e instanceof Lang.Exception) {
            _errorCode = 3;
        }
    }

    // Overrides DataField.onLayout
    function onLayout(dc) {
        var height = dc.getHeight();
        var width = dc.getWidth();
        var deviceSettings = System.getDeviceSettings();
        var padding = height - 55 < 0 ? 0 : 3;
        _fieldWidth = width;
        _isFullScreen = width == deviceSettings.screenWidth && height == deviceSettings.screenHeight;
        _batteryWidth = dc.getTextWidthInPixels("B", _batteryFont);
        _batteryY = height - 19 - padding;
        _lightY = _batteryY - padding - 32 /* Lights font size */;
        _titleY = (_lightY - dc.getFontHeight(_titleFont) - _titleTopPadding) >= 0 ? _titleTopPadding : null;
    }

    // onShow() is called when this View is brought to the foreground
    function onShow() {
        // In case the user modifies the network mode or light mode outside the datafield by using the built-in Garmin lights menu,
        // the LightNetwork and BikeLight will not be updated (LightNetwork.getNetworkMode, BikeLight.mode). The only way to update
        // them is to create a new LightNetwork.
        releaseLights();
        _lightNetwork = null; // Release light network
        setupNetwork();
    }

    // Overrides DataField.compute
    function compute(activityInfo) {
        // NOTE: Use only for testing purposes when using TestLightNetwork
        //if (_lightNetwork != null && _lightNetwork has :update) {
        //    _lightNetwork.update();
        //}

        if (_initializedLights == 0 || _errorCode != null) {
            return null;
        }

        var networkMode = _lightNetwork.getNetworkMode();
        if (networkMode != _networkMode) {
            if (_networkMode != null) {
                // When the network mode is changed, the overrides set by setMode method are cleared.
                setNetworkMode(0, networkMode);
                if (_initializedLights > 1) {
                    setNetworkMode(7, networkMode);
                }

                // As here we do not know whether the user prior onUpdate method call already overrode the light modes,
                // restore them again to make sure that we have the correct mode shown
                _lightNetwork.restoreHeadlightsNetworkModeControl();
                _lightNetwork.restoreTaillightsNetworkModeControl();
            }

            _networkMode = networkMode;
        }

        _acceleration = _lastSpeed != null && _lastSpeed > 0 && activityInfo.currentSpeed > 0
            ? ((activityInfo.currentSpeed / _lastSpeed) - 1) * 100
            : null;
        if (_sunsetTime == null && activityInfo.currentLocation != null) {
            var position = activityInfo.currentLocation.toDegrees();
            var time = Gregorian.utcInfo(Time.now(), Time.FORMAT_SHORT);
            var jd = getJD(time.year, time.month, time.day);
            _sunriseTime = Math.round(calcSunriseSetUTC(true, jd, position[0], position[1]) * 60).toNumber();
            _sunsetTime = Math.round(calcSunriseSetUTC(false, jd, position[0], position[1]) * 60).toNumber();
        }

        var globalFilterResult = null;
        var lightsData = _lightsData;
        var size = _initializedLights * 7;
        var titleResult = _titleResult;
        var globalFilterTitle = null;
        for (var i = 0; i < size; i += 7) {
            if (lightsData[i + 4] != 0 /* SMART */) {
                continue;
            }

            titleResult[0] = null;
            // Calculate global filters only once and only when one of the lights is in smart mode
            globalFilterResult = globalFilterResult == null
                ? checkFilters(activityInfo, _globalFilters, titleResult, null)
                : globalFilterResult;
            if (globalFilterResult == 0) {
                setLightMode(i, 0, null);
                continue;
            }

            if (globalFilterTitle == null) {
                globalFilterTitle = titleResult[0];
            }

            var light = lightsData[i];
            var lightMode = checkFilters(
                activityInfo,
                light.type == 0 /* LIGHT_TYPE_HEADLIGHT */ ? _headlightFilters : _taillightFilters,
                titleResult,
                light.identifier);
            var title = titleResult[0] != null ? titleResult[0] : globalFilterTitle;
            if (!setLightMode(i, lightMode, title) && lightsData[i + 5] != title) {
                lightsData[i + 5] = title;
            }
        }

        _lastSpeed = activityInfo.currentSpeed;

        return null;
    }

    // Overrides DataField.onUpdate
    function onUpdate(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var bgColor = getBackgroundColor();
        var fgColor = 0x000000; /* COLOR_BLACK */
        if (bgColor == 0x000000 /* COLOR_BLACK */) {
            fgColor = 0xFFFFFF; /* COLOR_WHITE */
        }

        dc.setColor(fgColor, bgColor);
        dc.clear();

        if (_errorCode != null) {
            drawCenterText(dc, "Error " + _errorCode, fgColor, 4, width, height);
            return;
        }

        if (_initializedLights == 0) {
            drawCenterText(dc, "No network", fgColor, 2, width, height);
            return;
        }

        draw(dc, width, height, fgColor, bgColor);
    }

    private function releaseLights() {
        _initializedLights = 0;
        _lightsData[0] = null;
        _lightsData[7] = null;
    }

    function onNetworkStateUpdate(networkState) {
        _networkState = networkState;
        if (_initializedLights > 0 && networkState != 2 /* LIGHT_NETWORK_STATE_FORMED */) {
            // We have to reinitialize in case the light network is dropped after its formation
            releaseLights();
            return;
        }

        if (_initializedLights > 0 || networkState != 2 /* LIGHT_NETWORK_STATE_FORMED */) {
            return;
        }

        // Initialize lights
        var lights = _lightNetwork.getBikeLights();
        var lightsData = _lightsData;
        var recordLightModes = Properties.getValue("RL");
        for (var i = 0; i < lights.size(); i++) {
            var light = lights[i];
            var lightType = light.type;
            var capableModes = light.getCapableModes();
            var filters = lightType == 0 /* LIGHT_TYPE_HEADLIGHT */ ? _headlightFilters : _taillightFilters;
            var controlMode = getLightData("CM", lightType, filters != null ? 0 /* SMART */ : 1 /* NETWORK */);
            var lightMode = getInitialLightMode(light, controlMode);
            var lightModeIndex = capableModes.indexOf(lightMode);
            if (lightModeIndex < 0) {
                lightModeIndex = 0;
                lightMode = 0; /* LIGHT_MODE_OFF */
            }

            var dataIndex = lightType == 0 /* LIGHT_TYPE_HEADLIGHT */ || lights.size() == 1 ? 0
                : lightType == 2 ? 7
                : -1;
            if (dataIndex < 0) {
                _errorCode = 1;
                return;
            }

            if (lightsData[dataIndex] != null) {
                _errorCode = 2;
                return;
            }

            if (recordLightModes && lightsData[dataIndex + 6] == null) {
                var field = createField(
                    lightType == 0 /* LIGHT_TYPE_HEADLIGHT */ ? "headlight_mode" : "taillight_mode",
                    lightType, // Id
                    2 /*DATA_TYPE_UINT8 */,
                    {
                        :mesgType=> 20 /* Fit.MESG_TYPE_RECORD */
                    }
                );

                lightsData[dataIndex + 6] = field;
                field.setData(lightMode); // Set initial mode
            }

            var lightModes = lightsData[dataIndex + 3]; // Set when parsing lights configuration
            var lightText = getLightText(lightType, lightMode, lightModes);
            lightsData[dataIndex] = light;
            lightsData[dataIndex + 1] = lightText;
            lightsData[dataIndex + 2] = lightMode;
            lightsData[dataIndex + 4] = controlMode;
            // In case of SMART or MANUAL control mode, we have to set the light mode in order to prevent the network mode
            // from changing it.
            if (controlMode != 1 /* NETWORK */) {
                light.setMode(lightMode);
            } else {
                setNetworkMode(dataIndex, _lightNetwork.getNetworkMode());
            }

            // Allow the initialization to complete even if the modes are invalid, so that the user
            // is able to correct them by modifying the light configuration
            validateLightModes(light, lightType == 0 /* LIGHT_TYPE_HEADLIGHT */ ? _headlightFilters : _taillightFilters);

            _initializedLights++;
        }
    }

    function onLightUpdate(light) {
        var lightsData = _lightsData;
        var dataIndex = light.type == 0 /* LIGHT_TYPE_HEADLIGHT */ ? 0 : 7;
        lightsData[dataIndex] = light;
        if (light.mode == lightsData[dataIndex + 2]) {
            return;
        }

        lightsData[dataIndex + 1] = getLightText(light.type, light.mode, lightsData[dataIndex + 3]);
        lightsData[dataIndex + 2] =  light.mode;
        var fitField = lightsData[dataIndex + 6];
        if (fitField != null) {
            fitField.setData(light.mode);
        }
    }

    (:touchScreen)
    function onTap(location) {
        if (_fieldWidth == null || _initializedLights == 0 || _errorCode != null) {
            return false;
        }

        // Find which light was tapped
        var dataIndex = _initializedLights == 1 || (_fieldWidth / 2) > location[0]
            ? 0 /* Headlight index */
            : 7; /* Taillight index */
        var lightsData = _lightsData;
        var light = lightsData[dataIndex];
        if (getLightBatteryStatus(light.identifier) > 5) {
            return false; // Battery is disconnected
        }

        var lightType = light.type;
        var controlMode = lightsData[dataIndex + 4];
        if (_isFullScreen) {
            return onLightPanelTap(location, dataIndex, lightType, controlMode);
        }

        var modes = light.getCapableModes();
        var index = modes.indexOf(lightsData[dataIndex + 2]);
        var newControlMode = null;
        var newMode = null;
        // Change to the next mode
        if (controlMode == 0 /* SMART */) {
            newControlMode = 1; /* NETWORK */
        } else if (controlMode == 1 /* NETWORK */) {
            newControlMode = 2; /* MANUAL */
            index = -1;
        }

        if (controlMode == 2 /* MANUAL */ || newControlMode == 2 /* MANUAL */) {
            index = (index + 1) % modes.size();
            if (controlMode == 2 /* MANUAL */ && index == 0) {
                newControlMode = 0; /* SMART */
                // The mode will be calculated in compute method
            } else {
                newMode = modes[index];
            }
        }

        setLightAndControlMode(dataIndex, lightType, newMode, newControlMode);
        return true;
    }

    (:touchScreen)
    private function setLightAndControlMode(dataIndex, lightType, newMode, newControlMode) {
        var controlMode = _lightsData[dataIndex + 4];
        if (newControlMode == 1 /* NETWORK */) {
            setNetworkMode(dataIndex, _networkMode);
            if (lightType == 0 /* LIGHT_TYPE_HEADLIGHT */) {
                _lightNetwork.restoreHeadlightsNetworkModeControl();
            } else {
                _lightNetwork.restoreTaillightsNetworkModeControl();
            }
        } else if ((controlMode == 2 /* MANUAL */ && newControlMode == null) || newControlMode == 2 /* MANUAL */) {
            setLightData("MM", lightType, newMode);
            setLightMode(dataIndex, newMode, null);
        }

        if (newControlMode != null) {
            setLightData("CM", lightType, newControlMode);
            _lightsData[dataIndex + 4] = newControlMode;
        }
    }

    (:touchScreen)
    private function onLightPanelTap(location, dataIndex, lightType, controlMode) {
        var panelData = lightType == 0 /* LIGHT_TYPE_HEADLIGHT */ ? _headlightPanel : _taillightPanel;
        var totalButtonGroups = panelData[0];
        var tapX = location[0];
        var tapY = location[1];
        var groupIndex = 6;
        while (groupIndex < panelData.size()) {
            var totalButtons = panelData[groupIndex];
            // All buttons in the group have the same y and height, take the first one
            var topY = panelData[groupIndex + 6];
            var height = panelData[groupIndex + 8];
            if (tapY >= topY && tapY < (topY + height)) {
                for (var j = 0; j < totalButtons; j++) {
                    var buttonIndex = groupIndex + 1 + (j * 8);
                    var leftX = panelData[buttonIndex + 4];
                    var width = panelData[buttonIndex + 6];
                    if (tapX >= leftX && tapX < (leftX + width)) {
                        var newMode = panelData[buttonIndex];
                        var newControlMode = null;
                        if (newMode < 0) {
                            newControlMode = controlMode != 0 /* SMART */ ? 0 : 1 /* NETWORK */;
                            newMode = null;
                        } else if (controlMode != 2 /* MANUAL */) {
                            newControlMode = 2;
                        }

                        setLightAndControlMode(dataIndex, lightType, newMode, newControlMode);
                        return true;
                    }
                }
            }

            groupIndex += 1 + (totalButtons * 8);
        }

        return false;
    }

    (:testNetwork)
    private function setupNetwork() {
        _lightNetwork = new TestLightNetwork(_lightNetworkListener);
    }

    (:deviceNetwork)
    private function setupNetwork() {
        _lightNetwork = new AntPlus.LightNetwork(_lightNetworkListener);
    }

    (:nonTouchScreen)
    private function draw(dc, width, height, fgColor, bgColor) {
        drawLights(dc, width, height, fgColor, bgColor);
    }

    (:touchScreen)
    private function draw(dc, width, height, fgColor, bgColor) {
        if (_isFullScreen) {
            drawLightPanels(dc, width, height, fgColor, bgColor);
        } else {
            drawLights(dc, width, height, fgColor, bgColor);
        }
    }

    (:touchScreen)
    private function drawLightPanels(dc, width, height, fgColor, bgColor) {
        if (!_panelInitialized) {
            initializeLightPanels(dc, width, height);
        }

        // In case the initialization was not successful, skip drawing
        if (_errorCode != null) {
            return;
        }

        dc.setPenWidth(2);
        if (_initializedLights == 1) {
            drawLightPanel(dc, 0, _lightsData[0].type == 0 /* LIGHT_TYPE_HEADLIGHT */ ? _headlightPanel : _taillightPanel, width, height, fgColor, bgColor);
            return;
        }

        drawLightPanel(dc, 0, _headlightPanel, width, height, fgColor, bgColor);
        drawLightPanel(dc, 7, _taillightPanel, width, height, fgColor, bgColor);
    }

    (:touchScreen)
    private function getDefaultLightPanelData(lightType, capableModes) {
        var totalButtonGroups = capableModes.size();
        var data = new  [6 + (8 * (totalButtonGroups + 1 /* For control mode button */)) + totalButtonGroups];
        data[0] = totalButtonGroups; // Total button groups
        data[1] = lightType == 0 /* LIGHT_TYPE_HEADLIGHT */ ? "Headlight" : "Taillight"; // Light name
        var dataIndex = 6;
        for (var i = 0; i < totalButtonGroups; i++) {
            var mode = capableModes[i];
            var totalButtons = mode == 0 /* Off */ ? 2 : 1; // Number of buttons;
            data[dataIndex] = totalButtons; // Total buttons in the group
            data[dataIndex + 1] = mode; // Light mode
            data[dataIndex + 2] = mode == 0 ? "Off" : mode.toString(); // Mode name
            if (mode == 0 /* Off */) {
                data[dataIndex + 9] = -1;
            }

            dataIndex += 1 + (totalButtons * 8);
        }

        return data;
    }

    (:touchScreen)
    private function initializeLightPanels(dc, width, height) {
        if (_initializedLights == 1) {
            initializeLightPanel(dc, 0, 2, width, height);
        } else {
            initializeLightPanel(dc, 0, 1, width, height);
            initializeLightPanel(dc, 7, 3, width, height);
        }

        _panelInitialized = true;
    }

    (:touchScreen)
    private function initializeLightPanel(dc, dataIndex, position, width, height) {
        var x = position < 3 ? 0 : (width / 2); // Left x
        var y = 0;
        var margin = 2;
        var buttonGroupWidth = (position != 2 ? width / 2 : width);
        var light = _lightsData[dataIndex];
        var capableModes = light.getCapableModes();
        var fontTopPaddings = WatchUi.loadResource(Rez.JsonData.FontTopPaddings)[0];
        // [:TotalButtonGroups:, :LightName:, :LightNameX:, :LightNameY:, :BatteryX:, :BatteryY:, (<ButtonGroup>)+]
        // <ButtonGroup> := [:NumberOfButtons:, :Mode:, :TitleX:, :TitleFont:, (<TitlePart>)+, :ButtonLeftX:, :ButtonTopY:, :ButtonWidth:, :ButtonHeight:){:NumberOfButtons:} ]
        // <TitlePart> := [(:Title:, :TitleY:)+]
        var panelData = light.type == 0 /* LIGHT_TYPE_HEADLIGHT */ ? _headlightPanel : _taillightPanel;
        var totalButtonGroups;
        var i;
        if (panelData == null) {
            totalButtonGroups = capableModes.size();
            panelData = getDefaultLightPanelData(light.type, capableModes);
            if (light.type == 0 /* LIGHT_TYPE_HEADLIGHT */) {
                _headlightPanel = panelData;
            } else {
                _taillightPanel = panelData;
            }
        } else {
            totalButtonGroups = panelData[0];
        }

        var buttonHeight = (height - 20 /* Battery */).toFloat() / totalButtonGroups;
        var fontResult = [0];
        var buttonPadding = margin * 2;
        var textPadding = margin * 4;
        var groupIndex = 6;
        for (i = 0; i < totalButtonGroups; i++) {
            var totalButtons = panelData[groupIndex];
            var buttonWidth = buttonGroupWidth / totalButtons;
            var titleParts = null;
            for (var j = 0; j < totalButtons; j++) {
                var buttonIndex = groupIndex + 1 + (j * 8);
                var buttonX = x + (buttonWidth * j);
                var mode = panelData[buttonIndex];
                if (mode > 0 && capableModes.indexOf(mode) < 0) {
                    _errorCode = 4;
                    return;
                }

                var modeTitle = mode < 0 ? "M" : panelData[buttonIndex + 1];
                var titleList = StringHelper.trimText(dc, modeTitle, 4, buttonWidth - textPadding, buttonHeight - textPadding, fontTopPaddings, fontResult);
                var titleFont = fontResult[0];
                var titleFontHeight = dc.getFontHeight(titleFont);
                var titleFontTopPadding = StringHelper.getFontTopPadding(titleFont, fontTopPaddings);
                var titleY = y + (buttonHeight - (titleList.size() * titleFontHeight) - titleFontTopPadding) / 2 + margin;
                titleParts = new [2 * titleList.size()];
                for (var k = 0; k < titleList.size(); k++) {
                   var partIndex = k * 2;
                   titleParts[partIndex] = titleList[k];
                   titleParts[partIndex + 1] = titleY;
                   titleY += titleFontHeight;
                }

                // Set data
                panelData[buttonIndex + 1] = buttonX + (buttonWidth / 2); // Title x
                panelData[buttonIndex + 2] = titleFont; // Title font
                panelData[buttonIndex + 3] = titleParts; // Title parts
                panelData[buttonIndex + 4] = buttonX; // Button left x
                panelData[buttonIndex + 5] = y; // Button top y
                panelData[buttonIndex + 6] = buttonWidth; // Button width
                panelData[buttonIndex + 7] = buttonHeight; // Button height
            }

            groupIndex += 1 + (totalButtons * 8);
            y += buttonHeight;
        }

        // Calculate light name and battery positions
        x = Math.round(width * 0.25f * position);
        var lightName = StringHelper.trimTextByWidth(dc, panelData[1], 1, buttonGroupWidth - buttonPadding - _batteryWidth);
        var lightNameWidth = lightName != null ? dc.getTextWidthInPixels(lightName, 1) : 0;
        var lightNameHeight = dc.getFontHeight(1);
        var lightNameTopPadding = StringHelper.getFontTopPadding(1, fontTopPaddings);
        panelData[1] = lightName; // Light name
        panelData[2] = x - (_batteryWidth / 2) - (margin / 2); // Light name x
        panelData[3] = y + ((20 - lightNameHeight - lightNameTopPadding) / 2); // Light name y
        panelData[4] = x + (lightNameWidth / 2) + (margin / 2); // Battery x
        panelData[5] = y - 1; // Battery y
    }

    (:touchScreen)
    private function drawLightPanel(dc, dataIndex, panelData, width, height, fgColor, bgColor) {
        var lightsData = _lightsData;
        var light = lightsData[dataIndex];
        var controlMode = lightsData[dataIndex + 4];
        var lightMode = lightsData[dataIndex + 2];
        var margin = 2;
        var buttonPadding = margin * 2;
        var batteryStatus = getLightBatteryStatus(light.identifier);
        if (batteryStatus > 5) {
            return;
        }

        // [:TotalButtonGroups:, :LightName:, :LightNameX:, :LightNameY:, :BatteryX:, :BatteryY:, (<ButtonGroup>)+]
        // <ButtonGroup> := [:NumberOfButtons:, :Mode:, :TitleX:, :TitleFont:, (<TitlePart>)+, :ButtonLeftX:, :ButtonTopY:, :ButtonWidth:, :ButtonHeight:){:NumberOfButtons:} ]
        // <TitlePart> := [(:Title:, :TitleY:)+]
        var totalButtonGroups = panelData[0];
        var groupIndex = 6;
        for (var i = 0; i < totalButtonGroups; i++) {
            var totalButtons = panelData[groupIndex];
            for (var j = 0; j < totalButtons; j++) {
                var buttonIndex = groupIndex + 1 + (j * 8);
                var mode = panelData[buttonIndex];
                var titleX = panelData[buttonIndex + 1];
                var titleFont = panelData[buttonIndex + 2];
                var titleParts = panelData[buttonIndex + 3];
                var buttonX = panelData[buttonIndex + 4] + margin;
                var buttonY = panelData[buttonIndex + 5] + margin;
                var buttonWidth = panelData[buttonIndex + 6] - buttonPadding;
                var buttonHeight = panelData[buttonIndex + 7] - buttonPadding;
                var isSelected = lightMode == mode;

                setTextColor(dc, isSelected ? _activityColor : bgColor);
                dc.fillRoundedRectangle(buttonX, buttonY, buttonWidth, buttonHeight, 8);
                setTextColor(dc, fgColor);
                dc.drawRoundedRectangle(buttonX, buttonY, buttonWidth, buttonHeight, 8);
                setTextColor(dc, isSelected ? 0xFFFFFF /* COLOR_WHITE */ : fgColor);
                if (mode < 0) {
                    dc.drawText(titleX, titleParts[1], titleFont, $.controlModes[controlMode], 1 /* TEXT_JUSTIFY_CENTER */);
                } else {
                    for (var k = 0; k < titleParts.size(); k += 2) {
                        dc.drawText(titleX, titleParts[k + 1], titleFont, titleParts[k], 1 /* TEXT_JUSTIFY_CENTER */);
                    }
                }
            }

            groupIndex += 1 + (totalButtons * 8);
        }

        setTextColor(dc, fgColor);
        if (panelData[1] != null) {
            dc.drawText(panelData[2], panelData[3], 1, panelData[1], 1 /* TEXT_JUSTIFY_CENTER */);
        }

        drawBattery(dc, fgColor, panelData[4], panelData[5], batteryStatus);
    }

    private function drawLights(dc, width, height, fgColor, bgColor) {
        if (_initializedLights == 1) {
            drawLight(0, 2, dc, width, fgColor, bgColor);
            return;
        }

        // Draw separator
        setTextColor(dc, _activityColor);
        dc.setPenWidth(_monochrome ? 1 : 2);
        dc.drawLine(width / 2, 0, width / 2, height);
        drawLight(0, 1, dc, width, fgColor, bgColor);
        drawLight(7, 3, dc, width, fgColor, bgColor);
    }

    private function drawLight(dataIndex, position, dc, width, fgColor, bgColor) {
        var lightsData = _lightsData;
        var lightX = Math.round(width * 0.25f * position);
        var light = lightsData[dataIndex];
        var lightText = lightsData[dataIndex + 1];
        var controlMode = lightsData[dataIndex + 4];
        var title = lightsData[dataIndex + 5];
        var batteryStatus = getLightBatteryStatus(light.identifier);
        var justification = light.type;
        var direction = justification == 0 ? 1 : -1;
        var lightXOffset = justification == 0 ? -4 : 2;
        dc.setColor(fgColor, bgColor);

        if (title != null && _titleY != null) {
            dc.drawText(lightX, _titleY, _titleFont, title, 1 /* TEXT_JUSTIFY_CENTER */);
        }

        dc.drawText(lightX + (direction * (_batteryWidth / 2)) + lightXOffset, _lightY, _lightsFont, getCurrentLightText(light.type, lightText, batteryStatus), justification);
        dc.drawText(lightX + (direction * 8), _lightY + 11, _controlModeFont, $.controlModes[controlMode], 1 /* TEXT_JUSTIFY_CENTER */);
        drawBattery(dc, fgColor, lightX, _batteryY, batteryStatus);
    }

    private function drawBattery(dc, fgColor, x, y, batteryStatus) {
        // Draw the battery shell
        setTextColor(dc, fgColor);
        dc.drawText(x, y, _batteryFont, "B", 1 /* TEXT_JUSTIFY_CENTER */);

        // Do not draw the indicator in case the light is not connected anymore or an invalid status is given
        // The only way to detect whether the light is still connected is to check whether the its battery status is not null
        if (batteryStatus > 5) {
            return;
        }

        // Draw the battery indicator
        var color = batteryStatus == 5 /* BATT_STATUS_CRITICAL */ ? 0xFF0000 /* COLOR_RED */
            : batteryStatus > 2 /* BATT_STATUS_GOOD */ ? 0xFF5500 /* COLOR_ORANGE */
            : 0x00AA00; /* COLOR_DK_GREEN */
        setTextColor(dc, color);
        dc.drawText(x, y, _batteryFont, batteryStatus.toString(), 1 /* TEXT_JUSTIFY_CENTER */);
    }

    private function drawCenterText(dc, text, color, font, width, height) {
        setTextColor(dc, color);
        dc.drawText(width / 2, height / 2, font, text, 1 /* TEXT_JUSTIFY_CENTER */ | 4 /* TEXT_JUSTIFY_VCENTER */);
    }

    private function setTextColor(dc, color) {
        dc.setColor(_monochrome ? 0x000000 /* COLOR_BLACK */ : color, -1 /* COLOR_TRANSPARENT */);
    }

    private function setLightMode(index, mode, title) {
        var lightsData = _lightsData;
        lightsData[index + 5] = title;
        if (lightsData[index + 2] == mode) {
            return false;
        }

        var light = lightsData[index];
        lightsData[index + 1] = getLightText(light.type, mode, lightsData[index + 3]);
        lightsData[index + 2] = mode;
        light.setMode(mode);

        return true;
    }

    private function getLightBatteryStatus(lightIdentifier) {
        var status = _lightNetwork.getBatteryStatus(lightIdentifier);
        return status == null ? 6 /* Disconnected */ : status.batteryStatus;
    }

    private function getInitialLightMode(light, controlMode) {
        return controlMode == 0 /* SMART */ ? 0 /* LIGHT_MODE_OFF */ // The mode will be calculated and set in the compute method
            : controlMode == 1 /*NETWORK*/ ? light.mode
            : getLightData("MM", light.type, 0 /* LIGHT_MODE_OFF */);
    }

    (:touchScreen)
    private function getLightData(id, lightType, defaultValue) {
        var key = id + lightType;
        var value = Application.Storage.getValue(key);
        if (value == null) {
            // First application startup
            value = defaultValue;
            Application.Storage.setValue(key, value);
        }

        return value;
    }

    (:nonTouchScreen)
    private function getLightData(id, lightType, defaultValue) {
        return defaultValue;
    }

    (:touchScreen)
    private function setLightData(id, lightType, value) {
        Application.Storage.setValue(id + lightType, value);
    }

    private function setNetworkMode(index, networkMode) {
        _lightsData[index + 4] = 1 /*NETWORK */;
        _lightsData[index + 5] = networkMode != null && networkMode < $.networkModes.size()
            ? $.networkModes[networkMode]
            : "TRAIL";
    }

    private function getCurrentLightText(lightType, lightText, batteryStatus) {
        return batteryStatus > 5 // Whether the light is disconnected
            ? lightType == 0 /* LIGHT_TYPE_HEADLIGHT */ ? "X>" : "<X"
            : lightText;
    }

    private function getLightText(lightType, mode, lightModes) {
        var lightModeCharacter = null;
        if (mode > 0) {
            var index = lightModes == null
                ? -1
                : ((lightModes >> (4 * ((mode > 9 ? mode - 49 : mode) - 1))) & 0x0F).toNumber() - 1;
            lightModeCharacter = index < 0 || index >= $.lightModeCharacters.size()
                ? "?" /* Unknown */
                : $.lightModeCharacters[index];
        }

        return lightType == 0 /* LIGHT_TYPE_HEADLIGHT */
            ? lightModeCharacter == null ? ">" : lightModeCharacter + ">"
            : lightModeCharacter == null ? "<" : "<" + lightModeCharacter;
    }

    private function getFont(key) {
        return WatchUi.loadResource(Rez.Fonts[key]);
    }

    private function validateLightModes(light, filters) {
        if (filters == null || light == null) {
            return true;
        }

        var i = 0;
        var capableModes = light.getCapableModes();
        while (i < filters.size()) {
            var totalFilters = filters[i + 1];
            if (capableModes.indexOf(filters[i + 2]) < 0) {
                _errorCode = 4;
                return false;
            }

            i = i + 3 + (totalFilters * 3);
        }

        return true;
    }

    private function checkFilters(activityInfo, filters, titleResult, lightIdentifier) {
        if (filters == null) {
            titleResult[0] = null;
            return lightIdentifier != null ? 0 : 1;
        }

        var i = 0;
        var nextGroupIndex = null;
        var lightMode = 1;
        var title = null;
        while (i < filters.size()) {
            var data = filters[i];
            if (nextGroupIndex == null) {
                title = data;
                var totalFilters = filters[i + 1];
                if (lightIdentifier != null) {
                    lightMode = filters[i + 2];
                    i += 3;
                } else {
                    i += 2;
                }

                nextGroupIndex = i + (totalFilters * 3);
                continue;
            } else if (i >= nextGroupIndex) {
                titleResult[0] = title;
                return lightMode;
            }

            var filterValue = filters[i + 2];
            var result = data == 'E' ? isWithinTimespan(filters, i, filterValue)
                : data == 'F' ? isInsideAnyPolygon(activityInfo, filterValue)
                : data == 'D' ? true
                : checkGenericFilter(activityInfo, data, filters[i + 1], filterValue, lightIdentifier);
            if (result) {
                i += 3;
            } else {
                i = nextGroupIndex;
                nextGroupIndex = null;
            }
        }

        if (nextGroupIndex != null) {
            titleResult[0] = title;
            return lightMode;
        }

        titleResult[0] = null;
        return 0;
    }

    private function isWithinTimespan(filters, index, filterValue) {
        if (filterValue.size() == 4) {
            filterValue = initializeTimeFilter(filterValue);
            if (filterValue == null) {
                return false;
            }

            filters[index + 2] = filterValue;
        }

        var value = (Time.now().value() - _todayMoment) % 86400;
        var from = filterValue[0];
        var to = filterValue[1];
        return from > to /* Whether timespan goes into the next day */
            ? value > from || value < to
            : value > from && value < to;
    }

    private function checkGenericFilter(activityInfo, filterType, operator, filterValue, lightIdentifier) {
        var value = filterType == 'C' ? activityInfo.currentSpeed
            : filterType == 'A' ? _acceleration
            : filterType == 'B' ? lightIdentifier != null ? getLightBatteryStatus(lightIdentifier) : null
            : filterType == 'G' ? (activityInfo.currentLocationAccuracy == null ? 0 : activityInfo.currentLocationAccuracy)
            : null;
        if (value == null) {
            return false;
        }

        return operator == '<' ? value < filterValue
            : operator == '>' ? value > filterValue
            : operator == '=' ? value == filterValue
            : false;
    }

    private function initializeTimeFilter(filterValue) {
        var from = initializeTimeFilterPart(filterValue, 0);
        var to = initializeTimeFilterPart(filterValue, 2);

        return from == null || to == null ? null : [from, to];
    }

    private function initializeTimeFilterPart(filterValue, index) {
        var type = filterValue[index];
        if (type > 0 /* Sunset or sunrise */ && _sunsetTime == null) {
            return null; // Not able to initialize
        }

        var value = filterValue[index + 1];
        return type == 2 /* Sunset */ ? _sunsetTime + value
            : type == 1 /* Sunrise */ ? _sunriseTime + value
            : value;
    }
}
