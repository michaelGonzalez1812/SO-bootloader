# SO-bootloader

Prerequisitos

```
instalar make
instalar qemu
```

## Instrucciones de compilación

Abra una terminal en la carpeta raiz del proyecto y ejecute los siguientes comandos
```
mkdir build
make
```
## Instrucciones de uso

Para ejectuar utilizando el emulador qemu ejecute el siguiente comando
```
qemu-system-x86_64 -fda build/snake.flp
```

para crear una dispositivo usb booteable ejecute el siguiente comando con permisos de superusuario

```
sudo dd if=build/snake.bin of=device/path
```

Este proyecto son modificaciones al proyecto del siguiente repositorio:

https://github.com/zakrent/Assembly-Snake-Bootable.git
