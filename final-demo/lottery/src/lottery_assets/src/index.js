import { canisterId, lottery } from "../../declarations/lottery";
import { Principal } from '@dfinity/principal';


// document.getElementById("canisterId").innerHTML = canisterId;
const runLotteryButton = document.getElementById("runLotteryButton");
const runFullLotteryButton = document.getElementById("runFullLotteryButton");
const participateButton = document.getElementById('participateButton');
const postNewLotteryButton = document.getElementById('postNewLotteryButton');
const listParticipantsButton = document.getElementById('listParticipantsButton');
const listLotteriesButton = document.getElementById('listLotteriesButton');

// const prompt = document.getElementById('prompt');


runLotteryButton.addEventListener("click", async () => {
  // e.preventDefault();
  let range = BigInt(document.getElementById("range").value);
  let sum = BigInt(document.getElementById("sum").value);
  runLotteryButton.setAttribute("disabled", true);
  let lotteryWinner = await lottery.runLottery(range, sum);
  // console.log(lotteryWinner);
  runLotteryButton.removeAttribute("disabled");
  // document.getElementById("greeting").innerText = greeting;
  document.getElementById("lotteryWinner").innerHTML = lotteryWinner;
  return false;
});

runFullLotteryButton.addEventListener("click", async () => {
  // e.preventDefault();
  runFullLotteryButton.setAttribute("disabled", true);
  let lotteryWinner = await lottery.runFullLottery();
  // console.log(lotteryWinner);
  runFullLotteryButton.removeAttribute("disabled");
  document.getElementById("lotteryWinner").innerHTML = lotteryWinner;
  return false;
});

participateButton.addEventListener('click', async (e)=>{
  e.preventDefault();
  participateButton.setAttribute('disabled', true);
  // await lottery.participate({canisterId: canisterId});
  let cid = await lottery.participate(Principal.fromText(canisterId));
  console.log(cid);
  participateButton.removeAttribute("disabled");
  // prompt.innerText = 'Success!';
  return false;
});


postNewLotteryButton.addEventListener('click', async (e)=>{
  e.preventDefault();
  postNewLotteryButton.setAttribute('disabled', true);
  let range = BigInt(document.getElementById("range").value);
  let sum = BigInt(document.getElementById("sum").value);
  let prize = BigInt(document.getElementById("prize").value);
  let result = await lottery.postNewLottery(range, sum, prize);
  console.log(result);
  postNewLotteryButton.removeAttribute("disabled");
  // prompt.innerText = 'Success!';
  return false;
});

listParticipantsButton.addEventListener('click', async (e)=>{
  e.preventDefault();
  listParticipantsButton.setAttribute('disabled', true);
  let participants = await lottery.listParticipants();
  listParticipantsButton.removeAttribute("disabled");
  console.log(participants);
  var participantDetails = "";
  for(let i = 0; i < participants.length; i++){
    participantDetails += "CanisterID: " + participants[i] + "; ";
    participantDetails += "\n";
  }
  document.getElementById("participants").innerHTML = participantDetails;
  // prompt.innerText = 'Success!';
  return false;
});

listLotteriesButton.addEventListener('click', async (e)=>{
  e.preventDefault();
  listLotteriesButton.setAttribute('disabled', true);
  let lotteries = await lottery.listLotteries();
  listLotteriesButton.removeAttribute("disabled");
  // console.log(lotteries);
  var lotteryDetails = "";
  for(let i = 0; i < lotteries.length; i++){
    lotteryDetails += "Winner: " + lotteries[i].lotteryWinner + "; ";
    lotteryDetails += "Range: " + lotteries[i].range + "; ";
    lotteryDetails += "Sum: " + lotteries[i].sum + "; ";
    // lotteryDetails += "Start: " + lotteries[i].startTime + "; ";
    lotteryDetails += "Prize: " + lotteries[i].prize + "; ";
    lotteryDetails += "\n";
  }
  // console.log(lotteryDetails);
  document.getElementById("lotteries").innerText = lotteryDetails;
  // prompt.innerText = 'Success!';
  return false;
});
