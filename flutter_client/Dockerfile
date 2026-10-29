# Multi-stage Dockerfile for Google Cloud Run (gcloud run deploy backyard-barista --source .)
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app
COPY . .

ARG DEFAULT_CITY=gaziantep
ARG GEMINI_MODEL=gemini-3.5-flash-lite

RUN flutter pub get && \
    flutter build web --release \
      --no-web-resources-cdn \
      --dart-define=DEFAULT_CITY=${DEFAULT_CITY} \
      --dart-define=GEMINI_MODEL=${GEMINI_MODEL} \
      --dart-define=GEMINI_PROXY_PATH=/api/gemini/generate

FROM nginx:alpine
ARG GEMINI_MODEL=gemini-3.5-flash-lite
ENV GEMINI_MODEL=${GEMINI_MODEL}
ENV GEMINI_RATE_LIMIT=10r/s
COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx/default.conf.template /etc/nginx/templates/default.conf.template
COPY nginx/15-gemini-key.envsh /docker-entrypoint.d/15-gemini-key.envsh
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
