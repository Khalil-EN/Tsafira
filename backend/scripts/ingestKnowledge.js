require("dotenv").config();

const fs =
  require("fs/promises");

const path =
  require("path");

const mongoose =
  require("mongoose");

const KnowledgeChunk =
  require(
    "../schemas/knowledgeChunkSchema"
  );

const OllamaService =
  require(
    "../services/ai/OllamaService"
  );


const KNOWLEDGE_DIRECTORY =
  path.join(
    __dirname,
    "../knowledge"
  );


function chunkText(
  text,
  maxCharacters = 1200
) {

  const paragraphs =
    text
      .split(/\n\s*\n/)
      .map(
        paragraph =>
          paragraph.trim()
      )
      .filter(Boolean);

  const chunks = [];

  let current = "";

  for (
    const paragraph
    of paragraphs
  ) {

    if (
      (
        current.length +
        paragraph.length +
        2
      ) <= maxCharacters
    ) {

      current +=
        current
          ? `\n\n${paragraph}`
          : paragraph;

    } else {

      if (current) {
        chunks.push(current);
      }

      current = paragraph;
    }
  }

  if (current) {
    chunks.push(current);
  }

  return chunks;
}


async function main() {

  if (
    !process.env.MONGO_URI
  ) {
    throw new Error(
      "MONGO_URI is missing."
    );
  }

  await mongoose.connect(
    process.env.MONGO_URI
  );

  console.log(
    "Connected to MongoDB."
  );

  await KnowledgeChunk.deleteMany({});

  const files =
    await fs.readdir(
      KNOWLEDGE_DIRECTORY
    );

  const markdownFiles =
    files.filter(
      file =>
        file.endsWith(".md") ||
        file.endsWith(".txt")
    );

  let totalChunks = 0;

  for (
    const file
    of markdownFiles
  ) {

    const filePath =
      path.join(
        KNOWLEDGE_DIRECTORY,
        file
      );

    const text =
      await fs.readFile(
        filePath,
        "utf8"
      );

    const chunks =
      chunkText(text);

    console.log(
      `Processing ${file}: ${chunks.length} chunks`
    );

    for (
      let index = 0;
      index < chunks.length;
      index++
    ) {

      const content =
        chunks[index];

      console.log(
        `Embedding ${file} chunk ${index + 1}/${chunks.length}`
      );

      const embedding =
        await OllamaService.embed(
          content
        );

      await KnowledgeChunk.create({
        source: file,

        title:
          file
            .replace(
              /\.(md|txt)$/,
              ""
            ),

        content,

        embedding,

        chunkIndex: index,
      });
    }

    totalChunks +=
      chunks.length;
  }

  console.log(
    `Finished. ${totalChunks} chunks stored.`
  );

  await mongoose.disconnect();
}


main()
  .catch(error => {

    console.error(
      "Knowledge ingestion failed:",
      error
    );

    process.exit(1);
  });