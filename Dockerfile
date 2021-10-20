# FROM nginx

# COPY ./dist  /usr/share/nginx/html
# COPY ./src/config/nginx.conf   /etc/nginx

# EXPOSE 80

FROM hub.c.163.com/library/node:slim AS builder

RUN yarn config set registry http://10.0.1.25:4873
RUN npm install -g n
RUN n latest
RUN yarn config set ignore-engines true

WORKDIR /workspace
COPY ./package.json .
COPY ./.yarnrc .
COPY ./yarn.lock .
RUN yarn 
# --frozen-lockfile

ARG GIT_SHA1="1.01"
ENV VERSION=$GIT_SHA1

COPY ./ /workspace/
RUN yarn build

FROM hub.c.163.com/library/nginx:stable-alpine

ARG GIT_SHA1=""
ENV VERSION=$GIT_SHA1

COPY --from=builder /workspace/dist /dist
COPY ./nginx/nginx.conf /etc/nginx
COPY ./nginx/fe.conf /etc/nginx/conf.d/default.conf
COPY ./docker-start.sh /

EXPOSE 80
CMD ["/bin/sh", "/docker-start.sh"]