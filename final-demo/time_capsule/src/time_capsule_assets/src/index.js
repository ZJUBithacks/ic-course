import { idlFactory, time_capsule } from "../../declarations/time_capsule";
import { AuthClient } from "@dfinity/auth-client";
import { Principal } from "@dfinity/candid/lib/cjs/idl";
import { createActor } from "../../declarations/time_capsule";

const allSection = document.getElementById('all')
const receivedSection = document.getElementById('received')

const toInput = document.getElementById('to')
const endTime = document.getElementById('time')
const toAllCheck = document.getElementById('toAll')
const textarea = document.getElementById('content')
const confirmButton = document.getElementById("confirm");
const loginButton = document.getElementById("loginButton");

const canisterId = "7midt-xaaaa-aaaai-qjdma-cai";

var authClient;
var actor;
var identity;

const login = async () => {
  authClient = await AuthClient.create();
  if (await authClient.isAuthenticated()) {
    identity = authClient.getIdentity();
    loginButton.innerText =
      identity.getPrincipal().toString().slice(0, 6) + '...';
    actor = createActor(canisterId, {
      agentOptions: {
        identity: identity,
        // host: 'http://localhost:8000/'
        host: 'https://ic0.app'
      }
    })
  } else {
    actor = createActor(canisterId, {
      agentOptions: {
        host: 'https://ic0.app'
      }
    })
  }

  const days = BigInt(1);
  const hours = BigInt(24);
  const nanoseconds = BigInt(3600000000000);
  

  loginButton.onclick = async () => {
    await authClient.login({
      onSuccess: async () => {
        identity = authClient.getIdentity();
        loginButton.innerText =
          identity.getPrincipal().toString().slice(0, 6) + '...';
        actor = createActor(canisterId, {
          agentOptions: {
            identity,
            // host: 'http://localhost:8000/'
            host: 'https://ic0.app'
          }
        })
      },
      identityProvider:
        process.env.DFX_NETWORK === "ic"
          ? "https://identity.ic0.app/#authorize"
          : process.env.LOCAL_II_CANISTER,
      // Maximum authorization expiration is 8 days
      maxTimeToLive: days * hours * nanoseconds,
    });
  };
};

toAllCheck.addEventListener('change', () => {
  if (toAllCheck.checked)
    toInput.setAttribute("hidden", true)
  else
    toInput.removeAttribute("hidden")
})

const Message = (item) => {
  let sealedTime = new Date(Number(item.sealedTime)/1e6)
  let unlockTime = new Date(Number(item.unlockTime)/1e6)
  let content = item.content.length > 0 ? item.content[0] : 'Hidden content.'
  if (item.unlockTime < new Date() * 1e6 && ( item.to.length <= 0 || item.to === identity.getPrincipal())){
    actor.getCapsule(item.id).then((res)=>{
      console.log('capsule'+item.id)
      if ('ok' in res && res.ok.content.length > 0){
        document.getElementsByName('capsule'+item.id).forEach((ele)=>{
          ele.innerText = res.ok.content[0]
        })

      } else {
        document.getElementsByName('capsule'+item.id).forEach((ele)=>{
          ele.innerText = res.err
        })
      }
    })
  }

  return `<p>From: ` + item.creator.toString().slice(0, 8) + `...</p><p>To: ` + item.to + `...</p><p name='capsule`+item.id+`'>` + content + `</p><p>Sealed at: ` + sealedTime + `</p><p>Unlock at: ` + unlockTime + `</p>`
}

document.querySelector("form").addEventListener("submit", async (e) => {
  e.preventDefault();
  confirmButton.setAttribute("disabled", true);
  let content = textarea.value
  let endtime = Date.parse(endTime.value) * 1e6 //milli
  // Interact with foo actor, calling the greet method
  actor.createCapsule({
    'to': toAllCheck.checked ? [] : [Principal.fromText(toInput.value)],
    'unlockTime': endtime,
    'content': content,
  }).then((res) => {
    console.log(res)
    confirmButton.innerText = 'Sent!';
    setTimeout(() => {
      confirmButton.innerText = 'Confirm';
      textarea.value = '';
    }, 3000)
    confirmButton.removeAttribute("disabled");
  })
});

var allLength = 0

const updateSections = async () => {
  
  let all = await actor.getAllCapsules()
  let my = authClient.isAuthenticated() ? await actor.getUserCapsules() : []
  if(all.length > allLength){
    allSection.innerHTML = all.map(
      item => {
        // from_unixtime(Number(item.sealedTime) / 1000, '%Y-%m-%d %h:%i:%s')
        return Message(item)
      }
    );
    receivedSection.innerHTML = my.map(
      item => {
        // from_unixtime(Number(item.sealedTime) / 1000, '%Y-%m-%d %h:%i:%s')
        return Message(item)
      }
    );
    allLength = all.length;
  }
} 

const init = () => {
  login()
  setInterval(() => {
    updateSections()
  }, 10000);
}

window.onload = init