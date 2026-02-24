# FitApp — Personalization & Goal Engine

## Stack
- **Backend**: Node.js + Express.js + MongoDB (Mongoose)
- **Frontend**: Flutter (Dart)

---

## Quick Start — Backend

```bash
cd fitapp-backend
npm install
cp .env.example .env          # edit MONGODB_URI
npm run dev                   # starts on http://localhost:3000

# Seed workout library (run once)
curl -X POST http://localhost:3000/api/workouts/seed
```

---

## API Reference

### Health Profile  `POST /api/profile`
```json
{
  "userId": "user_001",
  "weight": 80,
  "height": 178,
  "age": 25,
  "gender": "male",
  "activityLevel": "moderate",
  "injury": "none"
}
```
**Response** includes computed `bmi`, `bmr`, `tdee`, `bmiCategory`.

---

### Get Profile  `GET /api/profile/:userId`

---

### Set Goal  `POST /api/goals`
```json
{
  "userId": "user_001",
  "goalType": "gain",
  "manualCaloricAdjustment": 0
}
```
| goalType  | calAdj | Description         |
|-----------|--------|---------------------|
| `lose`    | -500   | Weight loss         |
| `gain`    | +400   | Muscle building     |
| `recomp`  | 0      | Body recomposition  |
| `maintain`| 0      | Maintenance         |

**Response** includes computed macros (protein/carbs/fat in grams + %).

---

### Smart Adjust Goal  `PATCH /api/goals/:goalId/adjust`
```json
{ "delta": 150 }   // or -150 to reduce
```
Tweaks the caloric target without creating a new goal. Recalculates macros automatically.

---

### Get Active Goal  `GET /api/goals/active/:userId`

---

### Get Workouts (injury-aware)  `GET /api/workouts`
```
?injury=knee&intensity=medium&equipment=gym
```
| Query       | Values                                    |
|-------------|-------------------------------------------|
| `injury`    | none, knee, shoulder, back, wrist, ankle  |
| `intensity` | low, medium, high                         |
| `equipment` | gym, home, pool, any                      |
| `muscle`    | chest, back, legs, arms, core, cardio...  |

---

### Generate Daily Plan  `POST /api/plan/generate`
```json
{
  "userId": "user_001",
  "date": "2026-02-23"
}
```
Auto-generates:
- 5 meal slots with calories/macros/foods based on goal type
- Workout selection filtered by injury + intensity
- Calorie burn estimate (MET formula)
- Idempotent — same user+date always returns same plan

---

### Get Plan  `GET /api/plan/:userId/:date`

---

## Flutter Setup

```bash
cd fitapp-flutter
# Download Cairo font and place in assets/fonts/
flutter pub get
flutter run
```

Change `baseUrl` in `lib/services/api_service.dart`:
- Android emulator: `http://10.0.2.2:3000/api`
- iOS simulator: `http://localhost:3000/api`
- Physical device: `http://<YOUR_PC_IP>:3000/api`

---

## Project Structure

```
fitapp-backend/
├── src/
│   ├── index.js                    # Express entry
│   ├── models/
│   │   ├── UserProfile.model.js    # BMI/BMR auto-compute
│   │   ├── Goal.model.js           # Target cals + macros
│   │   ├── Workout.model.js        # Exercise library
│   │   └── DailyPlan.model.js      # Full day schedule
│   ├── controllers/
│   │   ├── profile.controller.js
│   │   ├── goal.controller.js      # Smart adjustment logic
│   │   ├── workout.controller.js   # Injury-aware filtering
│   │   └── plan.controller.js      # Plan generation engine
│   ├── routes/
│   └── middleware/validate.js

fitapp-flutter/
├── lib/
│   ├── main.dart                   # App shell + nav
│   ├── services/api_service.dart   # All HTTP calls
│   ├── models/models.dart          # Profile, Goal, Workout, Plan
│   ├── screens/
│   │   ├── profile_screen.dart     # BMI/BMR + sliders
│   │   ├── goal_screen.dart        # Goal picker + smart adjust
│   │   ├── workout_screen.dart     # Injury-aware list
│   │   └── plan_screen.dart        # Timeline day view
│   └── widgets/
│       └── stat_card.dart
```
