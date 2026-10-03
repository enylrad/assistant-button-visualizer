# Assistant Button Visualizer

Shows the suggestion of Blizzard's **Assistant Button** (Single-Button Assistant) anywhere
on your screen, without moving your action bars.

Supports **World of Warcraft retail** (Midnight).

## How it works

The Assistant Button spell is kept in an action slot that is not on your visible bars
(slot 88 by default). The visualizer mirrors that slot as a free icon you can drag
wherever you want: next to your character, under your target frame, in the middle of
the screen...

The spell is placed on login and after talent or specialization changes. A slot that
already holds a spell is left alone, so forms and stances never cause it to be placed
again. Action slots cannot be changed in combat: a change requested then is done as
soon as combat ends.

## Features

- **Movable button**: drag it while it is unlocked; lock it to let clicks go through.
- **Range and usability tint**: red out of range, blue without enough power and grey
  when it cannot be used, like the default action buttons.
- **Visibility**: always, in combat, with a hostile target or in instances, and
  optionally hidden while mounted out of combat.
- **Opacity** (10% to 100%) and **icon size** (16 to 128).
- **Action slot**: any slot from 1 to 120, applied with a button so the slider never
  replaces the icons it passes over.
- **Addon language**: game language, English or Spanish.

## Options

`/abv` (or Game Menu → Options → AddOns → Assistant Button Visualizer, or the minimap
addons menu).

> [!TIP]
> Pick an action slot that is not on your visible bars, such as 80 or higher, so none
> of your icons is replaced. Bars 1 to 6 use slots 1-72.

## Commands

| Command | Description |
| --- | --- |
| `/abv` | Open the options. |
| `/abv reset` | Move the button back to the center of the screen. |
| `/abv install` | Place the spell in its action slot, replacing what is there. |
| `/abv help` | List the commands. |

## Development

```powershell
# Link the working copy into every installed WoW flavor (no admin rights needed)
./tools/link-wow.ps1

# Build AssistantButtonVisualizer-<version>.zip, ready to share
./tools/package.ps1
```

## License

MIT

---

## Español

Muestra la sugerencia del **Botón Asistente** de Blizzard en cualquier parte de la
pantalla, sin mover tus barras de acción.

El hechizo del Botón Asistente se guarda en una casilla de acción que no está en tus
barras visibles (la 88 por defecto) y el visualizador la refleja como un icono que
puedes arrastrar adonde quieras. Se coloca al conectar y al cambiar de talentos o
especialización; si la casilla ya tiene un hechizo no se toca. En combate no se pueden
cambiar las casillas: el cambio se hace al terminar el combate.

### Características

- **Botón movible**: arrástralo mientras esté desbloqueado; bloquéalo para que los clics
  lo atraviesen.
- **Color según alcance y uso**: rojo fuera de alcance, azul sin recurso suficiente y gris
  cuando no se puede usar.
- **Visibilidad**: siempre, en combate, con un objetivo hostil o en instancias, y
  opcionalmente oculto en montura fuera de combate.
- **Opacidad** (10% a 100%) y **tamaño del icono** (16 a 128).
- **Casilla de acción**: cualquiera de la 1 a la 120, aplicada con un botón.
- **Idioma del addon**: el del juego, inglés o español.

### Comandos

| Comando | Descripción |
| --- | --- |
| `/abv` | Abre las opciones. |
| `/abv reset` | Devuelve el botón al centro de la pantalla. |
| `/abv install` | Coloca el hechizo en su casilla, sustituyendo lo que haya. |
| `/abv help` | Muestra los comandos. |
