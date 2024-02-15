import Toybox.Lang;
import Toybox.Test;

class HeapOfPair {
    var heapSize as Number;
    var A as Array<Pair>;
    function initialize(size as Number) {
        A = [new Pair()];
        heapSize = 0;
    }

    function parent(i as Number) as Number {
        return (i + 1) / 2 - 1;
    }
    function left(i as Number) as Number {
        return i * 2 + 1;
    }
    function right(i as Number) as Number {
        return i * 2 + 2;
    }

    function swap(a as Number, b as Number) as Void {
        var tmp_d = A[a].distance;
        var tmp_i = A[a].index;
        A[a].distance = A[b].distance;
        A[a].index = A[b].index;
        A[b].distance = tmp_d;
        A[b].index = tmp_i;
    }

    function heapDecreaseKey(i as Number, key as Float) as Void {
        A[i].distance = key;
        while (i > 0 && A[parent(i)].distance > A[i].distance) {
            swap(i, parent(i));
            i = parent(i);
        }
    }

    function minHeapInsert(dist as Float, ndx as Number) as Void {
        heapSize += 1;
        if (heapSize > 1) {
            A.add(new Pair());
        }
        A[heapSize-1].distance = 1e12; // FIXME: Use FLOAT_MAX ??
        A[heapSize-1].index = ndx;
        heapDecreaseKey(heapSize-1, dist);
    }

    function minHeapify(i as Number) as Void {
        var l = left(i);
        var r = right(i);
        var smallest;
        if (l < heapSize && A[l].distance < A[i].distance) {
            smallest = l;
        } else {
            smallest = i;
        }
        if (r < heapSize && A[r].distance < A[smallest].distance) {
            smallest = r;
        }
        if (smallest != i) {
            swap(smallest, i);
            minHeapify(smallest);
        }
    }

    function heapExtractMin() as Pair {
        if (heapSize < 1) {
            Test.assertMessage(false, "Trying to extract elemnts from empty heap!");
        }
        var max = A[0];
        A[0] = A[heapSize-1];
        heapSize -= 1;
        minHeapify(0);
        return max;
    }

/*
    // For Debug
    function print() as Void {
        for (var i = 0; i < heapSize; i++) {
            System.println(A[i].distance + " " + A[i].index);
        }
    }
    function print_destructive(count as Number) as Void {
        for (var i = 0; i < count; i++) {
            var p = heapExtractMin();
            System.println(p.distance + " " + p.index);
        }
    }
*/


}


(:debug)
function subTestParent(logger as Logger, method as Method(a as Number) as Number, s as String, i as Number, expected as Number) as Boolean {
    var p = method.invoke(i);
    if (p != expected) {
        logger.error("Expected " + s + " of " + i + " to be " + expected + " - got " + p);
        return false;
    }
    return true;
}
(:test)
function testParent(logger as Logger) as Boolean {
    var pass = true;
    var h = new HeapOfPair(16);
    var m = h.method(:parent);
    pass &= subTestParent(logger, m, "parent", 2, 0);
    pass &= subTestParent(logger, m, "parent", 4, 1);
    pass &= subTestParent(logger, m, "parent", 7, 3);
    return pass;
}
(:test)
function testLeft(logger as Logger) as Boolean {
    var pass = true;
    var h = new HeapOfPair(16);
    var m = h.method(:left);
    pass &= subTestParent(logger, m, "left", 0, 1);
    pass &= subTestParent(logger, m, "left", 1, 3);
    pass &= subTestParent(logger, m, "left", 3, 7);
    return pass;
}
(:test)
function testRight(logger as Logger) as Boolean {
    var pass = true;
    var h = new HeapOfPair(16);
    var m = h.method(:right);
    pass &= subTestParent(logger, m, "right", 0, 2);
    pass &= subTestParent(logger, m, "right", 1, 4);
    pass &= subTestParent(logger, m, "right", 3, 8);
    return pass;
}