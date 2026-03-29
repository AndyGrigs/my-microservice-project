#!/bin/bash
# =============================================================
# install_dev_tools.sh
# Скрипт для автоматичного встановлення Docker, Docker Compose,
# Python 3.9+ та Django на Ubuntu / Debian
# =============================================================

set -e  # зупиняємо скрипт при будь-якій помилці

# ---------- допоміжна функція для кольорового виводу ----------
info()  { echo -e "\e[34m[INFO]\e[0m  $1"; }
ok()    { echo -e "\e[32m[OK]\e[0m    $1"; }
warn()  { echo -e "\e[33m[WARN]\e[0m  $1"; }

# ---------- перевірка прав root ----------
if [[ $EUID -ne 0 ]]; then
    warn "Скрипт потребує прав root. Запустіть через sudo."
    exit 1
fi

# ---------- оновлення списку пакетів ----------
info "Оновлення списку пакетів..."
apt-get update -y

# =============================================================
# 1. Docker
# =============================================================
if command -v docker &>/dev/null; then
    ok "Docker вже встановлено: $(docker --version)"
else
    info "Встановлення Docker..."
    apt-get install -y ca-certificates curl gnupg

    # додаємо офіційний GPG-ключ Docker
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
        | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg

    # додаємо репозиторій Docker
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
      https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
      > /etc/apt/sources.list.d/docker.list

    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io

    ok "Docker встановлено: $(docker --version)"
fi

# =============================================================
# 2. Docker Compose (плагін v2)
# =============================================================
if docker compose version &>/dev/null; then
    ok "Docker Compose вже встановлено: $(docker compose version)"
else
    info "Встановлення Docker Compose..."
    apt-get install -y docker-compose-plugin

    ok "Docker Compose встановлено: $(docker compose version)"
fi

# =============================================================
# 3. Python 3.9+
# =============================================================
# Шукаємо python3 і перевіряємо версію >= 3.9
PYTHON_OK=false
if command -v python3 &>/dev/null; then
    PY_VER=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
    PY_MAJOR=$(echo "$PY_VER" | cut -d. -f1)
    PY_MINOR=$(echo "$PY_VER" | cut -d. -f2)
    if [[ "$PY_MAJOR" -ge 3 && "$PY_MINOR" -ge 9 ]]; then
        PYTHON_OK=true
        ok "Python вже встановлено: python3 $PY_VER"
    else
        warn "Знайдено Python $PY_VER (потрібна >= 3.9). Встановлюємо новішу версію..."
    fi
fi

if [[ "$PYTHON_OK" == false ]]; then
    info "Встановлення Python 3 та pip..."
    apt-get install -y python3 python3-pip python3-venv

    PY_VER=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
    ok "Python встановлено: python3 $PY_VER"
fi

# =============================================================
# 4. Django (через pip)
# =============================================================
# Перевіряємо наявність pip (міг бути пропущений якщо Python вже існував)
if ! python3 -m pip --version &>/dev/null; then
    info "Встановлення pip..."
    apt-get install -y python3-pip
fi

if python3 -m django --version &>/dev/null; then
    ok "Django вже встановлено: $(python3 -m django --version)"
else
    info "Встановлення Django через pip..."
    python3 -m pip install django --break-system-packages 2>/dev/null \
        || python3 -m pip install django

    ok "Django встановлено: $(python3 -m django --version)"
fi

# =============================================================
echo ""
info "========== Підсумок =========="
echo "  Docker:         $(docker --version 2>/dev/null || echo 'не знайдено')"
echo "  Docker Compose: $(docker compose version 2>/dev/null || echo 'не знайдено')"
echo "  Python:         $(python3 --version 2>/dev/null || echo 'не знайдено')"
echo "  Django:         $(python3 -m django --version 2>/dev/null || echo 'не знайдено')"
echo ""
ok "Усі інструменти готові до роботи!"
