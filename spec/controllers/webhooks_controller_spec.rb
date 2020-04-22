# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WebhooksController, type: :controller do
  let(:repository) do
    { id: Faker::Number.number(digits: 8), name: %w[suite_apk suitepad_api ember_app].sample }
  end
  let(:author) do
    { id: Faker::Number.number(digits: 8), name: Faker::Internet.username, email: Faker::Internet.safe_email }
  end
  let(:tickets) do
    3.times.map do
      Faker::Base.regexify(/(#[a-z]{3}-[1-9]{3})/)
    end
  end
  let(:commits) do
    [
      {
        sha:     Faker::Crypto.sha1,
        message: "FEAT: Support Android 8.1 devices \n\nRef: #{tickets.first}, #{tickets.second}",
        date:    '2018-05-14T16:00:49Z',
        author:  author
      },
      {
        sha:     Faker::Crypto.sha1,
        message: "FIX: hide url not being passed to PDF URL\n\nRef: #{tickets.third}",
        date:    '2018-05-27T16:00:49Z',
        author:  author
      }
    ]
  end
  let(:release) do
    {
      id:       1_124_881_0,
      tag_name: '1.0.1',
      author:   author,
      commits:  commits
    }
  end
  let(:pull_request) do
    {
      id:               191_568_743,
      number:           1,
      state:            'closed',
      title:            'Update the README with deploy information',
      user:             author,
      body:             'This is a pretty simple change that we need to pull into master.',
      created_at:       '2018-05-30T20:18:30Z',
      updated_at:       '2018-05-30T20:18:50Z',
      closed_at:        '2018-05-30T20:18:50Z',
      merge_commit_sha: '414cb0069601a32b00bd122a2380cd283626a8e5',
      head:             {
        sha: '34c5c7793cb3b279e22454cb6750c80560547b3a'
      },
      commits:          commits
    }
  end

  let(:push_payload) do
    {
      commits:    commits,
      repository: repository,
      pushed_at:  '2018-05-29T20:18:44Z',
      pusher:     author
    }
  end
  let(:release_payload) do
    {
      action:      'released',
      released_at: '2018-05-30T20:18:44Z',
      release:     release,
      repository:  repository
    }
  end
  let(:pull_request_payload) do
    {
      action:       'created',
      number:       142,
      pull_request: pull_request,
      repository:   repository
    }
  end

  let(:payload) { {} }
  let(:integration_name) { 'git' }
  let(:params) { { integration_name: integration_name }.merge(payload) }
  let(:json_response) { JSON.parse(response.body, symbolize_names: true) }

  describe 'POST #receive' do
    context 'with valid data' do
      before do
        stub_request(:post, ENV['TICKET_TRACKING_URL']).to_return(status: 200)
      end

      describe 'Push Event' do
        let(:payload) { push_payload }

        after do
          expect(response).to have_http_status(:ok)
        end

        context 'when single commit is detected' do
          let(:commits) do
            [{
              sha:     Faker::Crypto.sha1,
              message: "FEAT: Support Android 8.1 devices \n\nRef: #{tickets.first}",
              date:    '2018-05-14T16:00:49Z',
              author:  author
            }]
          end

          it 'should return 200, persist data and perofrm post to ticket tracking' do
            expect { post(:receive, params: params) }
              .to change { Ticket.count }
              .by(1)
              .and change { Commit.count }
              .by(1)

            expected_payload = {
              query:   'state #{ready for release}',
              issues:  [{ id: tickets.first }],
              comment: "See SHA \##{commits.first[:sha]}"
            }
            expect(a_request(:post, ENV['TICKET_TRACKING_URL']).with(body: expected_payload)).to have_been_made
          end
        end

        context 'when multiple commits and tickets are detected' do
          it 'should return 200, persist data and perofrm multiple posts to ticket tracking' do
            expect { post(:receive, params: params) }
              .to change { Ticket.count }
              .by(3)
              .and change { Commit.count }
              .by(2)

            expect(a_request(:post, ENV['TICKET_TRACKING_URL'])).to have_been_made.twice
          end
        end
      end

      describe 'Pull Request Event' do
        let(:payload) { pull_request_payload }

        after do
          expect(response).to have_http_status(:ok)
        end

        context 'when single commit is detected' do
          let(:commits) do
            [{
              sha:     Faker::Crypto.sha1,
              message: "FEAT: Support Android 8.1 devices \n\nRef: #{tickets.first}",
              date:    '2018-05-14T16:00:49Z',
              author:  author
            }]
          end

          it 'should return 200, persist data and perofrm post to ticket tracking' do
            expect { post(:receive, params: params) }
              .to change { Ticket.count }
              .by(1)
              .and change { Commit.count }
              .by(1)
              .and change { PullRequest.count }
              .by(1)

            expected_payload = {
              query:   'state #{ready for release}',
              issues:  [{ id: tickets.first }],
              comment: "See SHA \##{commits.first[:sha]}"
            }
            expect(a_request(:post, ENV['TICKET_TRACKING_URL']).with(body: expected_payload)).to have_been_made
          end
        end

        context 'when multiple commits and tickets are detected' do
          it 'should return 200, persist data and perofrm multiple posts to ticket tracking' do
            expect { post(:receive, params: params) }
              .to change { Ticket.count }
              .by(3)
              .and change { Commit.count }
              .by(2)
              .and change { PullRequest.count }
              .by(1)

            expect(a_request(:post, ENV['TICKET_TRACKING_URL'])).to have_been_made.twice
          end
        end
      end

      describe 'Release Event' do
        let(:payload) { release_payload }

        after do
          expect(response).to have_http_status(:ok)
        end

        context 'when single commit is detected' do
          let(:commits) do
            [{
              sha:     Faker::Crypto.sha1,
              message: "FEAT: Support Android 8.1 devices \n\nRef: #{tickets.first}",
              date:    '2018-05-14T16:00:49Z',
              author:  author
            }]
          end

          it 'should return 200, persist data and perofrm post to ticket tracking' do
            expect { post(:receive, params: params) }
              .to change { Ticket.count }
              .by(1)
              .and change { Commit.count }
              .by(1)
              .and change { Release.count }
              .by(1)

            expected_payload = {
              query:   'state #{released}',
              issues:  [{ id: tickets.first }],
              comment: "Released in #{release[:tag_name]}"
            }
            expect(a_request(:post, ENV['TICKET_TRACKING_URL']).with(body: expected_payload)).to have_been_made
          end
        end

        context 'when multiple commits and tickets are detected' do
          it 'should return 200, persist data and perofrm multiple posts to ticket tracking' do
            expect { post(:receive, params: params) }
              .to change { Ticket.count }
              .by(3)
              .and change { Commit.count }
              .by(2)

            expect(a_request(:post, ENV['TICKET_TRACKING_URL'])).to have_been_made.once
          end
        end
      end
    end

    context 'with invalid data' do
      context 'with invalid integration name' do
        let(:integration_name) { 'svn' }

        it 'returns 404' do
          post(:receive, params: params)
          expect(response).to have_http_status(404)
        end
      end

      context 'with invalid payload' do
        it 'returns 422' do
          post(:receive, params: params)
          expect(response).to have_http_status(422)
        end
      end
    end
  end
end
