import Toybox.Application;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

using Toybox.Background;
using Toybox.Time;

(:background)
class BCTidesApp extends Application.AppBase {
    var delegate = null;
    var view = null;
    var background = false;
    var screenHeight = null;
    var tideData as Array<Array<Array>?>? = null;
    var tideDataValid as Array<Boolean>;
    var currentPosition = null;

    const stationsToShow as Number = 3;

    function initialize() {
        AppBase.initialize();
        tideDataValid = new  Array<Boolean>[stationsToShow];
        for (var i = 0; i < stationsToShow; i++) {
            tideDataValid[i] = false;
        }
    }

    private function loadData() as Void {
        if (tideData == null) {
            var tideDataFromStorage = StorageUtil.getTideData() as Array<Array<Array>?>?;
            if (tideDataFromStorage != null) {
                tideData = tideDataFromStorage;
                for (var i = 0; i < tideData.size(); i++) {
                    if (tideData[i] != null) {
                        tideDataValid[i] = true;
                    }
                }
            } else {
                tideData = [];
                for (var i = 0; i < stationsToShow; i++) {
                    tideData.add(null);
                }
            }
        }
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        loadData();  // Needed for Glance View
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Settings affect the display (units, display type, etc.)
    public function onSettingsChanged() as Void {
        WatchUi.requestUpdate();
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        loadData();
        view = new BCTidesView(me);
        delegate = new BCTidesDelegate(view);
        var mySettings = System.getDeviceSettings();
        screenHeight = mySettings.screenHeight;
        return [view, delegate] as Array<Views or InputDelegates>;
    }

    (:glance)
	function getGlanceView() {
        return [ new BCTidesGlanceView() ];
    }

    // Get service delegates to run background tasks for the app
    public function getServiceDelegate() as Array<ServiceDelegate> {
        background = true;
        if (PropUtil.getBackgroundDownload()) {
            var duration26h = new Time.Duration(Time.Gregorian.SECONDS_PER_DAY + 2 * Time.Gregorian.SECONDS_PER_HOUR);
            var eventTime = Time.today().add(duration26h);  // ~2am
            Background.registerForTemporalEvent(eventTime);
            //System.println("Setting background timer for " + eventTime.value());
        }

        return [new BackgroundTimerServiceDelegate()] as Array<ServiceDelegate>;
    }
}

(:background)
function getApp() as BCTidesApp {
    return Application.getApp() as BCTidesApp;
}
