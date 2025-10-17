FROM node:18-alpine AS development

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm install

COPY . .

RUN npm run build

FROM node:18-alpine AS production

ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm install --production --omit=dev

COPY --from=development /app/dist ./dist
# Copia src si necesitas que el configModule lea archivos .env que copiaste
# COPY --from=development /app/src ./src

EXPOSE 3000

CMD ["node", "dist/main"]
