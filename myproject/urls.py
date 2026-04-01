from django.contrib import admin
from django.urls import path
from django.http import JsonResponse, HttpResponse


def index(request):
    html = """
    <!DOCTYPE html>
    <html>
    <head><title>Django + Docker</title></head>
    <body>
        <h1>Django працює!</h1>
        <p>Стек: Django + PostgreSQL + Nginx + Docker</p>
        <ul>
            <li><a href="/health/">Health check</a></li>
            <li><a href="/admin/">Admin panel</a></li>
        </ul>
    </body>
    </html>
    """
    return HttpResponse(html)


def health(request):
    return JsonResponse({'status': 'ok'})


urlpatterns = [
    path('', index),
    path('admin/', admin.site.urls),
    path('health/', health),
]
