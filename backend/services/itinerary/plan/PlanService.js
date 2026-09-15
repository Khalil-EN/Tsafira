const PlanDAO = require('../../../dao/planDAO');
const PlanFactory = require('../../../domain/itineraries/plans/planFactory');
const PlanAssembler = require('./PlanAssembler');

const PlanService = {

  // ============================================================
  // API / PERSISTENCE OPERATIONS
  // ============================================================

  async createPlan(input) {
    let data = { ...input };

    // Automatically determine the next day number.
    if (!data.dayNumber && data.itineraryId) {
      const existing = await PlanDAO.getByItineraryId(
        data.itineraryId
      );

      data.dayNumber = existing.length + 1;
    }

    // Raw input -> domain object
    const plan = PlanFactory.create(data);

    // Domain object -> persistence representation
    const saved = await PlanDAO.create(plan.toJSON());

    // Reconstruct domain object from persisted data
    const persistedPlan = PlanFactory.create(saved);

    // Domain object -> API DTO
    return PlanAssembler.toDTO(persistedPlan);
  },

  async getPlanById(planId) {
    const raw = await PlanDAO.getById(planId);

    if (!raw) {
      return null;
    }

    const plan = PlanFactory.create(raw);

    return PlanAssembler.toDTO(plan);
  },

  async getPlansByItinerary(itineraryId) {
    const rawPlans = await PlanDAO.getByItineraryId(
      itineraryId
    );

    const plans = rawPlans.map(raw =>
      PlanFactory.create(raw)
    );

    return PlanAssembler.toDTOList(plans);
  },

  async updatePlan(planId, updates) {
    const existing = await PlanService._getPlanDomainById(planId);

    if (!existing) {
      return null;
    }

    if (updates.note !== undefined) {
      existing.setNote(updates.note);
    }

    const saved = await PlanDAO.update(
      planId,
      existing.toJSON()
    );

    if (!saved) {
      return null;
    }

    const updatedPlan = PlanFactory.create(saved);

    return PlanAssembler.toDTO(updatedPlan);
  },

  async deletePlan(planId) {
    return await PlanDAO.delete(planId);
  },

  // ============================================================
  // INTERNAL DOMAIN OPERATIONS
  // ============================================================

  async _getPlanDomainById(planId) {
    const raw = await PlanDAO.getById(planId);

    if (!raw) {
      return null;
    }

    return PlanFactory.create(raw);
  },
};

module.exports = PlanService;