# Alpine aports development environment

Brings a ready-to-use development environment to compile Alpine Linux aports

## Usage

Clone [aports](https://github.com/alpinelinux/aports), then inside the cloned project:

`docker run --rm -it -v $PWD:/aports -w /aports jrei/aports-dev`

Compile an aport as `dev` (who is sudoer):

```sh
cd $repository/$package
abuild -rP /tmp
```

See more instructions in the [official wiki](https://wiki.alpinelinux.org/wiki/Creating_an_Alpine_package)
