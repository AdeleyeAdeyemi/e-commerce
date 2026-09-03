# I want to write a python dockerfile for a non-root user
# The dockerfile will create a non-root user and set the appropriate permissions for the application to run as that user.
# Use an official base image
# THE Dockerfile will be multistage to reduce the final image size.
# The Dockerfile will install the necessary dependencies and copy the application code to the image.
# The dockerfile should use distroless images for the final stage to minimize the attack surface.
# The dockerfile will also include a health check to ensure the application is running correctly.
 # The Dockerfile should have Harden the Runtime#

FROM  python:3.10-slim AS builder

WORKDIR /build

COPY requirements.txt .

RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

COPY app.py .
COPY templates ./templates
COPY static ./static
COPY products.json .

FROM gcr.io/distroless/python3-debian12:nonroot

WORKDIR /app

# Copy installed Python packages
COPY --from=builder /install /usr/local

# Copy application
COPY --from=builder /build/app.py ./app.py
COPY --from=builder /build/templates ./templates
COPY --from=builder /build/static ./static
COPY --from=builder /build/products.json ./products.json

EXPOSE 8777

CMD ["app.py"]
