FROM debian:stretch
MAINTAINER Camptocamp

USER root

# create the working directory and a place to set the logs (if wanted)
RUN mkdir -p /odoo /var/log/odoo

COPY ./base_requirements.txt /odoo
COPY ./install /install

# Moved because there was a bug while installing `odoo-autodiscover`. There is
# an accent in the contributor name
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# build and dev packages
ENV BUILD_PACKAGE \
    build-essential \
    gcc \
    python3.5-dev \
    libevent-dev \
    libfreetype6-dev \
    libxml2-dev \
    libxslt1-dev \
    libsasl2-dev \
    libldap2-dev \
    libssl-dev \
    libjpeg-dev \
    libpng-dev \
    zlib1g-dev \
    git

# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
RUN set -x; \
        sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" > /etc/apt/sources.list.d/pgdg.list' \
        && /install/package_odoo_11.0_12.0.sh \
        && /install/setup-pip.sh \
        && /install/postgres.sh \
        && /install/wkhtml_12_4.sh \
        && /install/dev_package.sh \
        && python3 -m pip install --force-reinstall pip setuptools \
        && pip3 install -r /odoo/base_requirements.txt --ignore-installed \
        && /install/purge_dev_package_and_cache.sh \
        && /install/reportlab_init.sh

# grab gosu for easy step-down from root and dockerize to generate template and
# wait on postgres
# TODO remove dockerize (replace wait postgres by another script)
RUN /install/gosu.sh && /install/dockerize.sh

RUN curl -SL https://github.com/kelseyhightower/confd/releases/download/v0.16.0/confd-0.16.0-linux-amd64 -o /usr/local/bin/confd \
  && echo '255d2559f3824dd64df059bdc533fd6b697c070db603c76aaf8d1d5e6b0cc334 /usr/local/bin/confd' | sha256sum -c - \
  && chmod +x /usr/local/bin/confd

RUN mkdir -p /etc/confd/{conf.d,templates}
COPY ./conf.d /etc/confd/conf.d
COPY ./templates /etc/confd/templates
COPY ./src_requirements.txt /odoo
COPY ./bin /odoo-bin
COPY ./before-migrate-entrypoint.d /before-migrate-entrypoint.d
COPY ./start-entrypoint.d /start-entrypoint.d
COPY ./MANIFEST.in /odoo
# Place coveragerc in workdir where coverage will be launched from
COPY ./.coveragerc /

VOLUME ["/data/odoo", "/var/log/odoo"]

# Expose Odoo services
EXPOSE 8069 8072

ENV ODOO_VERSION=11.0 \
    PATH=/odoo-bin:$PATH \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    DB_HOST=db \
    DB_PORT=5432 \
    DB_NAME=odoodb \
    DB_USER=odoo \
    DB_PASSWORD=odoo \
    ODOO_BASE_URL=http://localhost:8069 \
    ODOO_REPORT_URL=http://localhost:8069 \
    # the place where you put the data of your project (csv, ...)
    ODOO_DATA_PATH=/odoo/data \
    DEMO=False \
    ADDONS_PATH=/odoo/local-src,/odoo/src/addons \
    OPENERP_SERVER=/etc/odoo.cfg

RUN touch /etc/odoo.cfg && \
    chmod -R u+x /odoo-bin && \
    chgrp -R 0 /odoo && \
    chgrp -R 0 /data/odoo && \
    chgrp -R 0 /var/log/odoo && \
    chmod -R g=u /odoo /etc/odoo.cfg

# Containers should NOT run as root as a good practice
# Enforced by openshift
USER 10001

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["odoo"]
