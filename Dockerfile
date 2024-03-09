# Use the official Golang image from the Docker Hub as the base image
FROM golang:1.16 as build

# Set the working directory inside the container
WORKDIR /go/src/app

# Copy everything from the current directory to the working directory inside the container
COPY . .

# Run the 'make' command to build the application
RUN make

# Start a new stage from scratch
FROM scratch

# Copy all HTML, PNG, JS, ICO, and CSS files from the current directory to the root directory inside the container
COPY *.html ./
COPY *.png ./
COPY *.js ./
COPY *.ico ./
COPY *.css ./

# Copy the 'rollouts-demo' binary from the 'build' stage to the root directory inside the container
COPY --from=build /go/src/app/rollouts-demo /rollouts-demo

# Declare and set the 'COLOR' environment variable
ARG COLOR
ENV COLOR=${COLOR}

# Declare and set the 'ERROR_RATE' environment variable
ARG ERROR_RATE
ENV ERROR_RATE=${ERROR_RATE}

# Declare and set the 'LATENCY' environment variable
ARG LATENCY
ENV LATENCY=${LATENCY}

# Specify the command to run when the container starts
ENTRYPOINT [ "/rollouts-demo" ]
