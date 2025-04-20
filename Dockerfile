FROM --platform=linux/amd64 python:3.8.10-slim AS backend
RUN mkdir -p /ECWMS/templates
#copy requirements.txt
ADD ./requirements.txt /ECWMS/requirements.txt
COPY ./backend_start.sh /ECWMS/backend_start.sh
#Configure working directory
WORKDIR /ECWMS
ENV port = ${port}
#Installation foundation dependency
#RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list
#RUN apt-get clean
RUN apt-get update --fix-missing && apt-get upgrade -y
RUN apt-get install build-essential -y
RUN apt-get install supervisor -y
#Configure pip3 Alibaba Source
#RUN pip3 config set global.index-url http://mirrors.aliyun.com/pypi/simple/
#RUN pip3 config set install.trusted-host mirrors.aliyun.com
RUN python3 -m pip install --upgrade pip
#Install supervisor daphne
RUN pip3 install supervisor
RUN pip3 install -U 'Twisted[tls,http2]'
RUN pip3 install -r requirements.txt
RUN pip3 install daphne
RUN chmod +x /ECWMS/backend_start.sh
CMD ["/ECWMS/backend_start.sh"]

FROM --platform=linux/amd64 node:14.19.3-buster-slim AS front
COPY ./templates/package.json /ECWMS/templates/package.json
#COPY ./templates/node_modules/ /ECWMS/templates/node_modules/
COPY ./web_start.sh /ECWMS/templates/web_start.sh
ENV port = ${port}
#ENV NODE_OPTIONS=--openssl-legacy-provider
RUN cd  /ECWMS/templates
RUN npm install -g npm --force
#RUN npm config set registry https://registry.npm.taobao.org
RUN npm install -g yarn --force
#RUN yarn config set registry https://registry.npm.taobao.org
RUN npm install -g @quasar/cli --force
RUN yarn install
RUN chmod +x /ECWMS/templates/web_start.sh
ENTRYPOINT ["/ECWMS/templates/web_start.sh"]

