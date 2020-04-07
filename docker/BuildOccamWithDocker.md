
# For OCCAM users: #

```shell
docker pull sricsl/occam:bionic
docker run -v `pwd`:/host -it sricsl/occam:bionic
```

# For OCCAM developers: Building a new Docker image #

```shell
docker build --build-arg UBUNTU=bionic --build-arg BUILD_TYPE=Release -t sricsl/occam:bionic -f docker/occam.Dockerfile .

```

The above step will automatically download all dependencies and build OCCAM under `/occam`.

Build arguments (required):
- UBUNTU: trusty, xenial, bionic
- BUILD_TYPE: Release, Debug

# For OCCAM releasers: Pushing a Docker image to DockerHub #
