#!/bin/bash

source env.var

for i in `seq 1 3`; do
printf "\n\n\nSetup $i manager node \n";
docker-machine create -d amazonec2 --amazonec2-instance-type "t2.small" \
  --amazonec2-region "eu-central-1" --amazonec2-subnet-id "subnet-ccbf57a5" \
  --engine-label role=db \
  --swarm \
  --swarm-master \
$NAME-swarm-manager$i&
done
wait

for i in `seq 2 3`; do
printf "\n\n\nSetup $i manager node \n";
docker-machine create -d amazonec2 --amazonec2-instance-type "t2.small" \
  --amazonec2-region "eu-central-1" --amazonec2-subnet-id "subnet-ccbf57a5" \
  --swarm \
  --swarm-master \
  --engine-label role=backend \
$NAME-swarm-manager$i&
done
wait

eval $(docker-machine env $NAME-swarm-manager1)
MANAGER_IP=$(docker-machine ip $NAME-swarm-manager1)

docker swarm init --advertise-addr $MANAGER_IP
MANAGER_TOKEN=$(docker swarm join-token --quiet manager)

eval $(docker-machine env $NAME-swarm-manager2)
docker swarm join \
--token $MANAGER_TOKEN \
$MANAGER_IP:2377

eval $(docker-machine env $NAME-swarm-manager3)
docker swarm join \
--token $MANAGER_TOKEN \
$MANAGER_IP:2377
