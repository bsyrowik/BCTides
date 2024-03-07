import Toybox.Lang;

using Toybox.WatchUi;

class DownloadDataConfirmationDelegate extends WatchUi.ConfirmationDelegate {
    private var _stationIndex as Number;

    function initialize(stationIndex as Number) {
        ConfirmationDelegate.initialize();
        _stationIndex = stationIndex;
    }

    function onResponse(response) {
        if (response == WatchUi.CONFIRM_YES) {
            WebRequests.getStationInfo(_stationIndex);
        }
        return true;
    }
}
