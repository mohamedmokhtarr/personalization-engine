module.exports = {
    calculateFoodIntake: (food, grams) => {
        const factor = grams / 100;
        return {
            calories: parseFloat((parseFloat(food.Calories) * factor).toFixed(2)),
            protein: parseFloat((parseFloat(food.Protein) * factor).toFixed(2)),
            carbs: parseFloat((parseFloat(food.Carbs) * factor).toFixed(2)),
            fat: parseFloat((parseFloat(food.Fat) * factor).toFixed(2))
        };
    },
    getMealCategory: (hour) => {
        if (hour >= 5 && hour < 11) return "breakfast";
        if (hour >= 11 && hour < 17) return "lunch";
        if (hour >= 17 && hour < 23) return "dinner";
        return "snacks";
    }
};module.exports = {
    calculateFoodIntake: (food, grams) => {
        const factor = grams / 100;
        return {
            calories: parseFloat((parseFloat(food.Calories) * factor).toFixed(2)),
            protein: parseFloat((parseFloat(food.Protein) * factor).toFixed(2)),
            carbs: parseFloat((parseFloat(food.Carbs) * factor).toFixed(2)),
            fat: parseFloat((parseFloat(food.Fat) * factor).toFixed(2))
        };
    },
    getMealCategory: (hour) => {
        if (hour >= 5 && hour < 11) return "breakfast";
        if (hour >= 11 && hour < 17) return "lunch";
        if (hour >= 17 && hour < 23) return "dinner";
        return "snacks";
    }
};