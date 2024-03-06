import Toybox.Application.Properties;
import Toybox.Lang;

using Toybox.WatchUi;

class BCTidesDelegate extends WatchUi.BehaviorDelegate {
    var mView = null;

    function initialize(view) {
        mView = view;
		WatchUi.BehaviorDelegate.initialize();
	}

    function onNextPage() {
        mView.nextPage();
        WatchUi.requestUpdate();
        return true;
    }

    function onPreviousPage() {
        mView.prevPage();
        WatchUi.requestUpdate();
        return true;
    }

    function onMenu() {
        MainMenu.pushMenu();
        return true;
    }

	function onStateUpdated(state) {
		WatchUi.requestUpdate();
	}

	function onSelect() {
        mView.cycleStations();
        WatchUi.requestUpdate();
        return true;
	}
}   
