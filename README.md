# Flutter_Proyect

Una aplicación de gestión educativa desarrollada en Flutter que permite a profesores y estudiantes gestionar cursos, categorías, grupos y actividades de manera eficiente.

## 📋 Requisitos

Para ejecutar este proyecto necesitas tener instalado:

- **Flutter SDK** (versión 3.9.0 o superior)
- **Android Studio** (con SDK de Android)
- **Git** (para clonar el repositorio)

### Configuración recomendada para pruebas:

- **Emulador:** Pixel 2 API (las pruebas se realizaron en esta configuración)
- **Sistema operativo:** Android API 29 o superior

## 🚀 Instalación y Ejecución

### 1. Clonar el repositorio

```bash
git clone https://github.com/Jhonayker0/Flutter_Proyect.git
cd Flutter_Proyect
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Configurar el emulador

- Abre Android Studio
- Ve a **AVD Manager** (Android Virtual Device Manager)
- Crea un nuevo dispositivo virtual o usa uno existente
- **Recomendado:** Pixel 2 con API 29 o superior
- Inicia el emulador

### 4. Verificar configuración

```bash
flutter doctor
```

Asegúrate de que no haya errores críticos.

### 5. Ejecutar la aplicación

```bash
flutter run
```

## 🎯 Funcionalidades Principales

- **Autenticación:** Login y registro de usuarios
- **Gestión de Cursos:** Crear, editar y eliminar cursos
- **Categorías y Grupos:** Sistema de organización por categorías con grupos
- **Actividades:** Creación y gestión de actividades educativas
- **Roles:** Diferenciación entre Profesor y Estudiante
- **Base de datos local:** Almacenamiento con SQLite

## 👥 Usuarios de Prueba

La aplicación incluye usuarios predeterminados para pruebas:

- **Usuario 1:**

  - Email: `a@a.com`
  - Contraseña: `123456`

- **Usuario 2:**

  - Email: `b@a.com`
  - Contraseña: `123456`

- **Usuario 3:**
  - Email: `c@a.com`
  - Contraseña: `123456`

## 🛠️ Tecnologías Utilizadas

- **Flutter** - Framework de desarrollo
- **GetX** - Gestión de estado y navegación
- **SQLite** - Base de datos local
- **Material Design** - Diseño de interfaz

## 📱 Compatibilidad

- **Android:** API 21+ (Android 5.0+)
- **iOS:** iOS 11.0+ (configuración pendiente)
- **Pruebas realizadas:** Pixel 2 Emulator
