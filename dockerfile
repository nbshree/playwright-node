FROM mcr.microsoft.com/playwright:v1.26.0-focal AS build

ENV NODE_OPTIONS=--max_old_space_size=8192

WORKDIR /app
#
#RUN  npm audit fix --force
# COPY package.json ./
# COPY package-lock.json ./
# COPY tests ./tests
COPY . .
#COPY .npmrc ./
# RUN npm config set registry https://registry.npm.taobao.org
RUN npm config set registry http://repo.lumicable.cn/repository/npm-group
RUN npm config set unsafe-perm true
RUN npm install
# # RUN npx playwright install-deps
# RUN npx playwright install
# RUN npx playwright --test
RUN npx playwright test --project=chromium
# RUN npm config set unsafe-perm false
#
# RUN mv .env.dev .env
# ARG buildId
# ENV BUILD_ID ${buildId}
# RUN npm run build
#
# FROM base AS final
# WORKDIR /app
# COPY --from=build /app/dist /usr/share/nginx/html
# #COPY dist /usr/share/nginx/html/
# COPY default.conf /etc/nginx/conf.d/default.conf.template
# COPY docker-entrypoint.sh /
# RUN chmod +x /docker-entrypoint.sh
# ENTRYPOINT ["/docker-entrypoint.sh"]
# CMD ["nginx", "-g", "daemon off;"]
# #COPY nginx.conf /etc/nginx/nginx.conf
# #EXPOSE 80
# #CMD ["nginx", "-g", "daemon off;"]
