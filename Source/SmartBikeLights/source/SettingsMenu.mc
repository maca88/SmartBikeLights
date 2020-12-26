using Toybox.WatchUi;
using Toybox.Application.Storage;

(:settings)
module Settings {
    const controlModeNames = [
        "Smart (S)",
        "Network (N)",
        "Manual (M)"
    ];

    function getLightData(lightType, view) {
        return view.headlightData[0].type == lightType ? view.headlightData : view.taillightData;
    }

    class LightsMenu extends WatchUi.Menu2 {

        private var _view;

        function initialize(view) {
            Menu2.initialize(null);
            Menu2.setTitle("Lights");
            Menu2.addItem(new WatchUi.MenuItem(view.headlightSettings[0], null, 0, null));
            Menu2.addItem(new WatchUi.MenuItem(view.taillightSettings[0], null, 2, null));
            _view = view.weak();
        }

        function onSelect(lightType, menuItem) {
            var menu = new LightMenu(lightType, _view.get());
            WatchUi.pushView(menu, new MenuDelegate(menu), WatchUi.SLIDE_IMMEDIATE);
        }
    }

    class LightMenu extends WatchUi.Menu2 {

        private var _view;
        private var _lightType;

        function initialize(lightType, view) {
            Menu2.initialize(null);
            Menu2.setTitle(lightType == 0 /* LIGHT_TYPE_HEADLIGHT */ ? view.headlightSettings[0] : view.taillightSettings[0]);
            Menu2.addItem(new WatchUi.MenuItem("Control mode", null, 0, null));
            Menu2.addItem(new WatchUi.MenuItem("Light modes", null, 1, null));
            _lightType = lightType;
            _view = view.weak();
        }

        function onSelect(id, menuItem) {
            var view = _view.get();
            var menu = id == 0 ? new LightControlModeMenu(_lightType, view) : new LightModesMenu(_lightType, view);
            WatchUi.pushView(menu, new MenuDelegate(menu), WatchUi.SLIDE_IMMEDIATE);
        }
    }

    class LightControlModeMenu extends WatchUi.Menu2 {

        private var _view;
        private var _lightType;

        function initialize(lightType, view) {
            Menu2.initialize(null);
            Menu2.setTitle("Control mode");
            _lightType = lightType;
            _view = view.weak();
            var lightData = getLightData(lightType, view);
            for (var i = 0; i < controlModeNames.size(); i++) {
                Menu2.addItem(new WatchUi.ToggleMenuItem(controlModeNames[i], null, i, lightData[4] == i, null));
            }
        }

        function onSelect(controlMode, menuItem) {
            var lightData = getLightData(_lightType, _view.get());
            var oldControlMode = lightData[4];
            if (oldControlMode == controlMode) {
                return;
            }

            // Update old control mode
            getItem(oldControlMode).setEnabled(false);
            // Set new control mode
            menuItem.setEnabled(true);
            var newMode = controlMode == 2 /* MANUAL */ ? lightData[2] : null;
            _view.get().setLightAndControlMode(lightData, _lightType, newMode, controlMode);
        }
    }

    class LightModesMenu extends WatchUi.Menu2 {

        private var _view;
        private var _lightType;

        function initialize(lightType, view) {
            Menu2.initialize(null);
            Menu2.setTitle("Light modes");
            _lightType = lightType;
            _view = view.weak();
            var lightData = getLightData(lightType, view);
            var lightSettings = lightType == 0 /* LIGHT_TYPE_HEADLIGHT */ ? view.headlightSettings : view.taillightSettings;
            for (var i = 1; i < lightSettings.size(); i += 2) {
                var mode = lightSettings[i + 1];
                Menu2.addItem(new WatchUi.ToggleMenuItem(lightSettings[i], null, mode, lightData[2] == mode, null));
            }
        }

        function onSelect(mode, menuItem) {
            var lightData = getLightData(_lightType, _view.get());
            // Update old control mode
            getItem(findItemById(lightData[2])).setEnabled(false);
            // Set light mode
            menuItem.setEnabled(true);
            var newControlMode = lightData[4] != 2 /* MANUAL */ ? 2 : null;
            _view.get().setLightAndControlMode(lightData, _lightType, mode, newControlMode);
        }
    }

    class MenuDelegate extends WatchUi.Menu2InputDelegate {

        private var _menu;

        function initialize(menu) {
            Menu2InputDelegate.initialize();
            _menu = menu.weak();
        }

        function onSelect(menuItem) {
            if (_menu.stillAlive()) {
                _menu.get().onSelect(menuItem.getId(), menuItem);
            }
        }

        function onBack() {
            _menu = null;
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            return false;
        }
    }
}