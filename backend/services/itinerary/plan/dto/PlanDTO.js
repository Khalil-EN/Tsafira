function PlanDTO(plan) {
  if (!plan) return null;

  return {
    id: plan.id,
    itineraryId: plan.itineraryId,

    title: plan.title,
    description: plan.description,

    date: plan.date,
    dayNumber: plan.dayNumber,

    activities: plan.activities ?? [],
    restaurants: plan.restaurants ?? [],

    note: plan.note ?? '',

    createdAt: plan.createdAt,
  };
}

module.exports = PlanDTO;