# Changelog

All notable changes to this project will be documented in this file.

## [2.0.0] - 2026-10-03

### Changed
- **No action slot needed:** the suggestion is read from the assisted combat API (`C_AssistedCombat`). The Assistant Button spell that 1.x kept in an action slot is removed from it once, on the first login.
- The 1.x settings become the "Default" profile. Opacity is now set separately in and out of combat.
- The options panel is split in sections (profile, visibility, appearance, position and language) and scrolls.

### Removed
- The action slot setting and `/abv install`: they are no longer needed.

### Added
- **Profiles:** shared by every character, per character or per specialization, with copy and reset.
- **Edit Mode:** the button can be moved from the game's Edit Mode, with `/abv move` or with the Move button in the options, even when it is locked.
- **Look:** icon shape (square, rounded, circle or soft circle), thin or action button border, cropped icon edges, a flash when the suggestion changes, fade time and an option to hide the button when there is no suggestion.

## [2.0.0] - 2026-10-03 (Español)

### Cambiado
- **Ya no hace falta una casilla de acción:** la sugerencia se lee de la API de combate asistido (`C_AssistedCombat`). El hechizo del Botón Asistente que la 1.x guardaba en una casilla se quita una vez, al conectar.
- La configuración de la 1.x pasa a ser el perfil "Default". La opacidad se ajusta por separado dentro y fuera de combate.
- El panel de opciones se divide en secciones (perfil, visibilidad, apariencia, posición e idioma) y tiene desplazamiento.

### Eliminado
- La opción de casilla de acción y `/abv install`: ya no hacen falta.

### Añadido
- **Perfiles:** compartido, por personaje o por especialización, con copiar y restablecer.
- **Modo Edición:** el botón se mueve desde el Modo Edición del juego, con `/abv move` o con el botón Mover de las opciones, aunque esté bloqueado.
- **Aspecto:** forma del icono (cuadrado, redondeado, círculo o círculo difuminado), borde fino o de botón de acción, icono recortado, destello al cambiar la sugerencia, tiempo de fundido y opción de ocultarlo cuando no hay sugerencia.

## [1.2.0] - 2026-10-03

### Added
- **Range and usability tint:** the button turns red out of range, blue without enough power and grey when the action cannot be used. Can be turned off.
- **Visibility modes:** "With a hostile target" and "In instances", plus an option to hide the button while mounted out of combat.
- **Addon language:** picker in the options (game language, English or Spanish).
- **Minimap addon menu entry**, and `/abv` now opens the options (`/abv help` lists the commands).
- Packaging and link scripts in `tools/`.

### Changed
- Support for WoW 12.1 (Interface 120100 and 120105).
- The addon was split into modules following RolePing and XPLedger. Settings from 1.1.x are migrated.
- The options panel uses the current Blizzard templates.

### Fixed
- An error on a fresh install, when the button read the settings before they existed.
- A slot changed in combat was never applied; it now moves when combat ends.
- Changing the slot cleared the previous one even when it no longer held a spell.
- "Frame Locked" was printed on every login.
- The help showed slot 88 instead of the configured slot.
- An empty slot forced the button to full opacity.

## [1.2.0] - 2026-10-03 (Español)

### Añadido
- **Color según alcance y uso:** el botón se vuelve rojo fuera de alcance, azul sin recurso suficiente y gris si la acción no se puede usar. Se puede desactivar.
- **Modos de visibilidad:** "Con un objetivo hostil" y "En instancias", y opción para ocultarlo en montura fuera de combate.
- **Idioma del addon:** selector en las opciones (idioma del juego, inglés o español).
- **Entrada en el menú de addons del minimapa**; `/abv` abre las opciones (`/abv help` muestra los comandos).
- Scripts de empaquetado y enlace en `tools/`.

### Cambiado
- Soporte para WoW 12.1 (Interface 120100 y 120105).
- El addon se ha dividido en módulos como RolePing y XPLedger. La configuración de 1.1.x se migra.
- El panel de opciones usa las plantillas actuales de Blizzard.

### Corregido
- Un error en instalaciones nuevas al leer la configuración antes de existir.
- Un cambio de casilla en combate nunca se aplicaba; ahora se hace al terminar el combate.
- Al cambiar de casilla se vaciaba la anterior aunque ya no tuviera un hechizo.
- Se mostraba "Frame Locked" en cada inicio de sesión.
- La ayuda mostraba la casilla 88 en lugar de la configurada.
- Una casilla vacía forzaba el botón a opacidad completa.

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
