FROM node:20-alpine AS builder

WORKDIR /app

COPY package.json package-lock.json ./ 
RUN npm install 

COPY . .

RUN npm run build

FROM node:20-alpine AS production

ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm install --production --frozen-lockfile

COPY --from=builder /app/dist ./dist

EXPOSE 3000

CMD ["node", "dist/main"]
