# Transcriptor Liquid (Flutter Edition)

Aplicación móvil desarrollada en **Flutter** para transcribir archivos de audio a texto usando la inteligencia artificial de OpenAI (Whisper), con un diseño premium inspirado en el estilo "Liquid Glass".

## Características Principales

1. **Diseño "Liquid Glass"**: Efectos de desenfoque translúcido (`BackdropFilter`) sobre fondos oscuros.
2. **Transcripción con Whisper**: Sube audios (mp3, m4a, wav) y transpásalos a texto de forma rápida.
3. **Historial Local**: Todo se guarda localmente en el teléfono usando `shared_preferences`. No dependes de una base de datos externa.
4. **Exportar y Compartir**: Convierte tus transcripciones a archivos `.txt` y envíalos vía WhatsApp, Correo, etc. usando `share_plus`.
5. **Sistema de Actualizaciones**: Revisa contra los *Releases* del repositorio oficial (`OscarAcosta17/transcripciones`) para ver si hay una versión más nueva.

## Requisitos de Sistema

- **Flutter SDK**: `3.x.x` (o superior)
- **Android Studio** o cadena de herramientas nativa para compilar.
- **API Key de OpenAI**: Debes configurarla en la pantalla de *Ajustes* dentro de la aplicación.

## Configuración y Ejecución Local

1. Clona el repositorio:
   ```bash
   git clone https://github.com/OscarAcosta17/transcripciones.git
   cd transcripciones
   ```

2. Descarga las dependencias:
   ```bash
   flutter pub get
   ```

3. Ejecuta la aplicación (conecta un emulador o un dispositivo físico por USB):
   ```bash
   flutter run
   ```

## Compilación del APK (Android)

Para generar el archivo ejecutable (`.apk`) e instalarlo en tu dispositivo:

```bash
flutter build apk --release
```

> **NOTA SOBRE WINDOWS**: Si al compilar obtienes un error relacionado con rutas o `CMake` (por el límite de 260 caracteres de Windows), deberás habilitar las "Rutas largas" en tu sistema operativo:
> 1. Abre PowerShell como Administrador.
> 2. Ejecuta: `New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1 -PropertyType DWORD -Force`
> 3. Reinicia tu computadora e intenta compilar de nuevo.

El APK generado lo encontrarás en la ruta:
`build/app/outputs/flutter-apk/app-release.apk`
