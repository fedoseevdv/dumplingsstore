FROM node:16 as build-stage
ARG NODE_ENV=production1
#ARG VUE_APP_API_URL=http://backend:8081
WORKDIR /app
COPY . .
RUN npx browserslist@latest --update-db
RUN npm install
RUN chmod -R a+x node_modules
RUN npm run build

FROM nginx as production-stage
#RUN mkdir /app && mkdir /app/momo-store
RUN mkdir /app
WORKDIR /app
#COPY --from=build-stage /app/dist /app
#COPY --from=build-stage /app/dist /app/momo-store
#COPY --from=build-stage /app/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build-stage /app/dist /app
COPY --from=build-stage /app/nginx.conf /etc/nginx/conf.d/default.conf
