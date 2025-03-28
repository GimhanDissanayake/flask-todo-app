# syntax=docker/dockerfile:1 # Dockerfile syntax version (ensures that Docker uses the latest stable version of the Dockerfile syntax)

ARG PY_VERSION=3.12

# Stage 1: Build Stage
FROM python:${PY_VERSION}-alpine AS builder

ARG PY_VERSION

# Set the working directory inside the container
WORKDIR /app

# Install dependencies using requirements.txt
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Stage 2: Production Stage
FROM python:${PY_VERSION}-alpine

ARG PY_VERSION

# Set the working directory
WORKDIR /app

# create a non-root user
RUN adduser -D appuser
USER appuser

# Copy the installed dependencies from the build stage
COPY --from=builder /app /app
COPY --from=builder /usr/local/lib/python${PY_VERSION}/site-packages /usr/local/lib/python${PY_VERSION}/site-packages

EXPOSE 5000

# Use Gunicorn to run the app (production server)
CMD ["python", "-m", "gunicorn", "-b", "0.0.0.0:5000", "app:app"]

