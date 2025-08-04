# Docker ELK 8.13.4

This project sets up a Docker-based environment for the **ELK Stack (Elasticsearch, Logstash, and Kibana) version 8.13.4**. The main purpose is to **study and understand** how the ELK stack works in a local development setting.

> ⚠️ **Note:** This setup is **not intended for production use**. It was built solely for educational and testing purposes.

## Stack Overview

* **Elasticsearch** 8.13.4
* **Kibana** 8.13.4
* **Logstash** 8.13.4

All services are defined using a `docker-compose.yml` file for easy deployment and orchestration.

## Customization

You can modify the configuration files for Elasticsearch, Kibana, or Logstash to experiment and learn how each component behaves.

If you want to use your own pipeline or config files, simply map your local configuration into the containers using volume mounts in the `docker-compose.yml` file.

## Usage

### Building the Docker Images (if using custom Dockerfiles)

```bash
docker-compose build
```

### Running the ELK Stack

```bash
docker-compose up -d
```

After startup:

* Access **Kibana** at: [http://localhost:5601](http://localhost:5601)
* Elasticsearch runs on port `9200`
* Logstash listens on port `5044` by default

## Learning Resources

* [Elasticsearch Documentation](https://www.elastic.co/guide/en/elasticsearch/reference/8.13/index.html)
* [Kibana Documentation](https://www.elastic.co/guide/en/kibana/8.13/index.html)
* [Logstash Documentation](https://www.elastic.co/guide/en/logstash/8.13/index.html)

## License

This project is open for personal use and learning. Refer to Elastic's licensing model for commercial or production deployment.
