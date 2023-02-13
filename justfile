push:
    colmena apply switch -v

docker-compose:
    docker compose up -d

docker-config:
    docker compose cp ./config/komga/application.yml komga:/config/.
    docker compose cp ./config/homepage/. homepage:/app/config/.
    docker compose cp ./config/recyclarr/. recyclarr:/config/.

docker-setup: docker-config docker-compose