class RecipeIngredientsForm
  include ActiveModel::Model

  attr_accessor :ingredients

  validates :ingredients, presence: true
  validate :ingredients_must_be_an_array

  def initialize(attributes = {})
    super()
    @ingredients = attributes[:ingredients]
  end

  private

  def ingredients_must_be_an_array
    errors.add(:ingredients, "must be an array") unless @ingredients.is_a?(Array)
  end
end
