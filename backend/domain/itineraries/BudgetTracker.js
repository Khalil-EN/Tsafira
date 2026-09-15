class BudgetTracker {
  constructor(allocation) {
    this.allocation = allocation;

    this.spent = {
      accommodation: 0,
      breakfast: 0,
      lunch: 0,
      dinner: 0,
      activities: 0,
      transport: 0,
    };
  }

  add(category, amount) {
    if (!(category in this.spent)) {
      throw new Error(
        `Unknown budget category: ${category}`
      );
    }

    const value = Number(amount);

    if (!Number.isFinite(value) || value < 0) {
      return;
    }

    this.spent[category] += value;
  }

  get foodSpent() {
    return (
      this.spent.breakfast +
      this.spent.lunch +
      this.spent.dinner
    );
  }

  get totalSpent() {
    return (
      this.spent.accommodation +
      this.foodSpent +
      this.spent.activities +
      this.spent.transport
    );
  }

  get remaining() {
    return this.allocation.total - this.totalSpent;
  }

  get withinBudget() {
    return this.totalSpent <= this.allocation.total + 0.01;
  }

  getSummary() {
    return {
      total: this.allocation.total,

      allocated: {
        accommodation: this.allocation.accommodation,
        food: this.allocation.food,
        activities: this.allocation.activities,
        transport: this.allocation.transport,
      },

      spent: {
        ...this.spent,
        food: this.foodSpent,
      },

      remaining: this.remaining,
      estimatedTotal: this.totalSpent,
      withinBudget: this.withinBudget,
    };
  }
}

module.exports = BudgetTracker;