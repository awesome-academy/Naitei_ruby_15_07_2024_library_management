#!/bin/bash
set -e

host="$1"
shift
cmd="$@"

until mysql -h "$host" -u"$MYSQL_USERNAME" -p"$MYSQL_PASSWORD" -e 'SHOW DATABASES;' &> /dev/null; do
  >&2 echo "MySQL is unavailable - sleeping"
  sleep 5
done

>&2 echo "MySQL is up - checking if the database exists"

if mysql -h "$host" -u"$MYSQL_USERNAME" -p"$MYSQL_PASSWORD" -e "use ${MYSQL_DATABASE};" &> /dev/null; then
  >&2 echo "Database ${MYSQL_DATABASE} already exists, skipping setup"
else
  >&2 echo "Database ${MYSQL_DATABASE} does not exist, running setup"
  bundle exec rails db:create db:migrate db:seed
fi

exec $cmd
