FROM node:24-alpine

RUN apk add --no-cache git jq bash tini && npm install -g npm@11.7.0
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/entrypoint.sh"]
