# FX Payment Processor

This project is a prototype of a simplified **FX Payment Processor**.
It powers a **multi-currency wallet system** where clients can:

- Fund their wallets in different currencies
- Convert between currencies using FX rates
- Withdraw funds to external bank accounts
- View balances and transaction history

Built with **Ruby on Rails (API-only mode)** and **PostgreSQL**, fully containerized with **Docker**.

---

🔎 Assumptions

- A wallet belongs to a user (1-to-1 relationship).
- Only USD and MXN currencies are supported.
- Currency conversions are treated as two transactions:
  - A withdraw from the source currency.
  - A fund in the target currency.
- The system is meant for prototype/testing, so:
  - No pagination is required for listing transactions.
  - Transaction history is expected to be small.

---


## 📦 Project Setup (Local)

### Requirements
- Ruby 3.2+
- Rails 7+
- PostgreSQL 15+

### Steps

1. Clone the repository:

```bash
git clone git@github.com:fernando-barajas/fx_payment_processor.git
cd fx_payment_processor
```

2. Install dependencies:

```bash
bundle install
```

3. Setup the database:

```bash
rails db:prepare
```

3.1 In case seeds didn't run

```bash
rails db:seed
```

4. Run the server:

```bash
./bin/rails s
```

### 🐳 Setup with Docker

1. Build and Run the App

```bash
docker-compose build
docker-compose up
```


### 🔗 API Endpoints

| Method | Endpoint                                 | Description                |
| ------ | ---------------------------------------- | -------------------------- |
| POST   | `/wallets/:user_id/fund`                 | Fund a wallet              |
| POST   | `/wallets/:user_id/convert`              | Convert between currencies |
| POST   | `/wallets/:user_id/withdraw`             | Withdraw funds             |
| GET    | `/wallets/:user_id/balances`             | View wallet balance        |
| GET    | `/wallets/:user_id/transactions`         | List transaction history   |
| GET    | `/wallets/:user_id/reconciliation_check` | Shows balances status      |


🔗 API Endpoints & Examples

1. Fund Wallet

```bash
curl -X POST http://localhost:3000/wallets/1/fund \
  -H "Content-Type: application/json" \
  -d '{"amount": 100, "currency": "USD"}'
```

Response

```json
{  message: "Wallet funded successfully" }
```

2. Convert Currency

```bash
curl -X POST http://localhost:3000/wallets/1/convert \
  -H "Content-Type: application/json" \
  -d '{"from_currency": "USD", "to_currency": "MXN", "amount": 50}'
```

Response

```json
{ message: "Funds converted successfully" }
```

2.1 Convert with custom exchange rate

```bash
curl -X POST http://localhost:3000/wallets/1/convert \
  -H "Content-Type: application/json" \
  -d '{"from_currency": "USD", "to_currency": "MXN", "amount": 50, "custom_exchange_rate": 20}'
```

Response

```json
{ message: "Funds converted successfully" }
```

3. Withdraw Funds

```bash
curl -X POST http://localhost:3000/wallets/1/withdraw \
  -H "Content-Type: application/json" \
  -d '{"amount": 30, "currency": "USD"}'
```

Response

```json
{ message: "Wallet withdrawn successfully" }
```

4. Get Wallet Balance

```bash
curl -X GET http://localhost:3000/wallets/1/balances
```

Response

```json
{
    "USD": 20.0,
    "MXN": 30.0
}
```

5. Get Transactions

```bash
curl -X GET http://localhost:3000/wallets/1/transactions
```

Response

```json
"fund_transactions": [
  {
      "amount": 20.0,
      "currency": "USD",
      "created_at": "2025-08-31 16:36:27"
  },
  {
      "amount": 30.0,
      "currency": "MXN",
      "created_at": "2025-08-31 16:36:34"
  }
],
"withdraw_transactions": [],
"convert_transactions": []
```

6. Get Reconciliation check

```bash
curl -X GET http://localhost:3000/wallets/1/reconciliation_check
```

Response

```json
{
  "USD": "OK",
  "MXN": "OK"
}
```


### ✅ Running Tests

1. To run specs locally:

```bash
 bundle exec rspec
 ```
