FROM node:14 AS Production 

ENV NODE_ENV=Production

WORKDIR /mern-ecommerce-master/server

COPY package.json . 

COPY package-lock.json .

COPY vercel.json . 

RUN npm install 

COPY . .

CMD ["sh", "-c", "npm run start"]

