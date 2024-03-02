import Toybox.Application;
import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.WatchUi;

class BCTidesApp extends Application.AppBase {
    var delegate = null;
    var view = null;
    var _hilo = null;
    var hilo_updated = false;

    function initialize() {
        AppBase.initialize();
    }

    private function loadData() as Void {
        if (_hilo == null) {
            _hilo = Storage.getValue("hiloData") as Array<Array>;
            if (_hilo != null) {
                TideUtil.dataValid = true;
            }
        }
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        loadData();
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        if (_hilo != null && hilo_updated) {
            Storage.setValue("hiloData", _hilo);
        }
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
        view.setDelegate(delegate);
        return [view, delegate] as Array<Views or InputDelegates>;
    }

    (:glance)
	function getGlanceView() {
        return [ new BCTidesGlanceView(me) ];
    }
}

function getApp() as BCTidesApp {
    return Application.getApp() as BCTidesApp;
}
