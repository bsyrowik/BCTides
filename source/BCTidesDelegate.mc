import Toybox.Application.Properties;
import Toybox.Lang;

using Toybox.WatchUi;

class BCTidesDelegate extends WatchUi.BehaviorDelegate {
    var mView = null;
    private var mGetDataMenuItem = null;

    function initialize(view) {
        mView = view;
		WatchUi.BehaviorDelegate.initialize();
	}

    function onNextPage() {
        if (mView.mPage < mView.mPageCount - 1) {
            mView.mPage += 1;
        } else {
            mView.mPage = 0;
        }
        mView.mPageUpdated = true;
        WatchUi.requestUpdate();
        return true;
    }

    function onPreviousPage() {
        if (mView.mPage > 0) {
            mView.mPage -= 1;
        } else {
            mView.mPage = mView.mPageCount - 1;
        }
        mView.mPageUpdated = true;
        WatchUi.requestUpdate();
        return true;
    }

    function setGetDataMenuItemSubLabel(name as String) as Void {
        mGetDataMenuItem.setSubLabel(name);
    }

    function onMenu() {
        mGetDataMenuItem = MainMenu.pushMenu();
        return true;
    }

	function onStateUpdated(state) {
		WatchUi.requestUpdate();
	}

	function onSelect() {
		//onMenu();
        return true;
	}
}   
