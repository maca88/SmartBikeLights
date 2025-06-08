using Toybox.Application;
using Toybox.Background;
using Toybox.Sensor;
using Toybox.System;

class LightTesterApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
        return [new LightTesterView()];
    }
}