const router = require("express").Router();
const { body, param } = require("express-validator");
const ctrl = require("../controllers/goal.controller");
const validate = require("../middleware/validate");

router.post(
  "/",
  [
    body("userId").notEmpty(),
    body("goalType").isIn(["lose", "gain", "recomp", "maintain"]),
    body("manualCaloricAdjustment").optional().isInt({ min: -500, max: 500 }),
  ],
  validate,
  ctrl.setGoal
);

router.patch(
  "/:goalId/adjust",
  [body("delta").isInt({ min: -500, max: 500 })],
  validate,
  ctrl.adjustGoal
);

router.get("/active/:userId",  ctrl.getActiveGoal);
router.get("/history/:userId", ctrl.getGoalHistory);

module.exports = router;
