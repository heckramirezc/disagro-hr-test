FROM node:20-alpine AS builder

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

COPY --from=builder /app/dist ./dist

EXPOSE 3000

CMD ["node", "dist/main"]
