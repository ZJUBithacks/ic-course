import Int "mo:base/Int";
import Array "mo:base/Array";
import Nat "mo:base/Nat";
import D "mo:base/Debug"; 


actor {

  public func qsort_print(arr: [Int]){
    let n = arr.size();
    let tmp = Array.thaw<Int>(arr);
    sort(tmp, 0, n - 1);
    let res = Array.freeze(tmp);
    D.print("print sorted vec...");
    var i = 0;
    while (i < n) {
      D.print(debug_show(tmp[i]));
      i += 1;
    };   
  };

  public func qsort(arr: [Int]): async [Int] {
    let n = arr.size();
    D.print("print sorted vec...");
    if (n < 2) {
      return arr;
    } else {
      let tmp = Array.thaw<Int>(arr);
      sort(tmp, 0, n - 1);
      let res = Array.freeze(tmp);
      return res;
    };
  };



  private func partition (arr: [var Int], low: Int, hight: Int): Int{
    var pivot = arr[Int.abs(hight)];
    var i = low - 1;
    var j = low;
    while (j <= hight - 1) {
      if (arr[Int.abs(j)] < pivot) {
        i += 1;
        var swap = arr[Int.abs(i)];
        arr[Int.abs(i)] := arr[Int.abs(j)];
        arr[Int.abs(j)] := swap;
      };
      j += 1;
    };

    var swap = arr[Int.abs(i + 1)];
    arr[Int.abs(i + 1)] := arr[Int.abs(hight)];
    arr[Int.abs(hight)] := swap;

    return i + 1;
  };

  private func sort(arr: [var Int], low: Int, hight: Int) {
    if (low < hight) {
      var pi = partition(arr, low, hight);

      sort(arr, low, pi - 1);
      sort(arr, pi + 1, hight);
    };
  };

};

