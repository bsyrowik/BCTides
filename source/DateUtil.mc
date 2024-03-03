import Toybox.Lang;
import Toybox.Test;

using Toybox.Time;
using Toybox.Time.Gregorian;

(:background)
module DateUtil {
    function getFromDateString() as String {
        // Start from midnight this morning; add another 14 hours buffer (some stations only have 2 tides per day)
        var duration_14h = new Time.Duration(14 * Time.Gregorian.SECONDS_PER_HOUR);
        var from = Time.today().subtract(duration_14h);
        var from_utc = Gregorian.utcInfo(from, Time.FORMAT_SHORT);
        return formatDateString(from_utc);
    }

    function getToDateString() as String {
        var duration_7d_6h = new Time.Duration(7 * Time.Gregorian.SECONDS_PER_DAY + 6 * Time.Gregorian.SECONDS_PER_HOUR);
        var to = Time.now().add(duration_7d_6h);
        var to_utc = Gregorian.utcInfo(to, Time.FORMAT_SHORT);
        return formatDateString(to_utc);
    }

    function parseDateString(str as String) as Time.Moment {
        // e.g. 2022-04-15T17:37:22Z
        var year   = str.substring(0,4).toNumber();
        var month  = str.substring(5,7).toNumber();
        var day    = str.substring(8,10).toNumber();
        var hour   = str.substring(11,13).toNumber();
        var minute = str.substring(14,16).toNumber();
        var options = {
            :year   => year,
            :month  => month,
            :day    => day,
            :hour   => hour,
            :minute => minute
        };
        //System.println("parsed to " + year.toString() + "-" + month.toString() + "-" + day.toString() + "T" + hour.toString() + ":" + minute.toString());
        return Gregorian.moment(options);
    }

    function formatTimeStringShort(moment as Time.Moment) as String {
        // Provides local time from a UTC moment
        // https://developer.garmin.com/connect-iq/api-docs/Toybox/Time/Gregorian.html#info-instance_function
        var info = Gregorian.info(moment, Time.FORMAT_SHORT);
        return Lang.format("$1$:$2$",
            [
                info.hour.format("%02d"),
                info.min.format("%02d")
            ]);
    }

    function formatDateStringShort(moment as Time.Moment) as String {
        var info = Gregorian.utcInfo(moment, Time.FORMAT_SHORT);
        // Moment should be in UTC; seconds zero'd
        return Lang.format("$1$-$2$ $3$:$4$",
            [
                info.month.format("%02d"),
                info.day.format("%02d"),
                info.hour.format("%02d"),
                info.min.format("%02d")
            ]);
    }

    function formatDateString(info as Gregorian.Info) as String {
        // Moment should be in UTC; seconds zero'd
        return Lang.format("$1$-$2$-$3$T$4$:$5$:00Z",
            [
                info.year,
                info.month.format("%02d"),
                info.day.format("%02d"),
                info.hour.format("%02d"),
                info.min.format("%02d")
            ]);
    }
}

/*
(:debug)
function dateUtilTestHelper(logger as Logger, method as Method(info as Gregorian.Info) as String, s as String, i as Gregorian.Info, expected as String) as Boolean { // FIXME: rename
    var p = method.invoke(i);
    if (p != expected) {
        logger.error("Expected " + s + " of " + i + " to be " + expected + " - got " + p);
        return false;
    }
    return true;
}
(:test)
function testFormatDateString(logger as Logger) as Boolean {
    var pass = true;
    var m = new Lang.Method(DateUtil, :formatDateString);
    var info = new Gregorian.Info();
    pass &= dateUtilTestHelper(logger, m, "formatDateString", info, "blah");
    return pass;
}
*/
