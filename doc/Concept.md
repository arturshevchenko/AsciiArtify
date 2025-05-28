# Concept: Порівняльний аналіз інструментів локального розгортання Kubernetes для AsciiArtify

## Вступ

Для ефективної локальної розробки та тестування програмного продукту AsciiArtify, який буде масштабуватись за допомогою Kubernetes, було розглянуто три основні інструменти для розгортання Kubernetes-кластерів в локальному середовищі:

* **Minikube** — стандартний інструмент для запуску локального Kubernetes-кластеру.
* **Kind** (Kubernetes IN Docker) — створює кластери всередині Docker-контейнерів.
* **K3d** — дозволяє запускати легкий кластер на базі k3s у Docker.


## Характеристики

| Характеристика                  | Minikube                       | Kind                        | K3d (на базі k3s)           |
| ------------------------------- | ------------------------------ | --------------------------- | --------------------------- |
| Підтримка ОС                    | Linux, macOS, Windows          | Linux, macOS, Windows       | Linux, macOS, Windows       |
| Архітектура                     | x86\_64, ARM (обмежено)        | x86\_64, ARM                | x86\_64, ARM                |
| Вимоги до Docker                | Опціонально (підтримує Podman) | Обов'язковий Docker         | Обов'язковий Docker         |
| Підтримка Podman                | Так (бета, нестабільно)        | Ні                          | Ні                          |
| Швидкість запуску               | Помірна                        | Висока                      | Висока                      |
| Інтеграція з Helm               | Так                            | Так                         | Так                         |
| Автоматизація CI/CD             | Так                            | Так                         | Так                         |
| Вбудовані додатки (Ingress, UI) | Так (addons)                   | Ні                          | Частково                    |
| Моніторинг                      | Через addons                   | Не входить за замовчуванням | Не входить за замовчуванням |
| Простота конфігурації           | Висока                         | Середня                     | Висока                      |
| Виробниче застосування          | Ні                             | Ні                          | Можливо (edge та IoT)       |

## Переваги та недоліки

### Minikube

**Переваги:**

* Найбільш поширений і добре задокументований.
* Підтримує UI, addons (наприклад, dashboard, ingress).
* Можна використовувати без Docker (через Podman, VirtualBox).

**Недоліки:**

* Повільніший запуск у порівнянні з kind та k3d.
* Важчий за ресурсами.
* Не ідеальний для CI/CD.

### Kind

**Переваги:**

* Дуже швидкий запуск і знищення кластеру.
* Простий YAML для конфігурації.
* Ідеально підходить для CI/CD.

**Недоліки:**

* Не підтримує Podman.
* Немає UI/додатків за замовчуванням.
* Менше friendly для новачків.

### K3d

**Переваги:**

* Дуже легкий і швидкий.
* Заснований на k3s — легкій реалізації Kubernetes.
* Добре працює з Docker.
* Підтримує багатонодові кластери.

**Недоліки:**

* Вимагає Docker.
* Менше документації.
* Моніторинг і UI потрібно налаштовувати вручну.

## Демонстрація: k3d

Рекомендований інструмент — **k3d**. Він забезпечує баланс швидкості, простоти та близькості до реального середовища розгортання. Нижче наведено приклад розгортання "Hello World" застосунку:

```bash
# Встановлення k3d
brew install k3d

# Створення кластеру
k3d cluster create asciiartify-cluster --agents 2

# Деплой nginx як Hello World
kubectl create deployment hello --image=nginx
kubectl expose deployment hello --type=NodePort --port=80

# Перевірка доступності
kubectl get services
```


## Висновки

Для PoC-проєкту стартапу AsciiArtify рекомендується використовувати **k3d** з наступних причин:

* Висока швидкість розгортання та легкість у використанні.
* Підходить для розробки та тестування lightweight-кластерів.
* Легко інтегрується в CI/CD.

**Kind** доцільно використовувати у сценаріях CI або коли Docker вже інтегрований у робочий процес.

**Minikube** — зручний для новачків та сценаріїв, де потрібні UI або робота без Docker, але має обмеження за ресурсами та швидкістю.

---

**Примітка:** Команді слід моніторити ситуацію з ліцензуванням Docker Desktop, а також експериментувати з підтримкою Podman у Minikube як альтернативою.

---

Демо: ![Image](demo.gif)

https://github.com/arturshevchenko/AsciiArtify

https://argo-cd.readthedocs.io/en/stable/

https://k3s.io/

https://minikube.sigs.k8s.io/docs/

https://kind.sigs.k8s.io/

https://k3d.io/stable/


---

## Практичний гайд: Як розгорнути демо "Hello from Ascii" у кожному кластері

> **Файл для розгортання:** [ascii-artify.yaml](./ascii-artify.yaml)  
> Примітка: yaml використовує простий імейдж, який повертає відповідь `Hello from ascii`.

### 1. Minikube

#### Встановлення:
```bash
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube && sudo mv minikube /usr/local/bin
minikube start
```
#### Деплой:
```bash
kubectl apply -f ascii-artify.yaml
kubectl get pods,svc
kubectl port-forward svc/ascii-artify 8081:80 &
```

#### Перевірка:
```bash
curl localhost:8081
kubectl logs $(kubectl get pods -l app=ascii-artify -o name)
```

#### Видалити:
```bash
minikube delete
```

### 2. Kind

#### Встановлення:
```bash
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-amd64
chmod +x kind && sudo mv kind /usr/local/bin
kind create cluster --name asciiartify
```

#### Деплой:
```bash
kubectl apply -f ascii-artify.yaml
kubectl get pods,svc
kubectl port-forward svc/ascii-artify 8081:80 &
```

#### Перевірка:
```bash
curl localhost:8081
kubectl logs $(kubectl get pods -l app=ascii-artify -o name)
```

#### Видалити:
```bash
kind delete cluster --name asciiartify
```

### 2. k3d

#### Встановлення:
```bash
curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
k3d cluster create k3d-asciiartify
```

#### Деплой:
```bash
kubectl apply -f ascii-artify.yaml
kubectl get pods,svc
kubectl port-forward svc/ascii-artify 8081:80 &
```

#### Перевірка:
```bash
curl localhost:8081
kubectl logs $(kubectl get pods -l app=ascii-artify -o name)
```

#### Видалити:
```bash
k3d cluster delete k3d-asciiartify
```