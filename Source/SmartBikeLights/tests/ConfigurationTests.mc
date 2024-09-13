import Toybox.Test;
import Toybox.System;

(:test)
class TestBikeLightsView extends BikeLightsView {

    var configuration;

    function initialize(configuration) {
        self.configuration = configuration;
        BikeLightsView.initialize();
    }

    protected function getPropertyValue(key) {
        return key.equals("LC") ? configuration : BikeLightsView.getPropertyValue(key);
    }

    // Do not initialize virtual lights
    function setupLightSensors() {
    }

    function getErrorCode() {
        return _errorCode;
    }
}

// Parse old config that has < and | characters
(:test :touchScreen)
function parseValidOldConfigurationForTouchScreen(logger) {
    var view = new TestBikeLightsView("1,1|NIGHT:1Es1800,r0###0,73404416#2,2|BREAK:1:7A<-30|:1:6D=1##5,4:Varia 510|2,:-1,Off:0|1,Steady Beam:4|1,Day Flash:7|1,Night Flash:6#B2713##2#0#0");
    Test.assert(view.headlightPanelSettings == null);
    Test.assert(view.taillightPanelSettings != null);

    return view.getErrorCode() == null;
}

// Parse old config that does not have tap icon behavior
(:test :touchScreen)
function parseValidOld2ConfigurationForTouchScreen(logger) {
    var view = new TestBikeLightsView("1,1!NIGHT:1Es1800,r0###0,73404416#2,2!BREAK:1:7:1A[-30!:1:6:1D=1##5,4:Varia 510!2,:-1,Off:0!1,Steady Beam:4!1,Day Flash:7!1,Night Flash:6#0::#0:0#B2713##2#0#0");
    Test.assert(view.headlightPanelSettings == null);
    Test.assert(view.taillightPanelSettings != null);

    return view.getErrorCode() == null;
}

(:test :touchScreen)
function parseValidOld3ConfigurationForTouchScreen(logger) {
    var view = new TestBikeLightsView("1,1!NIGHT:1Es1800,r0###0,73404416#2,2!BREAK:1:7:1:0A[-30!:1:6:0:0D=1##5,4:Varia 510!2,:-1,Off:0!1,Steady Beam:4!1,Day Flash:7!1,Night Flash:6#0::#0:0#123!:123!#B2713##2#0#0");
    Test.assert(view.headlightPanelSettings == null);
    Test.assert(view.taillightPanelSettings != null);
    Test.assert(view.headlightIconTapBehavior != null);
    Test.assert(view.taillightIconTapBehavior != null);

    return view.getErrorCode() == null;
}

(:test :touchScreen)
function parseValidOld4ConfigurationForTouchScreen(logger) {
    var view = new TestBikeLightsView("1,1!NIGHT:1Es1800,r0###0,73404416::1#2,2!BREAK:1:7:1:0A[-30!:1:6:0:0D=1##5,4:Varia 510:0!2,:-1,Off:0!1,Steady Beam:4!1,Day Flash:7!1,Night Flash:6#0::#0:0#123!:123!#0#B2713##2#0#0");
    Test.assert(view.headlightPanelSettings == null);
    Test.assert(view.taillightPanelSettings != null);
    Test.assert(view.headlightIconTapBehavior != null);
    Test.assert(view.taillightIconTapBehavior != null);

    return view.getErrorCode() == null;
}

// Old configuration without remote controllers
(:test :touchScreen)
function parseValidOld5ConfigurationForTouchScreen(logger) {
    var view = new TestBikeLightsView("1,1!NIGHT:1Es1800,r0###0,73404416::1#2,2!BREAK:1:7:1:0A[-30!:1:6:0:0D=1##5,4:Varia 510:0:16777215!2,:-1,Off:0!1,Steady Beam:4!1,Day Flash:7!1,Night Flash:6#0::#0:0#123!:123!#0#B2713##2#0#0");
    Test.assert(view.headlightPanelSettings == null);
    Test.assert(view.taillightPanelSettings != null);
    Test.assert(view.headlightIconTapBehavior != null);
    Test.assert(view.taillightIconTapBehavior != null);

    return view.getErrorCode() == null;
}

// Old configuration without remote controllers
(:test :touchScreen)
function parseValidOld5ConfigurationWithInitialSpacesForTouchScreen(logger) {
    var view = new TestBikeLightsView("   1,1!NIGHT:1Es1800,r0###0,73404416::1#2,2!BREAK:1:7:1:0A[-30!:1:6:0:0D=1##5,4:Varia 510:0!2,:-1,Off:0!1,Steady Beam:4!1,Day Flash:7!1,Night Flash:6#0::#0:0#123!:123!#0#B2713##2#0#0");
    Test.assert(view.headlightPanelSettings == null);
    Test.assert(view.taillightPanelSettings != null);
    Test.assert(view.headlightIconTapBehavior != null);
    Test.assert(view.taillightIconTapBehavior != null);

    return view.getErrorCode() == null;
}

(:test :touchScreen)
function parseValidConfigurationWithoutAdditionalLightModesForTouchScreen(logger) {
    var view = new TestBikeLightsView("1,1!NIGHT:1Es1800,r0###0,73404416::1#2,2!BREAK:1:7:1:0A[-30!:1:6:0:0D=1##5,4:Varia 510:0:16777215!2,:-1,Off:0!1,Steady Beam:4!1,Day Flash:7!1,Night Flash:6#0::#0:0#123!:123!#0#0#B2713##2#0#0");
    Test.assert(view.headlightPanelSettings == null);
    Test.assert(view.taillightPanelSettings != null);
    Test.assert(view.headlightIconTapBehavior != null);
    Test.assert(view.taillightIconTapBehavior != null);

    return view.getErrorCode() == null;
}

(:test :touchScreen)
function parseValidConfigurationForTouchScreen(logger) {
    var view = new TestBikeLightsView("1,1!NIGHT:1Es1800,r0###0,73404416::1:#2,2!BREAK:1:7:1:0A[-30!:1:6:0:0D=1##5,4:Varia 510:0:16777215!2,:-1,Off:0!1,Steady Beam:4!1,Day Flash:7!1,Night Flash:6#0::#0:0#123!:123!#0#0#B2713##2#0#0");
    Test.assert(view.headlightPanelSettings == null);
    Test.assert(view.taillightPanelSettings != null);
    Test.assert(view.headlightIconTapBehavior != null);
    Test.assert(view.taillightIconTapBehavior != null);

    return view.getErrorCode() == null;
}

(:test :touchScreen)
function parseValidConfigurationWithRemoteControllerForTouchScreen(logger) {
    var view = new TestBikeLightsView("1,1!NIGHT:1Es1800,r0###0,73404416::1#2,2!BREAK:1:7:1:0A[-30!:1:6:0:0D=1##5,4:Varia 510:0:16777215!2,:-1,Off:0!1,Steady Beam:4!1,Day Flash:7!1,Night Flash:6#0::#0:0#123!:123!#0#1|1:MicroRemote!1|1:3167:0!2|1:1::123!:123!!|2:1::,0=:!H]0#B2713##2#0#0");
    Test.assert(view.headlightPanelSettings == null);
    Test.assert(view.taillightPanelSettings != null);
    Test.assert(view.headlightIconTapBehavior != null);
    Test.assert(view.taillightIconTapBehavior != null);
    Test.assert(view.remoteControllers != null);

    return view.getErrorCode() == null;
}

// Parse old config that does not have activation/deactivation timer
(:test :settings)
function parseValidOldConfigurationForSettings(logger) {
    var view = new TestBikeLightsView("1,1!NIGHT:1Es1800,r0###0,73404416#1,1!:1:6:1D=1##4:Varia 510!Off:0!Solid:4!Day Flash:7!Night Flash:6#0::#0:0#B3121##2#0#0");
    Test.assert(view.headlightSettings == null);
    Test.assert(view.taillightSettings != null);

    return view.getErrorCode() == null;
}

(:test :settings)
function parseValidOld2ConfigurationForSettings(logger) {
    var view = new TestBikeLightsView("1,1!NIGHT:1Es1800,r0###0,73404416#1,1!:1:6:0:0D=1##4:Varia 510!Off:0!Solid:4!Day Flash:7!Night Flash:6#0::#0:0#B3121##2#0#0");
    Test.assert(view.headlightSettings == null);
    Test.assert(view.taillightSettings != null);

    return view.getErrorCode() == null;
}

// Missing remote controllers
(:test :settings)
function parseValidOld3ConfigurationForSettings(logger) {
    var view = new TestBikeLightsView("1,1!NIGHT:1Es1800,r0###0,73404416::1#1,1!:1:6:0:0D=1##4:Varia 510!Off:0!Solid:4!Day Flash:7!Night Flash:6#0::#0:0#0#B3121##2#0#0");
    Test.assert(view.headlightSettings == null);
    Test.assert(view.taillightSettings != null);

    return view.getErrorCode() == null;
}

// Missing remote controllers
(:test :settings)
function parseValidOld3ConfigurationWithInitialSpacesForSettings(logger) {
    var view = new TestBikeLightsView("   1,1!NIGHT:1Es1800,r0###0,73404416::1#1,1!:1:6:0:0D=1##4:Varia 510!Off:0!Solid:4!Day Flash:7!Night Flash:6#0::#0:0#0#B3121##2#0#0");
    Test.assert(view.headlightSettings == null);
    Test.assert(view.taillightSettings != null);

    return view.getErrorCode() == null;
}

(:test :settings)
function parseValidConfigurationWithoutAdditionalLightModesForSettings(logger) {
    var view = new TestBikeLightsView("1,1!NIGHT:1Es1800,r0###0,73404416::1#1,1!:1:6:0:0D=1##4:Varia 510!Off:0!Solid:4!Day Flash:7!Night Flash:6#0::#0:0#0#0#B3121##2#0#0");
    Test.assert(view.headlightSettings == null);
    Test.assert(view.taillightSettings != null);

    return view.getErrorCode() == null;
}

(:test :settings)
function parseValidConfigurationForSettings(logger) {
    var view = new TestBikeLightsView("1,1!NIGHT:1Es1800,r0###0,73404416::1:#1,1!:1:6:0:0D=1##4:Varia 510!Off:0!Solid:4!Day Flash:7!Night Flash:6#0::#0:0#0#0#B3121##2#0#0");
    Test.assert(view.headlightSettings == null);
    Test.assert(view.taillightSettings != null);

    return view.getErrorCode() == null;
}

(:test :settings)
function parseValidConfigurationWithRemoteControllerForSettings(logger) {
    var view = new TestBikeLightsView("1,1!NIGHT:1Es1800,r0###0,73404416::1#1,1!:1:6:0:0D=1##4:Varia 510!Off:0!Solid:4!Day Flash:7!Night Flash:6#0::#0:0#0#1|1:MicroRemote!1|1:32142:0!2|1:1::123!:123!!|2:1:10:,1=:!H]0#B3121##2#0#0");
    Test.assert(view.headlightSettings == null);
    Test.assert(view.taillightSettings != null);
    Test.assert(view.remoteControllers != null);

    return view.getErrorCode() == null;
}

(:test :settings)
function parseTouchScreenConfigurationForSettings(logger) {
    var view = new TestBikeLightsView("1,1!NIGHT:1Es1800,r0###0,73404416#2,2!BREAK:1:7:1A[-30!:1:6:1D=1##5,4:Varia 510!2,:-1,Off:0!1,Steady Beam:4!1,Day Flash:7!1,Night Flash:6#0::#0:0#B2713##2#0#0");
    Test.assert(view.headlightSettings == null);
    Test.assert(view.taillightSettings == null);

    return view.getErrorCode() == 4;
}

(:test :lowMemory)
function parseValidOldConfigurationForNoSettings(logger) {
    var view = new TestBikeLightsView("#4587520,196641#2,2!TEST:1:1:0:0H]0!:1:0:0:0D=1#6291461,1409482753####B3289#1#1#0#0");

    return view.getErrorCode() == null;
}

(:test :lowMemory)
function parseValidConfigurationWithoutAdditionalLightModesForNoSettings(logger) {
    var view = new TestBikeLightsView("#4587520,196641::1#2,2!TEST:1:1:0:0H]0!:1:0:0:0D=1#6291461,1409482753::1##0#B3289#1#1#0#0");

    return view.getErrorCode() == null;
}

(:test :lowMemory)
function parseValidConfigurationForNoSettings(logger) {
    var view = new TestBikeLightsView("#4587520,196641::1:#2,2!TEST:1:1:0:0H]0!:1:0:0:0D=1#6291461,1409482753::1:##0#B3289#1#1#0#0");

    return view.getErrorCode() == null;
}

(:test :lowMemory)
function assertLowMemory(logger) {
    var view = new TestBikeLightsView("#4587520,196641::1:#2,2!TEST:1:1:0:0H]0!:1:0:0:0D=1#6291461,1409482753::1:##0#B3289#1#1#0#0");
    var maxMemory = 29300; // This includes also the test code
    var memory = System.getSystemStats().usedMemory;

    Test.assertMessage(memory < maxMemory, "Memory is higher that expected (Expected: < " + maxMemory + ", Actual: " + memory + ")");
    return true;
}

(:test :touchScreen)
function parseSettingsConfigurationForTouchScreen(logger) {
    var view = new TestBikeLightsView("1,1!NIGHT:1Es1800,r0###0,73404416#1,1!:1:6:1D=1##4:Varia 510!Off:0!Solid:4!Day Flash:7!Night Flash:6#0::#0:0#B3121##2#0#0");
    Test.assert(view.headlightPanelSettings == null);
    Test.assert(view.taillightPanelSettings == null);

    return view.getErrorCode() == 4;
}

(:test)
function parseWithMissingGlobalFilterSeparator(logger) {
    var view = new TestBikeLightsView("1,1NIGHT:1Es1800,r0###0,73404416#2,2!BREAK:1:7:1A[-30!:1:6:1D=1##5,4:Varia 510!2,:-1,Off:0!1,Steady Beam:4!1,Day Flash:7!1,Night Flash:6#0::#0:0#B2713##2#0#0");

    return view.getErrorCode() == 4;
}

(:test)
function parseWithMissingGlobalFilterComma(logger) {
    var view = new TestBikeLightsView("11!NIGHT:1Es1800,r0###0,73404416#2,2!BREAK:1:7:1A[-30!:1:6:1D=1##5,4:Varia 510!2,:-1,Off:0!1,Steady Beam:4!1,Day Flash:7!1,Night Flash:6#0::#0:0#B2713##2#0#0");

    return view.getErrorCode() == 4;
}

(:test :touchScreen)
function parseWithMissingGlobalFilterNumbers(logger) {
    var view = new TestBikeLightsView("NIGHT:1Es1800,r0###0,73404416#2,2!BREAK:1:7:1A[-30!:1:6:1D=1##5,4:Varia 510!2,:-1,Off:0!1,Steady Beam:4!1,Day Flash:7!1,Night Flash:6#0::#0:0#B2713##2#0#0");

    return view.getErrorCode() == 4;
}

(:test)
function parseWithMissingGlobalFilterNumbersAndNoGroupName(logger) {
    var view = new TestBikeLightsView("!:1Es1800,r0###0,73404416#2,2!BREAK:1:7:1A[-30!:1:6:1D=1##5,4:Varia 510!2,:-1,Off:0!1,Steady Beam:4!1,Day Flash:7!1,Night Flash:6#0::#0:0#B2713##2#0#0");

    return view.getErrorCode() == 4;
}

(:test)
function parseWithMissingSeparators(logger) {
    var view = new TestBikeLightsView("1,1NIGHT:1Es1800,r0###0,73404416#2,2BREAK:1:7:1A[-30:1:6:1D=1##5,4:Varia 5102,:-1,Off:01,Steady Beam:41,Day Flash:71,Night Flash:6#0::#0:0#B2713##2#0#0");

    return view.getErrorCode() == 4;
}

(:test)
function parseWithMissingLightFilters(logger) {
    var view = new TestBikeLightsView("#4587520,196641");

    return true;
}
