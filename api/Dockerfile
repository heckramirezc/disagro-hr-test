FROM node:20-alpine AS development

WORKDIR /app

COPY package.json yarn.lock ./ 
RUN yarn install 

COPY . .

RUN yarn run build

FROM node:20-alpine AS production

ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

WORKDIR /app

COPY package.json yarn.lock ./
RUN yarn install --production --frozen-lockfile

COPY --from=development /app/dist ./dist
# Copia src si necesitas que el configModule lea archivos .env que copiaste
# COPY --from=development /app/src ./src

EXPOSE 3000

CMD ["node", "dist/main"]
