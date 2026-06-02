FROM nginx:alpine

RUN apk upgrade --no-cache libxml2

RUN rm /etc/nginx/conf.d/default.conf

COPY nginx.conf.template /etc/nginx/templates/default.conf.template

EXPOSE 80
