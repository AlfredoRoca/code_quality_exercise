FROM ruby:2.6.3
RUN apt-get update
  # && apt-get install -y build-essential apt-utils
RUN mkdir -p /app
WORKDIR /app
# ENV HOME=/app PATH=/app/bin:$PATH
# RUN gem install bundler
# ADD Gemfile* /app/
# RUN set -ex && bundle install --jobs 20 --retry 5
VOLUME /app
COPY . /app
# RUN set -ex && bundle install --jobs 20 --retry 5
CMD ["/bin/bash"]
