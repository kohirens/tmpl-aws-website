ARG USER_NAME='app'
ARG USER_UID='1001'
ARG USER_GID='1001'
ARG USER_GROUP='app_users'
ARG WD="/usr/share/nginx/html"

FROM alpine:3.18 AS base

COPY .docker/nginx/default.conf /etc/nginx/http.d/default.conf

ARG USER_NAME
ARG USER_UID
ARG USER_GID
ARG USER_GROUP

COPY .docker/nginx/generate-self-signed-cert.sh /usr/bin/

RUN env && apk --no-progress --purge --no-cache upgrade \
 && apk --no-progress --purge --no-cache add --upgrade \
    curl \
    nginx \
    openssl \
 && apk --no-progress --purge --no-cache upgrade \
 && rm -vrf /var/cache/apk/* \
 && chmod a+x /usr/bin/generate-self-signed-cert.sh \
 && source generate-self-signed-cert.sh

# Add a non-root group and user, helpful if you dev on Linux.
RUN addgroup --system --gid ${USER_GID} ${USER_GROUP} \
 && adduser --system \
    --disabled-password \
    --ingroup ${USER_GROUP} \
    --uid ${USER_UID} \
    ${USER_NAME} \
 && ln -sf /dev/stdout /var/log/nginx/access.log \
 && ln -sf /dev/stderr /var/log/nginx/error.log

ENTRYPOINT [ "nginx" ]

CMD [ "-g", "daemon off;" ]

HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -k -f https://127.0.0.1:4433/ || exit 1