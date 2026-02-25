// 1. استدعاء المكتبات الأساسية
const express = require("express");
const cors = require("cors");
const mongoose = require("mongoose");

// 2. استدعاء كافة المسارات (Routes) - شغل الفريق بالكامل
const profileRoutes    = require("./routes/profile.routes");
const goalRoutes       = require("./routes/goal.routes");
const workoutRoutes    = require("./routes/workout.routes");
const planRoutes       = require("./routes/plan.routes");
const gamificationRoutes = require("./routes/gamificationRoutes"); 
const progressRoutes   = require("./routes/progressRoutes");

const app = express();

// ── Middlewares الأساسية ──────────────────────────────────
app.use(cors());
app.use(express.json());

// ── Request Logger (شغل مختار الاحترافي) ──────────────────
app.use((req, _res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
  next();
});

// ── ربط المسارات (Routes) بالـ API ───────────────────────
app.use("/api/profile",    profileRoutes);
app.use("/api/goals",      goalRoutes);
app.use("/api/workouts",   workoutRoutes);
app.use("/api/plan",       planRoutes);
app.use("/api/gamification", gamificationRoutes); 
app.use("/api/progress",   progressRoutes);

// ── Health check (للتأكد إن السيرفر شغال) ──────────────────
app.get("/health", (_req, res) => res.json({ 
    status: "ok", 
    timestamp: new Date(),
    service: "TrainVerse API"
}));

// ── 404 Handler (لو المسار مش موجود) ─────────────────────
app.use((_req, res) => {
    res.status(404).json({ success: false, message: "Route not found" });
});

// ── Global Error Handler (عشان السيرفر ميعملش Crash) ──────
app.use((err, _req, res, _next) => {
  console.error(err.stack);
  res.status(err.status || 500).json({ 
    success: false, 
    message: err.message || "Internal server error" 
  });
});

// ── MongoDB Connection & Server Start ────────────────────

// استخدمنا البيانات اللي في الـ env بتاعك يدوي هنا عشان نحل مشكلة الـ undefined
const MONGO_URI = "mongodb://localhost:27017/fitapp"; 
const PORT = 5000;

mongoose
  .connect(MONGO_URI)
  .then(() => {
    console.log("✅ MongoDB Connected Successfully to: fitapp");
    app.listen(PORT, () => {
      console.log(`🚀 TrainVerse Server running on http://localhost:${PORT}`);
      console.log(`📡 Health Check: http://localhost:${PORT}/health`);
    });
  })
  .catch((err) => {
    console.error("❌ MongoDB connection error:", err.message);
    process.exit(1); // إيقاف التشغيل لو فشل الاتصال
  });

module.exports = app; // مهم لبعض أنواع الاختبارات