# Мій власний мікросервісний проєкт

Це репозиторій для навчального проєкту в межах курсу "DevOps CI/CD".

## Мета

Навчитися основам роботи з Git, GitHub та розгортання Django-застосунків у Docker.

---

## Опис проєкту

Веб-застосунок на базі **Django**, розгорнутий у Docker-контейнерах з використанням **PostgreSQL** як бази даних та **Nginx** як реверс-проксі.

## Архітектура

```
Client → Nginx (:80) → Django/Gunicorn (:8000) → PostgreSQL (:5432)
```

| Сервіс  | Технологія       | Призначення                        |
|---------|------------------|------------------------------------|
| `nginx` | Nginx Alpine     | Реверс-проксі, обробка HTTP-запитів |
| `web`   | Django + Gunicorn| Веб-застосунок                     |
| `db`    | PostgreSQL 15    | Зберігання даних                   |

## Структура проєкту

```
my-microservice-project/
├── Dockerfile          # Образ для Django-застосунку
├── docker-compose.yml  # Опис усіх сервісів
├── requirements.txt    # Python-залежності
├── manage.py           # Django CLI
├── myproject/
│   ├── settings.py     # Налаштування Django
│   ├── urls.py         # Маршрути (включно з /health/)
│   └── wsgi.py         # WSGI-точка входу
└── nginx/
    └── nginx.conf      # Конфігурація Nginx
```

## Вимоги

- [Docker](https://www.docker.com/) >= 20.x
- [Docker Compose](https://docs.docker.com/compose/) >= 2.x

## Запуск проєкту

```bash
# Клонувати репозиторій
git clone <repo-url>
cd my-microservice-project

# Запустити всі сервіси у фоновому режимі
docker-compose up -d

# Переглянути логи
docker-compose logs -f

# Зупинити сервіси
docker-compose down
```

## Перевірка роботи

| URL | Опис |
|-----|------|
| http://localhost | Головна сторінка застосунку |
| http://localhost/health/ | Перевірка стану застосунку |
| http://localhost/admin/ | Панель адміністратора Django |

## Змінні середовища

| Змінна | Значення за замовчуванням | Опис |
|--------|--------------------------|------|
| `DJANGO_SECRET_KEY` | `change-me-in-production` | Секретний ключ Django |
| `DJANGO_ALLOWED_HOSTS` | `localhost,127.0.0.1` | Дозволені хости |
| `DATABASE_URL` | — | URL підключення до PostgreSQL |
