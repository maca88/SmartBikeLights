import Toybox.Activity;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;

class GradeDataFieldView extends WatchUi.SimpleDataField {
    function initialize() {
        SimpleDataField.initialize();
        label = "Gradient";
        _gradientData[11] = true; // Enable
    }

    private var _gradientData = [
        0f,    // 0. Altitude last estimate
        0f,    // 1. Altitude kalman gain
        0.1f,  // 2. Altitude process noise
        0.5f,  // 3. Altitude estimation error

        0f,    // 4. Distance last estimate
        0f,    // 5. Distance kalman gain
        0.1f,  // 6. Distance process noise
        0.5f,  // 7. Distance estimation error

        0f,    // 8. Last elapsed distance
        0f,    // 9. Last calculation time
        0f,    // 10. Last gradient
        false  // 11. Whether gradient should be calculated
    ];

    function compute(activityInfo as Activity.Info) {
        //System.println("usedMemory=" + System.getSystemStats().usedMemory);
        var altitude = activityInfo.altitude;
        var elapsedDistance = activityInfo.elapsedDistance;
        var gradientData = _gradientData;
        if (gradientData[11] /* Enabled */ && altitude != null && elapsedDistance != null) {
            var diffDistance = elapsedDistance - gradientData[8] /* Last elapsed distance */;
            if (diffDistance > 0.5f && activityInfo.timerState == 3 /* TIMER_STATE_ON */) {
                var timer = System.getTimer();
                // Reset last estimate in case the GPS signal is lost to prevent abnormal gradients
                if ((timer - gradientData[9]) > 3000) {
                    //System.println("init d=" + elapsedDistance + " init a=" + altitude);
                    gradientData[0] = altitude; // Reset altitude last estimate
                    gradientData[4] = diffDistance; // Reset distance last estimate
                }

                gradientData[8] = elapsedDistance; // Update last elapsed distance
                gradientData[9] = timer; // Update last calculation time
                var lastEstimateAltitude = gradientData[0];
                var currentEstimateAltitude = updateGradientData(altitude, 0); // Update estimated altitude
                gradientData[10] = ((currentEstimateAltitude - lastEstimateAltitude) / updateGradientData(diffDistance, 4) /* Update estimated distance */) * 100; // Calculate gradient
                //System.println("d=" + elapsedDistance + " a=" + altitude + " ca=" + currentEstimateAltitude + " ddiff=" + diffDistance + " cddiff=" + gradientData[4] + " cadiff=" + (currentEstimateAltitude - lastEstimateAltitude) + " grade=" + gradientData[10]);
            } else {
                gradientData[10] = 0f; // Reset last gradient
            }
        }

        return gradientData[10];
    }

    private function updateGradientData(value, index) {
        // Calculate smooth gradient, applying simple kalman filter
        var gradientData = _gradientData;
        var lastEstimate = gradientData[index];
        var errorEstimate = gradientData[index + 3];
        var kalmanGain = errorEstimate / (errorEstimate + 5f /* Measure error */);
        var currentEstimate = lastEstimate + kalmanGain * (value - lastEstimate);
        var diffEstimate = (lastEstimate - currentEstimate).abs();
        gradientData[index + 3] = (1f - kalmanGain) * errorEstimate + diffEstimate * gradientData[index + 2] /* Process noise */; // Update estimation error
        gradientData[index + 1] = kalmanGain; // Update kalman gain
        gradientData[index + 2] = 1f /* Max process noise */ / (1f + diffEstimate * diffEstimate); // Update process noise
        gradientData[index] = currentEstimate; // Update last estimate
        return currentEstimate;
    }
}