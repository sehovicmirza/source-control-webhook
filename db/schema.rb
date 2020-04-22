# frozen_string_literal: true

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20_200_417_125_700) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'commits', force: :cascade do |t|
    t.bigint 'user_id', null: false
    t.bigint 'repository_id', null: false
    t.bigint 'release_id'
    t.string 'sha', null: false
    t.string 'message', null: false
    t.datetime 'date', null: false
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index ['release_id'], name: 'index_commits_on_release_id'
    t.index ['repository_id'], name: 'index_commits_on_repository_id'
    t.index ['user_id'], name: 'index_commits_on_user_id'
  end

  create_table 'commits_pull_requests', id: false, force: :cascade do |t|
    t.bigint 'commit_id', null: false
    t.bigint 'pull_request_id', null: false
    t.index %w[commit_id pull_request_id], name: 'index_commits_pull_requests_on_commit_id_and_pull_request_id'
    t.index %w[pull_request_id commit_id], name: 'index_commits_pull_requests_on_pull_request_id_and_commit_id'
  end

  create_table 'commits_tickets', id: false, force: :cascade do |t|
    t.bigint 'commit_id', null: false
    t.bigint 'ticket_id', null: false
    t.index %w[commit_id ticket_id], name: 'index_commits_tickets_on_commit_id_and_ticket_id'
    t.index %w[ticket_id commit_id], name: 'index_commits_tickets_on_ticket_id_and_commit_id'
  end

  create_table 'pull_requests', force: :cascade do |t|
    t.bigint 'user_id', null: false
    t.bigint 'repository_id', null: false
    t.string 'action'
    t.integer 'number'
    t.string 'state'
    t.string 'title'
    t.string 'body'
    t.datetime 'closed_at'
    t.string 'merge_commit_sha'
    t.string 'head_sha'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index ['repository_id'], name: 'index_pull_requests_on_repository_id'
    t.index ['user_id'], name: 'index_pull_requests_on_user_id'
  end

  create_table 'releases', force: :cascade do |t|
    t.bigint 'user_id', null: false
    t.bigint 'repository_id', null: false
    t.string 'action'
    t.datetime 'released_at'
    t.string 'tag_name'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index ['repository_id'], name: 'index_releases_on_repository_id'
    t.index ['user_id'], name: 'index_releases_on_user_id'
  end

  create_table 'repositories', force: :cascade do |t|
    t.string 'name'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
  end

  create_table 'tickets', force: :cascade do |t|
    t.bigint 'release_id'
    t.string 'external_identifier'
    t.string 'state'
    t.string 'comment'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index ['release_id'], name: 'index_tickets_on_release_id'
  end

  create_table 'users', force: :cascade do |t|
    t.string 'name'
    t.string 'email'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
  end

  add_foreign_key 'commits', 'releases'
  add_foreign_key 'commits', 'repositories'
  add_foreign_key 'commits', 'users'
  add_foreign_key 'pull_requests', 'repositories'
  add_foreign_key 'pull_requests', 'users'
  add_foreign_key 'releases', 'repositories'
  add_foreign_key 'releases', 'users'
  add_foreign_key 'tickets', 'releases'
end
