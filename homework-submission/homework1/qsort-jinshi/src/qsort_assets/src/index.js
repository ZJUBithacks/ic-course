import { qsort } from "../../declarations/qsort";

document.querySelector("form").addEventListener("submit", async (e) => {
  e.preventDefault();
  const button = e.target.querySelector("button");

  const name = document.getElementById("name").value;

  button.setAttribute("disabled", true);

  // Interact with foo actor, calling the greet method
  const greeting = await qsort.qsort(name);

  button.removeAttribute("disabled");

  document.getElementById("greeting").innerText = greeting;

  return false;
});
