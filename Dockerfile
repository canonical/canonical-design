# syntax=docker/dockerfile:experimental

# Build stage: Install python dependencies
# ===
FROM ubuntu:jammy AS python-dependencies
RUN apt-get update && apt-get install --no-install-recommends --yes python3-pip python3-setuptools
COPY requirements.txt /tmp/requirements.txt
RUN pip3 config set global.disable-pip-version-check true
RUN --mount=type=cache,target=/root/.cache/pip pip3 install --user --requirement /tmp/requirements.txt

# Build stage: Install yarn dependencies
# ===
FROM node:18 AS yarn-dependencies
WORKDIR /srv
COPY . .
RUN --mount=type=cache,target=/usr/local/share/.cache/yarn yarn install

# Build stage: Run "yarn run build-css"
# ===
FROM yarn-dependencies AS build-css
RUN yarn run build-css

# Build stage: Run "yarn run build-js"
# ===
FROM yarn-dependencies AS build-js
RUN yarn run build-js

# Build the production image
# ===
FROM ubuntu:jammy

ENV LANG C.UTF-8
WORKDIR /srv

# Install python and import python dependencies
RUN apt-get update && apt-get install --no-install-recommends --yes python3 python3-setuptools python3-lib2to3 python3-pkg-resources
ENV PATH="/root/.local/bin:${PATH}"

# Copy python dependencies
COPY --from=python-dependencies /root/.local/lib/python3.10/site-packages /root/.local/lib/python3.10/site-packages
COPY --from=python-dependencies /root/.local/bin /root/.local/bin

# Import code, build assets
COPY . .
RUN rm -rf package.json yarn.lock .babelrc webpack.config.js requirements.txt Dockerfile .stylelintrc .gitignore .djlintrc  
COPY --from=build-css /srv/static/css static/css
COPY --from=build-js /srv/node_modules/vanilla-framework/templates/_macros templates/_macros
COPY --from=build-js /srv/static/js/dist static/js/dist

# Set build ID
ARG BUILD_ID
ENV INSTANCE_REVISION_ID "${BUILD_ID}"

# Setup commands to run server
ENTRYPOINT ["./entrypoint"]
CMD ["0.0.0.0:80"]
