const PlanDTO = require('./dto/PlanDTO');

const PlanAssembler = {
  toDTO(plan) {
    return PlanDTO(plan);
  },

  toDTOList(plans) {
    return plans.map(plan =>
      PlanAssembler.toDTO(plan)
    );
  },
};

module.exports = PlanAssembler;