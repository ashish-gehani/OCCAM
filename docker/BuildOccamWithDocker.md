# For OCCAM developers: Building a new Docker image #

```shell
docker build --build-arg UBUNTU=xenial --build-arg BUILD_TYPE=Release -t sricsl/occam:xenial -f docker/occam.Dockerfile .

```

The above step will automatically download all dependencies and build OCCAM under `/occam`.

Build arguments (required):
- UBUNTU: trusty, xenial, bionic
- BUILD_TYPE: Release, Debug

# For OCCAM users: #

```shell
docker pull sricsl/occam:xenial
docker run -v `pwd`:/host -it sricsl/occam:xenial"
```
