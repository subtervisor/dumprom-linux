# dumprom-linux

A Linux port of **dumprom**, a Windows CE ROM dumping and analysis utility, now with compression support. dumprom was developed by Willem Jan Hengeveld. This project makes no code changes to it, only adds the needed glue for compression support.

## Prerequisites

### System Requirements

- Linux x86-64 system
- GCC/G++ with 32-bit multilib support (`gcc -m32`)
- GNU Make (>= 4.3 for grouped-target rules)
- `ar` (part of binutils)

### Dependencies

Install 32-bit development libraries on Ubuntu/Debian:

```bash
sudo apt-get install gcc-multilib g++-multilib
```

On Fedora/RHEL:

```bash
sudo dnf install glibc-devel.i686 libstdc++-devel.i686
```

On Arch Linux:

```bash
sudo pacman -S multilib-devel
```

## Building

```bash
# Clone with submodule (objconv)
git clone --recursive https://github.com/subtervisor/dumprom-linux
cd dumprom-linux

# Ensure NKCOMPR.LIB is in the current directory before building
make
```

The build output is a 32-bit Linux executable: `./dumprom`

## References

- dumprom: [dumprom romfile extraction tool](https://itsme.home.xs4all.nl/projects/xda/dumprom.html)
- Binary format conversion: [objconv - Binary Format Converter](https://www.agner.org/optimize/#objconv)

## License

Based on original dumprom code by Willem Jan Hengeveld. This build system is released in the public domain.
