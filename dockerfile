FROM node:14-slim AS build-env
# ที่ทำงานของเรา

WORKDIR /usr/src/app

COPY package*.json ./ 

RUN npm ci 

#if not COPY.. will  ERROR nest: not found
COPY . .
RUN npm run build


# FROM node:14-slim
# WORKDIR /usr/src/app
# COPY --from=build-env /usr/src/app ./
# CMD ["npm", "run", "start:prod"]


FROM gcr.io/distroless/nodejs:14
WORKDIR /usr/src/app

COPY --from=build-env /usr/src/app ./

CMD ["./dist/main.js"]
