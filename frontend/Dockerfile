# Frontend Dockerfile para landing page estática
FROM nginx:alpine

COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD wget -q -O - http://localhost:80/ >/dev/null || exit 1
