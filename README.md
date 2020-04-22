# README

Brief Testing Guide

1. Clone the repository and perform bundle install
2. Create database and run migrations
3. Open https://webhook.site/ and copy your URL
4. Update TICKET_TRACKING_URL environment variable with the URL from above
5. Start the Rails server
6. Run RSpec tests and confirm that they are passing 
7. Shoot your Postman requests to http://0.0.0.0:3000/webhooks/git 

NOTE:
Duplicated requests will not be sent to third party. For instance, if third party is notified once that ticket #foo-123 is 'ready for release' state, the same request should not occur when webhook receives identical event.
