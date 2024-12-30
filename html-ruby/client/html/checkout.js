let cardPayload = {};
const payBtn = document.querySelector("#pay");

document.addEventListener("DOMContentLoaded", async () => {
  payBtn.disabled = true;

  const { publishableKey } = await fetch("/config").then((r) => r.json());
  if (!publishableKey) {
    addMessage("No publishable key returned from the server. Please check `.env` and try again");
    alert("Please set your Frame publishable API key in the .env file");
  }

  const frame = await Frame.init(publishableKey);
  const card = await frame.createElement("card", {
    theme: frame.themes("clean"),
  });
  card.on("complete", (payload) => {
    cardPayload = payload.card;
    payBtn.disabled = false;
  });
  card.mount("#payment-card-element");

  // When the form is submitted...
  const form = document.getElementById("payment-form");
  let submitted = false;
  form.addEventListener("submit", async (e) => {
    e.preventDefault();

    // Disable double submission of the form
    if (submitted) {
      return;
    }
    submitted = true;
    payBtn.disabled = true;

    const body = { payment_method: cardPayload };
    const { clientSecret } = await fetch("/create-charge-intent", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
    }).then((r) => r.json());

    const { chargeIntent, hasError, error } = await frame.confirmCardPayment(clientSecret);
    console.log(chargeIntent);
    console.log(hasError);
    console.log(error);

    if (chargeIntent.status === "succeeded") {
      window.location.replace(`${window.location.origin}/success.html`);
    } else {
      window.location.replace(`${window.location.origin}/failed.html`);
    }
  });
});
