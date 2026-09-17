const OllamaService =
  require("./OllamaService");


const CLASSIFIER_MODEL =
  process.env.AI_CLASSIFIER_MODEL ||
  "qwen2.5:3b";


const CLASSIFICATION_SCHEMA = {
  type: "object",

  properties: {
    category: {
      type: "string",

      enum: [
        "APP",
        "TRAVEL",
        "UNRELATED",
      ],
    },
  },

  required: [
    "category",
  ],

  additionalProperties: false,
};


const RELEVANCE_PROMPT = `
Classify the user's request.

You MUST choose exactly one:

APP
TRAVEL
UNRELATED


DECISION RULE:

STEP 1:
Is the user asking about the Tsafira application?

The request should concern using or understanding Tsafira.

Examples:
- create a community
- delete my account
- create a post
- send a friend request
- see notifications
- use messaging
- use the trip planner

If YES -> APP.

IMPORTANT:

A request mentioning travel, hotels, restaurants,
booking, or tourism is NOT automatically APP.

For example:

"Write Python code for a hotel booking system."
-> UNRELATED

"Write code for a travel itinerary generator."
-> UNRELATED

"How do I build a restaurant reservation system?"
-> UNRELATED

These are programming/software requests, but they are
not specifically about Tsafira.


STEP 2:
If NOT APP, is the user asking about REAL-WORLD TRAVEL?

Examples:
- places to visit
- things to do
- restaurants to try
- hotels
- destinations
- tourism
- transportation between cities
- travel itineraries
- travel budgets
- traditional food to try while traveling
- best time to visit a country

If YES -> TRAVEL.


STEP 3:
If it is neither about Tsafira nor real-world travel:

-> UNRELATED.




The task is classification only.

Do not answer the user's question.

Return only the JSON object required by the output schema.
`;


const AIRelevanceService = {

  async classify(content) {

    if (
      !content ||
      !content.trim()
    ) {
      return "UNRELATED";
    }


    try {

      const response =
        await OllamaService.chat({

          model:
            CLASSIFIER_MODEL,

          system:
            RELEVANCE_PROMPT,

          messages: [
            {
              role: "user",

              content:
                content.trim(),
            },
          ],

          options: {
            temperature: 0,
          },

          format:
            CLASSIFICATION_SCHEMA,

        });


      console.log(
        `[CLASSIFIER RAW] ${response}`
      );


      const parsed =
        JSON.parse(response);


      const category =
        parsed.category;


      if (
        category === "APP" ||
        category === "TRAVEL" ||
        category === "UNRELATED"
      ) {

        return category;
      }


      console.warn(
        `[AI] Invalid classifier category: ${category}`
      );


      return "UNRELATED";

    } catch (error) {

      console.error(
        "[AI] Relevance classification failed:",
        error
      );


      return "UNRELATED";
    }
  },


  async isRelevant(content) {

    const category =
      await this.classify(
        content
      );


    return (
      category === "APP" ||
      category === "TRAVEL"
    );
  },
};


module.exports =
  AIRelevanceService;