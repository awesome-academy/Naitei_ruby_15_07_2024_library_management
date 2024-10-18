FROM ruby:3.2.2

RUN apt-get update -qq && apt-get install -y build-essential apt-utils libpq-dev nodejs default-mysql-client

WORKDIR /app

RUN gem install bundler

COPY Gemfile* ./

RUN bundle install

COPY . .

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
