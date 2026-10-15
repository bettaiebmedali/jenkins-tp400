FROM python:3.12-slim

ARG APP_VERSION=dev
ENV APP_VERSION=${APP_VERSION}

WORKDIR /app
COPY app.py .

EXPOSE 8000
USER nobody
CMD ["python", "app.py"]