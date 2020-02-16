FROM ruby:2.6.3
RUN apt-get update
  # && apt-get install -y build-essential apt-utils
RUN mkdir -p /app
WORKDIR /app
RUN gem install bundler
ADD Gemfile* /app/
RUN set -ex && bundle install
VOLUME /app
COPY . /app
CMD ["/bin/bash"]
