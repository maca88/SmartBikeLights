import Toybox.Activity;
import Toybox.Ant;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;
using Toybox.Application.Properties as Properties;

class TempeFieldView extends WatchUi.SimpleDataField {

    var temperature = null;
    var fitField;

    function initialize() {
        SimpleDataField.initialize();
        label = "Tempe";
        fitField = createField(
            "tempe",
            0,
            FitContributor.DATA_TYPE_FLOAT,
            {
                :mesgType=> FitContributor.MESG_TYPE_RECORD
            });
    }

    function compute(info as Activity.Info) as Numeric or Duration or String or Null {
        return temperature;
    }
}