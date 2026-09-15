const KnowledgeChunkDAO =
  require("../../dao/knowledgeChunkDAO");

const OllamaService =
  require("./OllamaService");


function cosineSimilarity(
  vectorA,
  vectorB
) {
  if (
    !Array.isArray(vectorA) ||
    !Array.isArray(vectorB)
  ) {
    return 0;
  }

  if (
    vectorA.length !==
    vectorB.length
  ) {
    return 0;
  }

  let dot = 0;
  let magnitudeA = 0;
  let magnitudeB = 0;

  for (
    let i = 0;
    i < vectorA.length;
    i++
  ) {
    dot +=
      vectorA[i] *
      vectorB[i];

    magnitudeA +=
      vectorA[i] *
      vectorA[i];

    magnitudeB +=
      vectorB[i] *
      vectorB[i];
  }

  if (
    magnitudeA === 0 ||
    magnitudeB === 0
  ) {
    return 0;
  }

  return (
    dot /
    (
      Math.sqrt(magnitudeA) *
      Math.sqrt(magnitudeB)
    )
  );
}


const RAGService = {

  async search(
    query,
    topK = 5
  ) {

    const queryEmbedding =
      await OllamaService.embed(
        query
      );

    const chunks =
      await KnowledgeChunkDAO.getAll();

    const results =
      chunks
        .map(chunk => ({
          ...chunk,

          score:
            cosineSimilarity(
              queryEmbedding,
              chunk.embedding
            ),
        }))
        .sort(
          (a, b) =>
            b.score - a.score
        )
        .slice(0, topK);

    return results;
  },


  async buildContext(
    query,
    topK = 5
  ) {

    const results =
      await this.search(
        query,
        topK
      );

    return results
      .map(
        (result, index) => {
          return [
            `SOURCE ${index + 1}`,
            `Title: ${result.title}`,
            `Content: ${result.content}`,
          ].join("\n");
        }
      )
      .join("\n\n");
  },
};


module.exports =
  RAGService;