using Toybox.WatchUi;
using Toybox.AntPlus;
using Toybox.Lang;
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
    protected var _monochrome;
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

    // Pre-calculated light panel values
    (:touchScreen) private var _headlightPanel;
    (:touchScreen) private var _taillightPanel;
    (:touchScreen) private var _panelInitialized = false;

    // Settings data
    (:settings) var headlightSettings;
    (:settings) var taillightSettings;
    (:settings) private var _settingsInitialized;

    // Fields used to evaluate filters
    protected var _todayMoment;
    protected var _sunsetTime;
    protected var _sunriseTime;
    (:dataField) private var _lastSpeed;
    (:dataField) private var _acceleration;
    (:polygons) private var _bikeRadar;

    private var _lastUpdateTime = 0;

    // Used as an out parameter for getting the group filter title
    private var _filterResult = [null /* Title */, 0 /* Filter timeout */];

    function initialize() {
        BaseView.initialize();
        _lightsFont = getFont(:lightsFont);
        _batteryFont = getFont(:batteryFont);
        _controlModeFont = getFont(:controlModeFont);
        _lightNetworkListener = new BikeLightNetworkListener(self);

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
            if (!validateLightModes(headlightData[0]) || !validateLightModes(taillightData[0])) {
                return;
            }

            headlightData[3] = headlightModes;
            var lightData = headlightModes == null ? headlightData : taillightData;
            lightData[3] = configuration[3];
        } catch (e) {
            _errorCode = 3;
        }
    }

    // Overrides DataField.onLayout
    function onLayout(dc) {
        // Due to getObsurityFlags returning incorrect results here, we have to postpone the calculation to onUpdate method
        _lightY = null; // Force to pre-calculate again
    }

    // onShow() is called when this View is brought to the foreground
    function onShow() {
        //System.println("onShow=" + _lastUpdateTime  + " timer=" + System.getTimer());
        // When start button is pressed onShow is called, skip re-initialization in such case. This also prevents
        // a re-initialization when switching between two data screens that both contain this data field.
        if (_initializedLights > 0 && System.getTimer() - _lastUpdateTime < 1500) {
            initializeLights(null, false);
            return;
        }

        // In case the user modifies the network mode outside the data field by using the built-in Garmin lights menu,
        // the LightNetwork mode will not be updated (LightNetwork.getNetworkMode). The only way to update it is to
        // create a new LightNetwork.
        releaseLights();
        _lightNetwork = null; // Release light network
        setupNetwork();
    }

    // Overrides DataField.compute
    (:dataField)
    function compute(activityInfo) {
        // NOTE: Use only for testing purposes when using TestLightNetwork
        //if (_lightNetwork != null && _lightNetwork has :update) {
        //    _lightNetwork.update();
        //}

        if (_initializedLights == 0 || _errorCode != null) {
            return null;
        }

        var lastSpeed = _lastSpeed;
        var currentSpeed = activityInfo.currentSpeed;
        _acceleration = lastSpeed != null && currentSpeed != null && lastSpeed > 0 && currentSpeed > 0
            ? ((currentSpeed / lastSpeed) - 1) * 100
            : null;
        if (_sunsetTime == null && activityInfo.currentLocation != null) {
            var position = activityInfo.currentLocation.toDegrees();
            var time = Gregorian.utcInfo(Time.now(), Time.FORMAT_SHORT);
            var jd = getJD(time.year, time.month, time.day);
            _sunriseTime = getSunriseSet(true, jd, position);
            _sunsetTime = getSunriseSet(false, jd, position);
        }

        var globalFilterResult = null;
        var size = _initializedLights;
        var filterResult = _filterResult;
        var globalFilterTitle = null;
        for (var i = 0; i < size; i++) {
            var lightData = i == 0 ? headlightData : taillightData;
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
            drawCenterText(dc, text, fgColor, width, height);
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

        var lightData = _initializedLights == 1 || lightType == 0 /* LIGHT_TYPE_HEADLIGHT */ ? headlightData : taillightData;
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

        if (updateLightTextAndMode(lightData, mode) && nextMode != mode && controlMode != 1 /* NETWORK */) {
            // Change was done outside the data field.
            onExternalLightModeChange(lightData, mode);
        }
    }

    (:settings)
    function getSettingsView() {
        if (_errorCode != null || _initializedLights == 0 || !initializeSettings() || !(WatchUi has :Menu2)) {
            return null;
        }

        var menu = _initializedLights > 1
            ? new Settings.LightsMenu(self)
            : new Settings.LightMenu(headlightData[0].type, self);

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
            setLightData("MM", lightType, newMode);
            setLightMode(lightData, newMode, null, forceSetMode);
        } else if (newControlMode == 0 /* SMART */ && forceSetMode) {
            setLightMode(lightData, lightData[2], null, true);
        }

        if (newControlMode != null) {
            setLightData("CM", lightType, newControlMode);
            lightData[4] = newControlMode;
        }
    }

    (:touchScreen)
    function onTap(location) {
        if (_fieldWidth == null || _initializedLights == 0 || _errorCode != null) {
            return false;
        }

        // Find which light was tapped
        var lightData = _initializedLights == 1 || (_fieldWidth / 2) > location[0]
            ? headlightData
            : taillightData;

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
        _monochrome = !settings[0];
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
        _monochrome = !settings[0];
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
                setLightData("CM", lightType, 1 /* NETWORK */);
            }

            var controlMode = getLightData("CM", lightType, filters != null ? 0 /* SMART */ : 1 /* NETWORK */);
            var lightMode = getInitialLightMode(light, controlMode);
            var lightModeIndex = capableModes.indexOf(lightMode);
            if (lightModeIndex < 0) {
                lightModeIndex = 0;
                lightMode = 0; /* LIGHT_MODE_OFF */
            }

            var lightData = lightType == 0 /* LIGHT_TYPE_HEADLIGHT */ || totalLights == 1 ? headlightData : taillightData;
            if (firstTime && lightData[0] != null) {
                errorCode = 2;
                break;
            }

            if (recordLightModes && lightData[6] == null) {
                lightData[6] = createField(
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
            validateLightModes(light);
        }

        _errorCode = errorCode;

        return errorCode == null ? totalLights : 0;
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
        return modes == null ? [0] : modes;
    }

    protected function setLightData(id, lightType, value) {
        Application.Storage.setValue(id + lightType, value);
    }

    (:lightButtons)
    protected function onExternalLightModeChange(lightData, mode) {
        //System.println("onExternalLightModeChange mode=" + mode + " lightType=" + lightData[0].type  + " timer=" + System.getTimer());
        setLightAndControlMode(lightData, lightData[0].type, mode, lightData[4] != 2 ? 2 /* MANUAL */ : null);
    }

    (:noLightButtons)
    protected function onExternalLightModeChange(lightData, mode) {
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
            // Assume that the change was done either by Garmin lights menu or a CIQ application
            setLightData("CM", lightType, 2 /* MANUAL */);
            setLightData("MM", lightType, mode);
        }
    }

    protected function releaseLights() {
        _initializedLights = 0;
        headlightData[0] = null;
        taillightData[0] = null;
    }

    (:settings)
    protected function initializeSettings() {
        if (_settingsInitialized) {
            return true;
        }

        if (!validateSettingsLightModes(headlightData[0]) || !validateSettingsLightModes(taillightData[0])) {
            return false;
        }

        if (headlightSettings == null && headlightData[0].type == 0 /* LIGHT_TYPE_HEADLIGHT */) {
            headlightSettings = getDefaultLightSettings(headlightData[0]);
        }

        if (taillightSettings == null) {
            var lightData = _initializedLights > 1 ? taillightData
                : headlightData[0].type == 2 ? headlightData
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

    (:rectangle)
    protected function drawCenterText(dc, text, color, width, height) {
        setTextColor(dc, color);
        dc.drawText(width / 2, height / 2, 2, text, 1 /* TEXT_JUSTIFY_CENTER */ | 4 /* TEXT_JUSTIFY_VCENTER */);
    }

    (:round)
    protected function drawCenterText(dc, text, color, width, height) {
        setTextColor(dc, color);
        dc.drawText(width / 2, height / 2, 0, text, 1 /* TEXT_JUSTIFY_CENTER */ | 4 /* TEXT_JUSTIFY_VCENTER */);
    }

    protected function getSunriseSet(sunrise, jd, position) {
        var value = calcSunriseSetUTC(sunrise, jd, position[0].toFloat(), position[1].toFloat());
        return getSecondsOfDay(value * 60);
    }

    protected function getSecondsOfDay(value) {
        value = value.toNumber();
        return (value < 0 ? value + 86400 : value) % 86400;
    }

    private function getLightFilters(light) {
        return light.type == 0 /* LIGHT_TYPE_HEADLIGHT */ ? _headlightFilters : _taillightFilters;
    }

    private function updateLightTextAndMode(lightData, mode) {
        if (lightData[2] == mode) {
            return false;
        }

        lightData[1] = getLightText(lightData[0].type, mode, lightData[3]);
        lightData[2] = mode;
        var fitField = lightData[6];
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

        var modes = light.getCapableModes();
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

    (:noLightButtons)
    private function setupLightButtons(configuration) {
    }

    (:touchScreen)
    private function setupLightButtons(configuration) {
        _controlModeOnly = getPropertyValue("CMO");
        _panelInitialized = false;
        _headlightPanel = configuration[5];
        _taillightPanel = configuration[6];
    }

    (:settings)
    private function setupLightButtons(configuration) {
        _settingsInitialized = false;
        headlightSettings = configuration[5];
        taillightSettings = configuration[6];
    }

    (:testNetwork)
    private function setupNetwork() {
        _lightNetwork = new TestNetwork.TestLightNetwork(_lightNetworkListener);
    }

    (:deviceNetwork)
    private function setupNetwork() {
        _lightNetwork = new AntPlus.LightNetwork(_lightNetworkListener);
    }

    (:nonTouchScreen)
    private function draw(dc, width, height, fgColor, bgColor) {
        if (_initializedLights == 1) {
            drawLight(headlightData, 2, dc, width, fgColor, bgColor);
            return;
        }

        // Draw separator
        setTextColor(dc, _activityColor);
        dc.setPenWidth(_monochrome ? 1 : 2);
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
        dc.setPenWidth(_monochrome ? 1 : 2);
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
            data[dataIndex + 1] = mode == 0 ? -1 : mode; // Light mode
            data[dataIndex + 2] = mode == 0 ? null : mode.toString(); // Mode name
            if (mode == 0 /* Off */) {
                data[dataIndex + 9] = mode;
                data[dataIndex + 10] = "Off";
            }

            dataIndex += 1 + (totalButtons * 8);
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

    (:lightButtons)
    protected function getLightData(id, lightType, defaultValue) {
        var key = id + lightType;
        var value = Application.Storage.getValue(key);
        if (value == null) {
            // First application startup
            value = defaultValue;
            Application.Storage.setValue(key, value);
        }

        return value;
    }

    (:noLightButtons)
    protected function getLightData(id, lightType, defaultValue) {
        var key = id + lightType;
        var value = Application.Storage.getValue(key);
        if (value != null) {
            Application.Storage.deleteValue(key);
        }

        return value != null ? value : defaultValue;
    }

    protected function getInitialLightMode(light, controlMode) {
        return controlMode <= 1 /*NETWORK*/ ? light.mode
            : getLightData("MM", light.type, 0 /* LIGHT_MODE_OFF */);
    }

    private function setTextColor(dc, color) {
        dc.setColor(_monochrome ? 0x000000 /* COLOR_BLACK */ : color, -1 /* COLOR_TRANSPARENT */);
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

    private function getFont(key) {
        return WatchUi.loadResource(Rez.Fonts[key]);
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
                _errorCode = 4;
                return false;
            }

            i = i + 4 + (totalFilters * 3);
        }

        return true;
    }

    (:settings)
    private function validateSettingsLightModes(light) {
        if (light == null) {
            return true;
        }

        var settings = light.type == 0 /* LIGHT_TYPE_HEADLIGHT */ ? headlightSettings : taillightSettings;
        if (settings == null) {
            return true;
        }

        var capableModes = light.getCapableModes();
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

    (:polygons)
    private function checkFilter(filterType, activityInfo, filters, i, filterValue, lightData) {
        return filterType == 'E' ? isWithinTimespan(filters, i, filterValue)
            : filterType == 'F' ? isInsideAnyPolygon(activityInfo, filterValue)
            : filterType == 'I' ? isTargetBehind(activityInfo, filters[i + 1], filterValue)
            : filterType == 'D' ? true
            : checkGenericFilter(activityInfo, filterType, filters[i + 1], filterValue, lightData);
    }

    (:noPolygons)
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
        var value = filterType == 'C' ? activityInfo.currentSpeed
            : filterType == 'A' ? _acceleration
            : filterType == 'B' ? lightData != null ? getLightBatteryStatus(lightData) : null
            : filterType == 'G' ? (activityInfo.currentLocationAccuracy == null ? 0 : activityInfo.currentLocationAccuracy)
            : filterType == 'H' ? activityInfo.timerState
            : null;
        if (value == null) {
            return false;
        }

        return operator == '<' ? value < filterValue
            : operator == '>' ? value > filterValue
            : operator == '=' ? value == filterValue
            : false;
    }

    (:polygons)
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
    (:polygons)
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

    (:polygons)
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

    (:polygons)
    private function checkOperatorValue(operator, value, filterValue) {
        if (value == null) {
            return filterValue < 0;
        }

        return operator == '<' ? value < filterValue
            : operator == '>' ? value > filterValue
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
    (:noLightButtons)
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

    (:lightButtons)
    private function parseConfiguration(value) {
        if (value == null || value.length() == 0) {
            return new [7];
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
            parseLightButtons(chars, filterResult[0] + 1, filterResult)       // Taillight panel/settings buttons
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
        // [:TotalButtonGroups:, :LightName:, :LightNameX:, :LightNameY:, :BatteryX:, :BatteryY:, (<ButtonGroup>)+]
        // <ButtonGroup> := [:NumberOfButtons:, :Mode:, :TitleX:, :TitleFont:, (<TitlePart>)+, :ButtonLeftX:, :ButtonTopY:, :ButtonWidth:, :ButtonHeight:){:NumberOfButtons:} ]
        // <TitlePart> := [(:Title:, :TitleY:)+]
        var data = new [6 + (8 * totalButtons) + totalButtonGroups];
        data[0] = totalButtonGroups;
        data[1] = parse(0 /* STRING */, chars, filterResult[0] + 1, filterResult);
        i = filterResult[0];
        var dataIndex = 6;

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
                    data[dataIndex + 1] = parse(0 /* STRING */, chars, filterResult[0] + 1, filterResult); // Will be transformed to titleX later
                    data[dataIndex] = parse(1 /* NUMBER */, chars, filterResult[0] + 1, filterResult);
                    dataIndex += 8;
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
                i++;
            }
        }

        return data;
    }

    (:noPolygons)
    private function parseFilter(charNumber, chars, i, filterResult) {
        return charNumber == 69 /* E */ ? parseTimespan(chars, i, filterResult)
            : parseGenericFilter(chars, i, filterResult);
    }

    (:polygons)
    private function parseFilter(charNumber, chars, i, filterResult) {
        return charNumber == 69 /* E */ ? parseTimespan(chars, i, filterResult)
            : charNumber == 70 /* F */? parsePolygons(chars, i, filterResult)
            : charNumber == 73 /* I */ ? parseBikeRadar(chars, i, filterResult)
            : parseGenericFilter(chars, i, filterResult);
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
    private function parseGenericFilter(chars, index, filterResult) {
        filterResult[1] = chars[index]; // Filter operator

        return parse(1 /* NUMBER */, chars, index + 1, filterResult);
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

    (:polygons)
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
    (:polygons)
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

    // The below source code was ported from: https://www.esrl.noaa.gov/gmd/grad/solcalc/main.js
    // which is used for the NOAA Solar Calculator: https://www.esrl.noaa.gov/gmd/grad/solcalc/
    protected function getJD(year, month, day) {
        if (month <= 2) {
            year -= 1;
            month += 12;
        }

        var a = Math.floor(year / 100);
        var b = 2 - a + Math.floor(a / 4);
        return Math.floor(365.25 * (year + 4716)) + Math.floor(30.6001 * (month + 1)) + day + b - 1524.5;
    }

    private function calcSunriseSetUTC(rise, jd, latitude, longitude) {
        var t = (jd - 2451545.0) / 36525.0;
        var eqTime = calcEquationOfTime(t);
        var solarDec = calcSunDeclination(t);
        var hourAngle = calcHourAngleSunrise(latitude, solarDec);
        if (!rise) {
            hourAngle = -hourAngle;
        }

        var delta = longitude + radToDeg(hourAngle);
        return 720 - (4.0 * delta) - eqTime; // timeUTC in minutes
    }

    private function calcEquationOfTime(t) {
        var epsilon = calcObliquityCorrection(t);
        var l0 = calcGeomMeanLongSun(t);
        var e = 0.016708634 - t * (0.000042037 + 0.0000001267 * t); // unitless
        var m = calcGeomMeanAnomalySun(t);

        var y = Math.tan(degToRad(epsilon)/2.0);
        y *= y;

        var sin2l0 = Math.sin(2.0 * degToRad(l0));
        var sinm   = Math.sin(degToRad(m));
        var cos2l0 = Math.cos(2.0 * degToRad(l0));
        var sin4l0 = Math.sin(4.0 * degToRad(l0));
        var sin2m  = Math.sin(2.0 * degToRad(m));

        var eTime = y * sin2l0 - 2.0 * e * sinm + 4.0 * e * y * sinm * cos2l0 - 0.5 * y * y * sin4l0 - 1.25 * e * e * sin2m;
        return radToDeg(eTime) * 4.0; // in minutes of time
    }

    private function calcSunDeclination(t) {
        var e = calcObliquityCorrection(t);
        var lambda = calcSunApparentLong(t);
        var sint = Math.sin(degToRad(e)) * Math.sin(degToRad(lambda));
        return radToDeg(Math.asin(sint)); // in degrees
    }

    private function calcHourAngleSunrise(lat, solarDec) {
        var latRad = degToRad(lat);
        var sdRad  = degToRad(solarDec);
        var haArg = (Math.cos(degToRad(90.833)) / (Math.cos(latRad) * Math.cos(sdRad)) - Math.tan(latRad) * Math.tan(sdRad));
        return Math.acos(haArg); // in radians (for sunset, use -HA)
    }

    private function calcSunApparentLong(t) {
        var o = calcGeomMeanLongSun(t) + calcSunEqOfCenter(t); // in degrees
        var omega = 125.04 - 1934.136 * t;
        return o - 0.00569 - 0.00478 * Math.sin(degToRad(omega)); // in degrees
    }

    private function calcSunEqOfCenter(t) {
        var m = calcGeomMeanAnomalySun(t);
        var mrad = degToRad(m);
        var sinm = Math.sin(mrad);
        var sin2m = Math.sin(mrad + mrad);
        var sin3m = Math.sin(mrad + mrad + mrad);
        return sinm * (1.914602 - t * (0.004817 + 0.000014 * t)) + sin2m * (0.019993 - 0.000101 * t) + sin3m * 0.000289; // in degrees
    }

    private function calcObliquityCorrection(t) {
        var e0 = calcMeanObliquityOfEcliptic(t);
        var omega = 125.04 - 1934.136 * t;
        return e0 + 0.00256 * Math.cos(degToRad(omega)); // in degrees
    }

    private function calcMeanObliquityOfEcliptic(t) {
        var seconds = 21.448 - t * (46.8150 + t * (0.00059 - t * 0.001813));
        return 23.0 + (26.0 + (seconds / 60.0)) / 60.0; // in degrees
    }

    private function calcGeomMeanLongSun(t) {
        var L0 = 280.46646 + t * (36000.76983 + t * 0.0003032);
        while (L0 > 360.0) {
            L0 -= 360.0;
        }

        while (L0 < 0.0) {
            L0 += 360.0;
        }

        return L0; // in degrees
    }

    private function calcGeomMeanAnomalySun(t) {
        return 357.52911 + t * (35999.05029 - 0.0001537 * t); // in degrees
    }

    private function degToRad(angleDeg) {
        return Math.PI * angleDeg / 180.0;
    }

    private function radToDeg(angleRad) {
        return 180.0 * angleRad / Math.PI;
    }
}