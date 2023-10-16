FROM node:lts-stretch as build
WORKDIR app

COPY package* .
# see https://github.com/gatsbyjs/gatsby/issues/20698#issuecomment-576353427
RUN npm install

RUN npm run build