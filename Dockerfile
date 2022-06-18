FROM alpine

RUN apk update && apk upgrade
RUN apk add nginx

EXPOSE 80 443
COPY ./startpage.html /usr/share/nginx/html/index.html
COPY ./default.conf /etc/nginx/http.d/default.conf
CMD ["nginx","-g","daemon off;"]
