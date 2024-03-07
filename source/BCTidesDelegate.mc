import Toybox.Application.Properties;
import Toybox.Lang;

using Toybox.WatchUi;

class BCTidesDelegate extends WatchUi.BehaviorDelegate {
    var view as BCTidesView;

    function initialize(associatedView as BCTidesView) {
        view = associatedView;
		WatchUi.BehaviorDelegate.initialize();
	}

    function onNextPage() {
        view.nextPage();
        WatchUi.requestUpdate();
        return true;
    }

    function onPreviousPage() {
        view.prevPage();
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
        view.cycleStations();
        WatchUi.requestUpdate();
        return true;
	}
}   
