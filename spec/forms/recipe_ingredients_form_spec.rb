require 'rails_helper'

RSpec.describe RecipeIngredientsForm do
  describe 'validations' do
    subject(:form) { described_class.new(ingredients: ingredients) }

    context 'when ingredients are present and valid' do
      let(:ingredients) { ['flour', 'sugar', 'eggs'] }

      it 'is valid' do
        expect(form).to be_valid
      end
    end

    context 'when ingredients are nil' do
      let(:ingredients) { nil }

      it 'is invalid' do
        expect(form).to be_invalid
        expect(form.errors[:ingredients]).to include("can't be blank")
      end
    end

    context 'when ingredients are not an array' do
      let(:ingredients) { 'flour, sugar, eggs' }

      it 'is invalid' do
        expect(form).to be_invalid
        expect(form.errors[:ingredients]).to include('must be an array')
      end
    end

    context 'when ingredients are an empty array' do
      let(:ingredients) { [] }

      it 'is invalid' do
        expect(form).to be_invalid
        expect(form.errors[:ingredients]).to include("can't be blank")
      end
    end
  end
end
