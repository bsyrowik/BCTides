import Toybox.Application.Storage;
import Toybox.Background;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;

// Main entry point for background processes.  onTemporalEvent() is run each
// time the periodic event is triggered by the system, indicating the timer has
// expired.
(:background)
class BackgroundTimerServiceDelegate extends System.ServiceDelegate {
    public function initialize() {
        ServiceDelegate.initialize();
    }

    public function onTemporalEvent() as Void {
        System.println("Attempting to retrieve tide data at " + Time.now().value());
        for (var i = 0; i < StorageUtil.getNumValidStationCodes(); i++) {
            // All valid station codes will appear at the beginning of the array
            WebRequests.getStationInfo(i);
        }
    }
}