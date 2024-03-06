import Toybox.Application;
import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

using Toybox.Background;
using Toybox.Time;

(:background)
class BCTidesApp extends Application.AppBase {
    var delegate = null;
    var view = null;
    var _hilo as Array<Array<Array> or Null> or Null;
    var tideDataValid as Array<Boolean>;
    var background = false;
    var screenHeight = null;

    function initialize() {
        AppBase.initialize();
        tideDataValid = [false, false, false];
        _hilo = null;
    }

    private function loadData() as Void {
        if (_hilo == null) {
            _hilo = Storage.getValue("tideData") as Array<Array<Array> or Null> or Null;
            if (_hilo != null) {
                for (var i = 0; i < _hilo.size(); i++) {
                    if (_hilo[i] != null) {
                        tideDataValid[i] = true;
                    }
                }
            } else {
                _hilo = [null, null, null]; // FIXME: don't hardcode 3 entries!
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
        return [ new BCTidesGlanceView(me) ];
    }

    // Get service delegates to run background tasks for the app
    public function getServiceDelegate() as Array<ServiceDelegate> {
        background = true;
        if (PropUtil.getBackgroundDownload()) {
            var duration26h = new Time.Duration(Time.Gregorian.SECONDS_PER_DAY + 2 * Time.Gregorian.SECONDS_PER_HOUR);
            var eventTime = Time.today().add(duration26h);  // ~2am
            Background.registerForTemporalEvent(eventTime);
            System.println("Setting background timer for " + eventTime.value());
        }

        return [new BackgroundTimerServiceDelegate()] as Array<ServiceDelegate>;
    }
}

(:background)
function getApp() as BCTidesApp {
    return Application.getApp() as BCTidesApp;
}
