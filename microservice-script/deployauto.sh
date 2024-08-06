#!/bin/bash

# This script is used to deploy the application to the server

printf "Deploying the application to the fly server\n"

printf "Enter the project directory: "
read project_dir
cd $project_dir

# condition to throw error if project directory is not provided
if [ -z "$project_dir" ]; then
    echo "Project directory is required"
    exit 1
fi

# check if the project directory exists
if [ ! -d "$project_dir" ]; then
    echo "No such file or directory exists"
    exit 1
fi

printf "Enter the microservice name: "
read microservice_name

# condition to throw error if microservice name is not provided
if [ -z "$microservice_name" ]; then
    echo "Microservice name is required"
    exit 1
fi

printf "Enter the fly app name: "
read fly_app_name

# condition to throw error if fly app name is not provided
if [ -z "$fly_app_name" ]; then
    echo "Fly app name is required"
    exit 1
fi

createDockerfile() {

    echo "FROM node:20-slim AS base" >>Dockerfile
    echo "ENV PNPM_HOME=\"/pnpm\"" >>Dockerfile
    echo "ENV PATH=\"\$PNPM_HOME:\$PATH\"" >>Dockerfile
    echo "RUN corepack enable" >>Dockerfile
    echo "COPY . /app" >>Dockerfile
    echo "WORKDIR /app" >>Dockerfile
    echo "" >>Dockerfile
    echo "FROM base AS prod-deps" >>Dockerfile
    echo "RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --prod --frozen-lockfile" >>Dockerfile
    echo "" >>Dockerfile
    echo "FROM base AS build" >>Dockerfile
    echo "RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile" >>Dockerfile
    echo "RUN pnpm run build:${microservice_name}" >>Dockerfile
    echo "" >>Dockerfile
    echo "FROM gcr.io/distroless/nodejs20-debian11" >>Dockerfile
    echo "COPY --from=prod-deps /app/node_modules /app/node_modules" >>Dockerfile
    echo "COPY --from=build /app/dist /app/dist" >>Dockerfile
    echo "COPY --from=build /app/package.json /app/package.json" >>Dockerfile
    echo "WORKDIR /app" >>Dockerfile
    echo "" >>Dockerfile
    echo "ENV PORT=5000" >>Dockerfile
    echo "EXPOSE 5000" >>Dockerfile
    echo "" >>Dockerfile
    echo "CMD [\"dist/apps/${microservice_name}/main.js\"]" >>Dockerfile

}

createFlyTomlFile() {

    echo "app = '${fly_app_name}'" >>fly.toml
    echo "primary_region = 'sin'" >>fly.toml
    echo "" >>fly.toml
    echo "[build]" >>fly.toml
    echo "" >>fly.toml
    echo "[http_service]" >>fly.toml
    echo "internal_port = 5000" >>fly.toml
    echo "force_https = true" >>fly.toml
    echo "auto_stop_machines = true" >>fly.toml
    echo "auto_start_machines = true" >>fly.toml
    echo "min_machines_running = 0" >>fly.toml
    echo "processes = ['app']" >>fly.toml
    echo "" >>fly.toml
    echo "[[vm]]" >>fly.toml
    echo "memory = '512mb'" >>fly.toml
    echo "cpu_kind = 'shared'" >>fly.toml
    echo "cpus = 1" >>fly.toml

}

createDockerfile
createFlyTomlFile

printf "Enter the fly organization name: "
read fly_org_name

if [ -z "$fly_org_name" ]; then
    fly launch
fi

if [ -n "$fly_org_name" ]; then
    fly launch --org=$fly_org_name
fi
