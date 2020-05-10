
# For OCCAM users: #

```shell
docker pull sricsl/occam10:bionic
docker run -v `pwd`:/host -it sricsl/occam10:bionic
```

# For OCCAM developers: Building a new Docker image #

```shell
docker build --build-arg UBUNTU=bionic --build-arg BUILD_TYPE=Release -t sricsl/occam10:bionic -f docker/occam.Dockerfile .

```

The above step will automatically download all dependencies and build OCCAM under `/occam`.

Build arguments (required):
- UBUNTU: bionic
- BUILD_TYPE: Release, Debug

# For OCCAM releasers: Pushing a Docker image to DockerHub #

```shell
# Login
echo "$DOCKER_PASSWORD" | docker login --username="$DOCKER_USERNAME" --password-stdin
# Push
docker push sricsl/occam10:bionic
```
