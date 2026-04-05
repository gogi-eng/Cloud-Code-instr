#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[✓]${NC} $*"; }
warn()  { echo -e "${YELLOW}[!]${NC} $*"; }
error() { echo -e "${RED}[✗]${NC} $*"; }

echo ""
echo "========================================="
echo "  OpenClaw — автоматическая установка"
echo "========================================="
echo ""

# --- 1. Проверка Node.js ---
REQUIRED_NODE_MAJOR=22

if command -v node &>/dev/null; then
    NODE_VERSION=$(node --version | sed 's/v//')
    NODE_MAJOR=$(echo "$NODE_VERSION" | cut -d. -f1)
    if [ "$NODE_MAJOR" -ge "$REQUIRED_NODE_MAJOR" ]; then
        info "Node.js $NODE_VERSION — подходит"
    else
        warn "Node.js $NODE_VERSION — нужна версия $REQUIRED_NODE_MAJOR+"
        warn "Устанавливаем через nvm..."
        if ! command -v nvm &>/dev/null; then
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
            export NVM_DIR="$HOME/.nvm"
            [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
        fi
        nvm install "$REQUIRED_NODE_MAJOR"
        nvm use "$REQUIRED_NODE_MAJOR"
        info "Node.js $(node --version) установлен"
    fi
else
    warn "Node.js не найден. Устанавливаем через nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
    nvm install "$REQUIRED_NODE_MAJOR"
    nvm use "$REQUIRED_NODE_MAJOR"
    info "Node.js $(node --version) установлен"
fi

# --- 2. Установка OpenClaw ---
if command -v openclaw &>/dev/null; then
    CURRENT_VERSION=$(openclaw --version 2>/dev/null || echo "unknown")
    info "OpenClaw уже установлен ($CURRENT_VERSION)"
    read -rp "Обновить до последней версии? [y/N] " UPDATE
    if [[ "$UPDATE" =~ ^[Yy]$ ]]; then
        npm install -g openclaw@latest
        info "OpenClaw обновлён до $(openclaw --version)"
    fi
else
    warn "OpenClaw не найден. Устанавливаем..."
    npm install -g openclaw@latest
    info "OpenClaw $(openclaw --version) установлен"
fi

# --- 3. Создание директории конфигурации ---
OPENCLAW_DIR="$HOME/.openclaw"

if [ ! -d "$OPENCLAW_DIR" ]; then
    mkdir -p "$OPENCLAW_DIR"
    info "Создана директория $OPENCLAW_DIR"
else
    info "Директория $OPENCLAW_DIR уже существует"
fi

mkdir -p "$OPENCLAW_DIR/workspace"

# --- 4. Копирование шаблонов ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -f "$OPENCLAW_DIR/openclaw.json" ]; then
    if [ -f "$SCRIPT_DIR/openclaw.example.json" ]; then
        cp "$SCRIPT_DIR/openclaw.example.json" "$OPENCLAW_DIR/openclaw.json"
        info "Конфиг скопирован → $OPENCLAW_DIR/openclaw.json"
    else
        warn "Файл openclaw.example.json не найден в $SCRIPT_DIR"
    fi
else
    warn "Конфиг уже существует: $OPENCLAW_DIR/openclaw.json (не перезаписываем)"
fi

if [ ! -f "$OPENCLAW_DIR/.env" ]; then
    if [ -f "$SCRIPT_DIR/.env.example" ]; then
        cp "$SCRIPT_DIR/.env.example" "$OPENCLAW_DIR/.env"
        chmod 600 "$OPENCLAW_DIR/.env"
        info "Шаблон .env скопирован → $OPENCLAW_DIR/.env"
    else
        warn "Файл .env.example не найден в $SCRIPT_DIR"
    fi
else
    warn "Файл .env уже существует: $OPENCLAW_DIR/.env (не перезаписываем)"
fi

# --- 5. Диагностика ---
echo ""
echo "========================================="
echo "  Диагностика"
echo "========================================="
echo ""

if command -v openclaw &>/dev/null; then
    openclaw doctor || true
fi

# --- Готово ---
echo ""
echo "========================================="
echo "  Что дальше?"
echo "========================================="
echo ""
echo "1. Добавьте API-ключ в $OPENCLAW_DIR/.env"
echo "   nano $OPENCLAW_DIR/.env"
echo ""
echo "2. Настройте конфиг под себя:"
echo "   nano $OPENCLAW_DIR/openclaw.json"
echo ""
echo "3. Запустите мастер настройки:"
echo "   openclaw onboard --install-daemon"
echo ""
echo "4. Или запустите напрямую:"
echo "   openclaw"
echo ""
info "Установка завершена!"
