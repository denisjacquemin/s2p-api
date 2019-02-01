# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_01_31_134559) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "school_id"
    t.string "payconiq_access_token"
    t.string "account_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "app_users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "authentication_token", limit: 30
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.index ["authentication_token"], name: "index_app_users_on_authentication_token", unique: true
    t.index ["confirmation_token"], name: "index_app_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_app_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_app_users_on_reset_password_token", unique: true
  end

  create_table "attachinary_files", id: :serial, force: :cascade do |t|
    t.string "attachinariable_type"
    t.integer "attachinariable_id"
    t.string "scope"
    t.string "public_id"
    t.string "version"
    t.integer "width"
    t.integer "height"
    t.string "format"
    t.string "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["attachinariable_type", "attachinariable_id", "scope"], name: "by_scoped_parent"
  end

  create_table "billed_students", id: :serial, force: :cascade do |t|
    t.integer "student_id"
    t.integer "message_id"
    t.string "communication"
    t.string "comment"
    t.integer "amount_to_pay_cents", default: 0
    t.string "amount_to_pay_currency"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "devices", id: :serial, force: :cascade do |t|
    t.string "token"
    t.string "codes", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true
    t.string "platform"
    t.string "uuid"
    t.string "registration_id"
    t.index ["uuid"], name: "index_devices_on_uuid", unique: true
  end

  create_table "email_recipients", id: :serial, force: :cascade do |t|
    t.string "email"
    t.integer "student_id"
    t.integer "message_id"
    t.string "status"
    t.string "dateandtime"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "form_templates", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "school_id"
    t.json "formdata"
    t.integer "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "forms", id: :serial, force: :cascade do |t|
    t.uuid "muuid"
    t.json "formdata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "duuid"
    t.index ["duuid"], name: "index_forms_on_duuid"
    t.index ["muuid"], name: "index_forms_on_muuid"
  end

  create_table "groups", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "school_id"
    t.string "code"
    t.boolean "updatable", default: true
    t.string "internal_id"
    t.string "group_type", default: ""
    t.index ["code"], name: "index_groups_on_code", unique: true
    t.index ["school_id", "name"], name: "index_groups_on_school_id_and_name", unique: true
  end

  create_table "groups_users", id: false, force: :cascade do |t|
    t.integer "group_id"
    t.integer "user_id"
    t.index ["group_id"], name: "index_groups_users_on_group_id"
    t.index ["user_id"], name: "index_groups_users_on_user_id"
  end

  create_table "message_categories", id: :serial, force: :cascade do |t|
    t.integer "school_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "message_categories_messages", id: false, force: :cascade do |t|
    t.integer "message_id", null: false
    t.integer "message_category_id", null: false
  end

  create_table "message_categories_students", id: false, force: :cascade do |t|
    t.integer "student_id", null: false
    t.integer "message_category_id", null: false
  end

  create_table "messages", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.integer "school_id"
    t.integer "groups", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status"
    t.integer "author_id"
    t.string "when"
    t.integer "mtype"
    t.boolean "send_by_email", default: true
    t.boolean "send_to_app", default: true
    t.integer "students", default: [], array: true
    t.boolean "skip_send_by_email", default: false
    t.json "attachments"
    t.json "formdata"
    t.uuid "muuid"
    t.boolean "wfa_sms_sent", default: false
    t.boolean "aa_sms_sent", default: false
    t.boolean "ar_sms_sent", default: false
    t.boolean "send_by_sms", default: false
    t.integer "amount_to_pay_cents", default: 0, null: false
    t.string "amount_to_pay_currency", default: "EUR", null: false
    t.string "billing_description"
    t.integer "billing_type", default: 0
    t.integer "account_id"
    t.text "billing_comment"
    t.string "billing_due_date"
    t.boolean "include_payment", default: false
    t.datetime "form_due_date"
    t.boolean "has_form", default: false
    t.string "custom_author"
  end

  create_table "mfiles", id: :serial, force: :cascade do |t|
    t.string "filename"
    t.string "file_url"
    t.integer "school_id"
    t.integer "message_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payments", id: :serial, force: :cascade do |t|
    t.integer "school_id"
    t.uuid "uuid"
    t.integer "status"
    t.integer "price_cents_cents", default: 0, null: false
    t.string "price_cents_currency", default: "EUR", null: false
    t.integer "mode"
    t.string "pq_transaction_id"
    t.string "pq_status"
    t.string "pq_transaction_signature"
    t.string "pq_security_timestamp"
    t.string "pq_security_key"
    t.string "pq_security_algorithm"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "message_id"
    t.string "students_names"
    t.string "communication"
  end

  create_table "phones", id: :serial, force: :cascade do |t|
    t.string "owner_name"
    t.string "number"
    t.integer "student_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rpush_apps", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "environment"
    t.text "certificate"
    t.string "password"
    t.integer "connections", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type", null: false
    t.string "auth_key"
    t.string "client_id"
    t.string "client_secret"
    t.string "access_token"
    t.datetime "access_token_expiration"
    t.string "apn_key"
    t.string "apn_key_id"
    t.string "team_id"
    t.string "bundle_id"
  end

  create_table "rpush_feedback", id: :serial, force: :cascade do |t|
    t.string "device_token", limit: 64, null: false
    t.datetime "failed_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "app_id"
    t.index ["device_token"], name: "index_rpush_feedback_on_device_token"
  end

  create_table "rpush_notifications", id: :serial, force: :cascade do |t|
    t.integer "badge"
    t.string "device_token", limit: 64
    t.string "sound"
    t.text "alert"
    t.text "data"
    t.integer "expiry", default: 86400
    t.boolean "delivered", default: false, null: false
    t.datetime "delivered_at"
    t.boolean "failed", default: false, null: false
    t.datetime "failed_at"
    t.integer "error_code"
    t.text "error_description"
    t.datetime "deliver_after"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "alert_is_json", default: false, null: false
    t.string "type", null: false
    t.string "collapse_key"
    t.boolean "delay_while_idle", default: false, null: false
    t.text "registration_ids"
    t.integer "app_id", null: false
    t.integer "retries", default: 0
    t.string "uri"
    t.datetime "fail_after"
    t.boolean "processing", default: false, null: false
    t.integer "priority"
    t.text "url_args"
    t.string "category"
    t.boolean "content_available", default: false, null: false
    t.text "notification"
    t.boolean "mutable_content", default: false, null: false
    t.string "external_device_id"
    t.index ["delivered", "failed", "processing", "deliver_after", "created_at"], name: "index_rpush_notifications_multi", where: "((NOT delivered) AND (NOT failed))"
  end

  create_table "schools", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.string "phone"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "validation_workflow_active", default: true
    t.string "url"
    t.string "filename"
    t.string "file_url"
    t.text "send_code_template"
    t.string "send_code_title_template"
    t.integer "sms_provision", default: 0
    t.boolean "billing_enable", default: false
    t.boolean "payconiq_enable", default: false
    t.boolean "iscity", default: false
    t.boolean "allow_translation", default: false
  end

  create_table "student_emails", id: :serial, force: :cascade do |t|
    t.integer "student_id"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_student_emails_on_email"
    t.index ["student_id"], name: "index_student_emails_on_student_id"
  end

  create_table "student_recipients", id: :serial, force: :cascade do |t|
    t.integer "student_id"
    t.boolean "viewed_by_app", default: false
    t.boolean "viewed_by_email", default: false
    t.boolean "viewed_by_sms", default: false
    t.integer "message_id"
    t.integer "school_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "students", id: :serial, force: :cascade do |t|
    t.string "firstname"
    t.string "lastname"
    t.integer "groups", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "school_id"
    t.string "code"
    t.string "classroom"
    t.string "level"
    t.integer "followers", default: 0
    t.string "emails_old"
    t.boolean "sent_message_by_email", default: true
    t.uuid "uuid"
    t.string "winpage_matricule"
    t.string "proeco_id"
    t.string "siel_id"
    t.index ["code"], name: "index_students_on_code", unique: true
  end

  create_table "students_users", id: false, force: :cascade do |t|
    t.integer "student_id"
    t.integer "user_id"
    t.index ["student_id"], name: "index_students_users_on_student_id"
    t.index ["user_id"], name: "index_students_users_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role"
    t.string "firstname"
    t.string "lastname"
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.integer "invited_by_id"
    t.integer "invitations_count", default: 0
    t.datetime "deleted_at"
    t.integer "schools", default: [], array: true
    t.string "function"
    t.string "code"
    t.integer "groups", default: [], array: true
    t.string "algolia_search_api_key"
    t.integer "new_announcement_counter", default: 0
    t.string "phone"
    t.string "email_reply_to", default: ""
    t.boolean "display_email_address", default: true
    t.boolean "send_email_to_author", default: true
    t.boolean "send_email_to_admin", default: true
    t.boolean "send_notification_by_email", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
