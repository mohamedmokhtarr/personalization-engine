const express = require("express");
const router = express.Router();
const { saveProgress } = require("../controllers/progressController");

router.post("/save", saveProgress);

module.exports = router;