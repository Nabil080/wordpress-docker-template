all:
	docker compose -f ./srcs/docker-compose.yml up --build

down:
	docker compose -f ./srcs/docker-compose.yml down -v

clean:
	docker stop $$(docker ps -qa)
	docker rm $$(docker ps -qa)
	docker rmi $$(docker images -qa)
	docker volume rm $$(docker volume ls -q)
	docker network rm network

re: down all

.PHONY: all down clean
