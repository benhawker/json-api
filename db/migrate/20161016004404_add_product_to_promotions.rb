class AddProductToPromotions < ActiveRecord::Migration[5.0]
  def change
    add_reference :promotions, :product, index: true, foreign_key: true
  end
end
