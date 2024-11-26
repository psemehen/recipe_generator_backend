module Recipes
  class Generator
    URL = "https://api.groq.com/openai/v1/chat/completions".freeze
    MODEL = "mixtral-8x7b-32768".freeze
    MAX_TOKENS = 1000.freeze

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
      "recipe:#{@ingredients.sort.join(',')}"
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
          content: "Generate a recipe using these ingredients: #{@ingredients.join(', ')}"
        }
      ]
    end

def system_message
  <<~MSG
    You are a professional chef creating recipes. Follow this structure strictly:
    Dish Name: [Provide a name for the dish that could be cooked based on provided ingredients]
    Preparation Time: [Specify total time including prep and cooking]
    Instructions:
    [Provide numbered, detailed step-by-step instructions]
    Possible Ingredient Substitutions:
    [Suggest substitutions for key ingredients]
    Serving Suggestions:
    [Provide serving suggestions]

    Ensure the recipe is easy to follow and suitable for all skill levels. Use correct English spelling and
    culinary terms. Only the Instructions should be in a numbered list format.
  MSG
end
  end
end
