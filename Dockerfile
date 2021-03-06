FROM node:12.10 as node
FROM ruby:2.6.4

ENV LANG C.UTF-8

ENV DEBCONF_NOWARNINGS yes

RUN apt-get update -qq && apt-get install -y build-essential \ 
                       libpq-dev \        
                       && rm -rf /var/lib/apt/lists/*


ENV ENTRYKIT_VERSION 0.4.0

RUN wget https://github.com/progrium/entrykit/releases/download/v${ENTRYKIT_VERSION}/entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz \
    && tar -xvzf entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz \
    && rm entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz \
    && mv entrykit /bin/entrykit \
    && chmod +x /bin/entrykit \
    && entrykit --symlink

ENV YARN_VERSION 1.17.3

COPY --from=node /opt/yarn-v$YARN_VERSION /opt/yarn
COPY --from=node /usr/local/bin/node /usr/local/bin/

RUN ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn \
    && ln -s /opt/yarn/bin/yarnpkg /usr/local/bin/yarnpkg

RUN mkdir /app

WORKDIR /app

ENTRYPOINT [ \
    "prehook", "ruby -v", "--", \
    "prehook", "bundle install -j3 --quiet", "--"]

