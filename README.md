# zeek-pcap-docker

Usage:

1) Build the container:

To build the container use the following:

```
podman build -t zeek-process:latest .
```

2) To utilize this container, place any pcap in a directory and then run the following from
within that directory:

```bash
podman run --rm \
  -v `pwd`:/pcap \
  localhost/zeek-process:latest
```

Notes:

Podman can be replaced with docker as appropriate.
