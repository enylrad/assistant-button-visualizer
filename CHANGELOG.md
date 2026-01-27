# Changelog

All notable changes to this project will be documented in this file.

## [1.1.1] - 2026-01-27

### Added
- **Optimization:** Added support for WoW Patch 12.0.1.
- **Localization:** Added full Spanish localization support.

## [1.1.1] - 2026-01-27 (Español)

### Añadido
- **Optimización:** Añadido soporte para el Parche 12.0.1 de WoW.
- **Localización:** Añadido soporte completo de localización al español.

## [1.1.0] - 2026-01-24

### Fixed
- **Reassignment Bug:** Fixed an issue where the addon would constantly re-install the spell (playing a sound) on login or talent change, especially when the spell ID changed due to stance/form (e.g. Druid forms).

### Added
- **Icon Size Control:** New slider in options to configure the icon size (16px to 128px), defaulting to original size.
- **Slot Cleanup:** Improved logic to clear the previous action slot when changing the configured slot.

## [1.0.0] - 2026-01-24

### Added
- **Initial Release:** Core visualizer functionality for the Assistant Button.
- **Movable Frame:** Ability to drag the visualizer anywhere on the screen.
- **Auto-Install logic:** The addon automatically places the required spell into the selected action slot on login or specialization change.
- **Visibility Modes:** Added "Always" and "In Combat" visibility settings.
- **Lock Position:** Option to lock the frame to prevent accidental moving.
- **Opacity Control:** Slider to adjust the transparency of the button (10% to 100%).
- **Custom Action Slot Selection:**
  - New setting to choose which action slot (1-120) the addon uses.
  - "Apply" button logic to stage changes before saving.
  - Informative tooltips and help text inside the options panel to help selecting safe slots.
- **Interface Options:** Fully integrated configuration panel in the standard WoW Options menu.
- **Slash Commands:**
  - `/abv reset`: Resets position to center.
  - `/abv install`: Manually triggers spell installation.

---

## [1.1.0] - 2026-01-24 (Español)

### Corregido
- **Bug de Reasignación:** Corregido un problema donde el addon reinstalaba constantemente el hechizo (reproduciendo un sonido) al iniciar sesión o cambiar talentos, especialmente cuando el ID del hechizo cambiaba por formas/posturas (ej. Druidas).

### Añadido
- **Control de Tamaño de Icono:** Nuevo deslizador en opciones para configurar el tamaño del icono (16px a 128px).
- **Limpieza de Casilla:** Mejorada la lógica para limpiar la casilla de acción anterior al cambiar la configuración.

## [1.0.0] - 2026-01-24 (Español)

### Añadido
- **Lanzamiento Inicial:** Funcionalidad principal del visualizador para el Botón Asistente.
- **Marco Movible:** Capacidad de arrastrar el visualizador a cualquier parte de la pantalla.
- **Lógica de Auto-Instalación:** El addon coloca automáticamente el hechizo necesario en la casilla seleccionada al iniciar sesión o cambiar de especialización.
- **Modos de Visibilidad:** Configuración de visibilidad para "Siempre" o "En Combate".
- **Bloqueo de Posición:** Opción para bloquear el marco y evitar movimientos accidentales.
- **Control de Opacidad:** Deslizador para ajustar la transparencia del botón (del 10% al 100%).
- **Selección de Casilla Personalizada:**
  - Nueva configuración para elegir qué casilla de acción (1-120) usa el addon.
  - Lógica de botón "Apply" (Aplicar) para confirmar cambios antes de guardar.
  - Ajustes de diseño y textos de ayuda detallados en el panel de opciones.
- **Opciones de Interfaz:** Panel de configuración integrado en el menú de opciones estándar de WoW.
- **Comandos de Chat:**
  - `/abv reset`: Restablece la posición al centro.
  - `/abv install`: Fuerza manualmente la instalación del hechizo.
