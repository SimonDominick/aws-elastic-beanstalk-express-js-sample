# using node16 as basic image
FROM node:16

# setting workdir
WORKDIR /app


COPY package*.json ./

# add dependences
RUN npm install

# copy all file 
COPY . .

# expose port
EXPOSE 8081

# start
CMD ["npm", "start"]



