from node:9.11.1-alpine

copy app /app

workdir /app
run npm install

workdir /app/client
run npm install

workdir /app

cmd ["npm", "start"]
