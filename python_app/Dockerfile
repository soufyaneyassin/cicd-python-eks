FROM  python:3.12-slim


WORKDIR /app

COPY pyproject.toml poetry.lock ./

COPY src ./src

COPY tests ./tests

RUN pip install poetry

RUN poetry config virtualenvs.create false \
    && poetry install --no-interaction 

EXPOSE 5000

CMD ["gunicorn", "app.main:create_app()", "--bind", "0.0.0.0:5000"]