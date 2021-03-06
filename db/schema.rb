ActiveRecord::Schema.define(version: 20161016080826) do
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "name"
  end

  create_table "images", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "product_id"
    t.string   "data"
    t.string   "url"
    t.index ["product_id"], name: "index_images_on_product_id", using: :btree
  end

  create_table "order_items", force: :cascade do |t|
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "product_id"
    t.integer  "order_id"
    t.integer  "quantity",   default: 1, null: false
    t.integer  "price"
    t.index ["order_id"], name: "index_order_items_on_order_id", using: :btree
    t.index ["product_id"], name: "index_order_items_on_product_id", using: :btree
  end

  create_table "orders", force: :cascade do |t|
    t.integer  "total",               default: 0
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.integer  "user_id"
    t.string   "cancellation_reason"
    t.string   "state",               default: "confirmed", null: false
    t.integer  "promotion_id"
    t.index ["promotion_id"], name: "index_orders_on_promotion_id", using: :btree
    t.index ["user_id"], name: "index_orders_on_user_id", using: :btree
  end

  create_table "products", force: :cascade do |t|
    t.string   "name"
    t.integer  "price"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "category_id"
    t.boolean  "in_stock",       default: true
    t.integer  "stock_quantity", default: 0,    null: false
    t.index ["category_id"], name: "index_products_on_category_id", using: :btree
  end

  create_table "promotions", force: :cascade do |t|
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "category_id"
    t.integer  "product_id"
    t.string   "name"
    t.string   "code"
    t.string   "promotion_type"
    t.integer  "discount"
    t.index ["category_id"], name: "index_promotions_on_category_id", using: :btree
    t.index ["product_id"], name: "index_promotions_on_product_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "name",         null: false
    t.string   "email",        null: false
    t.string   "user_type"
    t.string   "access_token"
  end

  add_foreign_key "images", "products"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "orders", "promotions"
  add_foreign_key "orders", "users"
  add_foreign_key "products", "categories"
  add_foreign_key "promotions", "categories"
  add_foreign_key "promotions", "products"
end
