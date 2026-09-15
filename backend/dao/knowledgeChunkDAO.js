const KnowledgeChunk =
  require("../schemas/knowledgeChunkSchema");

const KnowledgeChunkDAO = {

  async deleteAll() {
    return await KnowledgeChunk.deleteMany({});
  },


  async createMany(chunks) {
    return await KnowledgeChunk.insertMany(
      chunks
    );
  },


  async getAll() {
    return await KnowledgeChunk.find({})
      .lean();
  },


  async count() {
    return await KnowledgeChunk.countDocuments();
  },
};

module.exports =
  KnowledgeChunkDAO;