# Task3. Внешние интеграции (Smart Intercom & Smart Barrier)

### 1. Диаграмма контекста (C4 Context Diagram)

Ниже приведено текстовое описание компонентов и связей, которые необходимо изобразить на контекст-диаграмме. Вы можете взять шаблон C4 Context Diagram из Draw.io, перенести следующие блоки и связи, а затем сохранить как `Task3/context_diagram.drawio` и экспортировать в PDF/PNG.

#### 1.1. Компоненты и акторы

1. **Акторы (стейкхолдеры):**
   - **Собственник (Tenant)**  
     • Использует мобильное приложение (`tenant-core-app`) для управления смарт-услугами (домофон, шлагбаум), оплаты ЖКУ, просмотра информации о ремонтах.
   - **Управляющая компания (UK Manager)**  
     • Администратор: создаёт/удаляет разрешённых жильцов, просматривает логи доступа, настраивает правила распознавания.
   - **DevOps/Админ PropDev**  
     • Управляет инфраструктурой `tenant-core-app`, `CRM`, DNS, SSL-сертификатами, мониторингом. В случае проблем следит за работой интеграций.
   - **ИБ-специалист PropDev**  
     • Отвечает за безопасность API, аудиты, контроль мTLS, проверяет логи подозрительной активности.
   - **Партнёрские системы (External Smart Services):**
     1. **Partner – Smart Intercom Service**  
        – Обеспечивает распознавание лиц (ML/AI), видеострим, управление замком домофона.  
        – Содержит свою базу данных (Список разрешённых жильцов в зашифрованном виде, видео-архив).  
     2. **Partner – Smart Barrier Service**  
        – Обеспечивает распознавание автомобильных номеров (ANPR), управление шлагбаумом.  
        – Своя БД (псевдонимы номеров, логи попыток проезда).

2. **Системы PropDevelopment:**
   - **tenant-core-app (Mobile)**  
     • Kotlin / Swift (React Native) приложение для iOS/Android.  
     • Получает видеопоток через WebSocket, отправляет REST-запросы по открытию домофона/шлагбаума, принимает Push-уведомления (FCM/APNs).
   - **tenant-core-api (Backend)**  
     • Java Spring Boot (или .NET WebAPI).  
     • Exposes REST API: `/api/house/{houseId}/intercom`, `/api/house/{houseId}/barrier`.  
     • Обрабатывает JWT-токены, проверяет права, пересылает запросы к партнёрам, записывает логи доступа в `tenant-core-db`.
   - **tenant-core-db (Postgres)**  
     • Содержит таблицы жильцов, разрешённых лиц (hashedResidentId), истории запросов к домофону/шлагбауму (event logs), настройки модуля «Умный дом».
   - **CRM УК (`crm-tenant-app`)**  
     • Веб-интерфейс, где сотрудники УК: <br>– управляют списками разрешённых жильцов и номеров (через тот же API или через backend).  
   - **Push-Gateway (Firebase Cloud Messaging / Apple Push Notification)**  
     • Отвечает за доставку пушей собственнику при неудачном распознавании (уведомление «Доступ не разрешён»).
   - **DWH/BI**  
     • Собирает логи из `tenant-core-db`, строит отчёты по статистике использования «Умного дома» (Analytics).

3. **Сторонние (внешние) интерфейсы**:
   - **Gov Registry (Госорган по регистрации)**  
     • Передача сведений о новых договорах при онлайн-сделках (Task 1/2/3).  
   - **Payment Gateway (Системы приёма платежей)**  
     • Оплата ЖКУ через `tenant-core-app`.  
   - **Поставщики ресурсов ЖКУ (Utility Providers)**  
     • Интеграция для получения/передачи информации о состоянии дома (количество воды, газа), счётчики и т. д. (Task 2).

#### 1.2. Описание связей (стрелки)

- **Собственник ↔ tenant-core-app (Mobile)**  
  • WebSocket (WSS) → видеопоток от Partner-Intercom при звонке/распознавании.  
  • HTTPS (JWT) → REST `/api/house/{houseId}/intercom/request`.  
  • HTTPS (JWT) → REST `/api/house/{houseId}/barrier/request`.  
  • FCM / APNs → Push-уведомления при отказе доступа.

- **tenant-core-app (Mobile) ↔ tenant-core-api (Backend)**  
  • HTTPS (JWT) — аутентификация + авторизация запросов (residentId, houseId, action).

- **tenant-core-api (Backend) ↔ tenant-core-db (Postgres)**  
  • JDBC / HTTPS – записывает логи запросов к партнёрам, читает конфигурацию жильцов, разрешённых лиц.

- **tenant-core-api (Backend) ↔ Partner‐Smart‐Intercom Service**  
  • HTTPS (JWT signed by PropDev, проверяемый партнёром) → запрос «recognizeFace».  
  • Партнёр возвращает JSON с результатом: `{ allowed: true/false, residentHashId: "…" }`.  
  • Если allowed = true → возвращает управление обратно в tenant-core-api, tenant-core-api отдаёт «openDoor» в WebSocket (для tenant-core-app или консьержа).

- **Partner‐Smart‐Intercom Service ↔ Partner DB**  
  • (Внутренний протокол партнёра, не отображается на диаграмме PropDev).

- **tenant-core-api (Backend) ↔ Partner‐Smart‐Barrier Service**  
  • HTTPS (JWT) → запрос «recognizePlate» с номерным знаком.  
  • Сервис возвращает `{ allowed: true/false, plateHashId: "…" }`.  
  • Если allowed = true → tenant-core-api выдаёт команду «openBarrier» в соответствующее СКУД (через IoT-шлюз первого партнёра) → открытие шлагбаума.

- **Partner‐Smart‐Barrier Service ↔ Partner DB**  
  • (Внутренний протокол партнёра).

- **tenant-core-api (Backend) ↔ Push-Gateway (FCM/APNs)**  
  • Push Notification (JSON payload) при отказе: «Доступ запрещён. Обратитесь к УК.»

- **CRM УК (`crm-tenant-app`) ↔ tenant-core-api (Backend)**  
  • HTTPS (JWT с ролью `Manager_UK`) → CRUD разрешённых жильцов/номеров.  
  • tenant-core-api обновляет таблицы `allowed_residents`, `allowed_plates` в tenant-core-db.

- **DevOps / ИБ ↔ tenant-core-api**  
  • AD/LDAP для аутентификации (SSO).  
  • Прямой доступ к логу (SIEM) и мониторинг (Grafana).  
  • Публичные метрики (Prometheus) / алерты.

- **DWH/BI ↔ tenant-core-db**  
  • ETL (JDBC) перебирает таблицы `smart_intercom_logs`, `smart_barrier_logs`, агрегирует данные, строит отчёты.

> **Подписи стрелок (протоколы) обязательно указывать на диаграмме.**

#### 1.3. Файл для загрузки

- Создайте в папке `Task3` файл `context_diagram.drawio` и сверстайте описанное выше.  
- Экспортируйте в PDF/PNG: `Task3/context_diagram.pdf` (для наглядности).

---

### 2. Обновлённая диаграмма контейнеров (C4 Container Diagram)

Берём исходную «Group служб ЖКУ» из диаграммы PropDevelopment и добавляем новые контейнеры «Smart Intercom» и «Smart Barrier». Ниже текстовое описание того, что нужно добавить/поменять. После этого всё сверстать в draw.io и сохранить как `Task3/container_diagram_with_smart_services.drawio` с экспортом в PDF/PNG.

#### 2.1. Исходные контейнеры в группе ЖКУ

