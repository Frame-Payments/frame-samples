# Example Application built with Ruby and JavaScript


## How to run

1. Confirm .env configuration. Rename and move the `.env.example` to `.env` and then update the values accordingly

```
cp .env.example .env
```

You will need a Frame account in order to run the demo. Once you set up your account, go to the Frame [developer dashboard](https://app.framepayments.com/developer/apikeys) to find your API keys.

2. Install required dependencies

```
bundle install
```

3. Run the server locally

```
ruby server.rb
```

4. Go to http://localhost:4242 in your browser
