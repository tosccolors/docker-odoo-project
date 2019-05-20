#!/bin/bash
set -e

export PGHOST=${DB_HOST}
export PGPORT=${DB_PORT}
export PGUSER=${DB_USER}
export PGPASSWORD=${DB_PASSWORD}
export PGDATABASE=${DB_NAME}

export USER="${USER_NAME:-odoo}"
if ! whoami &> /dev/null; then
    if [ -w /etc/passwd ]; then
        echo "${USER}:x:$(id -u):0:${USER} user:${HOME}:/sbin/nologin" >> /etc/passwd
    fi
fi

# Accepted values for DEMO: True / False
# Odoo use a reverse boolean for the demo, which is not handy,
# that's why we propose DEMO which exports WITHOUT_DEMO used in
# openerp.cfg.tmpl
if [ -z "$DEMO" ]; then
  DEMO=False
fi
case "$(echo "${DEMO}" | tr '[:upper:]' '[:lower:]' )" in
  "false")
    echo "Running without demo data"
    export WITHOUT_DEMO=all
    ;;
  "true")
    echo "Running with demo data"
    export WITHOUT_DEMO=
    ;;
  # deprecated options:
  "odoo")
    echo "Running with demo data"
    echo "DEMO=odoo is deprecated, use DEMO=True"
    export WITHOUT_DEMO=
    ;;
  "none")
    echo "Running without demo data"
    echo "DEMO=none is deprecated, use DEMO=False"
    export WITHOUT_DEMO=all
    ;;
  "scenario")
    echo "DEMO=scenario is deprecated, use DEMO=False and MARABUNTA_MODE=demo with a demo mode in migration.yml"
    exit 1
    ;;
  "all")
    echo "DEMO=all is deprecated, use DEMO=True and MARABUNTA_MODE=demo with a demo mode in migration.yml"
    exit 1
    ;;
  *)
    echo "Value '${DEMO}' for DEMO is not a valid value in 'False', 'True'"
    exit 1
    ;;
esac

# Create configuration file from the template
# FIXME rename openerp.cfg.tmpl to odoo.cfg.tmpl in all versions
/usr/local/bin/confd -onetime -backend env

if [ -z "$(pip list --format=columns | grep "/odoo/src")" ]; then
  # The build runs 'pip install -e' on the odoo src, which creates an
  # odoo.egg-info directory *inside /odoo/src*. So when we run a container
  # with a volume shared with the host, we don't have this .egg-info (at least
  # the first time).
  # When it happens, we reinstall the odoo python package. We don't want to run
  # the install everytime because it would slow the start of the containers
  echo '/odoo/src/odoo.egg-info is missing, probably because the directory is a volume.'
  echo 'Running pip install -e /odoo/src to restore odoo.egg-info'
  pip install -e /odoo/src
  # As we write in a volume, ensure it has the same user.
  # So when the src is a host volume and we set the USER to be the
  # host user, the files are owned by the host user
  chown -R ${USER}: /odoo/src/odoo.egg-info
fi


# Same logic but for your custom project
if [ -z "$(pip list --format=columns | grep "/odoo" | grep -v "/odoo/src")" ]; then
  echo '/src/*.egg-info is missing, probably because the directory is a volume.'
  echo 'Running pip install -e /odoo to restore *.egg-info'
  pip install -e /odoo
  chown -R ${USER}: /odoo/*.egg-info
fi


# Wait until postgres is up
wait_postgres.sh

mkdir -p /data/odoo/{addons,filestore,sessions}
# FIXME still required?
if [ ! "$(stat -c '%U' /data/odoo/filestore)" = "${USER}" ]; then
  chown -R ${USER}: /data/odoo/filestore
fi
  if [ ! "$(stat -c '%U' /data/odoo/sessions)" = "${USER}" ]; then
  chown -R ${USER}: /data/odoo/sessions
fi
# TODO drop /var/log/odoo?
# if [ ! "$(stat -c '%U' /var/log/odoo)" = "${USER}" ]; then
#  chown -R ${USER}: /var/log/odoo
# fi

BASE_CMD=$(basename $1)
if [ "$BASE_CMD" = "odoo" ] || [ "$BASE_CMD" = "odoo.py" ] ; then

  BEFORE_MIGRATE_ENTRYPOINT_DIR=/before-migrate-entrypoint.d
  if [ -d "$BEFORE_MIGRATE_ENTRYPOINT_DIR" ]; then
    run-parts --verbose "$BEFORE_MIGRATE_ENTRYPOINT_DIR"
  fi

  if [ -z "$MIGRATE" -o "$MIGRATE" = True ]; then
    migrate
  fi

  START_ENTRYPOINT_DIR=/start-entrypoint.d
  if [ -d "$START_ENTRYPOINT_DIR" ]; then
    run-parts --verbose "$START_ENTRYPOINT_DIR"
  fi

fi

exec "$@"
