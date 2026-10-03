# Assistant Button Visualizer

Shows the spell Blizzard's **Assistant Button** (Single-Button Assistant) suggests anywhere
on your screen, as a free icon you can place where your eyes already are.

Supports **World of Warcraft retail** (Midnight), **Classic** (Vanilla, TBC, Mists) and
**WoW: Forever**.

## How it works

The addon asks the game's assisted combat system which spell it suggests next and shows
its icon. Nothing is placed on your action bars.

> [!NOTE]
> Versions 1.x kept the Assistant Button spell in an action slot (88 by default). 2.0
> removes it from that slot once, on the first login. If the assisted combat suggestions
> do not work on your client, the old method is still available in the options.

## Features

- **Movable button**: from the game's Edit Mode (retail and Forever), with `/abv move` or
  the *Move* button in the options. Lock it to let clicks go through.
- **Profiles**: one shared by every character, one per character or one per
  specialization, with copy and reset.
- **Visibility**: always, in combat, with a hostile target or in instances; optionally
  hidden while mounted and when there is no suggestion.
- **Look**: icon size, opacity in and out of combat, fade time, thin or action button
  border, cropped icon edges and a flash when the suggestion changes.
- **Range and usability tint**: red out of range, blue without enough power and grey
  when it cannot be used, like the default action buttons.
- **Addon language**: game language, English or Spanish.

## Options

`/abv` (or Game Menu → Options → AddOns → Assistant Button Visualizer, or the minimap
addons menu).

## Commands

| Command | Description |
| --- | --- |
| `/abv` | Open the options. |
| `/abv move` | Move the button; right click it or press Escape to finish. |
| `/abv reset` | Move the button back to the center of the screen. |
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

Muestra en cualquier parte de la pantalla el hechizo que sugiere el **Botón Asistente**
de Blizzard, como un icono que puedes colocar donde ya miras.

Compatible con **World of Warcraft retail** (Midnight), **Classic** (Vanilla, TBC, Mists)
y **WoW: Forever**.

El addon pregunta al sistema de combate asistido del juego qué hechizo sugiere y muestra
su icono, sin colocar nada en tus barras. Las versiones 1.x guardaban el hechizo en una
casilla de acción (la 88 por defecto); la 2.0 lo quita de esa casilla una vez, al
conectar. Si las sugerencias no funcionan en tu cliente, el método antiguo sigue
disponible en las opciones.

### Características

- **Botón movible**: desde el Modo Edición del juego (retail y Forever), con `/abv move`
  o con el botón *Mover* de las opciones. Bloquéalo para que los clics lo atraviesen.
- **Perfiles**: uno compartido, uno por personaje o uno por especialización, con copiar
  y restablecer.
- **Visibilidad**: siempre, en combate, con un objetivo hostil o en instancias; opcional
  ocultarlo en montura y cuando no hay sugerencia.
- **Aspecto**: tamaño, opacidad dentro y fuera de combate, tiempo de fundido, borde fino o
  de botón de acción, icono recortado y destello al cambiar la sugerencia.
- **Color según alcance y uso**: rojo fuera de alcance, azul sin recurso suficiente y gris
  cuando no se puede usar.
- **Idioma del addon**: el del juego, inglés o español.

### Comandos

| Comando | Descripción |
| --- | --- |
| `/abv` | Abre las opciones. |
| `/abv move` | Mueve el botón; clic derecho o Escape para terminar. |
| `/abv reset` | Devuelve el botón al centro de la pantalla. |
| `/abv help` | Muestra los comandos. |
