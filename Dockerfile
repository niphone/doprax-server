FROM nginx:mainline-alpine-slim
EXPOSE 80
USER root

COPY run.sh /run.sh
COPY supervisord.conf /etc/supervisord.conf
COPY nginx.conf /etc/nginx/nginx.conf

RUN apk update && apk add --no-cache supervisor wget unzip curl \
    && chmod a+x run.sh 

ENTRYPOINT [ "/run.sh" ]