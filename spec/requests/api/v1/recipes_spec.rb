require 'rails_helper'

RSpec.describe "Api::V1::Recipes", type: :request do
  describe 'POST /api/v1/recipes' do
    let(:ingredients) { ['chicken', 'rice', 'vegetables'] }
    let(:recipe_params) { { recipe: { ingredients: ingredients } } }
    let(:generated_recipe) { { name: 'Chicken Stir Fry', instructions: 'Cook chicken and vegetables with rice.' } }

    subject { post "/api/v1/recipes", params: recipe_params }

    context 'with valid ingredients' do
      before do
        allow_any_instance_of(RecipeIngredientsForm).to receive(:validate!).and_return(true)
        allow_any_instance_of(Recipes::Generator).to receive(:call).and_return(generated_recipe)
      end

      it 'returns a successful response' do
        subject
        expect(response).to have_http_status(:created)
      end

      it 'returns the generated recipe' do
        subject
        parsed_response = JSON.parse(response.body)['recipe']
        expect(parsed_response['name']).to eq(generated_recipe[:name])
        expect(parsed_response['instructions']).to eq(generated_recipe[:instructions])
      end

      it 'calls the recipe generator with the correct ingredients' do
        expect(Recipes::Generator).to receive(:new).with(ingredients).and_call_original
        subject
      end
    end

    context 'with invalid ingredients' do
      before do
        allow_any_instance_of(RecipeIngredientsForm).to receive(:validate!).and_raise(ArgumentError, 'Invalid ingredients')
      end

      it 'returns a bad request status' do
        subject
        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
