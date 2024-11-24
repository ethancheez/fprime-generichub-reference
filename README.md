# fprime-hub-test F' project

## Combine Dictionaries
```sh
python3 combine_dictionaries build-artifacts/teensy41/TeensyToPi_LocalDeployment/dict/LocalDeploymentTopologyAppDictionary.xml build-artifacts/aarch64-linux/TeensyToPi_RemoteDeployment/dict/RemoteDeploymentTopologyAppDictionary.xml dictionary.xml
```

## Teensy to Pi

Pi:
```sh
sudo ./TeensyToPi_RemoteDeployment -d /dev/ttyS0 -b 115200
```

GDS:
```sh
fprime-gds -n --dictionary dictionary.xml --communication-selection uart --uart-device /dev/ttyACM0 --uart-baud 115200
```
