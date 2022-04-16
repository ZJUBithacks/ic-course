import Array "mo:base/Array"
import Int from "mo:base/Int"

actor Qsort {
  public query func qsort(arr : [Int]) : async [Int] {
    let result = Array.thaw<Int>(arr);
    qsortHelper(result, 0, arr.size()-1);
    return Array.freeze<Int>(result);
  };

  private func qsortHelper(
    arr : [var Int],
    low : Int,
    high : Int,
  ) {
    if (low < high) {
      var i = low;
      var j = high;
      let pivot = arr[Int.abs(high)];

      // partition
      while (i <= j) {
        while (arr[Int.abs(i)] < pivot) {
          i += 1;
        };
        while (arr[Int.abs(j)] > pivot) {
          j -= 1;
        };
        if (i <= j) {
          var tmp = arr[Int.abs(i)];
          arr[Int.abs(i)] := arr[Int.abs(j)];
          arr[Int.abs(j)] := tmp;
          i += 1;
          j -= 1;
        };
      };

      // sort
      if (low < j) {
        qsortHelper(arr, low, j);
      };
      if (i < high) {
        qsortHelper(arr, i, high);
      };
    };
  };

};
