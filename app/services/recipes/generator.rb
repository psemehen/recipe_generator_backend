module Recipes
  class Generator
    URL = "https://api.groq.com/openai/v1/chat/completions".freeze
    MODEL = "llama-3.2-90b-vision-preview".freeze
    MAX_TOKENS = 1000

    def initialize(ingredients)
      @ingredients = ingredients
      @redis = Redis.new(Rails.application.config_for(:redis))
    end

    def call
      cached_recipe = @redis.get(cache_key)
      return JSON.parse(cached_recipe) if cached_recipe

      recipe = generate_recipe
      @redis.set(cache_key, recipe.to_json)
      recipe
    end

    private

    def cache_key
      "recipe:#{@ingredients.sort.join(",")}"
    end

    def generate_recipe
      response = HTTParty.post(
        URL,
        headers: headers,
        body: request_body.to_json
      )

      parsed_response(response.body)
    end

    def parsed_response(response)
      JSON.parse(response)["choices"][0]["message"]["content"]
    end

    def headers
      {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{Rails.application.credentials.groq.fetch(:api_key)}"
      }
    end

    def request_body
      {
        model: MODEL,
        messages: messages,
        max_tokens: MAX_TOKENS
      }
    end

    def messages
      [
        {
          role: "system",
          content: system_message
        },
        {
          role: "user",
          content: "Generate a recipe using ONLY these ingredients, without adding any others:
                    #{@ingredients.join(", ")}. The recipe must use all of these ingredients and should not include any
                    ingredients not listed here."
        }
      ]
    end

    def system_message
      <<~MSG
        You are a professional chef creating recipes. Follow this structure strictly, using exact headings and newlines as shown:

        Dish Name: [Provide a name for the dish that can be cooked using ONLY the provided ingredients.]
        Preparation Time: [Specify total time including prep and cooking.]
        Ingredients: [List ONLY the provided ingredients with quantities, one by one, separated by commas.]
        Instructions: [Provide clear instructions, detailed step-by-step instructions, one by one, separated with semi-colons, using ONLY the provided ingredients.]
        Possible Ingredient Substitutions: [Suggest substitutions for key ingredients, one by one, separated by commas, only if absolutely necessary.]
        Serving Suggestions: [Provide serving suggestions, one by one, separated by commas.]

        Ensure the recipe is easy to follow and suitable for all skill levels. Use correct English spelling and culinary terms. Maintain the exact format with newlines between sections as shown above. Do not include any additional text or explanations outside of these sections.
        Make sure to make it readable by adding dots after each full sentence/section. Most importantly, use ONLY the ingredients provided by the user, without adding any others.
      MSG
    end
  end
end
