# Multi-stage Dockerfile for Google Cloud Run (gcloud run deploy backyard-barista --source .)
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app
COPY . .

ARG DEFAULT_CITY=gaziantep
ARG GEMINI_MODEL=gemini-3.5-flash-lite

RUN flutter pub get && \
    flutter build web --release \
      --dart-define=DEFAULT_CITY=${DEFAULT_CITY} \
      --dart-define=GEMINI_MODEL=${GEMINI_MODEL}

FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
RUN printf 'server {\n  listen 8080;\n  server_name _;\n  root /usr/share/nginx/html;\n  index index.html;\n  location / {\n    try_files $uri $uri/ /index.html;\n  }\n}\n' > /etc/nginx/conf.d/default.conf
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
