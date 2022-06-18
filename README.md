# Docker
Цель: Разобраться с основами docker, с образа, эко системой docker в целом.

## Подготовка окружения
Имеем сервер с ubuntu 20.10.12.
### Установка docker
Ставим docker, docker-compose: https://docs.docker.com/desktop/linux/install/ubuntu/
Проверяем статус службы, версию:
```
sudo systemctl status docker
docker version
```
Чтобы без проблем выполнять команды docker под обычной учеткой, необходимо добавить её в группу докер и перелогиниться:
```
sudo usermod -aG docker sam
```
### Подготовка nginx:aplpine


