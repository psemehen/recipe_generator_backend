require "rails_helper"

RSpec.describe Recipes::Generator do
  let(:ingredients) { ["chicken", "rice", "vegetables"] }
  let(:redis_instance) { instance_double(Redis) }
  let(:generator) { described_class.new(ingredients) }

  before do
    allow(Redis).to receive(:new).and_return(redis_instance)
  end

  describe "#initialize" do
    it "sets the ingredients" do
      expect(generator.instance_variable_get(:@ingredients)).to eq(ingredients)
    end
  end

  describe "#call" do
    context "when recipe is cached" do
      let(:cached_recipe) { {"name" => "Chicken Stir Fry", "instructions" => "Cook everything."}.to_json }

      before do
        allow(redis_instance).to receive(:get).and_return(cached_recipe)
      end

      it "returns the cached recipe" do
        expect(generator.call).to eq(JSON.parse(cached_recipe))
      end

      it "does not generate a new recipe" do
        expect(generator).not_to receive(:generate_recipe)
        generator.call
      end
    end

    context "when recipe is not cached" do
      let(:generated_recipe) { {"name" => "New Chicken Dish", "instructions" => "Cook it well."} }

      before do
        allow(redis_instance).to receive(:get).and_return(nil)
        allow(redis_instance).to receive(:set)
        allow(generator).to receive(:generate_recipe).and_return(generated_recipe)
      end

      it "generates a new recipe" do
        expect(generator.call).to eq(generated_recipe)
      end

      it "caches the generated recipe" do
        generator.call
        expect(redis_instance).to have_received(:set).with(
          "recipe:#{ingredients.sort.join(",")}",
          generated_recipe.to_json
        )
      end
    end
  end

  describe "#generate_recipe" do
    let(:api_response) do
      {
        "choices" => [
          {
            "message" => {
              "content" => "Generated recipe content"
            }
          }
        ]
      }.to_json
    end

    before do
      stub_request(:post, Recipes::Generator::URL)
        .to_return(status: 200, body: api_response, headers: {"Content-Type" => "application/json"})
    end

    it "calls the Groq API" do
      generator.send(:generate_recipe)
      expect(WebMock).to have_requested(:post, Recipes::Generator::URL)
        .with(
          headers: {
            "Content-Type" => "application/json",
            "Authorization" => "Bearer #{Rails.application.credentials.groq.fetch(:api_key)}"
          }
        )
    end

    it "returns the parsed recipe content" do
      expect(generator.send(:generate_recipe)).to eq("Generated recipe content")
    end
  end
end
