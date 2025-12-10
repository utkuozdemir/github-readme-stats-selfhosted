FROM node:24-alpine

RUN apk add --no-cache git jq bash tini && npm install -g npm@11.7.0

# Create the working directory and set permissions
WORKDIR /repo
RUN chown nobody:nobody /repo

COPY entrypoint.sh /entrypoint.sh

# Configure NPM to use a writable cache directory (since 'nobody' home is /)
ENV NPM_CONFIG_CACHE=/tmp/.npm

# Switch to non-root user
USER nobody

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/entrypoint.sh"]
