# I want to write a python dockerfile for a non-root user
# The dockerfile will create a non-root user and set the appropriate permissions for the application to run as that user.
# Use an official base image
# THE Dockerfile will be multistage to reduce the final image size.
# The Dockerfile will install the necessary dependencies and copy the application code to the image.
# The dockerfile should use distroless images for the final stage to minimize the attack surface.
# The dockerfile will also include a health check to ensure the application is running correctly.
 # The Dockerfile should have Harden the Runtime#
# =========================
# Stage 1: Builder
# =========================
FROM python:3.10-slim AS builder

WORKDIR /build

# Install dependencies into a dedicated directory
COPY requirements.txt .

RUN pip install \
    --no-cache-dir \
    --target=/install \
    -r requirements.txt

# Copy application files
COPY app.py .
COPY templates ./templates
COPY static ./static
COPY products.json .


# =========================
# Stage 2: Distroless Runtime
# =========================
FROM gcr.io/distroless/python3-debian12:nonroot

WORKDIR /app

# Copy Python dependencies
COPY --from=builder /install /app/site-packages

# Copy application
COPY --from=builder /build/app.py ./app.py
COPY --from=builder /build/templates ./templates
COPY --from=builder /build/static ./static
COPY --from=builder /build/products.json ./products.json

# Tell Python where the dependencies are
ENV PYTHONPATH=/app/site-packages

EXPOSE 8777

CMD ["app.py"]

