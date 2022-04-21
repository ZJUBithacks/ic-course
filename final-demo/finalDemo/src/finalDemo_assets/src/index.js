import { Actor } from "@dfinity/agent";
import { VariantForm } from "@dfinity/candid";
import { Record, Variant } from "@dfinity/candid/lib/cjs/idl";
import { canisterId, finalDemo as dapp} from "../../declarations/finalDemo";



const newProposal = document.getElementById('new_proposal');
const st = document.getElementById('st');
const et = document.getElementById('et');
const proposalButton = document.getElementById('proposal_button');
const showallButton = document.getElementById('showall_button');
const getbyidButton = document.getElementById('getbyid_button');
const clearButton = document.getElementById('clear_button');
const getById = document.getElementById('get_by_id');
const findProposal = document.getElementById('find_proposal');
const prompt = document.getElementById('prompt');
const prompt1 = document.getElementById('prompt1');
const getReceipt = document.getElementById('get_receipt');
const receiptButton = document.getElementById('receipt_button');
const getReceiptById = document.getElementById('getreceipt_by_id');
const supportButton = document.getElementById('support_button')
const againstButton = document.getElementById('against_button')
const voteForId = document.getElementById('votefor_id')
const idSection = document.getElementById('id_section')

const transformDate = (bigint) => {
  return new Date(Number(bigint) / 1000000);
};

supportButton.addEventListener('click', async ()=> {
  supportButton.setAttribute('disabled', true);
  const content = voteForId.value.toString();
  // let tmp = Variant(VoteType.Against);
  
  let res = await dapp.vote(content, { Support: null });
  if (res.Err) {
    let temp1 = JSON.stringify(res.Err)
    prompt1.innerHTML = temp1;
    prompt1.style.color = "red";
  }
  if (res.Ok) {
    prompt1.innerHTML = `
    <div class="voteResult">
          <p>Proposal Name: ${res.Ok.id}</p>
          <p>supportVote: ${res.Ok.supportVote}</p>
          <p>againstVote: ${res.Ok.againstVote}</p>
          <p>Start Time: ${transformDate(res.Ok.startTime).toLocaleString()}</p> 
          <p>End Time: ${transformDate(res.Ok.endTime).toLocaleString()}</p> 
        </p>
    </div>
    `;
  }
  // supportButton.setAttribute('disabled', true);
  supportButton.removeAttribute("disabled");
  // voteForId.innerText = JSON.stringify(res);
})

clearButton.addEventListener('click', async ()=> {
  get_all.innerHTML = "";
  clearButton.removeAttribute("disabled");
})

againstButton.addEventListener('click', async ()=> {
  againstButton.setAttribute('disabled', true);
  const content = voteForId.value.toString();
  // let tmp = JSON.parse("{VoteType: Against}")

  let res = await dapp.vote(content, { Against: null });
  if (res.Err) {
    let temp1 = JSON.stringify(res.Err)
    prompt1.innerHTML = temp1;
    prompt1.style.color = "red";
  }
  if (res.Ok) {
    
    prompt1.innerHTML = `
    <div class="voteResult">
          <p>Proposal Name: ${res.Ok.id}</p>
          <p>supportVote: ${res.Ok.supportVote}</p>
          <p>againstVote: ${res.Ok.againstVote}</p>
          <p>Start Time: ${transformDate(res.Ok.startTime).toLocaleString()}</p> 
          <p>End Time: ${transformDate(res.Ok.endTime).toLocaleString()}</p> 
        </p>
    </div>
    `;
  }
  // againstButton.setAttribute('disabled', true);
  againstButton.removeAttribute("disabled");
  // voteForId.innerText = JSON.stringify(res);
})

receiptButton.addEventListener('click', async ()=> {
  // e.preventDefault();
  receiptButton.setAttribute('disabled', true);
  const content = getReceipt.value.toString();
  let res = await dapp.proposalResult(content);
  
  receiptButton.setAttribute('disabled', true);
  console.log(res);
  
  getReceiptById.innerHTML += JSON.stringify(res);

  receiptButton.removeAttribute("disabled");
  

})

idSection.append(canisterId);
proposalButton.addEventListener('click', async ()=> {
  proposalButton.setAttribute('disabled', true);
  prompt.innerText = "";
  const content = newProposal.value.toString();
  const stContent = st.value;
  const etContent = et.value;
  if (stContent >= etContent || stContent < 0) {
    alert("❌❎ 起始时间输入有误！");
  } else {
    let res = await dapp.createProposal(content, Number(stContent), Number(etContent));
  
    // proposalButton.setAttribute('disabled', false);
    alert("创建投票成功！");
    prompt.innerText = 'Success!';
  }
  newProposal.value = "";
  st.value = "";
  et.value = "";
  proposalButton.removeAttribute("disabled");
})


getbyidButton.addEventListener('click', async ()=> {
  getbyidButton.setAttribute('disabled', false);
  const content = findProposal.value.toString();
  let res = await dapp.getProposal(content);
  if (res.id === "not found") {
    alert("❌❎ 该投票没找到");
    getById.innerHTML = "";
  } else {
    var str = ("<div><ul><li>Proposal Name: " +res.id + "</li>"
    +"<li>proposer: "+res.proposer+"</li>"
    +"<li> startTime: " + transformDate(res.startTime).toLocaleString() +"</li>"
    +"<li>endTime: "+ transformDate(res.endTime).toLocaleString() +"</li>"
    +"<li>supportVote: "+res.supportVote+"</li>"
    +"<li>againstVote: "+res.againstVote+"</li></ul></div>");
    
    getById.innerHTML = (str);
  }
  findProposal.value = ' ';
  getbyidButton.removeAttribute("disabled");
})

showallButton.addEventListener('click', async ()=> {
  showallButton.setAttribute('disabled', false);
  get_all.innerHTML = "";

  let result = await dapp.getAllProrosal();
  result.map((res, index) => {
    console.log(res);
    var str = ("<div><ul><li>Proposal Name: " +res.id + "</li>"
    +"<li>proposer: "+res.proposer+"</li>"
    +"<li> startTime: " + transformDate(res.startTime).toLocaleString() +"</li>"
    +"<li>endTime: "+ transformDate(res.endTime).toLocaleString() +"</li>"
    +"<li>supportVote: "+res.supportVote+"</li>"
    +"<li>againstVote: "+res.againstVote+"</li></ul></div>");
    get_all.innerHTML += (str);
  })
  showallButton.removeAttribute("disabled");
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
