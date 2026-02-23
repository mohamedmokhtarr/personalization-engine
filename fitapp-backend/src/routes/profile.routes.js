const router = require("express").Router();
const { body, param } = require("express-validator");
const ctrl = require("../controllers/profile.controller");
const validate = require("../middleware/validate");

router.post(
  "/",
  [
    body("userId").notEmpty().withMessage("userId required"),
    body("weight").isFloat({ min: 20, max: 300 }),
    body("height").isFloat({ min: 100, max: 250 }),
    body("age").isInt({ min: 5, max: 120 }),
    body("gender").isIn(["male", "female"]),
    body("activityLevel").isIn(["sedentary", "light", "moderate", "active", "extreme"]),
    body("injury").optional().isIn(["none", "knee", "shoulder", "back", "wrist", "ankle"]),
  ],
  validate,
  ctrl.upsertProfile
);

router.get("/:userId", param("userId").notEmpty(), validate, ctrl.getProfile);
router.delete("/:userId", ctrl.deleteProfile);

module.exports = router;
