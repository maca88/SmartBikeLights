using Toybox;
using Toybox.WatchUi;
using Toybox.Application.Properties as Properties;

(:touchScreen)
module AppSettings {

    const colorValues = [16711680, 11141120, 16733440, 16755200, 65280, 43520, 43775, 255, 11141375, 16711935];
    const colorNames = [:Red, :DarkRed, :Orange, :Yellow, :Green, :DarkGreen, :Blue, :DarkBlue, :Purple, :Pink];
    const configurationNames = [:Primary, :Secondary, :Tertiary];
    const configurationValues = [1, 2, 3];
    const settingValues = ["IL", "AC", "CC"];

    class BaseMenu extends DataFieldUi.Menu2 {

        public function initialize() {
            Menu2.initialize(null);
        }

        public function close() {
            DataFieldUi.popMenu();
        }

        public function openSubMenu(menu) {
            DataFieldUi.pushMenu(menu);
        }
    }

    class Menu extends BaseMenu {

        public function initialize() {
            BaseMenu.initialize();
            Menu2.setTitle("Settings");
            // Invert lights
            Menu2.addItem(new DataFieldUi.ToggleMenuItem(Rez.Strings.IL, null, 0, Properties.getValue("IL"), null));
            // Activity color
            var colorIndex = colorValues.indexOf(Properties.getValue("AC"));
            Menu2.addItem(new DataFieldUi.MenuItem(Rez.Strings.AC, (colorIndex < 0 ? null : Rez.Strings[colorNames[colorIndex]]), 1, null));
            // Current configuration
            var configurationIndex = configurationValues.indexOf((Properties.getValue("CC")));
            Menu2.addItem(new DataFieldUi.MenuItem(Rez.Strings.CC, (configurationIndex < 0 ? null : Rez.Strings[configurationNames[configurationIndex]]), 2, null));
        }

        public function onSelect(index, menuItem) {
            var key = settingValues[index];
            if (index == 0) {
                var newValue = !Properties.getValue("IL"); // Toggle invert lights
                menuItem.setEnabled(newValue);
                Properties.setValue(key, newValue);
                Application.getApp().onSettingsChanged();
            } else {
                openSubMenu(index == 1
                    ? new ListMenu("Color", key, menuItem, colorValues, colorNames)
                    : new ListMenu("Configuration", key, menuItem, configurationValues, configurationNames));
            }
        }
    }

    class ListMenu extends BaseMenu {

        private var _menuItem;
        private var _key;
        private var _values;
        private var _names;

        public function initialize(title, key, menuItem, values, names) {
            BaseMenu.initialize();
            Menu2.setTitle(title);
            _key = key;
            _menuItem = menuItem.weak();
            _values = values;
            _names = names;
            var currentValue = Properties.getValue(key);
            for (var i = 0; i < values.size(); i++) {
                var value = values[i];
                var name = names[i];
                Menu.addItem(new DataFieldUi.MenuItem(Rez.Strings[name], null, value, null));
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
            Application.getApp().onSettingsChanged();
            // Set parent sub label
            var index = _values.indexOf(newValue);
            if (_menuItem.stillAlive() && index >= 0) {
                _menuItem.get().setSubLabel(Rez.Strings[_names[index]]);
            }

            close();
        }
    }
}