import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class TestMenu extends WatchUi.Menu2 {

    function initialize() {
        Menu2.initialize(null);
        setTitle("Menu");
        addItem(new WatchUi.MenuItem("Test", null, 0, null));
        addItem(new WatchUi.MenuItem("Test2", null, 1, null));
    }
}

class MenuDelegate extends WatchUi.Menu2InputDelegate {

    private var _menu;

    function initialize(menu) {
        Menu2InputDelegate.initialize();
        _menu = menu.weak();
    }

    function onSelect(menuItem) {
    }
}

class GradeDataFieldApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        return [ new GradeDataFieldView() ] as Array<Views or InputDelegates>;
    }

    function getSettingsView() {
        var menu = new TestMenu();
        return [menu, new MenuDelegate(menu)];
    }
}

function getApp() as GradeDataFieldApp {
    return Application.getApp() as GradeDataFieldApp;
}