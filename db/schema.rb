# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_10_25_210951) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "images", force: :cascade do |t|
    t.string "filename"
    t.integer "render_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["render_id"], name: "index_images_on_render_id"
  end

  create_table "loras", force: :cascade do |t|
    t.text "name"
    t.text "url_src"
    t.text "trigger"
    t.integer "model_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "platform"
    t.index ["model_id"], name: "index_loras_on_model_id"
  end

  create_table "models", force: :cascade do |t|
    t.text "name"
    t.text "url_src"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "platform"
  end

  create_table "render_loras", force: :cascade do |t|
    t.integer "render_id", null: false
    t.integer "lora_id", null: false
    t.float "scale"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lora_id"], name: "index_render_loras_on_lora_id"
    t.index ["render_id"], name: "index_render_loras_on_render_id"
  end

  create_table "renders", force: :cascade do |t|
    t.string "render_type"
    t.float "guidance_scale"
    t.integer "model_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "prompt"
    t.index ["model_id"], name: "index_renders_on_model_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "images", "renders"
  add_foreign_key "loras", "models"
  add_foreign_key "render_loras", "loras"
  add_foreign_key "render_loras", "renders"
  add_foreign_key "renders", "models"
end
