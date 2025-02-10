let cardPayload = {};
const payBtn = document.querySelector("#pay");

document.addEventListener("DOMContentLoaded", async () => {
  payBtn.disabled = false;

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

  const form = document.getElementById("payment-form");
  form.addEventListener("submit", async (e) => {
    e.preventDefault();
    payBtn.disabled = true;

    const body = {
      payment_method: cardPayload,
      // change with your customer ID
      customerId: "47a10b46-151b-4cc6-99d7-4994ef2081f1",
      // change with your product ID
      productId: "049a5468-d131-4a65-a848-1e424beacfc9",
    };
    const { clientSecret } = await fetch("/create-subscription", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
    }).then((r) => r.json());

    const { hasError } = await frame.confirmCardPayment(clientSecret);

    payBtn.disabled = false;

    if (hasError) {
      window.location.replace(`${window.location.origin}/failed.html`);
    } else {
      window.location.replace(`${window.location.origin}/success.html`);
    }
  });
});
