using Toybox;
using Toybox.Lang;
using Toybox.WatchUi;
using Toybox.Application.Properties as Properties;

(:touchScreen)
module AppSettings {

    const colorValues = [16711680, 11141120, 16733440, 16755200, 65280, 43520, 43775, 255, 11141375, 16711935];
    const colorNames = [:Red, :DarkRed, :Orange, :Yellow, :Green, :DarkGreen, :Blue, :DarkBlue, :Purple, :Pink];
    const configurationNames = [:Primary, :Secondary, :Tertiary];
    const configurationNameValues = ["CN1", "CN2", "CN3"];
    const configurationValues = [1, 2, 3];
    const settingValues = ["IL", "AC", "CC"];
    const buttonNames = ["", "Center", "Top", "Right", "Bottom", "Left"];

    class BaseMenu extends DataFieldUi.Menu2 {
        protected var viewRef;

        public function initialize(view) {
            Menu2.initialize(null);
            viewRef = view != null ? view.weak() : null;
        }

        public function close() {
            DataFieldUi.popMenu();
        }

        public function openSubMenu(menu) {
            DataFieldUi.pushMenu(menu);
        }
    }

    class Menu extends BaseMenu {

        public function initialize(view) {
            BaseMenu.initialize(view);

            Menu2.setTitle("Settings");
            // Invert lights
            Menu2.addItem(new DataFieldUi.ToggleMenuItem(Rez.Strings.IL, null, 0, Properties.getValue("IL"), null));
            // Activity color
            var colorIndex = colorValues.indexOf(Properties.getValue("AC"));
            Menu2.addItem(new DataFieldUi.MenuItem(Rez.Strings.AC, (colorIndex < 0 ? null : Rez.Strings[colorNames[colorIndex]]), 1, null));
            // Current configuration
            var configurationIndex = configurationValues.indexOf((Properties.getValue("CC")));
            Menu2.addItem(new DataFieldUi.MenuItem(Rez.Strings.CC, (configurationIndex < 0 ? null : Properties.getValue(configurationNameValues[configurationIndex])), 2, null));
            // Remote controllers
            if (view.remoteControllers != null && view.remoteControllers.size() > 0) {
                Menu2.addItem(new DataFieldUi.MenuItem(Rez.Strings.RemoteControllers, null, 3, null));
            }
        }

        // This method will be called only for native Menu2
        // As the current configuration is not updated for Edge touchscreen devices until the menu is closed,
        // there is no point in supporting onShow for custom Menu2
        public function onShow() {
            var view = viewRef.get();
            var hasRemoteControllers = view.remoteControllers != null && view.remoteControllers.size() > 0;
            var index = Menu2.findItemById(3);
            if (hasRemoteControllers && index < 0) {
                Menu2.addItem(new DataFieldUi.MenuItem(Rez.Strings.RemoteControllers, null, 3, null));
            } else if (!hasRemoteControllers && index >= 0) {
                Menu2.deleteItem(index);
            }
        }

        public function onSelect(index, menuItem) {
            var key = index < settingValues.size() ? settingValues[index] : null;
            if (index == 0) {
                var newValue = !Properties.getValue(key); // Toggle invert lights
                menuItem.setEnabled(newValue);
                Properties.setValue(key, newValue);
            } else {
                openSubMenu(index == 1 ? new ListMenu("Color", key, menuItem, colorValues, colorNames, null)
                    : index == 2 ? new ListMenu("Configuration", key, menuItem, configurationValues, configurationNames, configurationNameValues)
                    : new ControllersMenu(viewRef.get()));
            }
        }
    }

    class ControllersMenu extends BaseMenu {

        public function initialize(view) {
            BaseMenu.initialize(view);
            Menu2.setTitle("Controllers");

            var controllers = view.remoteControllers;
            if (controllers == null) {
                return;
            }

            for (var i = 0; i < controllers.size(); i++) {
                Menu2.addItem(new DataFieldUi.MenuItem("Pair " + controllers[i][1] /* Name */, null, i, null));
            }
        }

        public function onSelect(index, menuItem) {
            openSubMenu(new PairControllerMenu(viewRef.get(), index));
        }
    }

    class PairControllerMenu extends BaseMenu {

        private var _controllerIndex;
        private var _buttonIndex = 2; // Index of the first button

        public function initialize(view, controllerIndex) {
            BaseMenu.initialize(view);
            _controllerIndex = controllerIndex;
            Menu2.setTitle("Pairing");
            Menu2.addItem(new DataFieldUi.MenuItem("Starting...", null, 0, null));
            Menu2.addItem(new DataFieldUi.MenuItem("Cancel", null, 1, null));

            view.releaseLightSensors();
            startPairingNextButton();
        }

        public function onSelect(index, menuItem) {
            if (index == 1 /* Cancel */) {
                close();
            }
        }

        public function close() {
            BaseMenu.close();
            var view = viewRef.get();
            view.setupLightSensors(); // Setup again all light sensors
        }

        public function onLightConntected(controllerIndex, buttonIndex) {
            if (_buttonIndex == buttonIndex) {
                _buttonIndex++;
                startPairingNextButton();
            }
        }

        private function startPairingNextButton() {
            var view = viewRef.get();
            var menuItem = getItem(0);
            var controller = view.remoteControllers[_controllerIndex];
            var button = null;
            var error = null;
            while (_buttonIndex < controller.size()) {
                button = controller[_buttonIndex];
                if (button[1] /* Device number*/ <= 0) {
                    _buttonIndex++;
                    continue;
                }

                error = view.startLightSensor(_controllerIndex, _buttonIndex, null, method(:onLightConntected));
                break;
            }

            var completed = _buttonIndex >= controller.size();
            var text = completed ? "Paring complete"
                : error != null ? "Error " + error
                : "Pair " + buttonNames[button[0] /* Button id */] + " button";
            menuItem.setLabel(text);
            if (completed) {
                Menu2.deleteItem(1);
            }
        }
    }

    class ListMenu extends BaseMenu {

        private var _menuItem;
        private var _key;
        private var _values;
        private var _names;
        private var _nameKeys;

        public function initialize(title, key, menuItem, values, names, nameKeys) {
            BaseMenu.initialize(null);
            Menu2.setTitle(title);
            _key = key;
            _menuItem = menuItem.weak();
            _values = values;
            _names = names;
            _nameKeys = nameKeys;
            for (var i = 0; i < values.size(); i++) {
                var value = values[i];
                var name = nameKeys != null ? Properties.getValue(nameKeys[i]) : null;
                if (name == null) {
                    name = names[i];
                    name = name instanceof String ? name : Rez.Strings[name];
                }

                Menu.addItem(new DataFieldUi.MenuItem(name, null, value, null));
            }
        }

        public function onSelect(newValue, menuItem) {
            var oldValue = Properties.getValue(_key);
            if (oldValue == newValue) {
                close();
                return;
            }

            // Set new value
            Properties.setValue(_key, newValue);
            // Set parent sub label
            var index = _values.indexOf(newValue);
            if (_menuItem.stillAlive() && index >= 0) {
                var name = _nameKeys != null ? Properties.getValue(_nameKeys[index]) : null;
                if (name == null) {
                    name = _names[index];
                    name = name instanceof String ? name : Rez.Strings[name];
                }

                _menuItem.get().setSubLabel(name);
            }

            close();
        }
    }
}