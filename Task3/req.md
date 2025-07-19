# Требования к интеграциям «Smart Intercom» и «Smart Barrier»

## 1. Общие требования

1.1. **TLS 1.2+**  
- Все API-вызовы PropDev ↔ партнёры должны идти по HTTPS (TLS ≥1.2).  
- Сертификаты — доверенный CA, проверяются на обеих сторонах.

1.2. **JWT-аутентификация (RS256)**  
- PropDev (tenant-core-api) выдаёт токены RSA-2048 (алгоритм RS256).  
- Партнёры проверяют подпись по публичному ключу PropDev.  
- Время жизни токена ≤1 ч, ротация ключей — каждые 30 мин.

1.3. **IP-whitelisting / mTLS**  
- На фаерволах пропустить только фиксированные IP Prod-сетей.  
- Для операций открытия двери/шлагбаума использовать mutual TLS.

## 2. Аутентификация и авторизация

2.1. **JWT Claims**  
- `iss`: https://auth.propdev.ru  
- `sub`: hashedResidentId или userId УК  
- `exp`: время истечения  
- `scope`: один из `smart_intercom:read`, `smart_intercom:write`, `smart_barrier:read`, `smart_barrier:write`  
- `aud`: smart-services

2.2. **RBAC-ролии**  
- **Resident**: intercom/barrier `request`, видеопоток (read)  
- **Manager_UK**: CRUD `/uk/{houseId}/residents`, просмотр логов  
- **DevOps**: full deploy права, но без доступа к реальным ПД  
- **IB_Admin**: чтение всех логов, ротация токенов, отзыв сертификатов  

## 3. Передача и хранение данных

3.1. **Видеопоток (WSS)**  
- Низкобитрейтный H.264 (≤300 Кбит/с), ключевые кадры.  
- VPN/Wireguard от камеры до облака партнёра → WebSocket → мобильное приложение.

3.2. **Хеширование PII**  
- Передавать только `residentHashId` / `plateHashId` (SHA-256 + salt).  
- Изображения (снимки) хранить ≤24 ч, объём ≤1 МБ.

3.3. **Логи в PropDev**  
```sql
CREATE TABLE smart_services.smart_intercom_logs (
  id SERIAL PRIMARY KEY,
  resident_hash VARCHAR(64) NOT NULL,
  event_type VARCHAR(32) NOT NULL,        -- "request", "allowed", "denied"
  timestamp TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  metadata JSONB
);