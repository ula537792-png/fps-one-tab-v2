const express = require('express');
const app = express();
app.use(express.json());

let keysDB = {};

app.post('/create-key', (req, res) => {
    const { adminSecret, keyName, durationDays } = req.body;
    
    if (adminSecret !== "ТВОЙ_ОЧЕНЬ_СЕКРЕТНЫЙ_ПАРОЛЬ") {
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

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
