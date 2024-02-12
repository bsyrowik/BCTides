import Toybox.Application;
import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.WatchUi;

class garmin_sampleApp extends Application.AppBase {

    var delegate;
    var view = null;
    var _hilo = null;
    var hilo_updated = false;

    function initialize() {
        if (System.DeviceSettings has :isGlanceModeEnabled) {
            if (System.getDeviceSettings().isGlanceModeEnabled) {
                //System.println("glances enabled!");
            } else {
                //System.println("glances not enabled :(");
            }
        }

        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        if (_hilo == null) {
            _hilo = Storage.getValue("kits_hilo");
        }
        //System.println("starting");
  //      Position.enableLocationEvents( Position.LOCATION_CONTINUOUS, method( :onPosition ) );
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        //System.println("Stopping");
        if (_hilo != null && hilo_updated) {
            Storage.setValue("kits_hilo", _hilo);
        }
    }

    // Settings affect the display (units)
    public function onSettingsChanged() as Void {
        System.println("settings changed...");
        WatchUi.requestUpdate();
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        if (System.DeviceSettings has :isGlanceModeEnabled) {
            if (System.getDeviceSettings().isGlanceModeEnabled) {
                //System.println("glances enabled!");
            } else {
                //System.println("glances not enabled :(");
            }
        }
        if (_hilo == null) {
            _hilo = Storage.getValue("kits_hilo");
        }
        view = new garmin_sampleView(me);
        delegate = new garmin_sampleDelegate(view);
        return [view, delegate] as Array<Views or InputDelegates>;
    }

/*
    function onPosition( info as Position.Info ) as Void {
        System.println( "Position " + info.position.toGeoString( Position.GEO_DM ) );
    }
*/

    (:glance)
	function getGlanceView() {
        return [ new MyGlanceView(me) ];
    }

}

function getApp() as garmin_sampleApp {
    return Application.getApp() as garmin_sampleApp;
}