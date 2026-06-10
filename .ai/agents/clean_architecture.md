# Arquitectura Limpia - Documentación del Proyecto

## 1. Introducción

Este documento describe la implementación de la **Arquitectura Limpia** para este proyecto, siguiendo los principios originales definidos por Uncle Bob. La arquitectura está diseñada para:

- **Independencia de frameworks**: El núcleo del dominio no depende de tecnologías externas
- **Separación de responsabilidades**: Cada capa tiene un propósito específico
- **Inversión de Dependencias (DIP)**: Las capas internas dependen solo de interfaces, no de implementaciones concretas
- **Testabilidad**: Facilita la creación de pruebas unitarias y de integración

## 2. Principios Fundamentales

### 2.1 Reglas de Dependencia

```
Framework/Drivers ↔ Adaptors ↔ Domain ↔ Framework/Adaptors
       ↓                        ↓               ↓
    HTTP API          Database   Entities      Use Cases
```

- **Entidades** nunca dependen de frameworks ni adaptadores
- **Use Cases** solo conocen interfaces (repositorios)
- **Repositorios** definen qué datos se necesitan, no cómo obtenerlos
- **Adaptadores** traducen entre formatos internos y externos

### 2.2 Separación de Capas

| Capa | Responsabilidad | Dependencias Permitidas |
|------|----------------|------------------------|
| **Entities** | Modelos de dominio puros | Nula (framework-independiente) |
| **Use Cases** | Lógica de negocio | Interfaces de repositorio |
| **Repositories** | Contratos de acceso a datos | - |
| **Adaptors (In)** | Controladores, DTOs | Use Cases + Repositories (interfaces) |
| **Adaptors (Out)** | Gateways HTTP, DB drivers, Cache | Frameworks específicos |

## 3. Estructura del Proyecto

```
project_root/
├── src/
│   ├── core/                           # Dominio puro
│   │   ├── entities/
│   │   │   ├── user.go                # Entidad Usuario
│   │   │   ├── product.go             # Entidad Producto
│   │   │   └── order.go               # Entidad Pedido
│   │   ├── value_objects/
│   │   │   ├── money.go               # Valor: Dinero
│   │   │   ├── address.go             # Valor: Dirección
│   │   │   └── timestamp.go          # Valor: Timestamp
│   │   ├── repositories.go            # Definiciones de interfaz
│   │   │   ├── user_repository.go     # Repositorio Usuario
│   │   │   ├── product_repository.go  # Repositorio Producto
│   │   │   └── order_repository.go    # Repositorio Pedido
│   │   └── errors/                    # Errores de dominio
│   │       ├── entity_errors.go
│   │       └── transaction_errors.go
│   │
│   ├── use_cases/                     # Casos de uso (Business Logic)
│   │   ├── user_use_cases/
│   │   │   ├── register_user.go       # Registrar Usuario
│   │   │   ├── login_user.go         # Autenticar Usuario
│   │   │   └── profile_management.go # Gestión Perfil
│   │   ├── product_use_cases/
│   │   │   ├── create_product.go      # Crear Producto
│   │   │   ├── update_product.go      # Actualizar Producto
│   │   │   └── get_products.go       # Listar Productos
│   │   ├── order_use_cases/
│   │   │   ├── place_order.go         # Realizar Pedido
│   │   │   └── cancel_order.go       # Cancelar Pedido
│   │
│   ├── interfaces/                    # Adaptadores de Entrada/Salida
│   │   ├── in/                        # Controladores y DTOs
│   │   │   ├── controllers/
│   │   │   │   ├── user_controller.go # REST API Usuarios
│   │   │   │   ├── product_controller.go # REST API Productos
│   │   │   │   └── order_controller.go # REST API Pedidos
│   │   │   ├── dto/                   # Data Transfer Objects
│   │   │   │   ├── user_dto.go
│   │   │   │   ├── product_dto.go
│   │   │   │   └── order_dto.go
│   │   │   └── validation.go         # Validaciones de entrada
│   │   └── out/                      # Repositorios e Implementaciones
│   │       ├── repositories/
│   │       │   ├── user_repository_impl.go
│   │       │   ├── product_repository_impl.go
│   │       │   └── order_repository_impl.go
│   │       └── datasources/
│   │           ├── postgres_db.go    # PostgreSQL Driver
│   │           ├── redis_cache.go    # Redis Cache
│   │           └── email_service.go  # Servicio Email
│   │
│   ├── events/                        # Eventos de dominio
│   │   ├── order_created_event.go     # Evento Pedido Creado
│   │   ├── user_registered_event.go  # Evento Usuario Registrado
│   │   └── payment_completed_event.go# Evento Pago Completado
│   │
│   └── config/                       # Configuración
│       ├── environment.go            # Entorno
│       └── validation_rules.go       # Reglas de validación
│
├── infrastructure/                   # Infraestructura externa (opcional)
│   ├── database/
│   │   ├── migrations/
│   │   └── seeds/
│   └── external_services/
│       ├── payment_gateway.go
│       └── notification_service.go
│
├── cmd/                             # Entradas de aplicación
│   ├── server.go                    # Punto de entrada principal
│   └── healthcheck.go               # Endpoints de salud
│
└── tests/                           # Pruebas
    ├── core/
    │   ├── entities_test.go
    │   └── repositories_test.go
    └── use_cases/
        └── use_cases_test.go
```

## 4. Diagrama de Flujo Arquitectónico

```
                    [Client HTTP]
                          ↓
               ┌─────────┴─────────┐
               │   HTTP Gateway    │
               │ (Adaptador Out)   │
               └─────────┬─────────┘
                         ↓
            ┌────────────┴────────────┐
            │   REST Controllers      │
            │ (Adaptador In - Entrada)│
            └────────────┬────────────┘
                         ↓
        ┌────────────────┴────────────────┐
        │           Use Cases             │
        │    (Lógica de Negocio Pura)     │
        └────────────────┬────────────────┘
                         ↓
        ┌────────────────┴────────────────┐
        │        Repositories Interfaces  │
        │      (Contratos de Datos)       │
        └────────────────┬────────────────┘
                         ↓
        ┌────────────────┴────────────────┐
        │  Repository Implementations     │
        │  (Adaptadores Out - DB, Cache)  │
        └────────────────┬────────────────┘
                         ↓
            [Base de Datos / Servicios Externos]

    Flujo: Client → Controller → Use Case → Repository → Infrastructure
```

## 5. Ejemplo de Implementación por Capa

### 5.1 Núcleo: Entidad (Framework-Independiente)

```go
// core/entities/user.go
package entities

import "time"

type User struct {
    ID        string
    Email     string
    PasswordHash string
    CreatedAt time.Time
}
```

### 5.2 Núcleo: Repositorio (Interfaz)

go
// core/repositories/user_repository.go
package repositories

import "github.com/yourproject/core/entities"

type UserRepository interface {
    Save(user entities.User) error
    FindByID(id string) (*entities.User, error)
    FindByEmail(email string) (*entities.User, error)
}
```

### 5.3 Caso de Uso (Use Case)

go
// use_cases/user_use_cases/register_user.go
package usecases

import "github.com/yourproject/core/repositories"

type RegisterUser struct {
    UserRepository repositories.UserRepository
}

func (uc *RegisterUser) Execute(dto dto.RegisterUserDTO) error {
    // Lógica de negocio puro
    return uc.UserRepository.Save(newUser(dto))
}


### 5.4 Adaptador de Entrada: Controlador

go
// interfaces/in/controllers/user_controller.go
package controllers

import "github.com/yourproject/use_cases"

type UserController struct {
    RegisterUC usecases.RegisterUser
}

func (c *UserController) Register(w http.ResponseWriter, r *http.Request) {
    dto := parseRegisterRequest(r)
    err := c.RegisterUC.Execute(dto)
    
    if err != nil {
        http.Error(w, err.Error(), http.StatusConflict)
        return
    }
}
```

### 5.5 Adaptador de Salida: Implementación del Repositorio

```go
// interfaces/out/repositories/user_repository_impl.go
package repositories

import "github.com/yourproject/core/entities"

type userRepositoryImpl struct {
    db *database.DB
}

func (repo *userRepositoryImpl) Save(user entities.User) error {
    // Persistencia específica con DB
    return repo.db.SaveUser(user)
}
```

## 6. Reglas de Validación por Capa

| Capa | Tipo de Validación |
|------|-------------------|
| **Controllers** | DTO validation (schema, length, required fields) |
| **Use Cases** | Business rules validation (constraints, state) |
| **Repositories** | Data integrity constraints |

## 7. Gestión de Errores por Capa

```go
// core/errors/domain_errors.go

type EntityError struct {
    Message string
    Code    string
}

func NewEntityError(message string) EntityError {
    return EntityError{Message: message, Code: "ENTITY_ERROR"}
}

type TransactionError struct {
    Operation string
    Error     error
}
```

## 8. Eventos y Event Sourcing (Opcional)

```go
// events/order_created_event.go

type OrderCreatedEvent struct {
    OrderID      string
    UserID       string
    TotalAmount  decimal.Decimal
    CreatedAt    time.Time
}

type EventBus interface {
    Publish(event interface{}) error
}
```

## 9. Configuración y Entorno

```go
// config/environment.go

const (
    Development = "development"
    Production  = "production"
    Testing     = "testing"
)

type Env struct {
    Environment       string `env:"ENV"`
    DatabaseURL       string `env:"DATABASE_URL"`
    RedisURL          string `env:"REDIS_URL"`
    JWTSecret         string `env:"JWT_SECRET"`
}
```

## 10. Puntos de Entrada (Entry Points)

```go
// cmd/server.go

func main() {
    app := initApp(Env{})
    
    router := setupRouter(app)
    
    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        // Rutas principales
    })
}
```

## 11. Consideraciones de Pruebas

### 11.1 Unit Tests (Core + Use Cases)

```go
// tests/use_cases/register_user_test.go
package usecases

import "testing"

func TestRegisterUser_WhenValid(t *testing.T) {
    repo := &MockRepository{} // Mock del repositorio
    uc := &RegisterUser{repo}
    
    dto := RegisterUserDTO{
        Email:   "test@example.com",
        Password: "secure123",
        Name:    "Test User",
    }
    
    err := uc.Execute(dto)
    if err != nil {
        t.Error(err)
    }
}
```

### 11.2 Integration Tests (Repositories + DB)

```go
// tests/core/repositories_test.go
package repositories

import "testing"

func TestUserRepository_Save(t *testing.T) {
    db := setupTestDatabase()
    repo := NewRepository(db)
    
    user := entities.User{ID: "1", Email: "test@example.com"}
    
    err := repo.Save(user)
    // Assertions
}