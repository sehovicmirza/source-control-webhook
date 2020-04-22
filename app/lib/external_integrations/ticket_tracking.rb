# frozen_string_literal: true

module ExternalIntegrations
  class TicketTracking
    def initialize(event_type)
      @event_type = event_type
      @result = { status: nil }
    end

    def process(commits)
      unsynced_tickets = commits.map { |commit| fetch_unsynced_tickets(commit) }.flatten.compact

      if publish_updates(unsynced_tickets)
        Ticket.bulk_persist(unsynced_tickets)
      else
        @result[:status] = :failed
      end

      @result
    end

    def fetch_unsynced_tickets(commit)
      tickets = Ticket.fetch_or_initialize_by(commit.message)

      tickets.map do |ticket|
        next if ticket.synced_for?(@event_type)

        if @event_type == :release
          ticket.state = Ticket::STATES[:released]
          ticket.release = commit.release
        else
          ticket.state = Ticket::STATES[:ready]
          ticket.commits << commit
        end

        ticket
      end
    end

    private

    def publish_updates(tickets)
      case @event_type
      when :release
        tickets.group_by(&:release_tag).each do |tag_name, release_tickets|
          payload = build_release_payload(tag_name, release_tickets)

          return false unless send_request(payload)
        end
      when :pull_request, :commits
        tickets.group_by(&:last_commit_sha).each do |sha, commit_tickets|
          payload = build_commit_payload(sha, commit_tickets)

          return false unless send_request(payload)
        end
      end
    end

    def send_request(payload)
      response = Faraday.post(ENV['TICKET_TRACKING_URL'], payload.to_json, 'Content-Type' => 'application/json')

      response.status == 200
    end

    def build_commit_payload(commit_sha, tickets)
      {
        query:   'state #{ready for release}',
        issues:  build_issues_payload(tickets),
        comment: "See SHA \##{commit_sha}"
      }
    end

    def build_release_payload(release_tag, tickets)
      {
        query:   'state #{released}',
        issues:  build_issues_payload(tickets),
        comment: "Released in #{release_tag}"
      }
    end

    def build_issues_payload(tickets)
      [].tap do |issues|
        tickets.each { |ticket| issues << { id: ticket.external_identifier } }
      end
    end
  end
end
