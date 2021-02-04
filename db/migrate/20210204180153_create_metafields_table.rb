class CreateMetafieldsTable < ActiveRecord::Migration[6.1]
  def change
    create_table :product_metafields do |t|
      t.bigint :product_id
      t.string :metafield_key
      t.string :metafield_value
    end
  end
end
