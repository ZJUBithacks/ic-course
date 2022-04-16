import Nat "mo:base/Nat";
import Debug "mo:base/Debug";
import Array "mo:base/Array";
import Order "mo:base/Order";
import Int "mo:base/Int";

actor {

    private func quickSort0(array:[var Int], start:Nat, end:Nat){
        if(start >= end){
            return;
        };
        var left = start;
        var right = end;
        var key = array[left];
        while(left < right){
            while(array[right] > key and left < right){
                right -= 1;
            };
            while(array[left] <= key and left < right){
                left += 1;
            };
            if(left < right){
                var temp = array[left];
                array[left] := array[right];
                array[right] := temp;
            };
        };
        array[start] := array[left];
        array[left] := key;
        quickSort0(array, start, left - 1);
        quickSort0(array, left + 1, end);
    };

    private func quickSort1(array:[var Int], start:Nat, end:Nat){
        if(start >= end){
            return;
        };
        var left = start;
        var right = end;
        var temp = array[start];
        while(left < right){
            while(left < right and temp < array[right]){
                right -= 1;
            };
            if(left < right){
                array[left] := array[right];
                left += 1;
            };
            while(left < right and array[left] <= temp){
                left += 1;
            };
            if(left < right){
                array[right] := array[left];
                right -= 1;
            };
        };
        array[left] := temp;
        if(start < left){
            quickSort1(array, start, right - 1);
        };
        if(left < end){
            quickSort1(array, right + 1, end);
        };
    };

    public func qsort(array:[Int]) : async [Int] {
        // qSort(array);
        var resultArray:[var Int] = Array.thaw(array);
        quickSort1(resultArray, 0, resultArray.size() - 1);
        Array.freeze(resultArray);
    };
  
};
