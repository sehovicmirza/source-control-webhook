# frozen_string_literal: true

class Ticket < ApplicationRecord
  STATES = {
    released: 'released',
    ready:    'ready for release'
  }.freeze

  DELIMITERS = {
    reference:   "\n\nRef: ",
    identifiers: ', '
  }.freeze

  has_and_belongs_to_many :commits
  belongs_to :release, optional: true

  def synced_for?(event_type)
    persisted? && (event_type != :release || state == STATES[:released])
  end

  def last_commit_sha
    commits.last&.sha
  end

  def release_tag
    release&.tag_name
  end

  def self.fetch_or_initialize_by(commit_message)
    external_identifiers = extract_external_identifiers(commit_message)
    external_identifiers&.map do |external_identifier|
      find_or_initialize_by(external_identifier: external_identifier)
    end
  end

  def self.bulk_persist(objects)
    Ticket.transaction { objects.each(&:save) }
  end

  def self.extract_external_identifiers(commit_message)
    commit_message.split(DELIMITERS[:reference])[1]&.split(DELIMITERS[:identifiers])
  end
end
