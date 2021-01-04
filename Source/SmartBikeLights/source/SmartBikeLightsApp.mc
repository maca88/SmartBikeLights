using Toybox.Application;
using Toybox.WatchUi;

(:touchScreen)
class BikeLightsViewDelegate extends WatchUi.InputDelegate {
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
        _view = new BikeLightsView();
    }

    function onSettingsChanged() {
        _view.onSettingsChanged();
        _view.onShow(); // Reinitialize lights
    }

    // Return the initial view of your application here
    (:nonTouchScreen)
    function getInitialView() {
        return [_view];
    }

    (:touchScreen)
    function getInitialView() {
        return [_view, new BikeLightsViewDelegate(_view)];
    }

    (:settings)
    function getSettingsView() {
        return _view.getSettingsView();
    }
}
