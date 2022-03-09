#!/bin/bash


if [ ! -z "$DJANGO_SETTINGS_MODULE" ]; then
    export SETTINGS=$DJANGO_SETTINGS_MODULE
else
    export SETTINGS='hamy.settings'
fi

migrate() {
    python manage.py migrate --noinput --settings=${SETTINGS}
}

runserver() {
    python manage.py runserver 0.0.0.0:${PORTNUM:-8002} --settings=${SETTINGS}
}

if [ "$1" = "dev" ]; then
    pip install -r requirements/dev.txt
    migrate
    runserver
elif [ "$1" = "test" ]; then
    pip install -r requirements/test.txt
    migrate
    exec pytest --cov=. --cov-report term-missing
else
    echo "Bad argument: '$1'. 'dev' is the default setting. Other args: $*"
    pip install -r requirements/dev.txt
    migrate
    runserver
fi
