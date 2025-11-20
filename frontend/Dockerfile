FROM node:latest AS build

WORKDIR /app

COPY . .

RUN npm install && npm run build

FROM nginx:stable-alpine

COPY --from=build /app/dist /usr/share/nginx/html

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]

EXPOSE 80

