### Перемещение 
```
sudo cp monitoring.sh /usr/local/bin/
```

```
sudo cp monitoring.service /etc/systemd/system/
```

```
sudo cp monitoring.timer /etc/systemd/system/
```

### Делаем скрипт исполняемым
```
sudo chmod +x /usr/local/bin/monitoring.sh
```

### Создаем лог-файл с правильными правами
```
sudo touch /var/log/monitoring.log
```

```
sudo chmod 644 /var/log/monitoring.log
```

### Перезагружаем systemd
```
sudo systemctl daemon-reload
```

### Включаем и запускаем таймер
```
sudo systemctl enable monitoring.timer
```

```
sudo systemctl start monitoring.timer
```

### Проверяем статус
```
sudo systemctl status monitoring.timer
```

### Проверки 
### Проверка статуса таймера
sudo systemctl status monitoring.timer

### Просмотр логов в реальном времени

```
sudo tail -f /var/log/monitoring.log
```

### Запуск мониторинга вручную для тестирования
```
sudo systemctl start monitoring.service
```
### Просмотр последних записей в логе
```
sudo tail -20 /var/log/monitoring.log
```



## Управление
### Остановка мониторинга
```
sudo systemctl stop monitoring.timer
```

### Запуск мониторинга
```
sudo systemctl start monitoring.timer
```

### Отключение автозапуска
```
sudo systemctl disable monitoring.timer
```

### Просмотр всех активных таймеров
```
systemctl list-timers
```

### Перезапуск скрипта
```
sudo systemctl restart monitoring.timer monitoring.service
```