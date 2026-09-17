const OLLAMA_URL =
  process.env.OLLAMA_URL ||
  "http://localhost:11434";

const CHAT_MODEL =
  process.env.AI_CHAT_MODEL ||
  "qwen2.5:3b";

const EMBEDDING_MODEL =
  process.env.AI_EMBEDDING_MODEL ||
  "qwen3-embedding:0.6b";


const OllamaService = {

  async embed(text) {

    const response =
      await fetch(
        `${OLLAMA_URL}/api/embed`,
        {
          method: "POST",

          headers: {
            "Content-Type":
              "application/json",
          },

          body: JSON.stringify({
            model: EMBEDDING_MODEL,
            input: text,
          }),
        }
      );


    if (!response.ok) {

      const error =
        await response.text();

      throw new Error(
        `Ollama embedding error: ${error}`
      );
    }


    const data =
      await response.json();


    if (
      !data.embeddings ||
      !data.embeddings[0]
    ) {

      throw new Error(
        "Ollama returned no embedding."
      );
    }


    return data.embeddings[0];
  },


 async chat({
    system,
    messages,
    model,
    options,
    format,
  }) {

    const selectedModel =
      model || CHAT_MODEL;


    const response =
      await fetch(
        `${OLLAMA_URL}/api/chat`,
        {
          method: "POST",

          headers: {
            "Content-Type": "application/json",
          },

          body: JSON.stringify({

            model:
              selectedModel,

            messages: [
              {
                role: "system",
                content: system,
              },

              ...messages,
            ],

            stream: false,

            options:
              options || {
                temperature: 0.2,
              },

            ...(format
              ? { format }
              : {}),

          }),
        }
      );


    if (!response.ok) {

      const error =
        await response.text();

      throw new Error(
        `Ollama chat error: ${error}`
      );
    }


    const data =
      await response.json();


    return (
      data.message?.content ||
      ""
    ).trim();
  }
};


module.exports =
  OllamaService;