#!/bin/bash
set -e
set -x

# Remove a potentially pre-existing server.pid for Rails.
rm -f /usr/src/app/tmp/pids/server.pid

bundle check || bundle install
yarn install --check-files
bundle exec rails assets:precompile

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"