using Toybox.WatchUi;

// Used for lights and app settings menus
(:settings)
class MenuDelegate extends WatchUi.Menu2InputDelegate {

    private var _menu;

    function initialize(menu) {
        Menu2InputDelegate.initialize();
        _menu = menu.weak();
    }

    function onSelect(menuItem) {
        if (!_menu.stillAlive()) {
            return;
        }

        var menu = _menu.get();
        if (menu has :isContextValid && !menu.isContextValid()) {
            menu.close();
            return;
        }

        menu.onSelect(menuItem.getId(), menuItem);
    }

    function onBack() {
        if (!_menu.stillAlive()) {
            return;
        }

        _menu.get().close();
    }
}