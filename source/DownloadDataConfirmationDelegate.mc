import Toybox.Lang;

using Toybox.WatchUi;

class DownloadDataConfirmationDelegate extends WatchUi.ConfirmationDelegate {
    var stationIndex = 0;
    function initialize(ndx as Number) {
        ConfirmationDelegate.initialize();
        stationIndex = ndx;
    }

    function onResponse(response) {
        if (response == WatchUi.CONFIRM_YES) {
            WebRequests.getStationInfo(stationIndex);
        }
        return true;
    }
}