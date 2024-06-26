# LocalDeployment Application

This deployment was auto-generated by the F' utility tool.

## Building and Running the LocalDeployment Application

In order to build the LocalDeployment application, or any other F´ application, we first need to generate a build directory. This can be done with the following commands:

```
fprime-util generate
```

The next step is to build the LocalDeployment application's code.
```
fprime-util build
```

## Running the application and F' GDS

The following command will spin up the F' GDS as well as run the application binary and the components necessary for the GDS and application to communicate.

```
fprime-gds -n --dictionary ./build-artifacts/<build name>/LocalDeployment/dict/LocalDeploymentAppDictionary.xml --comm-adapter uart --uart-device /dev/ttyACM0 --uart-baud 115200
```

Change `<build name>` to the build of your deployment (i.e. `teensy41`, `featherM0`, etc.).
