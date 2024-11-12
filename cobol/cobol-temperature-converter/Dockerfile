# Start from the latest version of the Debian base image
FROM debian:latest

# Update package lists, install GnuCOBOL, and clean up cache to reduce image size
RUN apt-get update && \
    apt-get install -y gnucobol && \
    apt-get clean

# Set the working directory for the container
WORKDIR /app

# Copy all files from the local context to the container's working directory
COPY . .

# Compile the specified COBOL file (TemperatureConverter.cob) into an executable
RUN cobc -x -o TemperatureConverter TemperatureConverter.cob

# Define the default command to run the compiled program
CMD ["./TemperatureConverter"]
