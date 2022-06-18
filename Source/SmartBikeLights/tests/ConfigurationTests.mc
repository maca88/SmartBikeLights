import Toybox.Test;

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
function parseValidConfigurationForTouchScreen(logger) {
    var view = new TestBikeLightsView("1,1!NIGHT:1Es1800,r0###0,73404416#2,2!BREAK:1:7:1:0A[-30!:1:6:0:0D=1##5,4:Varia 510!2,:-1,Off:0!1,Steady Beam:4!1,Day Flash:7!1,Night Flash:6#0::#0:0#123!:123!#B2713##2#0#0");
    Test.assert(view.headlightPanelSettings == null);
    Test.assert(view.taillightPanelSettings != null);
    Test.assert(view.headlightIconTapBehavior != null);
    Test.assert(view.taillightIconTapBehavior != null);

    return view.getErrorCode() == null;
}

(:test :touchScreen)
function parseValidConfigurationWithInitialSpacesForTouchScreen(logger) {
    var view = new TestBikeLightsView("   1,1!NIGHT:1Es1800,r0###0,73404416#2,2!BREAK:1:7:1:0A[-30!:1:6:0:0D=1##5,4:Varia 510!2,:-1,Off:0!1,Steady Beam:4!1,Day Flash:7!1,Night Flash:6#0::#0:0#123!:123!#B2713##2#0#0");
    Test.assert(view.headlightPanelSettings == null);
    Test.assert(view.taillightPanelSettings != null);
    Test.assert(view.headlightIconTapBehavior != null);
    Test.assert(view.taillightIconTapBehavior != null);

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
function parseValidConfigurationForSettings(logger) {
    var view = new TestBikeLightsView("1,1!NIGHT:1Es1800,r0###0,73404416#1,1!:1:6:0:0D=1##4:Varia 510!Off:0!Solid:4!Day Flash:7!Night Flash:6#0::#0:0#B3121##2#0#0");
    Test.assert(view.headlightSettings == null);
    Test.assert(view.taillightSettings != null);

    return view.getErrorCode() == null;
}

(:test :settings)
function parseValidConfigurationWithInitialSpacesForSettings(logger) {
    var view = new TestBikeLightsView("   1,1!NIGHT:1Es1800,r0###0,73404416#1,1!:1:6:0:0D=1##4:Varia 510!Off:0!Solid:4!Day Flash:7!Night Flash:6#0::#0:0#B3121##2#0#0");
    Test.assert(view.headlightSettings == null);
    Test.assert(view.taillightSettings != null);

    return view.getErrorCode() == null;
}

(:test :settings)
function parseTouchScreenConfigurationForSettings(logger) {
    var view = new TestBikeLightsView("1,1!NIGHT:1Es1800,r0###0,73404416#2,2!BREAK:1:7:1A[-30!:1:6:1D=1##5,4:Varia 510!2,:-1,Off:0!1,Steady Beam:4!1,Day Flash:7!1,Night Flash:6#0::#0:0#B2713##2#0#0");
    Test.assert(view.headlightSettings == null);
    Test.assert(view.taillightSettings == null);

    return view.getErrorCode() == 4;
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
