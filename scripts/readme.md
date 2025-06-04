# Інструкція з використання
## Встановлення:

Скопіюйте скрипт у директорію scripts/ вашого репозиторію.

Додайте права на виконання:

```
chmod +x scripts/kubectl-resource-usage.sh
```
(Необов’язково) Зробіть його доступним як плагін:

```
sudo cp scripts/kubectl-resource-usage.sh /usr/local/bin/kubectl-resource_usage
sudo chmod +x /usr/local/bin/kubectl-resource_usage
```

Запуск:


```
kubectl resource-usage <namespace> <resource_type>
```

Приклади:

```
kubectl resource-usage kube-system pods
kubectl resource-usage default nodes
```