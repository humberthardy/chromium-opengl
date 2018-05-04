# Chromium with openGL support for [webrecorder](http://webrecorder.io) stack

## Requirements
1. Ubuntu with X11 server
2. `nvidia` GPU
3. docker 
4. [nvidia runtime for docker engine](https://github.com/NVIDIA/nvidia-docker)
5. nvidia driver > 390 (`sudo apt-get install nvidia-396`) 


## How to use it

1. Allow incomming connections to your X11 server (Run `xhost +` on your host OS)
2. Build the new `oldwebtoday/sphepherd` and `oldwebtoday/chromium-opengl:65` images by running `docker-compose build` from the terminal 
3. Restart your webrecorder's stack  

This modified version of `oldwebtoday/sphepherd` starts the browsers with:
   - `nvidia` runtime (equivalent to `docker run --runtime=nvidia`)
   - a bind of `/tmp/X11-unix:X0` between the host and browsers.
   - [privileged mode](https://docs.docker.com/engine/reference/run/#runtime-privilege-and-linux-capabilities) (equivalent to `docker run --privileged`)

Instead of using `oldwebtoday/base-browser` as base image, `oldwebtoday/chromium-opengl:65` is build from [glvnd-runtime](https://hub.docker.com/r/nvidia/opengl/) and use [TurboVNC](https://cdn.rawgit.com/TurboVNC/turbovnc/2.1.2/doc/index.html) (instead of `X11-vnc` and `Xvfb`)


## How it works
- X11 socket is shared between host and the docker containers.
- vglrun from [VirtualGl](https://www.virtualgl.org/) wrap the `chromium-browser` process. it redirects GPU calls inside the container to the host through the previous socket
- The flag `--disable-gpu-sandbox` is passed to Chromium. The normal behaviour of Chromium use some forks, and is bypassing `vglrun`. This flag avoid this.
   
