import Array "mo:base/Array";

actor QSort {
    // partition the array
    private func _partition(arr: [var Int], left: Nat, right: Nat) : Nat {
        let pivot = arr[left];
        var l: Nat = left;
        var r: Nat = right;
        while (l < r) {
            while (l < r and arr[r] > pivot) {
                r -= 1;
            };
            arr[l] := arr[r];
            while (l < r and arr[l] <= pivot) {
                l += 1;
            };
            arr[r] := arr[l];
        };
        arr[l] := pivot;
        return l;
    };

    // sort array in-place
    private func _qsort(arr: [var Int], left: Nat, right: Nat) {
        if (left < right) {
            let pi = _partition(arr, left,  right);
            if (pi > 0) _qsort(arr,  left, pi - 1);
            _qsort(arr, pi + 1, right);
        };
    };

    public func sort(arr : [Int]) : async [Int] {
        let arr_mut = Array.thaw<Int>(arr);
        _qsort(arr_mut, 0, arr_mut.size() - 1);
        Array.freeze<Int>(arr_mut)
    };

};
