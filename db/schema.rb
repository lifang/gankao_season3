# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120830064911) do

  create_table "action_logs", :force => true do |t|
    t.integer  "user_id",     :null => false
    t.integer  "types"
    t.integer  "category_id"
    t.string   "remark"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "total_num"
  end

  add_index "action_logs", ["category_id"], :name => "index_action_logs_on_category_id"
  add_index "action_logs", ["types"], :name => "index_action_logs_on_type"
  add_index "action_logs", ["user_id"], :name => "index_action_logs_on_user_id"

  create_table "adverts", :force => true do |t|
    t.string   "content"
    t.integer  "region_id"
    t.datetime "created_at"
  end

  add_index "adverts", ["region_id"], :name => "index_adverts_on_region_id"

  create_table "buses", :force => true do |t|
    t.string   "num"
    t.datetime "created_at"
  end

  add_index "buses", ["num"], :name => "index_buses_on_num"

  create_table "categories", :force => true do |t|
    t.string   "name",                     :null => false
    t.integer  "parent_id", :default => 0, :null => false
    t.float    "price"
    t.datetime "next_time"
  end

  add_index "categories", ["name"], :name => "index_categories_on_name"
  add_index "categories", ["parent_id"], :name => "index_categories_on_parent_id"

  create_table "category_manages", :force => true do |t|
    t.integer  "category_id", :null => false
    t.integer  "user_id"
    t.datetime "created_at"
  end

  add_index "category_manages", ["category_id"], :name => "index_category_manages_on_category_id"
  add_index "category_manages", ["user_id"], :name => "index_category_manages_on_user_id"

  create_table "charts", :force => true do |t|
    t.integer  "types"
    t.string   "image_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "collection_infos", :force => true do |t|
    t.integer  "paper_id"
    t.integer  "user_id"
    t.text     "question_ids"
    t.datetime "created_at"
  end

  add_index "collection_infos", ["paper_id"], :name => "index_collection_infos_on_paper_id"
  add_index "collection_infos", ["user_id"], :name => "index_collection_infos_on_user_id"

  create_table "collections", :force => true do |t|
    t.integer  "user_id",        :null => false
    t.string   "collection_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "category_id"
  end

  add_index "collections", ["user_id"], :name => "index_collections_on_user_id"

  create_table "competes", :force => true do |t|
    t.integer "user_id"
    t.date    "created_at"
    t.integer "price"
    t.string  "remark"
    t.integer "category_id"
  end

  add_index "competes", ["category_id"], :name => "index_competes_on_category_id"
  add_index "competes", ["user_id"], :name => "index_competes_on_user_id"

  create_table "courses", :force => true do |t|
    t.string "title"
    t.text   "description"
    t.date   "created_at"
  end

  add_index "courses", ["title"], :name => "index_courses_on_title"

  create_table "discriminates", :force => true do |t|
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "exam_raters", :force => true do |t|
    t.datetime "created_at"
    t.string   "name"
    t.string   "mobilephone"
    t.string   "email"
    t.string   "author_code"
    t.integer  "examination_id", :null => false
  end

  add_index "exam_raters", ["author_code"], :name => "index_exam_raters_on_author_code"
  add_index "exam_raters", ["examination_id"], :name => "index_exam_raters_on_examination_id"

  create_table "exam_users", :force => true do |t|
    t.integer  "examination_id",                       :null => false
    t.integer  "user_id"
    t.string   "password"
    t.datetime "created_at"
    t.integer  "paper_id"
    t.datetime "started_at"
    t.datetime "submited_at"
    t.datetime "ended_at"
    t.boolean  "is_submited",       :default => false
    t.boolean  "open_to_user",      :default => false
    t.string   "answer_sheet_url"
    t.boolean  "is_user_affiremed", :default => false
    t.integer  "total_score"
    t.boolean  "is_auto_rate",      :default => false
    t.boolean  "is_free",           :default => false
    t.integer  "correct_percent"
    t.string   "rank"
  end

  add_index "exam_users", ["examination_id"], :name => "index_exam_users_on_examination_id"
  add_index "exam_users", ["is_free"], :name => "index_exam_users_on_is_free"
  add_index "exam_users", ["paper_id"], :name => "index_exam_users_on_paper_id"
  add_index "exam_users", ["user_id"], :name => "index_exam_users_on_user_id"

  create_table "examination_paper_relations", :force => true do |t|
    t.integer "examination_id"
    t.integer "paper_id"
  end

  add_index "examination_paper_relations", ["examination_id"], :name => "index_examination_paper_relations_on_examination_id"
  add_index "examination_paper_relations", ["paper_id"], :name => "index_examination_paper_relations_on_paper_id"

  create_table "examination_tag_relations", :force => true do |t|
    t.integer "examination_id"
    t.integer "tag_id"
  end

  add_index "examination_tag_relations", ["examination_id"], :name => "index_examination_tag_relations_on_examination_id"
  add_index "examination_tag_relations", ["tag_id"], :name => "index_examination_tag_relations_on_tag_id"

  create_table "examinations", :force => true do |t|
    t.string   "title"
    t.integer  "creater_id",                          :null => false
    t.string   "description"
    t.boolean  "is_score_open",    :default => false
    t.boolean  "is_paper_open",    :default => false
    t.string   "exam_password1"
    t.string   "exam_password2"
    t.datetime "start_at_time"
    t.datetime "start_end_time"
    t.integer  "exam_time"
    t.boolean  "is_published",     :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "user_affirm",      :default => false
    t.integer  "status",           :default => 0
    t.integer  "price"
    t.datetime "get_free_end_at"
    t.datetime "exam_free_end_at"
    t.integer  "category_id"
    t.boolean  "is_should_rate"
    t.integer  "types"
    t.boolean  "is_free"
  end

  add_index "examinations", ["category_id"], :name => "index_examinations_on_category_id"
  add_index "examinations", ["creater_id"], :name => "index_examinations_on_creater_id"
  add_index "examinations", ["is_paper_open"], :name => "index_examinations_on_is_paper_open"
  add_index "examinations", ["is_score_open"], :name => "index_examinations_on_is_score_open"

  create_table "feedbacks", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "status"
    t.text     "description"
    t.string   "answer"
    t.datetime "created_at"
    t.integer  "category_id"
  end

  add_index "feedbacks", ["category_id"], :name => "index_feedbacks_on_category_id"
  add_index "feedbacks", ["status"], :name => "index_feedbacks_on_status"
  add_index "feedbacks", ["user_id"], :name => "index_feedbacks_on_user_id"

  create_table "inside_tests", :force => true do |t|
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "inside_tests", ["email"], :name => "index_inside_tests_on_email"

  create_table "invite_codes", :force => true do |t|
    t.string   "code"
    t.datetime "created_at"
    t.integer  "vicegerent_id"
    t.integer  "user_id"
    t.integer  "bus_id"
    t.datetime "use_time"
    t.integer  "status"
    t.datetime "ended_at"
    t.integer  "category_id"
  end

  add_index "invite_codes", ["code"], :name => "index_invite_codes_on_code"
  add_index "invite_codes", ["user_id"], :name => "index_invite_codes_on_user_id"
  add_index "invite_codes", ["vicegerent_id"], :name => "index_invite_codes_on_vicegerent_id"

  create_table "ip_tables", :force => true do |t|
    t.integer "start_at",      :limit => 8
    t.integer "end_at",        :limit => 8
    t.string  "province_name"
    t.string  "city_name"
  end

  add_index "ip_tables", ["city_name"], :name => "index_ip_tables_on_city_name"
  add_index "ip_tables", ["end_at"], :name => "index_ip_tables_on_end_at"
  add_index "ip_tables", ["province_name"], :name => "index_ip_tables_on_province_name"
  add_index "ip_tables", ["start_at"], :name => "index_ip_tables_on_start_at"

  create_table "model_roles", :force => true do |t|
    t.integer "role_id"
    t.integer "right_sum"
  end

  add_index "model_roles", ["role_id"], :name => "index_model_roles_on_role_id"

  create_table "notes", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.string   "note_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notes", ["user_id"], :name => "index_notes_on_user_id"

  create_table "notices", :force => true do |t|
    t.integer  "category_id"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.integer  "send_types"
    t.integer  "send_id"
    t.integer  "target_id"
    t.string   "description"
    t.datetime "created_at"
  end

  add_index "notices", ["category_id"], :name => "index_notices_on_category_id"
  add_index "notices", ["ended_at"], :name => "index_notices_on_ended_at"
  add_index "notices", ["send_id"], :name => "index_notices_on_send_id"
  add_index "notices", ["send_types"], :name => "index_notices_on_send_types"
  add_index "notices", ["started_at"], :name => "index_notices_on_started_at"
  add_index "notices", ["target_id"], :name => "index_notices_on_target_id"

  create_table "orders", :force => true do |t|
    t.integer  "user_id"
    t.integer  "types"
    t.integer  "total_price"
    t.string   "remark"
    t.datetime "start_time"
    t.datetime "end_time"
    t.boolean  "status"
    t.datetime "created_at"
    t.string   "out_trade_no"
    t.integer  "pay_type"
    t.integer  "category_id"
  end

  add_index "orders", ["out_trade_no"], :name => "index_orders_on_out_trade_no"
  add_index "orders", ["pay_type"], :name => "index_orders_on_pay_type"
  add_index "orders", ["user_id"], :name => "index_orders_on_user_id"

  create_table "paper_blocks", :force => true do |t|
    t.integer  "paper_id",    :null => false
    t.string   "title"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "time"
    t.string   "start_time"
  end

  add_index "paper_blocks", ["paper_id"], :name => "index_paper_blocks_on_paper_id"

  create_table "papers", :force => true do |t|
    t.integer  "category_id",                           :null => false
    t.string   "title"
    t.integer  "creater_id",                            :null => false
    t.string   "description"
    t.integer  "total_score",        :default => 0
    t.integer  "total_question_num", :default => 0
    t.boolean  "is_used",            :default => false
    t.string   "paper_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "paper_js_url"
    t.integer  "types"
    t.integer  "time"
    t.boolean  "status"
  end

  add_index "papers", ["category_id"], :name => "index_papers_on_category_id"
  add_index "papers", ["status"], :name => "index_papers_on_status"
  add_index "papers", ["types"], :name => "index_papers_on_types"

  create_table "phone_words", :force => true do |t|
    t.string   "name"
    t.integer  "category_id"
    t.string   "ch_mean"
    t.integer  "types"
    t.string   "phonetic"
    t.string   "enunciate_url"
    t.integer  "level"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "phone_words", ["category_id"], :name => "index_phone_words_on_category_id"
  add_index "phone_words", ["name"], :name => "index_phone_words_on_name"

  create_table "plan_tasks", :force => true do |t|
    t.integer  "study_plan_id"
    t.integer  "task_types"
    t.integer  "period_types"
    t.integer  "num"
    t.datetime "created_at"
  end

  add_index "plan_tasks", ["period_types"], :name => "index_plan_tasks_on_period_types"
  add_index "plan_tasks", ["study_plan_id"], :name => "index_plan_tasks_on_study_plan_id"
  add_index "plan_tasks", ["task_types"], :name => "index_plan_tasks_on_task_types"

  create_table "practice_sentences", :force => true do |t|
    t.integer  "category_id",   :default => 2
    t.string   "en_mean"
    t.string   "ch_mean"
    t.integer  "level"
    t.string   "enunciate_url"
    t.string   "error_mean"
    t.integer  "types",         :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "right_mean"
  end

  add_index "practice_sentences", ["category_id"], :name => "index_practice_sentences_on_category_id"
  add_index "practice_sentences", ["level"], :name => "index_practice_sentences_on_level"
  add_index "practice_sentences", ["types"], :name => "index_practice_sentences_on_types"

  create_table "problem_tag_relations", :force => true do |t|
    t.integer "tag_id",     :null => false
    t.integer "problem_id", :null => false
  end

  add_index "problem_tag_relations", ["problem_id"], :name => "index_problem_tag_relations_on_problem_id"
  add_index "problem_tag_relations", ["tag_id"], :name => "index_problem_tag_relations_on_tag_id"

  create_table "problem_tags", :force => true do |t|
    t.integer "problem_id",                :null => false
    t.integer "total_num",  :default => 1
  end

  add_index "problem_tags", ["problem_id"], :name => "index_problem_tags_on_problem_id"

  create_table "problems", :force => true do |t|
    t.integer  "category_id",                   :null => false
    t.text     "title"
    t.integer  "types",          :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "complete_title"
    t.integer  "status"
    t.integer  "question_type"
    t.string   "description"
  end

  add_index "problems", ["category_id"], :name => "index_problems_on_category_id"
  add_index "problems", ["question_type"], :name => "index_problems_on_question_type"
  add_index "problems", ["status"], :name => "index_problems_on_status"
  add_index "problems", ["types"], :name => "index_problems_on_types"

  create_table "proofs", :force => true do |t|
    t.string  "text"
    t.integer "user_id", :null => false
    t.boolean "checked"
  end

  create_table "question_answers", :force => true do |t|
    t.integer  "user_id"
    t.string   "answer"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_question_id"
    t.boolean  "is_right",         :default => false
  end

  add_index "question_answers", ["created_at"], :name => "index_question_answers_on_created_at"
  add_index "question_answers", ["is_right"], :name => "index_question_answers_on_is_right"
  add_index "question_answers", ["user_id"], :name => "index_question_answers_on_user_id"
  add_index "question_answers", ["user_question_id"], :name => "index_question_answers_on_user_question_id"

  create_table "question_tag_relations", :force => true do |t|
    t.integer "tag_id",      :null => false
    t.integer "question_id", :null => false
  end

  add_index "question_tag_relations", ["question_id"], :name => "index_question_tag_relations_on_question_id"
  add_index "question_tag_relations", ["tag_id"], :name => "index_question_tag_relations_on_tag_id"

  create_table "questions", :force => true do |t|
    t.integer "problem_id",                    :null => false
    t.text    "description"
    t.text    "answer"
    t.integer "correct_type",   :default => 0
    t.text    "analysis"
    t.text    "question_attrs"
    t.integer "score_percent"
  end

  add_index "questions", ["correct_type"], :name => "index_questions_on_correct_type"
  add_index "questions", ["problem_id"], :name => "index_questions_on_problem_id"

  create_table "rater_user_relations", :force => true do |t|
    t.integer  "exam_user_id",                     :null => false
    t.integer  "exam_rater_id",                    :null => false
    t.boolean  "is_marked",     :default => false
    t.boolean  "is_authed",     :default => false
    t.datetime "started_at"
    t.integer  "rate_time"
    t.boolean  "is_checked",    :default => false
  end

  add_index "rater_user_relations", ["exam_rater_id"], :name => "index_rater_user_relations_on_exam_rater_id"
  add_index "rater_user_relations", ["exam_user_id"], :name => "index_rater_user_relations_on_exam_user_id"
  add_index "rater_user_relations", ["is_authed"], :name => "index_rater_user_relations_on_is_authed"
  add_index "rater_user_relations", ["is_checked"], :name => "index_rater_user_relations_on_is_checked"
  add_index "rater_user_relations", ["is_marked"], :name => "index_rater_user_relations_on_is_marked"

  create_table "regions", :force => true do |t|
    t.integer "city_index"
    t.integer "parent_id"
    t.string  "name"
  end

  add_index "regions", ["city_index"], :name => "index_regions_on_city_index"
  add_index "regions", ["name"], :name => "index_regions_on_name"
  add_index "regions", ["parent_id"], :name => "index_regions_on_parent_id"

  create_table "report_errors", :force => true do |t|
    t.integer  "paper_id"
    t.string   "paper_title"
    t.integer  "user_id"
    t.string   "user_name"
    t.integer  "error_type"
    t.integer  "question_index"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "question_id"
    t.integer  "status"
    t.string   "description"
    t.integer  "category_id"
  end

  add_index "report_errors", ["category_id"], :name => "index_report_errors_on_category_id"

  create_table "roles", :force => true do |t|
    t.string "name"
  end

  create_table "schedules", :force => true do |t|
    t.string   "name"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "schedules", ["category_id"], :name => "index_schedules_on_category_id"

  create_table "score_levels", :force => true do |t|
    t.integer "examination_id", :null => false
    t.string  "key"
    t.string  "value"
  end

  add_index "score_levels", ["examination_id"], :name => "index_score_levels_on_examination_id"
  add_index "score_levels", ["key"], :name => "index_score_levels_on_key"

  create_table "skills", :force => true do |t|
    t.integer  "types"
    t.string   "skill_title"
    t.string   "skill_url"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "readed_num",   :default => 0
    t.integer  "like_num",     :default => 0
    t.integer  "user_id"
    t.string   "simplify_con"
    t.boolean  "status",       :default => false
  end

  add_index "skills", ["category_id"], :name => "index_skills_on_category_id"
  add_index "skills", ["readed_num"], :name => "index_skills_on_readed_num"

  create_table "statistics", :force => true do |t|
    t.datetime "created_at"
    t.string   "register"
    t.string   "action"
    t.string   "pay"
    t.string   "money"
    t.string   "login"
  end

  add_index "statistics", ["created_at"], :name => "index_statistics_on_created_at"

  create_table "study_plans", :force => true do |t|
    t.integer "category_id"
    t.integer "study_date"
  end

  add_index "study_plans", ["category_id"], :name => "index_study_plans_on_category_id"

  create_table "suns", :force => true do |t|
    t.integer  "category_id"
    t.integer  "types"
    t.integer  "user_id"
    t.integer  "num"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "suns", ["category_id"], :name => "index_suns_on_category_id"
  add_index "suns", ["user_id"], :name => "index_suns_on_user_id"

  create_table "tags", :force => true do |t|
    t.string  "name"
    t.integer "num",  :default => 0
  end

  create_table "tractates", :force => true do |t|
    t.integer  "category_id"
    t.integer  "types"
    t.integer  "level"
    t.string   "tractate_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tractates", ["category_id"], :name => "index_tractates_on_category_id"
  add_index "tractates", ["level"], :name => "index_tractates_on_level"
  add_index "tractates", ["types"], :name => "index_tractates_on_types"

  create_table "user_action_logs", :force => true do |t|
    t.integer  "user_id"
    t.string   "total_num"
    t.integer  "week_num"
    t.datetime "last_update_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_action_logs", ["user_id"], :name => "index_user_action_logs_on_user_id"

  create_table "user_beliefs", :force => true do |t|
    t.integer "user_id"
    t.date    "created_at"
    t.integer "belief"
  end

  add_index "user_beliefs", ["user_id"], :name => "index_user_beliefs_on_user_id"

  create_table "user_category_relations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "category_id"
    t.integer  "status"
    t.datetime "created_at"
    t.integer  "types"
  end

  add_index "user_category_relations", ["category_id"], :name => "index_user_category_relations_on_category_id"
  add_index "user_category_relations", ["status"], :name => "index_user_category_relations_on_status"
  add_index "user_category_relations", ["types"], :name => "index_user_category_relations_on_types"
  add_index "user_category_relations", ["user_id"], :name => "index_user_category_relations_on_user_id"

  create_table "user_plan_relations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "study_plan_id"
    t.datetime "created_at"
    t.datetime "ended_at"
    t.integer  "num"
    t.boolean  "status"
    t.boolean  "is_activity",   :default => false
  end

  add_index "user_plan_relations", ["created_at"], :name => "index_user_plan_relations_on_created_at"
  add_index "user_plan_relations", ["ended_at"], :name => "index_user_plan_relations_on_ended_at"
  add_index "user_plan_relations", ["is_activity"], :name => "index_user_plan_relations_on_is_activity"
  add_index "user_plan_relations", ["num"], :name => "index_user_plan_relations_on_num"
  add_index "user_plan_relations", ["status"], :name => "index_user_plan_relations_on_status"
  add_index "user_plan_relations", ["study_plan_id"], :name => "index_user_plan_relations_on_study_plan_id"
  add_index "user_plan_relations", ["user_id"], :name => "index_user_plan_relations_on_user_id"

  create_table "user_plans", :force => true do |t|
    t.integer  "category_id"
    t.integer  "user_id"
    t.string   "plan_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "days"
  end

  add_index "user_plans", ["category_id"], :name => "index_user_plans_on_category_id"
  add_index "user_plans", ["user_id"], :name => "index_user_plans_on_user_id"

  create_table "user_questions", :force => true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.string   "description"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_answer",   :default => false
  end

  add_index "user_questions", ["category_id"], :name => "index_user_questions_on_category_id"
  add_index "user_questions", ["created_at"], :name => "index_user_questions_on_created_at"
  add_index "user_questions", ["is_answer"], :name => "index_user_questions_on_is_answer"
  add_index "user_questions", ["user_id"], :name => "index_user_questions_on_user_id"

  create_table "user_role_relations", :force => true do |t|
    t.integer "role_id", :null => false
    t.integer "user_id", :null => false
  end

  add_index "user_role_relations", ["role_id"], :name => "index_user_role_relations_on_role_id"
  add_index "user_role_relations", ["user_id"], :name => "index_user_role_relations_on_user_id"

  create_table "user_score_infos", :force => true do |t|
    t.integer  "category_id"
    t.integer  "user_id"
    t.integer  "start_score"
    t.integer  "target_score"
    t.string   "all_start_level"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "modulus"
  end

  add_index "user_score_infos", ["category_id"], :name => "index_user_score_infos_on_category_id"
  add_index "user_score_infos", ["user_id"], :name => "index_user_score_infos_on_user_id"

  create_table "user_word_relations", :force => true do |t|
    t.datetime "created_at"
    t.integer  "user_id"
    t.text     "nomal_ids"
    t.text     "recite_ids"
    t.integer  "category_id"
    t.datetime "login_time"
    t.integer  "all_study_time"
    t.string   "practice_url"
    t.integer  "study_role"
    t.string   "timer"
  end

  add_index "user_word_relations", ["all_study_time"], :name => "index_user_word_relations_on_all_study_time"
  add_index "user_word_relations", ["category_id"], :name => "index_user_word_relations_on_category_id"
  add_index "user_word_relations", ["login_time"], :name => "index_user_word_relations_on_login_time"
  add_index "user_word_relations", ["practice_url"], :name => "index_user_word_relations_on_practice_url"
  add_index "user_word_relations", ["study_role"], :name => "index_user_word_relations_on_study_role"
  add_index "user_word_relations", ["user_id"], :name => "index_user_word_relations_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "username"
    t.string   "mobilephone"
    t.string   "email"
    t.string   "address"
    t.string   "salt"
    t.string   "encrypted_password"
    t.integer  "status",             :default => 0
    t.string   "active_code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "school"
    t.string   "code_id"
    t.string   "code_type"
    t.string   "belief_url"
    t.string   "open_id"
    t.string   "cert"
    t.string   "access_token"
    t.datetime "end_time"
    t.integer  "from"
    t.string   "remarks"
    t.string   "cover_url"
    t.integer  "login_times",        :default => 0
    t.string   "signin_days",        :default => "CET4=>0,CET6=>0,GRADUATE=>0"
  end

  add_index "users", ["code_id"], :name => "index_users_on_code_id"
  add_index "users", ["code_type"], :name => "index_users_on_code_type"
  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["from"], :name => "index_users_on_from"
  add_index "users", ["name"], :name => "index_users_on_name"
  add_index "users", ["status"], :name => "index_users_on_status"

  create_table "vicegerents", :force => true do |t|
    t.string   "name"
    t.string   "phone"
    t.string   "inline"
    t.string   "address"
    t.datetime "created_at"
  end

  add_index "vicegerents", ["name"], :name => "index_vicegerents_on_name"

  create_table "videos", :force => true do |t|
    t.string   "title"
    t.integer  "schedule_id"
    t.string   "video_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "img_url"
  end

  add_index "videos", ["schedule_id"], :name => "index_videos_on_schedule_id"

  create_table "word_discriminate_relations", :force => true do |t|
    t.integer  "word_id"
    t.integer  "discriminate_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "word_discriminate_relations", ["discriminate_id"], :name => "index_word_discriminate_relations_on_discriminate_id"
  add_index "word_discriminate_relations", ["word_id"], :name => "index_word_discriminate_relations_on_word_id"

  create_table "word_question_relations", :force => true do |t|
    t.integer  "word_id"
    t.integer  "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "word_question_relations", ["question_id"], :name => "index_word_question_relations_on_question_id"
  add_index "word_question_relations", ["word_id"], :name => "index_word_question_relations_on_word_id"

  create_table "word_sentences", :force => true do |t|
    t.integer  "word_id"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ch_mean"
  end

  add_index "word_sentences", ["word_id"], :name => "index_word_sentences_on_word_id"

  create_table "words", :force => true do |t|
    t.string   "name"
    t.integer  "category_id"
    t.string   "en_mean"
    t.string   "ch_mean"
    t.integer  "types"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "phonetic"
    t.string   "enunciate_url"
    t.integer  "level"
  end

  add_index "words", ["level"], :name => "index_words_on_level"
  add_index "words", ["name"], :name => "index_words_on_name"

end
