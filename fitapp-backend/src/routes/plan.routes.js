const router = require("express").Router();
const { body } = require("express-validator");
const ctrl = require("../controllers/plan.controller");
const validate = require("../middleware/validate");

router.post(
  "/generate",
  [
    body("userId").notEmpty(),
    body("date").optional().isDate(),
  ],
  validate,
  ctrl.generatePlan
);

router.get("/history/:userId",  ctrl.getPlanHistory);
router.get("/:userId/:date",    ctrl.getPlan);

module.exports = router;
