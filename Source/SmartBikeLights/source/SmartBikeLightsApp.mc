using Toybox.Application;
using Toybox.WatchUi;
using Toybox.AntPlus;
using Toybox.Sensor;

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

class BikeLightNetworkListener extends AntPlus.LightNetworkListener {
    private var _eventHandler;

    function initialize(eventHandler) {
        LightNetworkListener.initialize();
        _eventHandler = eventHandler.weak();
    }

    function onLightNetworkStateUpdate(state) {
        _eventHandler.get().onNetworkStateUpdate(state);
    }

    function onBikeLightUpdate(light) {
        _eventHandler.get().updateLight(light, light.mode);
    }
}

class SmartBikeLightsApp extends Application.AppBase {

    private var _view;
    (:highMemory)
    private var _pairing = false;

    function initialize() {
        //System.println("SmartBikeLightsApp.initialize");
        AppBase.initialize();
        _view = new BikeLightsView();
    }

    (:highMemory)
    function onSettingsChanged() {
        if (_pairing) {
            return;
        }

        _view.onSettingsChanged(true);
        _view.onShow(); // Reinitialize lights
    }

    (:lowMemory)
    function onSettingsChanged() {
        _view.onSettingsChanged();
        _view.onShow(); // Reinitialize lights
    }

    (:highMemory)
    function onStorageChanged() as Void {
        //System.println("onStorageChanged timer=" + System.getTimer() + " pairing=" + _pairing + " RN=" + Application.Storage.getValue("RN"));
        // RN key is set by BikeLightSensorDelegate
        if (!_pairing && Application.Storage.getValue("RN") != null) {
            Application.Storage.deleteValue("RN");
            _view.recreateLightNetwork();
        }
    }

    // Return the initial view of your application here
    (:nonTouchScreen)
    function getInitialView() {
        //System.println("getInitialView timer=" + System.getTimer());
        // Ideally onSettingsChanged should be called in onStart method, but as we do not know
        // at that time whether the app will be used for pairing, we have to do it here
        onSettingsChanged();
        return [_view];
    }

    (:touchScreen)
    function getInitialView() {
        //System.println("getInitialView timer=" + System.getTimer());
        // Ideally onSettingsChanged should be called in onStart method, but as we do not know
        // at that time whether the app will be used for pairing, we have to do it here
        onSettingsChanged();
        return [_view, new BikeLightsViewDelegate(_view)];
    }

    (:highMemory)
    function getSensorDelegate() as Sensor.SensorDelegate or Null {
        //System.println("getSensorDelegate timer=" + System.getTimer());
        _pairing = true;
        // Do not setup remote controllers and light network for pairing
        _view.onSettingsChanged(false);
        return new BikeLightSensorDelegate(_view);
    }

    (:highMemory)
    function onStop(state) {
        //System.println("onStop timer=" + System.getTimer() + " state=" + state);
        _view.release(true);
    }

    (:settings)
    function getSettingsView() {
        //System.println("getSettingsView timer=" + System.getTimer());
        return _view.getSettingsView();
    }
}
