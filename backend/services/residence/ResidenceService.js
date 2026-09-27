const residenceDAO = require('../../dao/residenceDAO');

const ResidenceAssembler = require('./ResidenceAssembler');

const ResidenceMapper = require('./ResidenceMapper');

const ResidenceService = {

    async createResidence(data) {

        const doc = await residenceDAO.create(data);

        return ResidenceAssembler.toDTO(doc);
    },


    async getResidenceById(id) {

        const doc = await residenceDAO.getById(id);

        return ResidenceAssembler.toDTO(doc);
    },


    async updateResidence(id, updates) {

        const doc = await residenceDAO.update(id,updates);

        return ResidenceAssembler.toDTO(doc);
    },


    async deleteResidence(id) {

        return await residenceDAO.delete(id);
    },

    async getResidencesForPlanning(filters = {}) {
        const docs = await residenceDAO.getAll(filters);

        const residences = ResidenceMapper.fromPersistenceList(docs);

        return residences;
    },

    async listResidences(filter = {}) {

        const docs = await residenceDAO.getAll(filter);

        return docs.map(ResidenceAssembler.toDTO);
    },


    async search(filters) {

        const docs = await residenceDAO.search(filters);

        return docs.map(ResidenceAssembler.toDTO);
    },

};

module.exports = ResidenceService;