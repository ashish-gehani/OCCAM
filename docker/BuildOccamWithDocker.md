# Building OCCAM with Docker and running tests #

```shell
docker build --build-arg UBUNTU=xenial --build-arg BUILD_TYPE=Release -t occam/occam_xenial_rel -f docker/occam.Dockerfile .
docker run -v `pwd`:/host -it occam/occam_xenial_rel"
```

This will automatically download all dependencies from a base image
and build OCCAM under `/occam`.

Build arguments (required):
- UBUNTU: trusty, xenial, bionic
- BUILD_TYPE: Release, Debug

