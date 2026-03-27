# Plan de Implementación TerraTech 🌿

Este documento detalla la hoja de ruta y la arquitectura para el desarrollo de la aplicación móvil **TerraTech**, siguiendo el patrón arquitectónico **P.U.L.S.O.** y utilizando **Flutter** con **Supabase**.

## 🏗️ Arquitectura P.U.L.S.O.

La aplicación se organiza en cinco capas principales para garantizar la escalabilidad y el mantenimiento:

1.  **P - Presentation (Presentación)**: UI, Widgets, Screens y Temas (`lib/presentation`).
2.  **U - Use Cases (Casos de Uso)**: Lógica de negocio pura y orquestación de servicios (`lib/use_cases`).
3.  **L - Logic (Lógica)**: Gestión de estado y proveedores (`lib/logic`). Utilizamos **Riverpod**.
4.  **S - Services (Servicios)**: Integraciones externas (Supabase, Sensores, APIs) (`lib/services`).
5.  **O - Objects (Objetos)**: Modelos de datos, entidades y DTOs (`lib/objects`).

---

## 📱 Estado de Pantallas (Fase UI)

| Pantalla | Descripción | Estado |
| :--- | :--- | :--- |
| **Splash** | Pantalla de carga inicial con logo animado | ✅ Implementada |
| **Login/Auth** | Registro e inicio de sesión con UI premium | ✅ Implementada |
| **Home** | Dashboard principal con métricas clave | ✅ Implementada |
| **My Garden** | Visualización detallada de la salud del jardín | ✅ Implementada |
| **Build** | Guía interactiva para la construcción de módulos | ✅ Implementada |
| **Shop** | Catálogo de sensores y componentes | ✅ Implementada |
| **Knowledge** | Recursos educativos y wiki de plantas | ✅ Implementada |
| **Profile** | Gestión de cuenta, logros y configuración | ✅ Implementada |

---

## 🛠️ Roadmap de Implementación

### Fase 1: Base y Diseño (Completada ✅)
- [x] Configuración inicial del proyecto.
- [x] Definición del sistema de diseño (Colores, Tipografía, Botones).
- [x] Implementación de la navegación principal con `go_router`.
- [x] Creación de pantallas de alta fidelidad con datos estáticos.

### Fase 2: Integración de Supabase (Completada ✅)
- [x] Configuración del cliente `Supabase` en `lib/services/`.
- [x] Implementación de Autenticación real (Email/Password, Google OAuth).
- [x] Creación de servicios de base de datos (CRUD para Gardens, Modules, Plants, SensorData).
- [x] Modelos de datos con mapeo JSON.

### Fase 3: Gestión de Estado Real (Completada ✅)
- [x] Migración a Providers de `Riverpod` en `lib/logic`.
- [x] Implementación de `Use Cases` para la lógica de sensores y riego.
- [x] Uso de `StreamProvider` para datos en tiempo real.
- [x] Gestión de errores y estados de carga.

### Fase 4: Funcionalidades Avanzadas (Completada ✅)
- [x] Sistema de notificaciones con `flutter_local_notifications`.
- [x] Gráficos dinámicos con `fl_chart` (LineChart, RadarChart, BarChart).
- [x] Sistema de logros y gamificación (XP, Niveles).
- [x] Algoritmos de análisis de sensores y recomendación de riego.

### Fase 5: Pulido y Despliegue (Completada ✅)
- [x] Tests unitarios para modelos y use cases.
- [x] Tests de widget para componentes principales.
- [x] Pruebas de integración con Supabase (requiere backend configurado).
- [ ] Optimización de rendimiento y Assets.
- [ ] Preparación para tiendas (App Store / Play Store).

---

## 📂 Estructura del Proyecto

```
lib/
├── app.dart                    # App principal
├── main.dart                   # Punto de entrada
├── core/
│   ├── constants/               # Constantes de la app
│   ├── router/                 # Configuración de GoRouter
│   └── theme/                  # Tema, colores, estilos
├── objects/
│   └── models/                 # Modelos de datos
├── services/                   # Servicios externos
│   ├── auth_service.dart
│   ├── database_service.dart
│   └── notification_service.dart
├── logic/                      # Providers de Riverpod
│   ├── auth_provider.dart
│   ├── garden_provider.dart
│   ├── module_provider.dart
│   ├── plant_provider.dart
│   ├── sensor_provider.dart
│   └── achievement_provider.dart
├── use_cases/                  # Lógica de negocio
│   ├── sensor_analysis_usecase.dart
│   ├── irrigation_usecase.dart
│   └── gamification_usecase.dart
└── presentation/
    ├── navigation/             # Navegación principal
    ├── screens/                # Pantallas
    └── widgets/                # Widgets reutilizables
        └── charts/             # Gráficos
```

---

## 🔧 Próximas Tareas para Producción

1. **Configurar Supabase Backend:**
   - Crear tablas en Supabase (users, gardens, modules, plants, sensor_data)
   - Configurar Row Level Security (RLS)
   - Implementar funciones RPC para XP y logros

2. **Agregar credenciales:**
   - Reemplazar `supabaseUrl` y `supabaseAnonKey` en `app_constants.dart`
   - Configurar OAuth de Google en Supabase

3. **Testing de integración:**
   - Probar flujo completo de autenticación
   - Verificar sincronización de datos en tiempo real

4. **Despliegue:**
   - Generar APK con `flutter build apk`
   - Configurar Firebase/Supabase para producción
   - Preparar assets y documentación para stores

---

*Última actualización: 27 de marzo de 2026*
