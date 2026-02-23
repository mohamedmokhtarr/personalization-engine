const router = require("express").Router();
const ctrl = require("../controllers/workout.controller");

router.post("/seed", ctrl.seedWorkouts);
router.get("/",      ctrl.getWorkouts);
router.get("/:id",   ctrl.getWorkoutById);

module.exports = router;
