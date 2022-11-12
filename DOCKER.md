# FoundryVTT

Run [FoundryVTT](https://foundryvtt.com/) in a docker container with a proxy provided by nginx.

This will locally bind to 8443/tcp and 443/tcp (from the nginx service). [Existing port forwarding instructions](https://foundryvtt.com/article/port-forwarding/) apply from maintainer documentation. Feel free to [enable or disable ports](https://docs.docker.com/compose/networking/) as desired or remap as seen in `docker-compose.yaml`

Data will be stored locally in `./foundry-data` so that it persists between runs. 

## Installation with Docker-Compose

* Dependencies: `docker`, `docker-compose`, and a valid [FoundryVTT purchase](https://foundryvtt.com/purchase/)

### Deploy

1. Clone this respository.

```sh
$ git clone https://github.com/boyobejamin/FoundryVTT-Docker
$ cd FoundryVTT-Docker
```

2. Download FoundryVTT and copy it to this folder

```sh
$ ls FoundryVTT*
FoundryVTT-9.269.zip
```

3. Update `./Dockerfile` with the currently downloaded verison of FoundryVTT number (IF DIFFERENT)

4. Deploy. 

```sh
$ docker-compose up -d --build
```

### Troubleshooting

```sh
$ docker logs nginx
$ docker logs foundryvtt
```

### Docker-Compose Variables

| Name | Description | 
| --- | --- |
| SSL_CERT_BASE64 | PEM certificate provided as a base64 encoded string. Useful if you want to provide a signed certifiate, such as [Let's Encrypt](https://letsencrypt.org/) |
| SSL_KEY_BASE64 | RSA Key provided as a base64 encoded string. Useful if you want to provide a signed certifiate, such as [Let's Encrypt](https://letsencrypt.org/)|
| VTT_HOSTNAME | Override hostname, such as `vtt.dndiscool.net` |