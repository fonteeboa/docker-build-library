FROM debian:latest
RUN apt-get update && \
    apt-get install -y gnucobol && \
    apt-get clean
WORKDIR /app
COPY . .
RUN cobc -x -o TemperatureConverter TemperatureConverter.cob
CMD ["./TemperatureConverter"]
