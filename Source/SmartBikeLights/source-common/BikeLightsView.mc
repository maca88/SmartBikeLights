using Toybox.WatchUi;
using Toybox.AntPlus;
using Toybox.Math;
using Toybox.System;
using Toybox.Application;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Application.Properties as Properties;

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
    "HIVI", /* LIGHT_NETWORK_MODE_HIGH_VIS */
    "TRAIL"
];

(:dataField)
class BaseView extends WatchUi.DataField {

    function initialize() {
        DataField.initialize();
    }
}

(:widget)
class BaseView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }
}

class BikeLightsView extends BaseView {

    // Fonts
    protected var _lightsFont;
    protected var _batteryFont;
    protected var _controlModeFont;

    // Fields related to lights and their network
    protected var _lightNetwork;
    protected var _lightNetworkListener;
    protected var _networkMode;
    protected var _networkState;
    protected var _initializedLights = 0;

    // Light data:
    // 0. BikeLight instance
    // 1. Light text (S>)
    // 2. Light mode
    // 3. An integer that represents light modes
    // 4. Light control mode:  0 SMART, 1 NETWORK, 2 MANUAL
    // 5. Title
    // 6. Fit field
    // 7. Next light mode
    // 8. Next title
    // 9. Compute setMode timeout
    // 10. Minimum active filter group time in seconds
    var headlightData = new [11]; // Can represent a taillight in case it is the only one
    var taillightData = new [11];

    protected var _errorCode;

    // Settings
    protected var _separatorWidth;
    protected var _titleTopPadding;
    protected var _titleFont;
    protected var _activityColor;
    (:touchScreen) private var _controlModeOnly = false;

    // Pre-calculated positions
    (:rectangle) protected var _isFullScreen;
    (:rectangle) protected var _fieldWidth;
    protected var _batteryWidth = 49;
    protected var _batteryY;
    protected var _lightY;
    protected var _titleY;
    protected var _offsetX;

    // Parsed filters
    protected var _globalFilters;
    protected var _headlightFilters;
    protected var _taillightFilters;

    (:touchScreen) private var _headlightPanelSettings;
    (:touchScreen) private var _taillightPanelSettings;

    // Pre-calculated light panel values
    (:touchScreen) private var _headlightPanel;
    (:touchScreen) private var _taillightPanel;
    (:touchScreen) private var _panelInitialized = false;

    // Settings data
    (:settings) var headlightSettings;
    (:settings) var taillightSettings;
    (:settings) private var _settingsInitialized;
    (:highMemory) private var _individualNetwork;

    // Fields used to evaluate filters
    protected var _todayMoment;
    protected var _sunsetTime;
    protected var _sunriseTime;
    (:dataField) private var _lastSpeed;
    (:dataField) private var _acceleration;
    (:highMemory) private var _bikeRadar;

    private var _lastUpdateTime = 0;
    private var _lastOnShowCallTime = 0;

    // Used as an out parameter for getting the group filter title
    private var _filterResult = [null /* Title */, 0 /* Filter timeout */];

    function initialize() {
        BaseView.initialize();
        var fonts = Rez.Fonts;
        _lightsFont = WatchUi.loadResource(fonts[:lightsFont]);
        _batteryFont = WatchUi.loadResource(fonts[:batteryFont]);
        _controlModeFont = WatchUi.loadResource(fonts[:controlModeFont]);
        _lightNetworkListener = new BikeLightNetworkListener(self);

        // In order to avoid calling Gregorian.utcInfo every second, calcualate Unix Timestamp of today
        var now = Time.now();
        var time = Gregorian.utcInfo(now, 0 /* FORMAT_SHORT */);
        _todayMoment = now.value() - ((time.hour * 3600) + (time.min * 60) + time.sec);

        onSettingsChanged();
    }

    // Called from SmartBikeLightsApp.onSettingsChanged()
    function onSettingsChanged() {
        //System.println("onSettingsChanged" + " timer=" + System.getTimer());
        var errorCode = _errorCode;
        if (errorCode != null && errorCode < 3) {
            return;
        }

        errorCode = null;
        _activityColor = getPropertyValue("AC");
        try {
            // Free memory before parsing to avoid out of memory exception
            _globalFilters = null;
            _headlightFilters = null;
            _taillightFilters = null;
            var configuration = parseConfiguration(getPropertyValue("LC"));
            _globalFilters = configuration[0];
            _headlightFilters = configuration[2];
            _taillightFilters = configuration[4];
            setupLightButtons(configuration);

            var headlightModes = configuration[1]; // Headlight modes
            if (validateLightModes(headlightData[0]) && validateLightModes(taillightData[0])) {
                headlightData[3] = headlightModes;
                var lightData = headlightModes == null ? headlightData : taillightData;
                lightData[3] = configuration[3];
            } else {
                errorCode = 4;
            }
        } catch (e) {
            errorCode = 3;
        }

        _errorCode = errorCode;
    }

    // Overrides DataField.onLayout
    function onLayout(dc) {
        // Due to getObsurityFlags returning incorrect results here, we have to postpone the calculation to onUpdate method
        _lightY = null; // Force to pre-calculate again
    }

    (:lowMemory :deviceNetwork)
    function onShow() {
        //System.println("onShow=" + _lastUpdateTime  + " timer=" + System.getTimer());
        var timer = System.getTimer();
        _lastOnShowCallTime = timer;
        if (_initializedLights > 0 && timer - _lastUpdateTime < 1500) {
            initializeLights(null, false);
            return;
        }

        releaseLights();
        _lightNetwork = null; // Release light network
        _lightNetwork = new AntPlus.LightNetwork(_lightNetworkListener);
    }

    (:lowMemory :testNetwork)
    function onShow() {
        //System.println("onShow=" + _lastUpdateTime  + " timer=" + System.getTimer());
        var timer = System.getTimer();
        _lastOnShowCallTime = timer;
        if (_initializedLights > 0 && timer - _lastUpdateTime < 1500) {
            initializeLights(null, false);
            return;
        }

        releaseLights();
        _lightNetwork = null; // Release light network
        _lightNetwork = new TestNetwork.TestLightNetwork(_lightNetworkListener);
    }

    (:highMemory)
    function onShow() {
        //System.println("onShow=" + _lastUpdateTime  + " timer=" + System.getTimer());
        var timer = System.getTimer();
        _lastOnShowCallTime = timer;
        if (_lightNetwork instanceof AntLightNetwork.IndividualLightNetwork) {
            // We don't need to recreate IndividualLightNetwork as the network mode does not change
            return;
        }

        // When start button is pressed onShow is called, skip re-initialization in such case. This also prevents
        // a re-initialization when switching between two data screens that both contain this data field.
        if (_initializedLights > 0 && timer - _lastUpdateTime < 1500) {
            initializeLights(null, false);
            return;
        }

        // In case the user modifies the network mode outside the data field by using the built-in Garmin lights menu,
        // the LightNetwork mode will not be updated (LightNetwork.getNetworkMode). The only way to update it is to
        // create a new LightNetwork.
        recreateLightNetwork();
    }

    (:highMemory)
    function release() {
        releaseLights();
        if (_lightNetwork != null && _lightNetwork has :release) {
            _lightNetwork.release();
        }

        _lightNetwork = null; // Release light network
    }

    // Overrides DataField.compute
    (:dataField)
    function compute(activityInfo) {
        //System.println("usedMemory=" + System.getSystemStats().usedMemory);
        // Needed for TestLightNetwork and IndividualLightNetwork
        if (_errorCode == null && _lightNetwork != null && _lightNetwork has :update) {
            _errorCode = _lightNetwork.update();
        }

        var initializedLights = _initializedLights;
        if (initializedLights == 0 || _errorCode != null) {
            return null;
        }

        var lastSpeed = _lastSpeed;
        var currentSpeed = activityInfo.currentSpeed;
        _acceleration = lastSpeed != null && currentSpeed != null && lastSpeed > 0 && currentSpeed > 0
            ? ((currentSpeed / lastSpeed) - 1) * 100
            : null;
        if (_sunsetTime == null && activityInfo.currentLocation != null) {
            var position = activityInfo.currentLocation.toDegrees();
            var time = Gregorian.utcInfo(Time.now(), 0 /* FORMAT_SHORT */);
            _sunriseTime = getSunriseSet(true, time, position);
            _sunsetTime = getSunriseSet(false, time, position);
        }

        var globalFilterResult = null;
        var filterResult = _filterResult;
        var globalFilterTitle = null;
        for (var i = 0; i < initializedLights; i++) {
            var lightData = getLightData(i, null);
            if (lightData[7] != null) {
                if (lightData[9] <= 0) {
                    lightData[7] = null;
                } else {
                    lightData[9]--; /* Timeout */
                    continue;
                }
            }

            if (lightData[4] != 0 /* SMART */ || lightData[2] < 0 /* Disconnected */) {
                lightData[10] = null;
                continue;
            }

            var filterTimer = lightData[10];
            if (filterTimer != null && filterTimer > 1) {
                lightData[10]--;
                continue;
            }

            filterResult[0] = null;
            // Calculate global filters only once and only when one of the lights is in smart mode
            globalFilterResult = globalFilterResult == null
                ? checkFilters(activityInfo, _globalFilters, filterResult, null)
                : globalFilterResult;
            if (globalFilterResult == 0) {
                setLightMode(lightData, 0, null, false);
                continue;
            }

            if (globalFilterTitle == null) {
                globalFilterTitle = filterResult[0];
            }

            var light = lightData[0];
            var lightMode = checkFilters(
                activityInfo,
                getLightFilters(light),
                filterResult,
                lightData);
            var title = filterResult[0] != null ? filterResult[0] : globalFilterTitle;
            lightData[10] = filterResult[1];
            setLightMode(lightData, lightMode, title, false);
        }

        _lastSpeed = activityInfo.currentSpeed;

        return null;
    }

    // Overrides DataField.onUpdate
    (:dataField)
    function onUpdate(dc) {
        var timer = System.getTimer();
        var lastUpdateTime = _lastUpdateTime;
        // In case the device woke up from a sleep, set the control mode that was used before it went to sleep. When
        // a device goes to sleep, it turns off the lights which triggers onExternalLightModeChange method in case
        // the light are turned on and sets the control mode to manual. In such case, we store the control mode that
        // was used before the external change so that we can restore it when the device wakes up. Idealy we would not
        // change the control mode before a sleep, but as there is no way to detect when the device goes to sleep we
        // cannot do that. We are able to detect only when the device woke up by checking whether onShow method was called
        // prior calling onUpdate method. This will work only if the device went to sleep on the data screen were this
        // data field is displayed, otherwise it will not work as onUpdate will not be called.
        if (lastUpdateTime > 0 && (timer - lastUpdateTime) > 2000 && (timer - _lastOnShowCallTime) > 2000) {
            //System.println("WAKE UP lastOnShowCallTime=" + _lastOnShowCallTime  + " timer=" + System.getTimer());
            for (var i = 0; i < 3; i += 2) {
                var prevControlMode = getLightProperty("PCM", i, null);
                if (prevControlMode != null) {
                    setLightProperty("CM", i, prevControlMode);
                }
            }

            onShow();
        }

        _lastUpdateTime = timer;
        var width = dc.getWidth();
        var height = dc.getHeight();
        var bgColor = getBackgroundColor();
        var fgColor = 0x000000; /* COLOR_BLACK */
        if (bgColor == 0x000000 /* COLOR_BLACK */) {
            fgColor = 0xFFFFFF; /* COLOR_WHITE */
        }

        dc.setColor(fgColor, bgColor);
        dc.clear();
        if (_lightY == null) {
            preCalculate(dc, width, height);
        }

        var text = _errorCode != null ? "Error " + _errorCode
            : _initializedLights == 0 ? "No network"
            : null;
        if (text != null) {
            drawCenterText(dc, text, fgColor, width, height);
            return;
        }

        draw(dc, width, height, fgColor, bgColor);
    }

    (:widget)
    function onUpdate(dc) {
        _lastUpdateTime = System.getTimer();
        var width = dc.getWidth();
        var height = dc.getHeight();
        var bgColor = getBackgroundColor();
        var fgColor = 0x000000; /* COLOR_BLACK */
        if (bgColor == 0x000000 /* COLOR_BLACK */) {
            fgColor = 0xFFFFFF; /* COLOR_WHITE */
        }

        dc.setColor(fgColor, bgColor);
        dc.clear();
        if (_lightY == null) {
            preCalculate(dc, width, height);
        }

        var text = _errorCode != null ? "Error " + _errorCode
            : _initializedLights == 0 ? "No network"
            : null;
        if (text != null) {
            setTextColor(dc, fgColor);
            dc.drawText(width / 2, height / 2, 2, text, 1 /* TEXT_JUSTIFY_CENTER */ | 4 /* TEXT_JUSTIFY_VCENTER */);
            return;
        }

        draw(dc, width, height, fgColor, bgColor);
    }

    function onNetworkStateUpdate(networkState) {
        //System.println("onNetworkStateUpdate=" + networkState  + " timer=" + System.getTimer());
        _networkState = networkState;
        if (_initializedLights > 0 && networkState != 2 /* LIGHT_NETWORK_STATE_FORMED */) {
            // Set the mode to disconnected in order to be recorded in case lights recording is enabled
            updateLightTextAndMode(headlightData, -1);
            if (_initializedLights > 1) {
                updateLightTextAndMode(taillightData, -1);
            }

            // We have to reinitialize in case the light network is dropped after its formation
            releaseLights();
            return;
        }

        if (_initializedLights > 0 || networkState != 2 /* LIGHT_NETWORK_STATE_FORMED */) {
            //System.println("Skip=" + _initializedLights + " networkState=" + networkState +" timer=" + System.getTimer());
            return;
        }

        var networkMode = _lightNetwork.getNetworkMode();
        if (networkMode == null) {
            networkMode = 3; // TRAIL
        }

        // In case the user changes the network mode outside the application, set the default to network control mode
        var newNetworkMode = _networkMode != null && networkMode != _networkMode ? networkMode : null;
        _networkMode = networkMode;

        // Initialize lights
        _initializedLights = initializeLights(newNetworkMode, true);
    }

    function updateLight(light, mode) {
        var lightType = light.type;
        if (_initializedLights == 0 || (lightType != 0 /* LIGHT_TYPE_HEADLIGHT */ && lightType != 2 /* LIGHT_TYPE_TAILLIGHT */)) {
            //System.println("skip updateLight light=" + light.type + " mode=" + mode + " timer=" + System.getTimer());
            return;
        }

        var lightData = getLightData(lightType, _initializedLights);
        lightData[0] = light;
        var nextMode = lightData[7];
        if (mode == lightData[2] && nextMode == null) {
            //System.println("skip updateLight light=" + light.type + " mode=" + mode + " currMode=" + lightData[2] + " nextMode=" + lightData[7]  + " timer=" + System.getTimer());
            return;
        }

        //System.println("updateLight light=" + light.type + " mode=" + mode + " currMode=" + lightData[2] + " nextMode=" + nextMode + " timer=" + System.getTimer());
        var controlMode = lightData[4];
        if (nextMode == mode) {
            lightData[5] = lightData[8]; // Update title
            lightData[7] = null;
            lightData[8] = null;
        } else if (controlMode != 1 /* NETWORK */) {
            lightData[5] = null;
        }

        if (updateLightTextAndMode(lightData, mode) &&
            nextMode != mode && controlMode != 1 /* NETWORK */ &&
            // In the first few seconds during and after the network formation the lights may automatically switch to different
            // light modes, which can change their control mode to manual. In order to avoid changing the control mode, we
            // ignore initial light mode changes. This mostly helps when a device wakes up after only a few seconds of sleep.
            (System.getTimer() - _lastOnShowCallTime) > 5000) {
            // Change was done outside the data field.
            onExternalLightModeChange(lightData, mode);
        }
    }

    (:settings)
    function getSettingsView() {
        if (_errorCode != null || _initializedLights == 0 || !initializeSettings() || !(WatchUi has :Menu2)) {
            return null;
        }

        var menuContext = [headlightSettings, taillightSettings];
        var menu = _initializedLights > 1
            ? new Settings.LightsMenu(self, menuContext)
            : new Settings.LightMenu(headlightData[0].type, self, menuContext);

        return [menu, new Settings.MenuDelegate(menu)];
    }

    (:lightButtons)
    function setLightAndControlMode(lightData, lightType, newMode, newControlMode) {
        if (lightData[0] == null || _errorCode != null) {
            return; // This can happen when in menu the network is dropped or an invalid configuration is set
        }

        var controlMode = lightData[4];
        // In case the previous mode is Network we have to call setMode to override it
        var forceSetMode = controlMode == 1 /* NETWORK */ && newControlMode != null;
        if (newControlMode == 1 /* NETWORK */) {
            setNetworkMode(lightData, _networkMode);
        } else if ((controlMode == 2 /* MANUAL */ && newControlMode == null) || newControlMode == 2 /* MANUAL */) {
            setLightProperty("MM", lightType, newMode);
            setLightMode(lightData, newMode, null, forceSetMode);
        } else if (newControlMode == 0 /* SMART */ && forceSetMode) {
            setLightMode(lightData, lightData[2], null, true);
        }

        if (newControlMode != null) {
            setLightProperty("CM", lightType, newControlMode);
            lightData[4] = newControlMode;
        }
    }

    (:touchScreen)
    function onTap(location) {
        if (_fieldWidth == null || _initializedLights == 0 || _errorCode != null) {
            return false;
        }

        // Find which light was tapped
        var lightData = getLightData((_fieldWidth / 2) > location[0] ? 0 : 2, _initializedLights);

        if (getLightBatteryStatus(lightData) > 5) {
            return false; // Battery is disconnected
        }

        var light = lightData[0];
        var lightType = light.type;
        var controlMode = lightData[4];
        if (_isFullScreen) {
            return onLightPanelTap(location, lightData, lightType, controlMode);
        }

        var modes = getLightModes(light);
        var index = modes.indexOf(lightData[2]);
        var newControlMode = null;
        var newMode = null;
        // Change to the next mode
        if (_controlModeOnly && controlMode != 0 /* SMART */) {
            newControlMode = 0; /* SMART */
        } else if (controlMode == 0 /* SMART */) {
            newControlMode = 1; /* NETWORK */
        } else if (controlMode == 1 /* NETWORK */) {
            newControlMode = 2; /* MANUAL */
            index = -1;
        }

        if (!_controlModeOnly && (controlMode == 2 /* MANUAL */ || newControlMode == 2 /* MANUAL */)) {
            index = (index + 1) % modes.size();
            if (controlMode == 2 /* MANUAL */ && index == 0) {
                newControlMode = 0; /* SMART */
                // The mode will be calculated in compute method
            } else {
                newMode = modes[index];
            }
        }

        setLightAndControlMode(lightData, lightType, newMode, newControlMode);
        return true;
    }

    protected function getPropertyValue(key) {
        return Properties.getValue(key);
    }

    (:widget)
    protected function getBackgroundColor() {
    }

    (:rectangle)
    protected function preCalculate(dc, width, height) {
        var deviceSettings = System.getDeviceSettings();
        var padding = height - 55 < 0 ? 0 : 3;
        var settings = WatchUi.loadResource(Rez.JsonData.Settings);
        _separatorWidth = settings[0];
        _titleFont = settings[1];
        _titleTopPadding = settings[2];
        _offsetX = settings[3];
        _fieldWidth = width;
        _isFullScreen = width == deviceSettings.screenWidth && height == deviceSettings.screenHeight;
        _batteryY = height - 19 - padding;
        _lightY = _batteryY - padding - 32 /* Lights font size */;
        _titleY = (_lightY - dc.getFontHeight(_titleFont) - _titleTopPadding) >= 0 ? _titleTopPadding : null;
    }

    (:round)
    protected function preCalculate(dc, width, height) {
        var flags = getObscurityFlags();
        var settings = WatchUi.loadResource(Rez.JsonData.Settings);
        _separatorWidth = settings[0];
        _titleFont = settings[1];
        _titleTopPadding = settings[2];
        var titleHeight = dc.getFontHeight(_titleFont) + _titleTopPadding;
        var lightHeight = height < 55 ? 35 : 55;
        var totalHeight = lightHeight + titleHeight;
        var includeTitle = height > 90 && width > 150;
        totalHeight = includeTitle ? totalHeight : lightHeight;
        var startY = (12800 >> flags) & 0x01 == 1 ? 2 /* From top */
            : (200 >> flags) & 0x01 == 1 ? height - totalHeight /* From bottom */
            : (height - totalHeight) / 2; /* From center */
        _titleY = includeTitle ? startY : null;
        _lightY = includeTitle ? _titleY + titleHeight : startY;
        _batteryY = height < 55 ? null : _lightY + 35;
        var offsetDirection = ((1415136409 >> (flags * 2)) & 0x03) - 1;
        _offsetX = settings[3] * offsetDirection;
    }

    protected function initializeLights(newNetworkMode, firstTime) {
        //System.println("initializeLights=" + newNetworkMode + " firstTime=" + firstTime + " timer=" + System.getTimer());
        var errorCode = _errorCode;
        if (errorCode == 1 || errorCode == 2) {
            errorCode = null;
        }

        var lights = _lightNetwork.getBikeLights();
        if (lights == null) {
            _errorCode = errorCode;
            return 0;
        }

        var recordLightModes = getPropertyValue("RL");
        var totalLights = lights.size();
        for (var i = 0; i < totalLights; i++) {
            var light = lights[i];
            var lightType = light != null ? light.type : 7;
            if (lightType != 0 && lightType != 2) {
                errorCode = 1;
                break;
            }

            var capableModes = getLightModes(light);
            var filters = getLightFilters(light);
            if (newNetworkMode != null) {
                setLightProperty("CM", lightType, 1 /* NETWORK */);
            }

            var controlMode = getLightProperty("CM", lightType, filters != null ? 0 /* SMART */ : 1 /* NETWORK */);
            var lightMode = getInitialLightMode(light, controlMode);
            var lightModeIndex = capableModes.indexOf(lightMode);
            if (lightModeIndex < 0) {
                lightModeIndex = 0;
                lightMode = 0; /* LIGHT_MODE_OFF */
            }

            var lightData = getLightData(lightType, totalLights);
            if (firstTime && lightData[0] != null) {
                errorCode = 2;
                break;
            }

            // Store fit field always on the correct light data in order avoid creating two taillight_mode fit fields
            var fitData = getLightData(lightType, null);
            if (recordLightModes && fitData[6] == null) {
                fitData[6] = createField(
                    lightType == 0 /* LIGHT_TYPE_HEADLIGHT */ ? "headlight_mode" : "taillight_mode",
                    lightType, // Id
                    1 /*DATA_TYPE_SINT8 */,
                    {
                        :mesgType=> 20 /* Fit.MESG_TYPE_RECORD */
                    }
                );
            }

            lightData[0] = light;
            lightData[2] = null; // Force to update light text in case light modes were changed
            updateLightTextAndMode(lightData, lightMode);
            var oldControlMode = lightData[4];
            lightData[4] = controlMode;
            // In case of SMART or MANUAL control mode, we have to set the light mode in order to prevent the network mode
            // from changing it.
            if (firstTime || oldControlMode != controlMode) {
                setInitialLightMode(lightData, lightMode, controlMode);
            }

            // Allow the initialization to complete even if the modes are invalid, so that the user
            // is able to correct them by modifying the light configuration
            if (!validateLightModes(light)) {
                errorCode = 4;
            }
        }

        _errorCode = errorCode;

        return errorCode == null || errorCode == 4 ? totalLights : 0;
    }

    (:touchScreen)
    protected function onLightPanelTap(location, lightData, lightType, controlMode) {
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
                        onLightPanelModeChange(lightData, lightType, newMode, controlMode);
                        return true;
                    }
                }
            }

            groupIndex += 1 + (totalButtons * 8);
        }

        return false;
    }

    (:touchScreen)
    protected function onLightPanelModeChange(lightData, lightType, lightMode, controlMode) {
        var newControlMode = lightMode < 0 ? controlMode != 0 /* SMART */ ? 0 : 1 /* NETWORK */
            : controlMode != 2 /* MANUAL */ ? 2
            : null;
        setLightAndControlMode(lightData, lightType, lightMode, newControlMode);
    }

    protected function setInitialLightMode(lightData, lightMode, controlMode) {
        if (controlMode != 1 /* NETWORK */) {
            setLightMode(lightData, lightMode, null, true);
        } else {
            setNetworkMode(lightData, _networkMode);
        }
    }

    protected function setLightMode(lightData, mode, title, force) {
        if (lightData[2] == mode) {
            lightData[5] = title; // updateLight may not be called when setting the same mode
            if (!force) {
                return;
            }
        }

        //System.println("setLightMode=" + mode + " light=" + lightData[0].type + " force=" + force + " timer=" + System.getTimer());
        lightData[7] = mode; // Next mode
        lightData[8] = title; // Next title
        // Do not set a timeout in case we force setting the same mode, as we won't get a light update
        lightData[9] = lightData[2] == mode ? 0 : 5; // Timeout for compute method
        lightData[0].setMode(mode);
    }

    protected function getLightBatteryStatus(lightData) {
        var status = _lightNetwork.getBatteryStatus(lightData[0].identifier);
        if (status == null) { /* Disconnected */
            updateLightTextAndMode(lightData, -1);
            return 6;
        }

        return status.batteryStatus;
    }

    protected function getLightModes(light) {
        var modes = light.getCapableModes();
        if (modes == null) {
            return [0];
        }

        // LightNetwork supports up to five custom modes, any custom mode beyond the fifth one will be set to NULL.
        // Cycliq lights FLY6 CE and Fly12 CE have the following modes: [0, 1, 2, 3, 6, 7, 63, 62, 61, 60, 59, null]
        // In such case we need to remove the NULL values from the array.
        if (modes.indexOf(null) > -1) {
            modes = modes.slice(0, null);
            modes.removeAll(null);
        }

        return modes;
    }

    protected function setLightProperty(id, lightType, value) {
        Application.Storage.setValue(id + lightType, value);
    }

    (:lightButtons)
    protected function onExternalLightModeChange(lightData, mode) {
        //System.println("onExternalLightModeChange mode=" + mode + " lightType=" + lightData[0].type  + " timer=" + System.getTimer());
        var controlMode = lightData[4];
        var lightType = lightData[0].type;
        setLightProperty("PCM", lightType, controlMode);
        setLightAndControlMode(lightData, lightType, mode, controlMode != 2 ? 2 /* MANUAL */ : null);
    }

    (:noLightButtons)
    protected function onExternalLightModeChange(lightData, mode) {
        var controlMode = lightData[4];
        lightData[4] = 2; /* MANUAL */
        lightData[5] = null;
        // As onHide is never called, we use the last update time in order to determine whether the data field is currently
        // displayed. In case that the data field is currently not displayed, we assume that the user used either Garmin
        // lights menu or a CIQ application to change the light mode. In such case set the next control mode to manual so
        // that when the data field will be again displayed the manual control mode will be active. In case when the light
        // mode is changed while the data field is displayed (by pressing the button on the light), do not set the next mode
        // so that the user will be able to reset back to smart by moving to a different data screen and then back to the one
        // that contains this data field. In case when the network mode is changed when the data field is not displayed by
        // using Garmin lights menu, network control mode will be active when the data field will be again displayed. As the
        // network mode is not updated when changed until a new instance of the LightNetwork is created, the logic is done in
        // onNetworkStateUpdate method.
        if (System.getTimer() > _lastUpdateTime + 1500) {
            var lightType = lightData[0].type;
            setLightProperty("PCM", lightType, controlMode);
            // Assume that the change was done either by Garmin lights menu or a CIQ application
            setLightProperty("CM", lightType, 2 /* MANUAL */);
            setLightProperty("MM", lightType, mode);
        }
    }

    (:nonTouchScreen)
    protected function releaseLights() {
        _initializedLights = 0;
        headlightData[0] = null;
        taillightData[0] = null;
    }

    (:touchScreen)
    protected function releaseLights() {
        _initializedLights = 0;
        headlightData[0] = null;
        taillightData[0] = null;
        _panelInitialized = false;
        _headlightPanel = null;
        _taillightPanel = null;
    }

    (:settings)
    protected function initializeSettings() {
        if (_settingsInitialized) {
            return true;
        }

        if (!validateSettingsLightModes(headlightData[0]) || !validateSettingsLightModes(taillightData[0])) {
            return false;
        }

        var lightType = headlightData[0].type;
        if (headlightSettings == null && lightType == 0 /* LIGHT_TYPE_HEADLIGHT */) {
            headlightSettings = getDefaultLightSettings(headlightData[0]);
        }

        if (taillightSettings == null) {
            var lightData = _initializedLights > 1 ? taillightData
                : lightType == 2 ? headlightData
                : null;
            taillightSettings = lightData != null ? getDefaultLightSettings(lightData[0]) : null;
        }

        _settingsInitialized = true;
        return true;
    }

    (:rectangle)
    protected function drawLight(lightData, position, dc, width, fgColor, bgColor) {
        var justification = lightData[0].type;
        var direction = justification == 0 ? 1 : -1;
        var lightX = Math.round(width * 0.25f * position);
        var batteryStatus = getLightBatteryStatus(lightData);
        var title = lightData[5];
        var lightXOffset = justification == 0 ? -4 : 2;
        dc.setColor(fgColor, bgColor);

        if (title != null && _titleY != null) {
            dc.drawText(lightX, _titleY, _titleFont, title, 1 /* TEXT_JUSTIFY_CENTER */);
        }

        dc.drawText(lightX + (direction * (_batteryWidth / 2)) + lightXOffset, _lightY, _lightsFont, lightData[1], justification);
        dc.drawText(lightX + (direction * 8), _lightY + 11, _controlModeFont, $.controlModes[lightData[4]], 1 /* TEXT_JUSTIFY_CENTER */);
        drawBattery(dc, fgColor, lightX, _batteryY, batteryStatus);
    }

    (:round)
    protected function drawLight(lightData, position, dc, width, fgColor, bgColor) {
        var justification = lightData[0].type;
        var direction = justification == 0 ? 1 : -1;
        var lightX = Math.round(width * 0.25f * position) + _offsetX;
        lightX += _initializedLights == 2 ? (direction * ((width / 4) - 25)) : 0;
        var batteryStatus = getLightBatteryStatus(lightData);
        var title = lightData[5];
        var lightXOffset = justification == 0 ? -4 : 2;
        dc.setColor(fgColor, bgColor);

        if (title != null && _titleY != null) {
            dc.drawText(lightX + (direction * 22), _titleY, _titleFont, title, justification);
        }

        dc.drawText(lightX + (direction * (_batteryWidth / 2)) + lightXOffset, _lightY, _lightsFont, lightData[1], justification);
        dc.drawText(lightX + (direction * 8), _lightY + 11, _controlModeFont, $.controlModes[lightData[4]], 1 /* TEXT_JUSTIFY_CENTER */);
        if (_batteryY != null) {
            drawBattery(dc, fgColor, lightX, _batteryY, batteryStatus);
        }
    }

    protected function drawBattery(dc, fgColor, x, y, batteryStatus) {
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

    (:dataField :rectangle)
    protected function drawCenterText(dc, text, color, width, height) {
        setTextColor(dc, color);
        dc.drawText(width / 2, height / 2, 2, text, 1 /* TEXT_JUSTIFY_CENTER */ | 4 /* TEXT_JUSTIFY_VCENTER */);
    }

    (:dataField :round)
    protected function drawCenterText(dc, text, color, width, height) {
        setTextColor(dc, color);
        dc.drawText(width / 2, height / 2, 0, text, 1 /* TEXT_JUSTIFY_CENTER */ | 4 /* TEXT_JUSTIFY_VCENTER */);
    }

    protected function getSecondsOfDay(value) {
        value = value.toNumber();
        return value == null ? null : (value < 0 ? value + 86400 : value) % 86400;
    }

    // The below source code was ported from: https://www.esrl.noaa.gov/gmd/grad/solcalc/main.js
    // which is used for the NOAA Solar Calculator: https://www.esrl.noaa.gov/gmd/grad/solcalc/
    protected function getSunriseSet(rise, time, position) {
        var month = time.month;
        var year = time.year;
        if (month <= 2) {
            year -= 1;
            month += 12;
        }

        var a = Math.floor(year / 100);
        var b = 2 - a + Math.floor(a / 4);
        var jd = Math.floor(365.25 * (year + 4716)) + Math.floor(30.6001 * (month + 1)) + time.day + b - 1524.5;
        var t = (jd - 2451545.0) / 36525.0;
        var omega = degToRad(125.04 - 1934.136 * t);
        var l1 = 280.46646 + t * (36000.76983 + t * 0.0003032);
        while (l1 > 360.0) {
            l1 -= 360.0;
        }

        while (l1 < 0.0) {
            l1 += 360.0;
        }

        var l0 = degToRad(l1);
        var e = 0.016708634 - t * (0.000042037 + 0.0000001267 * t); // unitless
        var mrad = degToRad(357.52911 + t * (35999.05029 - 0.0001537 * t));
        var ec = degToRad((23.0 + (26.0 + ((21.448 - t * (46.8150 + t * (0.00059 - t * 0.001813))) / 60.0)) / 60.0) + 0.00256 * Math.cos(omega));
        var y = Math.tan(ec/2.0);
        y *= y;
        var sinm = Math.sin(mrad);
        var eqTime = (180.0 * (y * Math.sin(2.0 * l0) - 2.0 * e * sinm + 4.0 * e * y * sinm * Math.cos(2.0 * l0) - 0.5 * y * y * Math.sin(4.0 * l0) - 1.25 * e * e * Math.sin(2.0 * mrad)) / 3.141593) * 4.0; // in minutes of time
        var sunEq = sinm * (1.914602 - t * (0.004817 + 0.000014 * t)) + Math.sin(mrad + mrad) * (0.019993 - 0.000101 * t) + Math.sin(mrad + mrad + mrad) * 0.000289; // in degrees
        var latRad = degToRad(position[0].toFloat() /* latitude */);
        var sdRad  = degToRad(180.0 * (Math.asin(Math.sin(ec) * Math.sin(degToRad((l1 + sunEq) - 0.00569 - 0.00478 * Math.sin(omega))))) / 3.141593);
        var hourAngle = Math.acos((Math.cos(degToRad(90.833)) / (Math.cos(latRad) * Math.cos(sdRad)) - Math.tan(latRad) * Math.tan(sdRad))); // in radians (for sunset, use -HA)
        if (!rise) {
            hourAngle = -hourAngle;
        }

        return getSecondsOfDay((720 - (4.0 * (position[1].toFloat() /* longitude */ + (180.0 * hourAngle / 3.141593))) - eqTime) * 60); // timeUTC in seconds
    }

    private function getLightFilters(light) {
        return light.type == 0 /* LIGHT_TYPE_HEADLIGHT */ ? _headlightFilters : _taillightFilters;
    }

    private function updateLightTextAndMode(lightData, mode) {
        if (lightData[2] == mode) {
            return false;
        }

        var lightType = lightData[0].type;
        lightData[1] = getLightText(lightType, mode, lightData[3]);
        lightData[2] = mode;
        var fitData = getLightData(lightType, null);
        var fitField = fitData[6];
        if (fitField != null) {
            fitField.setData(mode);
        }

        return true;
    }

    (:settings)
    private function getDefaultLightSettings(light) {
        if (light == null) {
            return null;
        }

        var modes = getLightModes(light);
        var data = new [2 * modes.size() + 1];
        var dataIndex = 1;
        data[0] = light.type == 0 /* LIGHT_TYPE_HEADLIGHT */ ? "Headlight" : "Taillight";
        for (var i = 0; i < modes.size(); i++) {
            var mode = modes[i];
            data[dataIndex] = mode == 0 ? "Off" : mode.toString();
            data[dataIndex + 1] = mode;
            dataIndex += 2;
        }

        return data;
    }

    (:noLightButtons :lowMemory)
    private function setupLightButtons(configuration) {
    }

    (:noLightButtons :highMemory)
    private function setupLightButtons(configuration) {
        _individualNetwork = configuration[7];
        if (_individualNetwork != null /* Is enabled */ || _lightNetwork instanceof AntLightNetwork.IndividualLightNetwork) {
            recreateLightNetwork();
        }
    }

    (:touchScreen)
    private function setupLightButtons(configuration) {
        _controlModeOnly = getPropertyValue("CMO");
        _panelInitialized = false;
        _headlightPanelSettings = configuration[5];
        _taillightPanelSettings = configuration[6];
        _individualNetwork = configuration[7];
        if (_individualNetwork != null /* Is enabled */ || _lightNetwork instanceof AntLightNetwork.IndividualLightNetwork) {
            recreateLightNetwork();
        }
    }

    (:settings)
    private function setupLightButtons(configuration) {
        _settingsInitialized = false;
        headlightSettings = configuration[5];
        taillightSettings = configuration[6];
        _individualNetwork = configuration[7];
        if (_individualNetwork != null /* Is enabled */ || _lightNetwork instanceof AntLightNetwork.IndividualLightNetwork) {
            recreateLightNetwork();
        }
    }

    (:highMemory :deviceNetwork)
    private function recreateLightNetwork() {
        release();
        _lightNetwork = _individualNetwork != null
            ? new AntLightNetwork.IndividualLightNetwork(_individualNetwork[0], _individualNetwork[1], _lightNetworkListener)
            : new AntPlus.LightNetwork(_lightNetworkListener);
    }

    (:highMemory :testNetwork)
    private function recreateLightNetwork() {
        release();
        _lightNetwork = _individualNetwork != null
            ? new AntLightNetwork.IndividualLightNetwork(_individualNetwork[0], _individualNetwork[1], _lightNetworkListener)
            : new TestNetwork.TestLightNetwork(_lightNetworkListener);
    }

    (:nonTouchScreen)
    private function draw(dc, width, height, fgColor, bgColor) {
        if (_initializedLights == 1) {
            drawLight(headlightData, 2, dc, width, fgColor, bgColor);
            return;
        }

        // Draw separator
        setTextColor(dc, _activityColor);
        dc.setPenWidth(_separatorWidth);
        dc.drawLine(width / 2 + _offsetX, 0, width / 2 + _offsetX, height);
        drawLight(headlightData, 1, dc, width, fgColor, bgColor);
        drawLight(taillightData, 3, dc, width, fgColor, bgColor);
    }

    (:touchScreen)
    private function draw(dc, width, height, fgColor, bgColor) {
        if (_isFullScreen) {
            drawLightPanels(dc, width, height, fgColor, bgColor);
            return;
        }

        if (_initializedLights == 1) {
            drawLight(headlightData, 2, dc, width, fgColor, bgColor);
            return;
        }

        // Draw separator
        setTextColor(dc, _activityColor);
        dc.setPenWidth(_separatorWidth);
        dc.drawLine(width / 2 + _offsetX, 0, width / 2 + _offsetX, height);
        drawLight(headlightData, 1, dc, width, fgColor, bgColor);
        drawLight(taillightData, 3, dc, width, fgColor, bgColor);
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
            drawLightPanel(dc, headlightData, headlightData[0].type == 0 /* LIGHT_TYPE_HEADLIGHT */ ? _headlightPanel : _taillightPanel, width, height, fgColor, bgColor);
            return;
        }

        drawLightPanel(dc, headlightData, _headlightPanel, width, height, fgColor, bgColor);
        drawLightPanel(dc, taillightData, _taillightPanel, width, height, fgColor, bgColor);
    }

    (:touchScreen)
    private function getDefaultLightPanelSettings(lightType, capableModes) {
        var totalButtonGroups = capableModes.size();
        var totalButtons = totalButtonGroups + 1 /* For control mode button */;
        var data = new [3 + (2 * totalButtons) + totalButtonGroups];
        data[0] = totalButtonGroups + 1; // Total buttons
        data[1] = totalButtonGroups; // Total button groups
        data[2] = lightType == 0 /* LIGHT_TYPE_HEADLIGHT */ ? "Headlight" : "Taillight"; // Light name
        var dataIndex = 3;
        for (var i = 0; i < totalButtonGroups; i++) {
            var mode = capableModes[i];
            var totalGroupButtons = mode == 0 /* Off */ ? 2 : 1; // Number of buttons;
            data[dataIndex] = totalGroupButtons; // Total buttons in the group
            data[dataIndex + 1] = mode == 0 ? -1 : mode; // Light mode
            data[dataIndex + 2] = mode == 0 ? null : mode.toString(); // Mode name
            if (mode == 0 /* Off */) {
                data[dataIndex + 3] = mode;
                data[dataIndex + 4] = "Off";
            }

            dataIndex += 1 + (totalGroupButtons * 2);
        }

        return data;
    }

    (:touchScreen)
    private function initializeLightPanels(dc, width, height) {
        if (_initializedLights == 1) {
            initializeLightPanel(dc, headlightData, 2, width, height);
        } else {
            initializeLightPanel(dc, headlightData, 1, width, height);
            initializeLightPanel(dc, taillightData, 3, width, height);
        }

        _panelInitialized = true;
    }

    (:touchScreen)
    private function initializeLightPanel(dc, lightData, position, width, height) {
        var x = position < 3 ? 0 : (width / 2); // Left x
        var y = 0;
        var margin = 2;
        var buttonGroupWidth = (position != 2 ? width / 2 : width);
        var light = lightData[0];
        var capableModes = getLightModes(light);
        var fontTopPaddings = WatchUi.loadResource(Rez.JsonData.FontTopPaddings)[0];
        var panelSettings = light.type == 0 /* LIGHT_TYPE_HEADLIGHT */ ? _headlightPanelSettings : _taillightPanelSettings;
        if (panelSettings == null) {
            panelSettings = getDefaultLightPanelSettings(light.type, capableModes);
        }

        var i;
        var totalButtonGroups = panelSettings[1];
        // [:TotalButtonGroups:, :LightName:, :LightNameX:, :LightNameY:, :BatteryX:, :BatteryY:, (<ButtonGroup>)+]
        // <ButtonGroup> := [:NumberOfButtons:, :Mode:, :TitleX:, :TitleFont:, (<TitlePart>)+, :ButtonLeftX:, :ButtonTopY:, :ButtonWidth:, :ButtonHeight:){:NumberOfButtons:} ]
        // <TitlePart> := [(:Title:, :TitleY:)+]
        var panelData = new [6 + (8 * panelSettings[0]) + totalButtonGroups];
        panelData[0] = totalButtonGroups;
        var buttonHeight = (height - 20 /* Battery */).toFloat() / totalButtonGroups;
        var fontResult = [0];
        var buttonPadding = margin * 2;
        var textPadding = margin * 4;
        var groupIndex = 6;
        var settingsGroupIndex = 3;
        for (i = 0; i < totalButtonGroups; i++) {
            var totalButtons = panelSettings[settingsGroupIndex];
            var buttonWidth = buttonGroupWidth / totalButtons;
            panelData[groupIndex] = totalButtons; // Buttons in group
            var titleParts = null;
            for (var j = 0; j < totalButtons; j++) {
                var buttonIndex = groupIndex + 1 + (j * 8);
                var modeIndex = settingsGroupIndex + 1 + (j * 2);
                var buttonX = x + (buttonWidth * j);
                var mode = panelSettings[modeIndex];
                if (mode > 0 && capableModes.indexOf(mode) < 0) {
                    _errorCode = 4;
                    return;
                }

                var modeTitle = mode < 0 ? "M" : panelSettings[modeIndex + 1];
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
                panelData[buttonIndex] = mode; // Light mode
                panelData[buttonIndex + 1] = buttonX + (buttonWidth / 2); // Title x
                panelData[buttonIndex + 2] = titleFont; // Title font
                panelData[buttonIndex + 3] = titleParts; // Title parts
                panelData[buttonIndex + 4] = buttonX; // Button left x
                panelData[buttonIndex + 5] = y; // Button top y
                panelData[buttonIndex + 6] = buttonWidth; // Button width
                panelData[buttonIndex + 7] = buttonHeight; // Button height
            }

            groupIndex += 1 + (totalButtons * 8);
            settingsGroupIndex += 1 + (totalButtons * 2);
            y += buttonHeight;
        }

        // Calculate light name and battery positions
        x = Math.round(width * 0.25f * position);
        var lightName = StringHelper.trimTextByWidth(dc, panelSettings[2], 1, buttonGroupWidth - buttonPadding - _batteryWidth);
        var lightNameWidth = lightName != null ? dc.getTextWidthInPixels(lightName, 1) : 0;
        var lightNameHeight = dc.getFontHeight(1);
        var lightNameTopPadding = StringHelper.getFontTopPadding(1, fontTopPaddings);
        panelData[1] = lightName; // Light name
        panelData[2] = x - (_batteryWidth / 2) - (margin / 2); // Light name x
        panelData[3] = y + ((20 - lightNameHeight - lightNameTopPadding) / 2); // Light name y
        panelData[4] = x + (lightNameWidth / 2) + (margin / 2); // Battery x
        panelData[5] = y - 1; // Battery y

        if (light.type == 0 /* LIGHT_TYPE_HEADLIGHT */) {
            _headlightPanel = panelData;
        } else {
            _taillightPanel = panelData;
        }
    }

    (:touchScreen)
    private function drawLightPanel(dc, lightData, panelData, width, height, fgColor, bgColor) {
        var light = lightData[0];
        var controlMode = lightData[4];
        var lightMode = lightData[2];
        var nextLightMode = lightData[7];
        var margin = 2;
        var buttonPadding = margin * 2;
        var batteryStatus = getLightBatteryStatus(lightData);
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
                var isNext = nextLightMode == mode;

                setTextColor(dc, isSelected ? _activityColor : isNext ? fgColor : bgColor);
                dc.fillRoundedRectangle(buttonX, buttonY, buttonWidth, buttonHeight, 8);
                setTextColor(dc, isNext ? bgColor : fgColor);
                dc.drawRoundedRectangle(buttonX, buttonY, buttonWidth, buttonHeight, 8);
                setTextColor(dc, isSelected ? 0xFFFFFF /* COLOR_WHITE */ : isNext ? bgColor : fgColor);
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

    protected function getLightData(lightType, totalLights) {
        return lightType == 0 || totalLights == 1 ? headlightData : taillightData;
    }

    (:lightButtons)
    protected function getLightProperty(id, lightType, defaultValue) {
        var key = id + lightType;
        var value = Application.Storage.getValue(key);
        if (value != null && defaultValue == null) {
            Application.Storage.deleteValue(key);
        }

        if (value == null && defaultValue != null) {
            // First application startup
            value = defaultValue;
            Application.Storage.setValue(key, value);
        }

        return value;
    }

    (:noLightButtons)
    protected function getLightProperty(id, lightType, defaultValue) {
        var key = id + lightType;
        var value = Application.Storage.getValue(key);
        if (value != null) {
            Application.Storage.deleteValue(key);
        }

        return value != null ? value : defaultValue;
    }

    protected function getInitialLightMode(light, controlMode) {
        return controlMode <= 1 /*NETWORK*/ ? light.mode
            : getLightProperty("MM", light.type, 0 /* LIGHT_MODE_OFF */);
    }

    (:colorScreen)
    private function setTextColor(dc, color) {
        dc.setColor(color, -1 /* COLOR_TRANSPARENT */);
    }

    (:monochromeScreen)
    private function setTextColor(dc, color) {
        dc.setColor(0x000000, -1 /* COLOR_TRANSPARENT */);
    }

    private function setNetworkMode(lightData, networkMode) {
        lightData[5] = networkMode != null && networkMode < $.networkModes.size()
            ? $.networkModes[networkMode]
            : null;

        //System.println("setNetworkMode=" + networkMode + " light=" + lightData[0].type + " timer=" + System.getTimer());
        if (lightData[0].type == 0 /* LIGHT_TYPE_HEADLIGHT */) {
            _lightNetwork.restoreHeadlightsNetworkModeControl();
        } else {
            _lightNetwork.restoreTaillightsNetworkModeControl();
        }
    }

    private function getLightText(lightType, mode, lightModes) {
        var lightModeCharacter = "";
        if (mode < 0) {
            lightModeCharacter = "X"; // Disconnected
        } else if (mode > 0) {
            var index = lightModes == null
                ? -1
                : ((lightModes >> (4 * ((mode > 9 ? mode - 49 : mode) - 1))) & 0x0F).toNumber() - 1;
            lightModeCharacter = index < 0 || index >= $.lightModeCharacters.size()
                ? "?" /* Unknown */
                : $.lightModeCharacters[index];
        }

        return lightType == 0 /* LIGHT_TYPE_HEADLIGHT */ ? lightModeCharacter + ">" : "<" + lightModeCharacter;
    }

    private function validateLightModes(light) {
        if (light == null) {
            return true;
        }

        var filters = getLightFilters(light);
        if (filters == null) {
            return true;
        }

        var i = 0;
        var capableModes = getLightModes(light);
        while (i < filters.size()) {
            var totalFilters = filters[i + 1];
            if (capableModes.indexOf(filters[i + 2]) < 0) {
                return false;
            }

            i = i + 4 + (totalFilters * 3);
        }

        return true;
    }

    (:settings)
    private function validateSettingsLightModes(light) {
        if (light == null) {
            return true; // In case only one light is connected
        }

        var settings = light.type == 0 /* LIGHT_TYPE_HEADLIGHT */ ? headlightSettings : taillightSettings;
        if (settings == null) {
            return true;
        }

        var capableModes = getLightModes(light);
        for (var i = 2; i < settings.size(); i += 2) {
            if (capableModes.indexOf(settings[i]) < 0) {
                _errorCode = 4;
                return false;
            }
        }

        return true;
    }

    (:dataField)
    private function checkFilters(activityInfo, filters, filterResult, lightData) {
        if (filters == null) {
            filterResult[0] = null;
            filterResult[1] = null;
            return lightData != null ? 0 : 1;
        }

        var i = 0;
        var nextGroupIndex = null;
        var lightMode = 1;
        var title = null;
        var minActiveTime = null;
        while (i < filters.size()) {
            var data = filters[i];
            if (nextGroupIndex == null) {
                title = data;
                var totalFilters = filters[i + 1];
                if (lightData != null) {
                    lightMode = filters[i + 2];
                    minActiveTime = filters[i + 3];
                    i += 4;
                } else {
                    i += 2;
                }

                nextGroupIndex = i + (totalFilters * 3);
                continue;
            } else if (i >= nextGroupIndex) {
                filterResult[0] = title;
                filterResult[1] = minActiveTime;
                return lightMode;
            }

            if (checkFilter(data, activityInfo, filters, i, filters[i + 2], lightData)) {
                i += 3;
            } else {
                i = nextGroupIndex;
                nextGroupIndex = null;
            }
        }

        if (nextGroupIndex != null) {
            filterResult[0] = title;
            filterResult[1] = minActiveTime;
            return lightMode;
        }

        filterResult[0] = null;
        filterResult[1] = null;
        return 0;
    }

    (:dataField :highMemory)
    private function checkFilter(filterType, activityInfo, filters, i, filterValue, lightData) {
        return filterType == 'E' ? isWithinTimespan(filters, i, filterValue)
            : filterType == 'F' ? isInsideAnyPolygon(activityInfo, filterValue)
            : filterType == 'I' ? isTargetBehind(activityInfo, filters[i + 1], filterValue)
            : filterType == 'D' ? true
            : checkGenericFilter(activityInfo, filterType, filters[i + 1], filterValue, lightData);
    }

    (:dataField :lowMemory)
    private function checkFilter(filterType, activityInfo, filters, i, filterValue, lightData) {
        return filterType == 'E' ? isWithinTimespan(filters, i, filterValue)
            : filterType == 'D' ? true
            : checkGenericFilter(activityInfo, filterType, filters[i + 1], filterValue, lightData);
    }

    (:dataField)
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

    (:dataField)
    private function checkGenericFilter(activityInfo, filterType, operator, filterValue, lightData) {
        var value = filterType == 'A' ? _acceleration
            : filterType == 'B' ? lightData != null ? getLightBatteryStatus(lightData) : null
            : filterType == 'C' ? activityInfo.currentSpeed
            : filterType == 'G' ? (activityInfo.currentLocationAccuracy == null ? 0 : activityInfo.currentLocationAccuracy)
            : filterType == 'H' ? activityInfo.timerState
            : filterType == 'J' ? activityInfo.startLocation == null ? 0 : 1
            : filterType == 'K' && Activity has :getProfileInfo ? Activity.getProfileInfo().name
            : null;
        if (value == null) {
            return false;
        }

        return operator == '<' || operator == '[' ? value < filterValue
            : operator == '>' || operator == ']' ? value > filterValue
            // Use equals method only for string values as it checks also the type. When comparing
            // numeric values we want to ignore the type (e.g. 0 == 0f), so == operator is used instead.
            : operator == '=' ? value instanceof String ? value.equals(filterValue) : value == filterValue
            : false;
    }

    (:dataField :highMemory)
    private function isInsideAnyPolygon(activityInfo, filterValue) {
        if (activityInfo.currentLocation == null) {
            return false;
        }

        var position = activityInfo.currentLocation.toDegrees();
        for (var i = 0; i < filterValue.size(); i += 8) {
            if (isPointInPolygon(position[1] /* Longitude */, position[0] /* Latitude  */, filterValue, i)) {
                return true;
            }
        }

        return false;
    }

    // Code ported from https://stackoverflow.com/a/14998816
    (:dataField :highMemory)
    private function isPointInPolygon(x, y, points, index) {
        var result = false;
        var pointX;
        var lastPointX;
        var pointY;
        var lastPointY;
        var to = index + 8;
        var j = to - 2;
        for (var i = index; i < to; i += 2) {
            pointY = points[i];
            pointX = points[i + 1];
            lastPointY = points[j];
            lastPointX = points[j + 1];
            if (pointY < y && lastPointY >= y || lastPointY < y && pointY >= y)
            {
                if ((pointX + (y - pointY) / (lastPointY - pointY) * (lastPointX - pointX)) < x) {
                    result = !result;
                }
            }

            j = i;
        }

        return result;
    }

    (:dataField :highMemory)
    private function isTargetBehind(activityInfo, operator, filterValue) {
        if (_bikeRadar == null) {
            if (Toybox.AntPlus has :BikeRadar) {
                _bikeRadar = new AntPlus.BikeRadar(null);
            } else {
                return false;
            }
        }

        var targets = _bikeRadar.getRadarInfo();
        if (targets == null) {
            return false;
        }

        var range = filterValue[0];
        var threatOperator = filterValue[1];
        var threat = filterValue[2];
        for (var i = 0; i < targets.size(); i++) {
            var target = targets[i];
            if (checkOperatorValue(threatOperator, target.threat, threat) &&
                checkOperatorValue(operator, target.range, range)) {
                return true;
            }
        }

        return false;
    }

    (:dataField :highMemory)
    private function checkOperatorValue(operator, value, filterValue) {
        if (value == null) {
            return filterValue < 0;
        }

        return operator == '<' || operator == '[' ? value < filterValue
            : operator == '>' || operator == ']' ? value > filterValue
            : operator == '=' ? value == filterValue
            : false;
    }

    (:dataField)
    private function initializeTimeFilter(filterValue) {
        var from = initializeTimeFilterPart(filterValue, 0);
        var to = initializeTimeFilterPart(filterValue, 2);

        return from == null || to == null ? null : [from, to];
    }

    (:dataField)
    private function initializeTimeFilterPart(filterValue, index) {
        var type = filterValue[index];
        if (type > 0 /* Sunset or sunrise */ && _sunsetTime == null) {
            return null; // Not able to initialize
        }

        var value = filterValue[index + 1];
        return getSecondsOfDay(
            type == 2 /* Sunset */ ? _sunsetTime + value
            : type == 1 /* Sunrise */ ? _sunriseTime + value
            : value
        );
    }

    // <GlobalFilters>#<HeadlightModes>#<HeadlightFilters>#<TaillightModes>#<TaillightFilters>
    (:noLightButtons :lowMemory)
    private function parseConfiguration(value) {
        if (value == null || value.length() == 0) {
            return new [5];
        }

        var filterResult = [0 /* next index */, 0 /* operator type */];
        var chars = value.toCharArray();
        return [
            parseFilters(chars, 0, false, filterResult),                      // Global filter
            parseLong(chars, filterResult[0] + 1, filterResult),              // Headlight modes
            parseFilters(chars, filterResult[0] + 1, true, filterResult),     // Headlight filters
            parseLong(chars, filterResult[0] + 1, filterResult),              // Taillight modes
            parseFilters(chars, filterResult[0] + 1, true, filterResult)      // Taillight filters
        ];
    }

    (:noLightButtons :highMemory)
    private function parseConfiguration(value) {
        if (value == null || value.length() == 0) {
            return new [8];
        }

        var filterResult = [0 /* next index */, 0 /* operator type */];
        var chars = value.toCharArray();
        return [
            parseFilters(chars, 0, false, filterResult),                      // Global filter
            parseLong(chars, filterResult[0] + 1, filterResult),              // Headlight modes
            parseFilters(chars, filterResult[0] + 1, true, filterResult),     // Headlight filters
            parseLong(chars, filterResult[0] + 1, filterResult),              // Taillight modes
            parseFilters(chars, filterResult[0] + 1, true, filterResult),     // Taillight filters
            null,                                                             // Headlight panel/settings buttons (will be always empty)
            null,                                                             // Taillight panel/settings buttons (will be always empty)
            parseIndividualNetwork(chars, filterResult[0] + 3, filterResult)  // Individual network settings
        ];
    }

    (:lightButtons)
    private function parseConfiguration(value) {
        if (value == null || value.length() == 0) {
            return new [8];
        }

        var filterResult = [0 /* next index */, 0 /* operator type */];
        var chars = value.toCharArray();
        return [
            parseFilters(chars, 0, false, filterResult),                      // Global filter
            parseLong(chars, filterResult[0] + 1, filterResult),              // Headlight modes
            parseFilters(chars, filterResult[0] + 1, true, filterResult),     // Headlight filters
            parseLong(chars, filterResult[0] + 1, filterResult),              // Taillight modes
            parseFilters(chars, filterResult[0] + 1, true, filterResult),     // Taillight filters
            parseLightButtons(chars, filterResult[0] + 1, filterResult),      // Headlight panel/settings buttons
            parseLightButtons(chars, filterResult[0] + 1, filterResult),      // Taillight panel/settings buttons
            parseIndividualNetwork(chars, filterResult[0] + 1, filterResult)  // Individual network settings
        ];
    }

    (:highMemory)
    private function parseIndividualNetwork(chars, i, filterResult) {
        if (parse(1 /* NUMBER */, chars, i, filterResult) != 1) {
            return null;
        }

        return [
            parse(1 /* NUMBER */, chars, filterResult[0] + 1, filterResult), // Headlight device number
            parse(1 /* NUMBER */, chars, filterResult[0] + 1, filterResult)  // Taillight device number
        ];
    }

    // <TotalButtons>:<LightName>|[<Button>| ...]
    // <Button> := <ModeTitle>:<LightMode>
    // Example: 6:Ion Pro RT|Off:0|High:1|Medium:2|Low:5|Night Flash:62|Day Flash:63
    (:settings)
    private function parseLightButtons(chars, i, filterResult) {
        var totalButtons = parse(1 /* NUMBER */, chars, i, filterResult);
        if (totalButtons == null || totalButtons > 10) {
            return null;
        }

        var data = new [1 + (2 * totalButtons)];
        data[0] = parse(0 /* STRING */, chars, filterResult[0] + 1, filterResult);
        i = filterResult[0];
        var dataIndex = 1;

        for (var j = 0; j < totalButtons; j++) {
            data[dataIndex] = parse(0 /* STRING */, chars, filterResult[0] + 1, filterResult);
            data[dataIndex + 1] = parse(1 /* NUMBER */, chars, filterResult[0] + 1, filterResult);
            dataIndex += 2;
        }

        return data;
    }

    // <TotalButtons>,<TotalButtonGroups>:<LightName>|[<ButtonGroup>| ...]
    // <ButtonGroup> := <ButtonsNumber>,[<Button>, ...]
    // <Button> := <ModeTitle>:<LightMode>
    // Example: 7,6:Ion Pro RT|2,:-1,Off:0|1,High:1|1,Medium:2|1,Low:5|1,Night Flash:62|1,Day Flash:63
    (:touchScreen)
    private function parseLightButtons(chars, i, filterResult) {
        var totalButtons = parse(1 /* NUMBER */, chars, i, filterResult);
        if (totalButtons == null) {
            return null;
        }

        var totalButtonGroups = parse(1 /* NUMBER */, chars, filterResult[0] + 1, filterResult);
        // [:TotalButtons:, :TotalButtonGroups:, :LightName:, (<ButtonGroup>)+]
        // <ButtonGroup> = :NumberOfButtons:, (<Button>){:NumberOfButtons:})
        // <Button> = :Mode:, :Title:
        var data = new [3 + (2 * totalButtons) + totalButtonGroups];
        data[0] = totalButtons;
        data[1] = totalButtonGroups;
        data[2] = parse(0 /* STRING */, chars, filterResult[0] + 1, filterResult);
        i = filterResult[0];
        var dataIndex = 3;

        while (i < chars.size()) {
            var char = chars[i];
            if (char == '#') {
                break;
            }

            if (char == '|') {
                var numberOfButtons = parse(1 /* NUMBER */, chars, filterResult[0] + 1, filterResult); // Number of buttons in the group
                data[dataIndex] = numberOfButtons;
                dataIndex++;
                for (var j = 0; j < numberOfButtons; j++) {
                    data[dataIndex + 1] = parse(0 /* STRING */, chars, filterResult[0] + 1, filterResult);
                    data[dataIndex] = parse(1 /* NUMBER */, chars, filterResult[0] + 1, filterResult);
                    dataIndex += 2;
                }

                i = filterResult[0];
            } else {
                return null;
            }
        }

        return data;
    }

    (:widget)
    private function parseFilters(chars, i, lightMode, filterResult) {
        filterResult[0] = i;
    }

    // <TotalFilters>,<TotalGroups>|[<FilterGroup>| ...]
    // <FilterGroup> := <GroupName>:<FiltersNumber>(?:<LightMode>)(?:<MinActiveTime>)[<Filter>, ...]
    // <Filter> := <FilterType><FilterOperator><FilterValue>
    (:dataField)
    private function parseFilters(chars, i, lightMode, filterResult) {
        var totalFilters = parse(1 /* NUMBER */, chars, i, filterResult);
        if (totalFilters == null) {
            return null;
        }

        var groupDataLength = lightMode ? 4 : 2;
        var totalGroups = parse(1 /* NUMBER */, chars, filterResult[0] + 1, filterResult);
        var data = new [(totalFilters * 3) + totalGroups * groupDataLength];
        i = filterResult[0];
        var dataIndex = 0;

        while (i < chars.size()) {
            var charNumber = chars[i].toNumber();
            if (charNumber == 35 /* # */) {
                break;
            }

            if (charNumber == 124 /* | */) {
                data[dataIndex] = parse(0 /* STRING */, chars, i + 1, filterResult); // Group title
                data[dataIndex + 1] = parse(1 /* NUMBER */, chars, filterResult[0] + 1, filterResult); // Number of filters in the group
                if (lightMode) {
                    data[dataIndex + 2] = parse(1 /* NUMBER */, chars, filterResult[0] + 1 /* Skip : */, filterResult); // The light mode id
                    if (chars[filterResult[0]] == ':') { // For back compatibility
                        data[dataIndex + 3] = parse(1 /* NUMBER */, chars, filterResult[0] + 1 /* Skip : */, filterResult); // The min active filter time
                    }
                }

                dataIndex += groupDataLength;
                i = filterResult[0];
            } else if (charNumber >= 65 /* A */ && charNumber <= 90 /* Z */) {
                var filterValue = parseFilter(charNumber, chars, i + 1, filterResult);
                data[dataIndex] = chars[i]; // Filter type
                data[dataIndex + 1] = filterResult[1]; // Filter operator
                data[dataIndex + 2] = filterValue; // Filter value
                dataIndex += 3;
                i = filterResult[0];
            } else {
                // Skip any extra characters (e.g. character : for a string generic filter)
                i++;
                filterResult[0] = i;
            }
        }

        return data;
    }

    (:lowMemory)
    private function parseFilter(charNumber, chars, i, filterResult) {
        return charNumber == 69 /* E */ ? parseTimespan(chars, i, filterResult)
            : parseGenericFilter(charNumber, chars, i, filterResult);
    }

    (:highMemory)
    private function parseFilter(charNumber, chars, i, filterResult) {
        return charNumber == 69 /* E */ ? parseTimespan(chars, i, filterResult)
            : charNumber == 70 /* F */? parsePolygons(chars, i, filterResult)
            : charNumber == 73 /* I */ ? parseBikeRadar(chars, i, filterResult)
            : parseGenericFilter(charNumber, chars, i, filterResult);
    }

    // E<?FromType><FromValue>,<?ToType><ToValue> (Es45,r-45 E35645,8212)
    (:dataField)
    private function parseTimespan(chars, index, filterResult) {
        var data = new [4];
        filterResult[1] = null; /* Filter operator */
        parseTimespanPart(chars, index, filterResult, data, 0);
        parseTimespanPart(chars, filterResult[0] + 1 /* Skip , */, filterResult, data, 2);

        return data;
    }

    (:dataField)
    private function parseGenericFilter(charNumber, chars, index, filterResult) {
        filterResult[1] = chars[index]; // Filter operator
        // In case of a string value, the last character will be a : character in order to know where the next filter starts.
        // The : character will be automatically skipped by the parseFilters method, so we do not have to increment the
        // filterResult index here.
        return parse(charNumber == 75 /* Profile name */ ? 0 /* STRING */ : 1 /* NUMBER */, chars, index + 1, filterResult);
    }

    (:dataField)
    private function parseTimespanPart(chars, index, filterResult, data, dataIndex) {
        var char = chars[index];
        var type = char == 's' ? 2 /* Sunset */
            : char == 'r' ? 1 /* Sunrise */
            : 0; /* Total minutes of the day */
        if (type != 0) {
            index++;
        }

        data[dataIndex] = type;
        data[dataIndex + 1] = parse(1 /* NUMBER */, chars, index, filterResult);
    }

    (:highMemory)
    private function parsePolygons(chars, index, filterResult) {
        filterResult[1] = null; /* Filter operator */
        // The first value represents the total number of polygons
        var data = new [parse(1 /* NUMBER */, chars, index, filterResult) * 8];
        var dataIndex = 0;
        index = filterResult[0] + 1;
        while (dataIndex < data.size()) {
            data[dataIndex] = parse(1 /* NUMBER */, chars, index, filterResult);
            dataIndex++;
            index = filterResult[0] + 1;
        }

        return data;
    }

    // I<300>0
    (:highMemory)
    private function parseBikeRadar(chars, index, filterResult) {
        filterResult[1] = chars[index]; // Filter operator
        var data = new [3];
        data[0] = parse(1 /* NUMBER */, chars, index + 1, filterResult); // Range
        data[1] = chars[filterResult[0]]; // Threat operator
        data[2] = parse(1 /* NUMBER */, chars, filterResult[0] + 1, filterResult); // Threat

        return data;
    }

    private function parseLong(chars, index, resultIndex) {
        var left = parse(1 /* NUMBER */, chars, index, resultIndex);
        if (left == null) {
            return null;
        }

        var right = parse(1 /* NUMBER */, chars, resultIndex[0] + 1, resultIndex);
        return (left.toLong() << 32) | right;
    }

    private function parse(type, chars, index, resultIndex) {
        var stringValue = null;
        var i;
        var isFloat = false;
        for (i = index; i < chars.size(); i++) {
            var char = chars[i];
            if (char == '.') {
                isFloat = true;
            }

            if (char == ':' || char == '|' || (type == 1 /* NUMBER */ && (char == '/' || char > 57 /* 9 */ || char < 45 /* - */))) {
                break;
            }

            stringValue = stringValue == null ? char.toString() : stringValue + char;
        }

        resultIndex[0] = i;
        return stringValue == null || type == 0 ? stringValue
            : isFloat ? stringValue.toFloat()
            : stringValue.toNumber();
    }

    private function degToRad(angleDeg) {
        return 3.141593 * angleDeg / 180.0;
    }
}