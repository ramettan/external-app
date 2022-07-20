FROM  node:18-alpine3.15

COPY . /app/

WORKDIR /app

RUN npm ci --omit=dev

CMD ["node", "server.js"]