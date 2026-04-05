# Подключение и настройка OpenClaw

Пошаговая инструкция по установке и настройке [OpenClaw](https://github.com/openclaw/openclaw) — открытого AI-ассистента, который работает на вашем компьютере и подключается к мессенджерам (WhatsApp, Telegram, Discord, Slack и др.).

---

## Что такое OpenClaw?

OpenClaw — это бесплатный open-source AI-агент, который:

- работает на вашем железе (ноутбук, VPS, Raspberry Pi);
- подключается к 25+ мессенджерам (WhatsApp, Telegram, Discord, Slack, Signal и др.);
- использует языковые модели (Claude, GPT-4, Gemini, DeepSeek, локальные через Ollama);
- запоминает контекст между сессиями;
- поддерживает 13 700+ готовых навыков из ClawHub;
- работает как фоновый сервис (daemon).

---

## Требования

| Что нужно | Минимум | Рекомендуется |
|-----------|---------|---------------|
| Node.js | 22+ | 24 |
| RAM | 8 ГБ | 16 ГБ |
| ОС | Linux / macOS / Windows (WSL2) | Linux |
| API-ключ LLM | Один из: Anthropic, OpenAI, DeepSeek, Ollama | Anthropic Claude |

---

## Шаг 1. Установить Node.js

Если Node.js ещё не установлен, ставим через `nvm`:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.bashrc
nvm install 22
nvm use 22
```

Проверяем:

```bash
node --version
# Должно показать v22.x.x или выше
```

---

## Шаг 2. Установить OpenClaw

```bash
npm install -g openclaw@latest
```

Проверяем:

```bash
openclaw --version
```

> Альтернатива через pnpm: `pnpm add -g openclaw@latest`

---

## Шаг 3. Запустить мастер настройки

```bash
openclaw onboard --install-daemon
```

Мастер задаст несколько вопросов:

1. **Имя ассистента** — как будет представляться бот (например, «Clawd»).
2. **API-ключ** — ключ от выбранного LLM-провайдера.
3. **Мессенджер** — какой канал подключить (WhatsApp, Telegram и т.д.).

Флаг `--install-daemon` создаёт фоновый сервис:
- **Linux** — systemd-юнит
- **macOS** — launchd-агент

После этого OpenClaw запускается автоматически при загрузке системы.

---

## Шаг 4. Получить API-ключ

Выберите LLM-провайдера и получите ключ:

| Провайдер | Где получить | Переменная |
|-----------|-------------|------------|
| Anthropic (Claude) | [console.anthropic.com](https://console.anthropic.com) | `ANTHROPIC_API_KEY` |
| OpenAI (GPT-4) | [platform.openai.com](https://platform.openai.com) | `OPENAI_API_KEY` |
| DeepSeek | [platform.deepseek.com](https://platform.deepseek.com) | `DEEPSEEK_API_KEY` |
| Ollama (локально) | [ollama.com](https://ollama.com) | Не нужен |

Запишите ключ в файл `~/.openclaw/.env`:

```bash
mkdir -p ~/.openclaw
cp .env.example ~/.openclaw/.env
# Откройте файл и вставьте свой ключ:
nano ~/.openclaw/.env
```

Защитите файл:

```bash
chmod 600 ~/.openclaw/.env
```

---

## Шаг 5. Настроить конфиг

Основной файл конфигурации: `~/.openclaw/openclaw.json`

В этом репозитории есть готовый шаблон — [`openclaw.example.json`](./openclaw.example.json). Скопируйте его:

```bash
cp openclaw.example.json ~/.openclaw/openclaw.json
```

Отредактируйте под себя:

```bash
nano ~/.openclaw/openclaw.json
```

### Минимальный конфиг

```json
{
  "agent": {
    "workspace": "~/.openclaw/workspace"
  },
  "channels": {
    "whatsapp": {
      "allowFrom": ["+79001234567"]
    }
  }
}
```

### Полный конфиг (с Telegram + WhatsApp)

```json
{
  "identity": {
    "name": "Clawd",
    "theme": "helpful assistant",
    "emoji": "🦞"
  },
  "agent": {
    "workspace": "~/.openclaw/workspace",
    "model": {
      "primary": "anthropic/claude-sonnet-4-5",
      "fallback": "openai/gpt-4o"
    }
  },
  "channels": {
    "whatsapp": {
      "dmPolicy": "allowlist",
      "allowFrom": ["+79001234567"],
      "groups": {
        "*": {
          "requireMention": true
        }
      }
    },
    "telegram": {
      "botToken": "${TELEGRAM_BOT_TOKEN}",
      "dmPolicy": "allowlist",
      "allowFrom": ["123456789"],
      "groups": {
        "*": {
          "requireMention": true
        }
      }
    }
  }
}
```

---

## Шаг 6. Подключить мессенджер

### WhatsApp

1. В конфиге добавьте свой номер в `channels.whatsapp.allowFrom`.
2. Запустите `openclaw` — в терминале появится QR-код.
3. Откройте WhatsApp → «Связанные устройства» → сканируйте QR-код.

### Telegram

1. Создайте бота через [@BotFather](https://t.me/BotFather) в Telegram.
2. Скопируйте токен бота.
3. Запишите токен в `~/.openclaw/.env`:
   ```
   TELEGRAM_BOT_TOKEN=ваш_токен_от_botfather
   ```
4. В конфиге укажите свой Telegram ID в `channels.telegram.allowFrom`.
5. Перезапустите OpenClaw.

### Discord

1. Создайте приложение на [Discord Developer Portal](https://discord.com/developers/applications).
2. Включите бота и скопируйте токен.
3. Добавьте в `.env`: `DISCORD_BOT_TOKEN=ваш_токен`
4. В конфиге добавьте секцию `channels.discord`.

---

## Шаг 7. Проверить работу

```bash
openclaw doctor
```

Эта команда проверит:
- версию Node.js;
- наличие API-ключей;
- подключение к мессенджерам;
- состояние фонового сервиса.

---

## Полезные команды

| Команда | Что делает |
|---------|-----------|
| `openclaw` | Запускает в текущем терминале |
| `openclaw onboard` | Мастер первоначальной настройки |
| `openclaw doctor` | Диагностика проблем |
| `openclaw daemon start` | Запуск фонового сервиса |
| `openclaw daemon stop` | Остановка фонового сервиса |
| `openclaw daemon status` | Статус фонового сервиса |
| `openclaw skill install <name>` | Установка навыка из ClawHub |
| `openclaw skill list` | Список установленных навыков |
| `openclaw config edit` | Открыть конфиг в редакторе |

---

## Автоматическая установка

В этом репозитории есть скрипт [`setup.sh`](./setup.sh), который делает всё автоматически:

```bash
chmod +x setup.sh
./setup.sh
```

Скрипт:
1. Проверяет/устанавливает Node.js 22+.
2. Устанавливает OpenClaw глобально.
3. Создаёт директорию `~/.openclaw/`.
4. Копирует шаблоны конфига и `.env`.
5. Запускает `openclaw doctor`.

---

## Безопасность

- **Всегда обновляйтесь** до последней версии: `npm update -g openclaw`
- **API-ключи** храните только в `~/.openclaw/.env` с правами `chmod 600`.
- **Никогда не коммитьте** `.env`-файл с реальными ключами.
- В группах включайте `requireMention: true`, чтобы бот не отвечал на каждое сообщение.

---

## Ссылки

- [GitHub OpenClaw](https://github.com/openclaw/openclaw)
- [Документация](https://open-claw.bot/docs)
- [ClawHub (навыки)](https://clawhub.openclaw.dev)
- [Конфигурация](https://www.getopenclaw.ai/en/how-to/openclaw-configuration-guide)
