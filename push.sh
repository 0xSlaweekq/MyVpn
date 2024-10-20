#!/bin/bash

# start bash -i ./start.sh
# alias defpass="echo 'YOUR_DOCKER_PASS"
# alias doccon="docker login -u YOUR_DOCKER_USER_NAME --password-stdin"
# defpass | doccon
# docker image prune -af

IMAGES=''3proxy' '3x-ui' 'outline''

for image in $IMAGES
do
  echo "Start building and push $image"
  docker buildx build -f ./$image/Dockerfile -t slaweekq/$image:latest --push ./$image
  echo "Successfily pulled image: slaweekq/$image:latest

  "
done


echo "Start building and push myvpn"
docker buildx build -f ./Dockerfile -t slaweekq/myvpn:latest --push .
echo "Successfily pulled image: slaweekq/myvpn:latest, 3proxy, 3x-ui and outline

"
