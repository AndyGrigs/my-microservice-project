FROM python:3.11-slim

WORKDIR /app

# Copy requirements first — this layer is cached separately
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN python manage.py collectstatic --noinput

EXPOSE 8000

# gunicorn instead of runserver — production WSGI server
CMD ["gunicorn", "myproject.wsgi:application", "--bind", "0.0.0.0:8000", "--workers", "3"]
