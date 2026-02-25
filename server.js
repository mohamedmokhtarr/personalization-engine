const express = require('express');
const csv = require('csvtojson');
const path = require('path');
const cors = require('cors');

const app = express();

app.use(express.json());
app.use(cors());

const csvFilePath = path.join(__dirname, 'data', 'USDA_Clean.csv');
let foods = [];

console.log("⏳ Loading Database, please wait...");
csv().fromFile(csvFilePath)
    .then((jsonObj) => {
        foods = jsonObj;
        console.log("✅ Database Ready! Total items: " + foods.length);
    })
    .catch(err => {
        console.error("❌ Error loading CSV: ", err);
    });

app.post('/generate-plan', (req, res) => {
    const target = parseInt(req.body.targetCalories);
    if (!target) return res.status(400).json({ success: false, error: "Goal required" });

    const p = Math.round((target * 0.25) / 4);
    const c = Math.round((target * 0.50) / 4);
    const f = Math.round((target * 0.25) / 9);

    const meals = [
        { name: "Breakfast", icon: "🍳", pct: 0.25 },
        { name: "Lunch", icon: "🍱", pct: 0.35 },
        { name: "Dinner", icon: "🥗", pct: 0.25 },
        { name: "Snacks", icon: "🍎", pct: 0.15 }
    ].map(m => ({
        name: m.name,
        icon: m.icon,
        calories: Math.round(target * m.pct),
        protein: Math.round(p * m.pct),
        carbs: Math.round(c * m.pct),
        fat: Math.round(f * m.pct)
    }));

    res.json({
        success: true,
        macros: { proteinGrams: p, carbsGrams: c, fatGrams: f },
        mealPlan: meals 
    });
});

app.post('/track-food', (req, res) => {
    const { foodName, quantity } = req.body;
    const food = foods.find(f => f.Description && f.Description.toLowerCase().includes(foodName.toLowerCase()));

    if (!food) return res.status(404).json({ success: false, message: "Food not found" });

    const factor = (parseFloat(quantity) || 100) / 100;
    
    res.json({
        success: true,
        calories: Number((parseFloat(food.Calories || 0) * factor).toFixed(2)),
        protein: Number((parseFloat(food.Protein || 0) * factor).toFixed(2)),
        carbs: Number((parseFloat(food.Carbs || 0) * factor).toFixed(2)),
        fat: Number((parseFloat(food.Fat || 0) * factor).toFixed(2))
    });
});

app.get('/search-suggestions', (req, res) => {
    const query = req.query.q ? req.query.q.toLowerCase() : "";
    if (query.length < 2) return res.json([]);
    const suggestions = foods
        .filter(f => f.Description && f.Description.toLowerCase().includes(query))
        .slice(0, 10)
        .map(f => f.Description);
    res.json(suggestions);
});

const PORT = 5000;
const server = app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Server is LIVE at http://localhost:${PORT}`);
    console.log("📌 Press Ctrl+C to stop.");
});

// منع السيرفر من الخروج المفاجئ في الويندوز
process.stdin.resume();

// معالجة أخطاء المنفذ (Port)
server.on('error', (e) => {
    if (e.code === 'EADDRINUSE') {
        console.error(`❌ Error: Port ${PORT} is already in use. Please close other node processes.`);
    } else {
        console.error("❌ Server Error: ", e);
    }
});