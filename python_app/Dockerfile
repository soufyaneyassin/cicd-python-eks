FROM  python:3.10-slim


WORKDIR /app

COPY pyproject.toml .

COPY src ./src

COPY tests ./tests

RUN pip install --no-cache-dir .

EXPOSE 5000

CMD ["gunicorn", "app.main:create_app()", "--bind", "0.0.0.0:5000"]