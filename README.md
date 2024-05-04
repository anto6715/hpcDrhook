# Custom compile configuration for DRHOOK library in some HPC systems

The original readme is available in [README](README)

## How to compile

The system is able to detect automatically the hpc system where it's running using the global defined variable **HPC_SYSTEM**.
IT's sufficient to run the command:

```shell
./COMPILE.sh
```

## Library

After the compilation file, if no error occurs the following library must be generated:

```shell
libdrhook.a
```

## HPC

The supported HPC systems are:

* [ZEUS](https://www.cmcc.it/it/research/super-computing-center-scc)
* [JUNO](https://www.cmcc.it/it/research/super-computing-center-scc)
