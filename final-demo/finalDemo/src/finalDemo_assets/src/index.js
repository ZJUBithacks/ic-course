import { Actor } from "@dfinity/agent";
import { VariantForm } from "@dfinity/candid";
import { Record, Variant } from "@dfinity/candid/lib/cjs/idl";
import { canisterId, finalDemo as dapp} from "../../declarations/finalDemo";



const newProposal = document.getElementById('new_proposal');
const proposalButton = document.getElementById('proposal_button');
const showallButton = document.getElementById('showall_button');
const getbyidButton = document.getElementById('getbyid_button');
const getById = document.getElementById('get_by_id');
const findProposal = document.getElementById('find_proposal');
const prompt = document.getElementById('prompt');
const getReceipt = document.getElementById('get_receipt');
const receiptButton = document.getElementById('receipt_button');
const getReceiptById = document.getElementById('getreceipt_by_id');
const supportButton = document.getElementById('support_button')
const againstButton = document.getElementById('against_button')
const voteForId = document.getElementById('votefor_id')
const idSection = document.getElementById('id_section')

supportButton.addEventListener('click', async ()=> {
  supportButton.setAttribute('disabled', true);
  const content = voteForId.value.toString();
  let tmp = Variant(VoteType.Against);
  
  let res = await dapp.vote(content, tmp);
  voteForId.innerText = ' ';
})

againstButton.addEventListener('click', async ()=> {
  againstButton.setAttribute('disabled', true);
  const content = voteForId.value.toString();
  // let tmp = JSON.parse("{VoteType: Against}")
  let tmp = Variant ();
  let res = await dapp.vote(content, tmp);
  voteForId.innerText = JSON.stringify(res);
})

receiptButton.addEventListener('click', async ()=> {
  receiptButton.setAttribute('disabled', true);
  const content = getReceipt.value.toString();
  let res = await dapp.proposalResult(content);
  
  receiptButton.setAttribute('disabled', false);
  
  getReceiptById.innerHTML += JSON.stringify(res);
  

})


idSection.append(canisterId);
proposalButton.addEventListener('click', async ()=> {
  proposalButton.setAttribute('disabled', true);
  const content = newProposal.value.toString();
  let res = await dapp.createProposal(content, 0, 30);
  
  proposalButton.setAttribute('disabled', false);
  newProposal.innerText = '';
  prompt.innerText = 'Success!';
})


getbyidButton.addEventListener('click', async ()=> {
  getbyidButton.setAttribute('disabled', false);
  const content = findProposal.value.toString();
  let res = await dapp.getProposal(content);
  var str = ("<div><ul><li>Proposal Name: " +res.id + "</li>"
  +"<li>proposer: "+res.proposer+"</li>"
  +"<li> createTime: " + res.createTime+"</li>"
  +"<li>endTime: "+res.endTime+"</li>"
  +"<li>supportVote: "+res.supportVote+"</li>"
  +"<li>againstVote: "+res.againstVote+"</li></ul></div>");
  getById.innerHTML += (str);
  findProposal.value = ' ';
})

showallButton.addEventListener('click', async ()=> {
  showallButton.setAttribute('disabled', false);

  let result = await dapp.getAllProrosal();
  result.map((res, index) => {
    console.log(res);
    var str = ("<div><ul><li>Proposal Name: " +res.id + "</li>"
    +"<li>proposer: "+res.proposer+"</li>"
    +"<li> createTime: " + res.createTime+"</li>"
    +"<li>endTime: "+res.endTime+"</li>"
    +"<li>supportVote: "+res.supportVote+"</li>"
    +"<li>againstVote: "+res.againstVote+"</li></ul></div>");
    get_all.innerHTML += (str);
  })
})



document.querySelector("form").addEventListener("submit", async (e) => {
  e.preventDefault();
  const button = e.target.querySelector("button");

  const name = document.getElementById("name").value.toString();

  button.setAttribute("disabled", true);

  // Interact with foo actor, calling the greet method
  const greeting = await finalDemo.greet(name);

  button.removeAttribute("disabled");

  document.getElementById("greeting").innerText = greeting;

  return false;
});
