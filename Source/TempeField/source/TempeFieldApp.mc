using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Ant;
using Toybox.AntPlus;
using Toybox.Sensor;
using Toybox.Lang;
using Toybox.System;

(:background)
class TestServiceDelegate extends System.ServiceDelegate {

    private var _sensor;

	function initialize() {
    	ServiceDelegate.initialize();
    }

    function onTemporalEvent() {
        System.println("onTemporalEvent");
        _sensor = new TempeSensor(method(:onDataReceived));
        if (!_sensor.open()) {
            System.println("Unable to open channel");
            Background.exit(null);
        }
    }

    function onSleepTime() as Void {
        System.println("onSleepTime");
    }

    function onWakeTime() as Void {
        System.println("onWakeTime");
    }

    function onDataReceived(data) {
        System.println("onDataReceived=" + data);
        //_sensor.close();
        Background.exit(data);
    }
}

class TempeFieldApp extends Application.AppBase {
    private var _view;

    function initialize() {
        System.println("initialize");
        AppBase.initialize();
    }

    function getInitialView() {
        _view = new TempeFieldView();
        Background.registerForSleepEvent();
        Background.registerForWakeEvent();
        var lastTime = Background.getLastTemporalEventTime();
        if (lastTime != null) {
            // Events scheduled for a time in the past trigger immediately
            var nextTime = lastTime.add(new Time.Duration(5 * 60));
            System.println("nextTime=" + nextTime.value());
            Background.registerForTemporalEvent(nextTime);
        } else {
            Background.registerForTemporalEvent(Time.now());
        }

        return [_view];
    }

    function onBackgroundData(temperature) {
        System.println("temperature=" + temperature + "view=" + _view);
        if (_view != null) {
            _view.temperature = temperature;
            _view.fitField.setData(temperature);
        }

        Background.registerForTemporalEvent(new Time.Duration(5 * 60));
    }

    function getServiceDelegate(){
        System.println("getServiceDelegate");
        return [new TestServiceDelegate()];
    }
}