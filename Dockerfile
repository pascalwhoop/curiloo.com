FROM hugomods/hugo:exts-0.119.0
WORKDIR app

COPY . .
# see https://github.com/gatsbyjs/gatsby/issues/20698#issuecomment-576353427
RUN hugo --minify