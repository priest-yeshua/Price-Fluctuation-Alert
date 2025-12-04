# 📘 PriceFluctuationAlert – Drosera Trap + Responder

This repository contains a complete implementation of a **Drosera Trap** that detects significant price fluctuations using:

- A Chainlink-compatible oracle  
- A UniswapV2 liquidity pair (as fallback)  
- A custom responder contract  

This system is deployed on the **Hoodi network** and monitored automatically through the **Drosera Operator Node**.

---

## 📂 Repository Structure

```
src/
  PriceFluctuationAlert.sol
  PriceAlertResponder.sol
  interfaces/

script/
  DeployTrap.s.sol
  DeployResponder.s.sol

out/
  PriceFluctuationAlert.sol/PriceFluctuationAlert.json

drosera.toml
```

---

# ⚙️ 1. Smart Contracts

## 🔹 Trap Contract  
Deployed at:

```
0xFB57dD969B5854B893CB1F522ac799ecf9Ca8902
```

This contract:

- Reads price from oracle  
- Falls back to UniswapV2 pair  
- Detects when price moves more than 10%  
- Signals Drosera to trigger response  

---

## 🔹 Responder Contract  
Deployed at:

```
0x5764003aef4358993c099E747F61AF5028344865
```

This contract receives:

```
respondCallback(uint256 changeWad)
```

You can extend it to send alerts, automate trades, log events, etc.

---

# 🛠️ 2. Drosera Configuration

Your working **drosera.toml**:

```toml
ethereum_rpc = "https://rpc.hoodi.ethpandaops.io"
drosera_rpc = "https://relay.hoodi.drosera.io"
eth_chain_id = 560048
drosera_address = "0x91cB447BaFc6e0EA0F4Fe056F5a9b1F14bb06e5D"

[traps]

[traps.price_fluctuation_alert]
path = "out/PriceFluctuationAlert.sol/PriceFluctuationAlert.json"
contract = "0xFB57dD969B5854B893CB1F522ac799ecf9Ca8902"
response_contract = "0x5764003aef4358993c099E747F61AF5028344865"
response_function = "respondCallback(uint256)"
cooldown_period_blocks = 33
min_number_of_operators = 1
max_number_of_operators = 2
block_sample_size = 10
private_trap = true
whitelist = ["0x4a5d78cd395c3f612d0b26f2ca3d6a7399ffc7a4"]
```

---

# 🛰️ 3. Running the Drosera Operator Node

Install Drosera Operator:

```bash
curl -LO https://github.com/drosera-network/drosera-operator/releases/latest/download/drosera-operator-linux
chmod +x drosera-operator-linux
mv drosera-operator-linux /usr/local/bin/drosera-operator
```

Run the node:

```bash
drosera-operator node --config drosera.toml
```

If working, you’ll see:

```
collect OK
shouldRespond = true
sending response...
```

---

# ♻️ 4. Running Drosera 24/7

### Option A — Using screen

```bash
screen -S drosera
drosera-operator node --config drosera.toml
```

Detach:

```
CTRL + A + D
```

### Option B — Using systemd

Create service:

```ini
[Unit]
Description=Drosera Operator Node
After=network.target

[Service]
User=root
WorkingDirectory=/root/PriceFluctuationAlert
ExecStart=/usr/local/bin/drosera-operator node --config drosera.toml
Restart=always

[Install]
WantedBy=multi-user.target
```

Enable:

```bash
systemctl daemon-reload
systemctl enable drosera
systemctl start drosera
```

---

# 🧪 5. Verify Trap Status

Check trap on relay:

```bash
curl https://relay.hoodi.drosera.io/trap_status
```

Should show:

```
"price_fluctuation_alert": "active"
```

---

# 🎉 Summary

This repo includes:

A deployed Price Fluctuation Trap 
A deployed Responder 
A complete Drosera configuration 
A working node setup 
Automated 24/7 monitoring
