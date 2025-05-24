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

    function onStart(state) {
        //System.println("onStart timer=" + System.getTimer() + " state=" + state);
        onSettingsChanged();
    }

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
        return [_view];
    }

    (:touchScreen)
    function getInitialView() {
        //System.println("getInitialView timer=" + System.getTimer());
        return [_view, new BikeLightsViewDelegate(_view)];
    }

    (:highMemory)
    function getSensorDelegate() as Sensor.SensorDelegate or Null {
        //System.println("getSensorDelegate timer=" + System.getTimer());
        // Release remote controllers here, as we do not know until now whether the started app
        // will be used for native pairing
        _view.release(true);
        _pairing = true;
        return new BikeLightSensorDelegate(_view);
    }

    (:highMemory)
    function onStop(state) {
        //System.println("onStop timer=" + System.getTimer() + " state=" + state);
        _view.release(true);
    }

    (:settings)
    function getSettingsView() {
        return _view.getSettingsView();
    }
}
