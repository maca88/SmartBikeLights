using Toybox.WatchUi;
using Toybox.Application.Storage;

(:settings)
module LightsSettings {
    const controlModeNames = [
        "Smart (S)",
        "Network (N)",
        "Manual (M)"
    ];

    class BaseMenu extends WatchUi.Menu2 {
        protected var context;
        protected var viewRef;
        protected var closed = false;

        function initialize(view, context) {
            Menu2.initialize(null);
            viewRef = view.weak();
            self.context = context;
        }

        function onShow() {
            if (!isContextValid()) {
                close();
            }
        }

        function isContextValid() {
            var view = viewRef.get();
            return context[0] == view.headlightSettings && // Check for settings change
                context[1] == view.taillightSettings && // Check for settings change
                view.getLightData(null)[0] != null; // Check whether the network was disconnected
        }

        function close() {
            if (closed) {
                return;
            }

            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            closed = true;
        }

        function openSubMenu(menu) {
            WatchUi.pushView(menu, new MenuDelegate(menu), WatchUi.SLIDE_IMMEDIATE);
        }
    }

    class LightsMenu extends BaseMenu {

        function initialize(view, context, root) {
            BaseMenu.initialize(view, context);
            setTitle("Lights");
            addItem(new WatchUi.MenuItem(context[2][0], null, 0, null));
            addItem(new WatchUi.MenuItem(context[3][0], null, 2, null));
            if (root) {
                addItem(new WatchUi.MenuItem("Settings", null, 3, null));
            }
        }

        function onSelect(lightType, menuItem) {
            openSubMenu(lightType == 3
                ? new AppSettings.Menu()
                : new LightMenu(lightType, viewRef.get(), context, false));
        }
    }

    class LightMenu extends BaseMenu {

        private var _lightType;

        function initialize(lightType, view, context, root) {
            BaseMenu.initialize(view, context);
            var lightSettings = lightType == 0 /* LIGHT_TYPE_HEADLIGHT */ ? context[2] : context[3];
            setTitle(lightSettings[0]);
            _lightType = lightType;
            // Register callbacks
            var selfRef = self.weak();
            view.onLightModeChangeCallback = selfRef;
            view.onLightControlModeChangeCallback = selfRef;
            var lightData = view.getLightData(lightType);
            var modeIndex = lightSettings.indexOf(lightData[2]);
            addItem(new WatchUi.MenuItem("Control mode", controlModeNames[lightData[4]], 0, null));
            addItem(new WatchUi.MenuItem("Light modes", modeIndex < 0 ? null : lightSettings[modeIndex - 1], 1, null));
            if (root) {
                addItem(new WatchUi.MenuItem("Settings", null, 2, null));
            }
        }

        function onLightModeChange(lightType, lightMode) {
            if (closed || _lightType != lightType) {
                return;
            }

            var lightSettings = lightType == 0 /* LIGHT_TYPE_HEADLIGHT */ ? context[2] : context[3];
            var modeIndex = lightSettings.indexOf(lightMode);
            var item = getItem(1);
            item.setSubLabel(modeIndex < 0 ? null : lightSettings[modeIndex - 1]);
        }

        function onLightControlModeChange(lightType, controlMode) {
            if (closed || _lightType != lightType) {
                return;
            }

            var item = getItem(0);
            item.setSubLabel(controlModeNames[controlMode]);
        }

        function onSelect(id, menuItem) {
            var view = viewRef.get();
            var menu = id == 0 ? new LightControlModeMenu(_lightType, view, menuItem, context)
                : id == 1 ? new LightModesMenu(_lightType, view, menuItem, context)
                : new AppSettings.Menu();
            openSubMenu(menu);
        }
    }

    class LightControlModeMenu extends BaseMenu {

        private var _lightType;
        private var _menuItem;

        function initialize(lightType, view, menuItem, context) {
            BaseMenu.initialize(view, context);
            setTitle("Control mode");
            _lightType = lightType;
            _menuItem = menuItem.weak();
            var lightData = view.getLightData(_lightType);
            for (var i = 0; i < controlModeNames.size(); i++) {
                if (i == 0 && lightData[17] /* Filters */ == null) {
                    continue; // Do not show smart mode when there are no filters
                }

                addItem(new WatchUi.MenuItem(controlModeNames[i], null, i, null));
            }
        }

        function onSelect(controlMode, menuItem) {
            var view = viewRef.get();
            var lightData = view.getLightData(_lightType);
            var oldControlMode = lightData[4];
            if (oldControlMode != controlMode) {
                // Set new control mode
                var newMode = controlMode == 2 /* MANUAL */ ? lightData[2] : null;
                view.setLightAndControlMode(lightData, _lightType, newMode, controlMode);
            }

            // Set parent sub label
            if (_menuItem.stillAlive()) {
                _menuItem.get().setSubLabel(controlModeNames[controlMode]);
            }

            close();
        }
    }

    class LightModesMenu extends BaseMenu {

        private var _lightType;
        private var _menuItem;

        function initialize(lightType, view, menuItem, context) {
            BaseMenu.initialize(view, context);
            setTitle("Light modes");
            _lightType = lightType;
            _menuItem = menuItem.weak();
            var lightSettings = lightType == 0 /* LIGHT_TYPE_HEADLIGHT */ ? context[2] : context[3];
            for (var i = 1; i < lightSettings.size(); i += 2) {
                var mode = lightSettings[i + 1];
                addItem(new WatchUi.MenuItem(lightSettings[i], null, mode, null));
            }
        }

        function onSelect(mode, menuItem) {
            var view = viewRef.get();
            var lightData = view.getLightData(_lightType);
            // Set light mode
            var newControlMode = lightData[4] != 2 /* MANUAL */ ? 2 : null;
            view.setLightAndControlMode(lightData, _lightType, mode, newControlMode);
            // Set parent sub label
            if (_menuItem.stillAlive()) {
                var lightSettings = _lightType == 0 /* LIGHT_TYPE_HEADLIGHT */ ? context[2] : context[3];
                var modeIndex = lightSettings.indexOf(mode);
                _menuItem.get().setSubLabel(modeIndex < 0 ? null : lightSettings[modeIndex - 1]);
            }

            close();
        }
    }
}