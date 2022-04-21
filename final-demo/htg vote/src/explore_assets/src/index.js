import { explore } from "../../declarations/explore";

const transformDate = (bigint) => {
  return new Date(Number(bigint) / 1000000);
};

document.querySelector("#createVote").addEventListener("submit", async (e) => {
  e.preventDefault();

  const name = document.getElementById("name").value.toString();
  const startTime = document.getElementById("startTime").value;
  const endTime = document.getElementById("endTime").value;

  // Interact with foo actor, calling the greet method
  const createRes = await explore.createProposal(
    name,
    Number(startTime),
    Number(endTime)
  );
  console.log(createRes);
});

document.getElementById("queryVote").addEventListener("submit", async (e) => {
  e.preventDefault();
  const voteList = document.getElementById("voteList");
  const vote = document.getElementById("voteName").value;

  const voteRes = await explore.getProposal(vote);
  const start = transformDate(voteRes.startTime).toLocaleString();
  const end = transformDate(voteRes.endTime).toLocaleString();
  const supportVote = voteRes.supportVote;
  const againstVote = voteRes.againstVote;

  if (voteRes.id === "placeholder") {
    voteList.innerHTML = `<p>No vote found</p>`;
  } else {
    if (voteList.childNodes.length > 0) {
      voteList.removeChild(voteList.childNodes[0]);
    }
    const newEl = document.createElement("div");
    newEl.innerHTML = `
    <div class="voteResult">
          <p>Vote:${voteRes.id}</p>
          <p>upvote:${supportVote}</p>
          <p>downvote:${againstVote}</p>
          <p>Start Time:${start}</p> 
          <p>End Time:${end}</p> 
        </p>
    </div>
    `;

    voteList.appendChild(newEl);
  }
});

document.getElementById("upvote").addEventListener("submit", async (e) => {
  e.preventDefault();
  const voteId = document.getElementById("voteId").value;
  const voteResult = document.getElementById("voteResult");
  // remove all child
  if (voteResult.childNodes.length > 0) {
    voteResult.removeChild(voteResult.childNodes[0]);
  }

  const res = await explore.vote(voteId, { Support: null });

  if (res.err) {
    const voteErr = document.createElement("p");
    voteErr.innerText = res.err;
    voteErr.style.color = "red";
    voteResult.appendChild(voteErr);
  }

  if (res.ok) {
    const voteOk = document.createElement("p");
    voteOk.innerText = res.ok;
    voteOk.style.color = "green";
    voteResult.appendChild(voteOk);
  }
});

document.getElementById("downvote").addEventListener("submit", async (e) => {
  e.preventDefault();
  const voteId = document.getElementById("voteId").value;
  const voteResult = document.getElementById("voteResult");
  // remove all child
  if (voteResult.childNodes.length > 0) {
    voteResult.removeChild(voteResult.childNodes[0]);
  }

  const res = await explore.vote(voteId, { Against: null });

  if (res.err) {
    const voteErr = document.createElement("p");
    voteErr.innerText = res.err;
    voteErr.style.color = "red";
    voteResult.appendChild(voteErr);
  }

  if (res.ok) {
    const voteOk = document.createElement("p");
    voteOk.innerText = res.ok;
    voteOk.style.color = "green";
    voteResult.appendChild(voteOk);
  }
});
