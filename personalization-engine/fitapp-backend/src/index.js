require("dotenv").config();
const express = require("express");
const cors = require("cors");
const mongoose = require("mongoose");

const profileRoutes  = require("./routes/profile.routes");
const goalRoutes     = require("./routes/goal.routes");
const workoutRoutes  = require("./routes/workout.routes");
const planRoutes     = require("./routes/plan.routes");

const app  = express();
const PORT = process.env.PORT || 3000;

// ── Middleware ────────────────────────────────────────────
app.use(cors());
app.use(express.json());

// ── Request logger (dev) ──────────────────────────────────
app.use((req, _res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
  next();
});

// ── Routes ────────────────────────────────────────────────
app.use("/api/profile",  profileRoutes);
app.use("/api/goals",    goalRoutes);
app.use("/api/workouts", workoutRoutes);
app.use("/api/plan",     planRoutes);

// ── Health check ──────────────────────────────────────────
app.get("/health", (_req, res) => res.json({ status: "ok", timestamp: new Date() }));

// ── 404 handler ───────────────────────────────────────────
app.use((_req, res) => res.status(404).json({ success: false, message: "Route not found" }));

// ── Global error handler ──────────────────────────────────
app.use((err, _req, res, _next) => {
  console.error(err.stack);
  res.status(err.status || 500).json({ success: false, message: err.message || "Internal server error" });
});

// ── MongoDB + Start ───────────────────────────────────────
mongoose
  .connect(process.env.MONGODB_URI)
  .then(() => {
    console.log("✅ MongoDB connected");
    app.listen(PORT, () => console.log(`🚀 Server running on http://localhost:${PORT}`));
  })
  .catch((err) => {
    console.error("❌ MongoDB connection error:", err.message);
    process.exit(1);
  });

module.exports = app;
