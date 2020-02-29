# Local

    bundle install
    bundle exec rspec

# Docker

    # builds the 2 images: app, redis-cq
    docker-compose build

    # executes the tests and pretty-prints the results
    docker-compose run app

    # stops the redis-cq container
    docker-compose stop
