using Toybox.Application;
using Toybox.WatchUi;

(:touchScreen)
class SmartBikeLightsViewDelegate extends WatchUi.InputDelegate {
    private var _eventHandler;

    function initialize(eventHandler) {
        InputDelegate.initialize();
        _eventHandler = eventHandler.weak();
    }

    function onTap(clickEvent) {
        return _eventHandler.stillAlive()
            ? _eventHandler.get().onTap(clickEvent.getCoordinates())
            : false;
    }
}

class SmartBikeLightsApp extends Application.AppBase {

    private var _view;

    function initialize() {
        AppBase.initialize();
        _view = new SmartBikeLightsView();
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    function onSettingsChanged() {
        _view.onSettingsChanged();
    }

    // Return the initial view of your application here
    (:nonTouchScreen)
    function getInitialView() {
        return [_view];
    }

    (:touchScreen)
    function getInitialView() {
        return [_view, new SmartBikeLightsViewDelegate(_view)];
    }
}
