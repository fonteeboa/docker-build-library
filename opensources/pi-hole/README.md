# Pi-hole Web

This Dockerfile sets up a container using the latest Pi-hole image for local development. It allows you to copy modified files into the web folder for customization.

## Customization

If you do not want to copy your custom files, comment out the following lines in the Dockerfile:

```dockerfile
RUN rm -rf /var/www/html/admin
COPY . /var/www/html/admin/
```

This project is used for customizing the Pi-hole web interface. You can find the related [fork here](https://github.com/fonteeboa/pihole-web).

For more details, check out the official [Pi-hole documentation](https://docs.pi-hole.net/).

## Usage

### Building the Docker Image

```bash
docker build -t pihole/custom-web:latest .
```

### Running the Container

```bash
docker run -d --name pihole-web \
  -p 53:53/tcp -p 53:53/udp \
  -p 67:67/udp -p 80:80/tcp \
  pihole/custom-web
```
