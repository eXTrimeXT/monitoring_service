#!/bin/bash

# Скрипт мониторинга процесса test
# Логирование в /var/log/monitoring.log

LOG_FILE="/var/log/monitoring.log"
MONITORING_URL="https://test.com/monitoring/test/api"
PROCESS_NAME="test"
PID_FILE="/var/run/monitoring.pid"
LAST_PID_FILE="/var/run/monitoring.last_pid"

# Функция логирования
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Проверка наличия процесса
check_process() {
    pgrep -x "$PROCESS_NAME" > /dev/null
    return $?
}

# Получение PID процесса
get_process_pid() {
    pgrep -x "$PROCESS_NAME"
}

# Отправка запроса на сервер мониторинга
send_monitoring_request() {
    local response_code
    response_code=$(curl -s -o /dev/null -w "%{http_code}" -H "User-Agent: MonitoringScript/1.0" "$MONITORING_URL")
    
    if [ "$response_code" -eq 200 ] || [ "$response_code" -eq 201 ] || [ "$response_code" -eq 202 ]; then
        return 0
    else
        log_message "ERROR: Monitoring server returned HTTP $response_code"
        return 1
    fi
}

# Проверка доступности сервера мониторинга
check_monitoring_server() {
    if ! curl -s --head --connect-timeout 5 "$MONITORING_URL" > /dev/null; then
        log_message "ERROR: Monitoring server is not accessible"
        return 1
    fi
    return 0
}

# Основная логика
main() {
    local current_pid
    local last_pid
    
    # Проверяем доступность сервера мониторинга
    if ! check_monitoring_server; then
        exit 1
    fi
    
    # Проверяем запущен ли процесс
    if check_process; then
        current_pid=$(get_process_pid)
        
        # Читаем предыдущий PID из файла
        if [ -f "$LAST_PID_FILE" ]; then
            last_pid=$(cat "$LAST_PID_FILE")
        else
            last_pid=""
        fi
        
        # Если PID изменился - процесс был перезапущен
        if [ -n "$last_pid" ] && [ "$current_pid" != "$last_pid" ]; then
            log_message "INFO: Process $PROCESS_NAME was restarted. Old PID: $last_pid, New PID: $current_pid"
        fi
        
        # Сохраняем текущий PID
        echo "$current_pid" > "$LAST_PID_FILE"
        
        # Отправляем запрос на сервер мониторинга
        if ! send_monitoring_request; then
            # Ошибка уже записана в лог в функции send_monitoring_request
            exit 1
        fi
    else
        # Процесс не запущен - ничего не делаем
        exit 0
    fi
}

# Запуск основной функции
main