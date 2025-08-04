# COBOL Temperature Converter Docker

This Dockerfile sets up a container to compile and run the **COBOL Temperature Converter** project using **GnuCOBOL**.

The container provides an isolated environment for experimenting with legacy COBOL applications in a modern Dockerized workflow.

## Repository

You can find the source code and Docker setup in the project repository:
[github.com/fonteeboa/cobol-temperature-converter](https://github.com/fonteeboa/cobol-temperature-converter)

## Purpose

This project was created to:

* Explore COBOL development using modern tools
* Provide a portable runtime for compiling and executing COBOL
* Serve as a learning exercise for language interoperability and legacy system simulation

## Quick Start

```bash
docker build -t cobol/temp-converter .
docker run --rm cobol/temp-converter
```

---

Made with nostalgia and curiosity
