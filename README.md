🧑🏼‍💻บันทึกการทำ Distroless Image ด้วยตัวเอง
บทความนี้เขียนเพื่อบันทึกความเข้าใจของผมถ้าผิดตรงไหนก็บอกด้วยหล่ะ 👀

## ที่มา Docker version Alpine

โครงการของ Alpine Linux นี้ก็ถูกพัฒนาขึ้นมาเพื่อตอบโจทย์การใช้ Container ให้มีขนาดไม่เกิน 8MB และใช้พื้นที่รวมไม่เกิน 130 MB รวมถึงยังถูกออกแบบมาให้มีความปลอดภัยสูง เมื่อทำการติดตั้งเครื่องมือต่างๆ เข้าไปจะมีขนาดอยู่ประมาณ 200MB ซึ่งก็ยังมีขนาดที่น้อยกว่าของเวอร์ชั่น “slim“ อยู่ดี

แต่มันก็ยังมีขนาดใหญ่อยู่ดีเพราะยังมี OS packed อยู่

## ว่าด้วยเรื่องของแต่ละ version docker แบบย่อ

### stretch/buster/jessie

stretch/buster/jessie is codenamed รุ่นที่ต่างกันของ Debian

- “Buster” was the codename for all version 10
- “Stretch” was the codename for all version 9
- “Jessie” was the codename for all version 8

### Slim images

ติดตั้งแพ็คเกจขั้นต่ำที่จำเป็นในการเรียกใช้

### Alpine

กลับไปอ่านด้านบน

> มันยังไม่ดีพอที่จะใช้แค่ Alpine application runtime image
> เราควรจะตัด OS เพื่อให้มันเล็กสุดๆ

---

![Screenshot_23](https://dev-to-uploads.s3.amazonaws.com/i/cahnzasvsnfgzndrp19k.png)

ในที่นี้ผมจะลองเป็น Nodejs

## มาดูความหมายของกันอีกที "Distroless"

> images contain only your application and its runtime dependencies. They do not contain package managers, shells or any other programs you would expect to find in a standard Linux distribution.

## มาดู Dockerfile ที่เตรียมไว้

```dockerfile
FROM node:14-slim AS build-env
# ที่ทำงานของเรา

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm ci --only=production

# if not COPY.. will  ERROR nest: not found
COPY . .

RUN npm run build

FROM node:14-slim

WORKDIR /usr/src/app

COPY --from=build-env /usr/src/app ./

CMD ["npm", "run", "start:prod"]


# FROM gcr.io/distroless/nodejs:14

# COPY --from=build-env /usr/src/app /usr/src/app
# WORKDIR /usr/src/app

```

> dockerfile แบบ build production ธรรมดา

> ตอน build มันสั่ง `nest build` แล้วมันจะหา nest ใน /usr/src/app ต้องถอยมาที่ root directory

## ลองแบบ Distroless Image

```dockerfile
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
```

> เปลี่ยนเป็น "./dist/main.js" เพราะว่า
>
> > The entrypoint of this image is set to "node"
> > [document of distroless](https://github.com/GoogleContainerTools/distroless/blob/master/nodejs/README.md)
> > จะได้ผลลัพท์แบบนี้
> > ![Screenshot_2](https://dev-to-uploads.s3.amazonaws.com/i/lvon1yz2wpq8lyp6ygps.png)

**reference**:

- [distroless image](https://github.com/GoogleContainerTools/distroless)

- [เลือก Docker image แบบไหนดี สำหรับการพัฒนา NodeJS](https://igokuz.com/%E0%B9%80%E0%B8%A5%E0%B8%B7%E0%B8%AD%E0%B8%81-docker-image-%E0%B9%81%E0%B8%9A%E0%B8%9A%E0%B9%84%E0%B8%AB%E0%B8%99%E0%B8%94%E0%B8%B5-%E0%B8%AA%E0%B8%B3%E0%B8%AB%E0%B8%A3%E0%B8%B1%E0%B8%9A%E0%B8%81%E0%B8%B2%E0%B8%A3%E0%B8%9E%E0%B8%B1%E0%B8%92%E0%B8%99%E0%B8%B2-nodejs-d2c966ea1e3b)

- [ลอง Setup โปรเจค Docker + Node.js ง่ายๆ สำหรับ Dev และ Production](https://medium.com/insightera/%E0%B8%A5%E0%B8%AD%E0%B8%87-setup-%E0%B9%82%E0%B8%9B%E0%B8%A3%E0%B9%80%E0%B8%88%E0%B8%84-docker-node-js-%E0%B8%87%E0%B9%88%E0%B8%B2%E0%B8%A2%E0%B9%86-%E0%B8%AA%E0%B8%B3%E0%B8%AB%E0%B8%A3%E0%B8%B1%E0%B8%9A-dev-%E0%B9%81%E0%B8%A5%E0%B8%B0-production-e41b0f21cec1)

- [version ของ docker](https://medium.com/swlh/alpine-slim-stretch-buster-jessie-bullseye-bookworm-what-are-the-differences-in-docker-62171ed4531d)

- [How to Dockerize your NestJS App for production](https://dev.to/abbasogaji/how-to-dockerize-your-nestjs-app-for-production-2lmf)
