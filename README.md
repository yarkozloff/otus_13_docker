# Docker
Цель: Разобраться с основами docker, с образа, эко системой docker в целом.

Описание ДЗ:
- Создайте свой кастомный образ nginx на базе alpine. 
- После запуска nginx должен отдавать кастомную страницу (достаточно изменить дефолтную страницу nginx)
- Определите разницу между контейнером и образом. Вывод опишите в домашнем задании.
- Ответьте на вопрос: Можно ли в контейнере собрать ядро?
- Собранный образ необходимо запушить в docker hub и дать ссылку на ваш
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
- FROM — задаёт базовый (родительский) образ.
- RUN — выполняет команду и создаёт слой образа. Используется для установки в контейнер пакетов.
- EXPOSE — указывает на то, какие порты планируется открыть для того, чтобы через них можно было бы связаться с работающим контейнером.
- COPY — копирует в контейнер файлы и папки. (конфиг и стартовую страницу). ADD позволяет решать те же задачи, что и COPY, но еще умеет добавлять в контейнер файлы, загруженные из удалённых источников, а также распаковывать локальные .tar-файлы.
- CMD — предоставляет Docker команду, которую нужно выполнить при запуске контейнера.

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
### Собираем и тестим:
Для начала собирается образ (указываем логин на Docker hub, чтобы потом запушить):
```
docker build -t yarkozloff/firstnginx .
```
Затем авторизуемся через консоль:
```
docker login
```
Загружаем (пушим) образ в личный удаленный репозиторий на Docker hub:
```
[root@yarkozloff mydocker]# docker push yarkozloff/firstnginx
The push refers to a repository [docker.io/yarkozloff/firstnginx]
1dce661ba643: Pushed
9f55b751c2e8: Pushed
da235ad86db7: Pushed
3a1175cc88be: Pushed
24302eb7d908: Mounted from library/alpine
latest: digest: sha256:8c739673947ead73acb885af2789275f9cdf728dc90c93130c08cddcb8284dd6 size: 1363
```
Теперь можно скачать образ из репозитория и запуститься:
```
[root@yarkozloff mydocker]# docker pull yarkozloff/firstnginx
Using default tag: latest
Trying to pull repository docker.io/yarkozloff/firstnginx ...
latest: Pulling from docker.io/yarkozloff/firstnginx
Digest: sha256:8c739673947ead73acb885af2789275f9cdf728dc90c93130c08cddcb8284dd6
Status: Downloaded newer image for docker.io/yarkozloff/firstnginx:latest
```
Порт 80 занят, поэтому использовал нестандартный:
```
[root@yarkozloff mydocker]# docker run -p 888:80 -d firstnginx
ceaf76c06541ad69c3ec1aaadd241502408a550ca2a87a5bc0a553fa5e43cc48
```
Теперь можно курлануть или открыть в браузере:
```
[root@yarkozloff mydocker]# curl http://localhost:888
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
Виртуалка без gui, открываю с рабочей станции:
![image](https://user-images.githubusercontent.com/69105791/174452500-07244c73-74dd-4dd9-8311-5b08dad1185e.png)
При выполнении дз понадобились удаления образов/контейнеров, воспользовался этой статьей:
https://linux-notes.org/ostanovit-udalit-vse-docker-kontejnery/


## Определите разницу между контейнером и образом.
- Образ представляет собой файловую систему с набором параметров (библиотеки, зависимости и тд), он создаётся из Dockerfile. Является шаблоном для создания контейнера и никогда не меняется.
- Контейнер представлет собой экземпляр образа и является конечной точкой в докере. На контейнер накладывается слой для записи, и если его закоммитить, то он станет образом.

## Можно ли в контейнере собрать ядро?
Контейнер это экземпляр образа. При изначальной сборке образа можно указать свой заранее собранный образ ОС в Dockerfile в параметре FROM, но после того как мы его коммитим изменения больше внести нельзя. Возможно за счет слоя записи в контейнере можно внести некоторые изменения в ядро.

## Собранный образ необходимо запушить в docker hub
https://hub.docker.com/r/yarkozloff/firstnginx
