FROM node:14 AS Production 

ENV NODE_ENV=Production

WORKDIR /mern-ecommerce-master/client

COPY package.json . 

COPY package-lock.json .

COPY vercel.json . 

RUN npm install 

COPY . .

RUN  npm run build 

CMD ["sh", "-c", "npm run start"]