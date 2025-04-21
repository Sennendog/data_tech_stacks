docker exec -it $(docker ps --filter name=jobmanager --format={{.ID}}) /bin/sh
