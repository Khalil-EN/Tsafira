const mongoose = require("mongoose");

const knowledgeChunkSchema =
  new mongoose.Schema(
    {
      source: {
        type: String,
        required: true,
      },

      title: {
        type: String,
        default: "",
      },

      content: {
        type: String,
        required: true,
      },

      embedding: {
        type: [Number],
        required: true,
      },

      chunkIndex: {
        type: Number,
        required: true,
      },
    },

    {
      timestamps: true,
    }
  );

knowledgeChunkSchema.index({
  source: 1,
});

module.exports =
  mongoose.model(
    "KnowledgeChunk",
    knowledgeChunkSchema
);