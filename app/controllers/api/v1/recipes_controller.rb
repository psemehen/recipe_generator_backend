class Api::V1::RecipesController < ApplicationController
  def create
    ingredients = validate_ingredients
    create_recipe(ingredients) if ingredients
  end

  private

  def validate_ingredients
    form = RecipeIngredientsForm.new(ingredients: recipe_params[:ingredients])

    begin
      form.validate!
      form.ingredients
    rescue ArgumentError => e
      json_error(e.message, :bad_request)
      nil
    end
  end

  def create_recipe(ingredients)
    recipe = Recipes::Generator.new(ingredients).call
    render json: { recipe: recipe }, status: :created
  end

  def recipe_params
    params.require(:recipe).permit(ingredients: [])
  end
end
