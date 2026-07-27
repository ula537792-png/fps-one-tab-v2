const express = require('express');
const app = express();
app.use(express.json());

let keysDB = {};

// Главная страница для создания ключей прямо в браузере
app.get('/', (req, res) => {
    res.send(`
        <html>
        <head>
            <title>Inverium Key Generator</title>
            <style>
                body { background: #0f0f0f; color: #fff; font-family: sans-serif; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; }
                .card { background: #161616; padding: 30px; border-radius: 16px; border: 1px solid #ff6496; width: 300px; box-shadow: 0 4px 20px rgba(0,0,0,0.5); }
                input, button { width: 100%; padding: 10px; margin-top: 10px; border-radius: 8px; border: none; font-weight: bold; box-sizing: border-box; }
                input { background: #222; color: #fff; border: 1px solid #333; }
                button { background: #ff6496; color: #fff; cursor: pointer; }
                button:hover { opacity: 0.9; }
                #result { margin-top: 15px; word-break: break-all; color: #ff6496; font-family: monospace; }
            </style>
        </head>
        <body>
            <div class="card">
                <h3>Key Generator</h3>
                <input type="password" id="secret" placeholder="Admin Secret">
                <input type="text" id="keyName" placeholder="Key Name (e.g. MY-KEY)" value="KEY-1">
                <input type="number" id="duration" placeholder="Days" value="1">
                <button onclick="createKey()">Create Key</button>
                <div id="result"></div>
            </div>
            <script>
                async function createKey() {
                    const secret = document.getElementById('secret').value;
                    const keyName = document.getElementById('keyName').value;
                    const durationDays = Number(document.getElementById('duration').value);
                    const resDiv = document.getElementById('result');
                    
                    resDiv.innerText = "Creating...";
                    const response = await fetch('/create-key', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ adminSecret: secret, keyName, durationDays })
                    });
                    const data = await response.json();
                    if(data.success) {
                        resDiv.innerText = "Success! Ключ: " + keyName;
                    } else {
                        resDiv.innerText = "Error: " + (data.message || "Access Denied");
                    }
                }
            </script>
        </body>
        </html>
    `);
});

app.post('/create-key', (req, res) => {
    const { adminSecret, keyName, durationDays } = req.body;
    
    if (adminSecret !== "ratcaz") {
        return res.status(403).json({ success: false, message: "Access Denied" });
    }
    
    const durationMs = durationDays * 24 * 60 * 60 * 1000;
    keysDB[keyName] = {
        duration: durationMs,
        expiresAt: null,
        boundUser: null
    };
    
    res.json({ success: true, message: `Ключ ${keyName} успешно создан на ${durationDays} дн.` });
});

app.post('/redeem-key', (req, res) => {
    const { key, userId } = req.body;
    
    if (!keysDB[key]) {
        return res.json({ success: false, message: "Неверный ключ!" });
    }
    
    const keyData = keysDB[key];
    const now = Date.now();

    if (keyData.boundUser && keyData.boundUser !== userId) {
        return res.json({ success: false, message: "Ключ уже используется на другом аккаунте!" });
    }

    if (!keyData.expiresAt) {
        keyData.expiresAt = now + keyData.duration;
        keyData.boundUser = userId;
    }

    if (now > keyData.expiresAt) {
        return res.json({ success: false, message: "Срок действия ключа истёк!" });
    }

    res.json({ success: true, message: "Ключ принят!" });
});

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
