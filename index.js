const express = require('express');
const mongoose = require('mongoose');
// بننادي على ملف الـ Routes اللي إنتِ لسه بعتاه
const gamificationRoutes = require('./routes/gamificationRoutes'); 

const app = express();
app.use(express.json()); // عشان السيرفر يفهم البيانات اللي بتبعتيها (JSON)

// بنفعل الـ Routes بتاعتك ونخليها تبدأ بكلمة /api
app.use('/api', gamificationRoutes);

// توصيل قاعدة البيانات (MongoDB)
mongoose.connect('mongodb://127.0.0.1:27017/trainverse')
  .then(() => console.log('✅ Connected to MongoDB'))
  .catch(err => console.error('❌ Database error:', err));

// تشغيل السيرفر
app.listen(3000, () => {
  console.log('🚀 Server is running on http://localhost:3000');
});