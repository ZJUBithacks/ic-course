import Random "mo:base/Random";
import Buffer "mo:base/Buffer";
import Array "mo:base/Array";
import List "mo:base/List";
import Iter "mo:base/Iter";
import Blob "mo:base/Blob";
import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Time "mo:base/Time";
import Debug "mo:base/Debug";

actor {

  type LotteryInfo = {
    // id: Nat;
    lotteryWinner: Text;
    range: Nat;
    sum: Nat;
    startTime: Time.Time;
    prize: Nat;
  };

  var lotteryIndex : Nat = 0;
  var participants: List.List<Principal> = List.nil();
  var lotteries: List.List<LotteryInfo> = List.nil();

  public type Lottery = actor {
    participate: shared(Principal) -> async ();
    listParticipants: shared query () -> async [Principal];
    postNewLottery: shared (LotteryInfo) -> async ();
    listLotteries: shared query () -> async [LotteryInfo];
    showTimeline: shared () -> async [LotteryInfo];
  };

  public shared query func listParticipants (): async [Principal] {
    List.toArray(participants)
  };

  public shared func participate (id : Principal): async Principal {
    if (not List.some(participants, func (p: Principal ): Bool { p==id })){
      participants := List.push(id, participants);
    };
    id
  };

  public shared func postNewLottery (range : Nat, sum : Nat, prize : Nat): async Time.Time{
    let newLottery: LotteryInfo = {
      // id: List.size(lotteries);
      lotteryWinner = "";
      range = range;
      sum = sum;
      prize = prize;
      startTime = Time.now();
    };
    lotteries := List.push(newLottery, lotteries);
    newLottery.startTime
  };

  public shared query func listLotteries () : async [LotteryInfo] {
    List.toArray(lotteries)
  };

  public func runFullLottery() : async [Principal] {
    // let tempLottery = List.get<LotteryInfo>(lotteries : [LotteryInfo], lotteryIndex);
    // let tempLottery = List.pop<LotteryInfo>(lotteries);
    // lotteryIndex += 1;
    // let tempRange;
    // switch(){
    //   case null {
    //   };
    //   case (?tempLottery){
    //     tempRange = tempLottery.range;
    //     tempSum = tempLottery.sum;
    //   }
    // };
    // let tempLotteryWinnersIndex : [Nat] = runLottery(tempLottery.range, tempLottery.sum);
    // for(i in Iter.range(0, tempLottery.sum - 1)){
    //   lotteryWinnersBuffer.add(List.toArray(participants)[tempLotteryWinnersIndex[i]]);
    // };
    let tempLottery = List.toArray(lotteries)[lotteryIndex];
    lotteryIndex += 1;
    let lotteryWinnersBuffer : Buffer.Buffer<Principal> = Buffer.Buffer(tempLottery.range);
    for(i in Iter.range(1, tempLottery.sum)){
      lotteryWinnersBuffer.add(List.toArray(participants)[Random.rangeFrom(255, await Random.blob()) % tempLottery.range]);
    };
    lotteryWinnersBuffer.toArray()
  };

  public func runLottery(range : Nat, sum : Nat) : async [Nat] {
    let resultBuffer : Buffer.Buffer<Nat> = Buffer.Buffer(range);
    for(i in Iter.range(1, sum)){
      resultBuffer.add(Random.rangeFrom(255, await Random.blob()) % range + 1);
    };
    resultBuffer.toArray()
  };

  // public shared func showTimeline () : async [LotteryInfo] {
  //   var all: List.List<LotteryInfo> = List.nil();
  //   for (id in Iter.fromList(participants)) {
  //     let canister: Lottery = actor(Principal.toText(id));
  //     let localLotteries = await canister.listLotteries;
  //     for (lottery in Iter.fromArray(localLotteries)) {
  //       all := List.push(lottery, all);
  //     }
  //   };
  //   List.toArray(all)
  // };

  // public func randomNumber(range : Nat8) : async Nat {
  //   Random.rangeFrom(255, await Random.blob()) % range + 1
  // };

};
