# Docker
Цель: Разобраться с основами docker, с образа, эко системой docker в целом.
Описание ДЗ:
Создайте свой кастомный образ nginx на базе alpine. После запуска nginx должен
отдавать кастомную страницу (достаточно изменить дефолтную страницу nginx)
Определите разницу между контейнером и образом
Вывод опишите в домашнем задании.
Ответьте на вопрос: Можно ли в контейнере собрать ядро?
Собранный образ необходимо запушить в docker hub и дать ссылку на ваш
репозиторий.

## Подготовка окружения
Имеем сервер с CentOS Linux 7 (Core) 
Установка docker
Ставим docker, docker-compose: https://docs.docker.com/engine/install/centos/
Проверяем статус службы, версию:
```
sudo systemctl status docker
docker version
```
* Чтобы без проблем выполнять команды docker под обычной учеткой, необходимо добавить её в группу докер и перелогиниться:
```
sudo usermod -aG docker sam
```
## Подготовка Dockerfile
### Для начала подготовим стартовую страницу nginx:
```
<!DOCTYPE html>
<html>
<head>
<title>yarokozloff</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome!</h1>
<p>This my site yarkozloff </p>

<p>Please check my repositories on dockerhub
<a href="https://hub.docker.com/u/yarkozloff">hub.docker.com/u/yarkozloff</a>.</p>

<p><em>Thank you</em></p>
</body>
</html>
```
### Подготовим конфиг nginx:
```
    server {
        listen       80;
        listen       [::]:4881;
        server_name  _;
        root         /usr/share/nginx/html;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }
```
### Создаем Dockerfile
FROM — задаёт базовый (родительский) образ.
RUN — выполняет команду и создаёт слой образа. Используется для установки в контейнер пакетов.
EXPOSE — указывает на то, какие порты планируется открыть для того, чтобы через них можно было бы связаться с работающим контейнером.
COPY — копирует в контейнер файлы и папки. (конфиг и стартовую страницу).
ADD позволяет решать те же задачи, что и COPY, но еще умеет добавлять в контейнер файлы, загруженные из удалённых источников, а также распаковывать локальные .tar-файлы.
CMD — предоставляет Docker команду, которую нужно выполнить при запуске контейнера.

Итого полученный Dockerfile:
```
FROM alpine
RUN apk update && apk upgrade
RUN apk add nginx
EXPOSE 80 443
COPY ./startpage.html /usr/share/nginx/html/index.html
COPY ./default.conf /etc/nginx/http.d/default.conf
CMD ["nginx","-g","daemon off;"]
```
