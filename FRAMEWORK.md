# DisenchanterPlus: la base como framework

Análisis de la base del addon (módulos, utilidades, UI genérica, configuración, eventos, localización, versiones y minimapa) para reutilizarla en otros addons. Excluye la funcionalidad de desencantado y encantado (procesos, tablas de datos, tooltips y ventanas de producto). Es solo un análisis: no se ha cambiado código.

Organización: las secciones 1 a 3 describen el framework nuevo (CorePlus). La sección 4 es el anexo del addon actual y no se toca.

## 1. Diseño propuesto

**Nombre y nomenclatura del framework:** `CorePlus`, con prefijo de globales `CP_`. Sigue la terminación `Plus` de los addons (`DisenchanterPlus`). Carpeta y TOC: `CorePlus/`, `CorePlus.toc`. Tabla de SavedVariables: `CorePlusDB`, para que cada addon use su propia base de datos. Los globales del framework usan `CP_` (`CP_Framework`, `CP_ModuleLoader`), igual que el addon usa `DP_`. Los addons que lo usen mantienen su propio nombre y prefijo.

Crear una capa `Framework/` que reciba la configuración del addon al iniciarse:

```lua
local fw = CP_Framework:New({
  name       = "MiAddon",                -- nombre del AceAddon y del minimapa
  dbName     = "MiAddonDB",              -- SavedVariables (el addon actual conserva "DisenchanterPlusDB")
  prefix     = "MA",                     -- prefijo de módulos, frames y globales
  imagePath  = "Interface\\AddOns\\MiAddon\\Images\\",
  soundPath  = "Interface\\AddOns\\MiAddon\\Sounds\\",
  translate  = function(key) return L[key] or key end,
})
```

La capa expondría:
- **Núcleo:** creación del AceAddon, la base de datos y el registro de módulos con namespace propio.
- **Ciclo de vida:** el addon pasa callbacks `OnInitialize` y `OnLogin` en lugar de que `Init.lua` esté fijo.
- **Servicios sin estado de producto:** popup, frames, colores, medios, sonidos (con un callback `isMuted`), eventos y detección de versión.
- **Registro de opciones:** `RegisterTab` y `RegisterGroup` para que cada addon añada sus propias opciones.
- **Registro de acciones:** `RegisterSlashCommand` y `AddMinimapAction`, para que la base no conozca las acciones de producto.
- **Librerías embebidas** (`embeds.xml`): LibStub, CallbackHandler-1.0, AceAddon-3.0, AceEvent-3.0, AceTimer-3.0, AceBucket-3.0, AceComm-3.0, AceConsole-3.0, AceDB-3.0, AceDBOptions-3.0, AceLocale-3.0, AceGUI-3.0, AceConfig-3.0 (incluye AceConfigDialog y AceConfigRegistry), LibDataBroker-1.1, LibDBIcon-1.0 y LibDropdown-1.0.

## 2. Componentes UI reutilizables

Hoy la UI está en piezas sueltas. Hay funciones útiles, pero cada ventana construye su propio contenido:

| Componente | Lo que existe hoy | Lo que falta |
|---|---|---|
| Ventana | `CustomPopup.lua` (solo confirmación), `Window/*` | Ventana genérica con título, cierre, arrastre, ESC (`UISpecialFrames`), posición guardada y escala. |
| Pestañas | `CustomFrames:CreateTab`, `EnableTab`, `DisableTab` (`CustomFrames.lua`, líneas 40–94) | Grupo de pestañas que gestione su propio registro y contenido. |
| Botones | `CustomFrames:DrawCustomCleanButton` (línea 109) con iconos de `CustomMedias` | Botón con estados (normal, deshabilitado, resaltado) y tooltip, sin depender de iconos fijos. |
| Tabla o lista | No hay componente genérico | Filas con columnas, scroll, ordenación, selección y filtros. `SortMultipleValues` existe, pero no tiene llamadas: no es una base válida (ver apartado 4.3). |
| Formularios | `CustomConfig.lua` construye grupos de AceConfig a mano | Helpers para casillas, desplegables, rangos, colores y texto, con etiquetas traducidas. |
| Desplegable | `CreateCharacterDropdownList` (línea 284), sin llamadas (ver apartado 4.3) | Desplegable genérico que reciba lista y valor por defecto. |
| Tooltip | Construcción manual en `Tooltip/*` | Constructor de líneas (título, texto, doble columna) sobre `GameTooltip`. |
| Mensajes | `CustomFunctions:Print/Error/Warning` | Avisos y estados vacíos o de carga, con el mismo estilo. |

Recomendación: crear un componente por tipo con una API pequeña y devolver siempre el `frame`, para que el addon pueda colocarlo. Así la ventana de un addon nuevo se compone con piezas ya probadas.

Ejemplo de uso propuesto:

```lua
local win = fw.UI:Window({ title = "Mis datos", width = 600, height = 400, saveKey = "mainWindow" })
local tabs = fw.UI:Tabs(win, { { id = "list", text = "Lista" }, { id = "cfg", text = "Ajustes" } })
local tbl = fw.UI:Table(tabs:GetPage("list"), {
  columns = { { key = "name", title = "Nombre", sortable = true }, { key = "qty", title = "Cantidad" } },
})
```

## 3. Coherencia visual con Forever

Hoy `VersionCheck.lua` detecta Forever con `GetBuildInfo()` (línea 8: `^1%.60%.`) y lo trata como Classic (línea 17). Eso sirve para la lógica, pero no para el aspecto. Para que los componentes sean coherentes:

- **Tokens de diseño en un solo sitio:** colores, fuentes, tamaños de botón, espaciado, texturas y bordes. Hoy están repartidos en `CustomColors.lua`, `CustomMedias.lua` y en cada ventana.
- **Perfil visual por cliente:** un perfil elegido con los indicadores de `VersionCheck.lua`. De momento solo se define `forever`. El perfil `tbc` queda pendiente. Cada componente pide sus tokens al perfil, no los define.
- **Perfil `forever` con estilo Retail:** el cliente Forever es moderno, así que el perfil usa las APIs y plantillas de Retail. Para la ventana, `ButtonFrameTemplate`, `PortraitFrameTemplate` o `BasicFrameTemplateWithInset`. Para listas, `ScrollBox` con `CreateDataProvider` y `CreateScrollBoxListLinearView`. Para desplegables, `WowStyle1DropdownTemplate`. Para botones, `UIPanelButtonTemplate`. Para ajustes, la API `Settings` o el estilo de AceConfig. Para texturas, atlas en lugar de rutas fijas.
- **Comprobado en el código de Blizzard:** las plantillas anteriores existen en `Sources/1.60.1` (FrameXML y SharedXML de la build de Forever). Es la referencia para este perfil. Una plantilla que no aparezca ahí no se usa.
- **Probado en el cliente Forever:** un addon de prueba (`Sources/DP_TemplateTest`, ignorado por git) creó cada plantilla dentro de `pcall`. Sin errores ni fallos al cargar, y el aspecto fue aceptado. Plantillas probadas: `ButtonFrameTemplate`, `PortraitFrameTemplate`, `BasicFrameTemplateWithInset`, `UIPanelButtonTemplate`, `UIPanelCloseButton`, `UIPanelScrollFrameTemplate`, `InputBoxTemplate`, `WowStyle1DropdownTemplate`, `UISliderTemplateWithLabels`, `WowScrollBoxList` con `MinimalScrollBar`, `SquareIconButtonTemplate` y `UIPanelCloseButtonDefaultAnchors`.
- **Botones en Forever:** tres variantes, todas con plantillas de Blizzard:
  - Solo icono: `SquareIconButtonTemplate` con `SetIcon`.
  - Icono y texto: `UIPanelButtonTemplate` con una textura hija `ARTWORK` a la izquierda. No hay plantilla de Blizzard para esta variante.
  - Cerrar: `UIPanelCloseButtonDefaultAnchors`.
  El icono puede ser una ruta de textura de addon (`Interface\\AddOns\\...\\*.tga`), como en el addon de prueba.
- **Deprecadas en 1.60.1:** `OptionsSliderTemplate` está en `Blizzard_FrameXML/DeprecatedTemplates.xml` (línea 37). No se usa en el perfil `forever`; para sliders se usa `UISliderTemplateWithLabels` o el control de `Settings`.
- **Pendiente a futuro:** el perfil `tbc` y sus plantillas antiguas. Se revisarán con `Sources/2.5.6` cuando se aborde TBC.
- **Sin textos ni rutas fijas dentro de los componentes:** iconos y textos entran por parámetro, como se indica en el apartado 1.

Referencia indicada por el usuario: Forever tiene aspecto de Retail, aunque la lógica lo trata como Classic. Por eso el perfil visual debe ser independiente de la detección de lógica: `forever` usa las plantillas y el estilo de Retail, mientras que `IsClassic` sigue controlando solo la lógica del juego. No hay capturas de referencia, así que el estilo debe validarse en el cliente.

## 4. Anexo: addon actual (no se toca)

Esta sección no forma parte del framework. Describe DisenchanterPlus tal como está hoy y no se modifica.

### 4.1 Estado de cada pieza de la base

| Pieza | Archivo | Estado | Motivo |
|---|---|---|---|
| Cargador de módulos | `Modules/ModuleLoader.lua` | Reutilizable | Registro `CreateModule` / `ImportModule` sin dependencias de producto. Solo usa el global `DP_ModuleLoader`. |
| Detección de versión | `Modules/VersionCheck.lua` | Reutilizable con cambios | La detección de cliente es genérica. Crea el AceAddon con el nombre fijo `"DisenchanterPlus"` (línea 3). |
| Utilidades | `Modules/Custom/CustomFunctions.lua` | Con cambios | Usa `DisenchanterPlus:Print/Error/Warning` y lee `db.global.characters` (líneas 287 y 318). |
| Colores | `Modules/Custom/CustomColors.lua` | Reutilizable | Paletas genéricas. |
| Frames | `Modules/Custom/CustomFrames.lua` | Con cambios | Rutas de imagen fijas (líneas 7, 8, 122–178). |
| Popup | `Modules/Custom/CustomPopup.lua` | Con cambios | Textos `Accept`/`Cancel` con `DisenchanterPlus:DP_i18n` (líneas 167 y 178). |
| Medios | `Modules/Custom/CustomMedias.lua` | Con cambios | Unas 60 rutas fijas a `Interface/AddOns/DisenchanterPlus/...`. |
| Sonidos | `Modules/Custom/CustomSounds.lua` | Con cambios | Rutas fijas (líneas 24–28) y lee `db.char.general.muteSounds` (línea 9). |
| Config de AceConfig | `Modules/Custom/CustomConfig.lua` | Con cambios | Genera grupos reutilizables, pero sus textos usan `DisenchanterPlus:DP_i18n` (18 usos). |
| Ajustes | `Modules/Settings/Settings.lua`, `SettingsDefaults.lua` y tabs | Mixto | La estructura es genérica. Los valores por defecto y los tabs mezclan opciones de producto. |
| Eventos | `Modules/EventHandler.lua` | Con cambios | Registro de personajes útil. Comprueba `DisenchanterPlusDB` (línea 9) y llama a `DP_Init`. |
| Init | `Modules/Init.lua` | Acoplado | Es el punto de composición del producto: inicializa tooltip y procesos de encantado. |
| Minimapa | `Modules/MinimapIcon.lua` | Acoplado | Importa `DP_DisenchantProcess`, `DP_EnchantProcess` y `DP_DisenchantWindow`. Los textos del menú son de producto. El registro LDB (línea 101) usa el nombre fijo. |
| Comandos | `Modules/SlashCommands.lua` | Acoplado | Mezcla comandos genéricos (configuración, ayuda) con los de producto. |
| Ventanas base | `Modules/Window/WelcomeWindow.lua`, `IgnoredWindow.lua` | Mixto | El patrón de ventana es reutilizable. El contenido es de producto. |
| Base de datos | `Modules/Database.lua` | Mixto | Inicialización de AceDB reutilizable. Las claves y los valores por defecto son de producto. |

### 4.2 Qué impide reutilizarlo

- **Nombres fijos:** el AceAddon se llama `DisenchanterPlus` (`VersionCheck.lua`, línea 3). La SavedVariables `DisenchanterPlusDB` aparece en `EventHandler.lua` (línea 9). El registro del minimapa usa `"DisenchanterPlus"` (`MinimapIcon.lua`, líneas 29 y 101). Los frames se llaman `DisenchanterPlus_*` y los globales usan `DP_`.
- **Localización acoplada:** `CustomConfig.lua`, `CustomPopup.lua` y `MinimapIcon.lua` (líneas 82–96) llaman a `DisenchanterPlus:DP_i18n(...)`.
- **Rutas fijas:** imágenes, iconos y sonidos apuntan a `Interface\\AddOns\\DisenchanterPlus\\...`.
- **Dependencias de producto dentro de utilidades:** `CustomSounds.lua` lee `db.char.general.muteSounds`, `CustomFunctions.lua` lee `db.global.characters`, e `Init.lua` y `MinimapIcon.lua` importan módulos de desencantado y encantado.
- **Ajustes sin registro:** cada tab se construye a mano en `Modules/Settings/*`, y `SettingsDefaults.lua` mezcla opciones genéricas con las de producto.
- **Detección de cliente sin encapsular:** `DisenchanterPlus.IsClassic`, `IsTBC`, `IsEra`, etc. se leen como globales del addon.

### 4.3 Auditoría: código muerto, duplicados y errores

Todo está verificado con búsquedas en `Modules/` y `DisenchanterPlus.lua`. Antes de marcar una función como muerta hay que descartar llamadas dinámicas (callbacks de AceConfig, `ScheduleTimer`, búsqueda por nombre de cadena).

#### Código muerto (sin llamadas)
- `CustomFunctions.lua`: `RemoveDuplicationsInTable`, `RemoveIndexFromTable`, `SortComplexTableByKey` (solo una llamada comentada en `Database.lua`, línea 154), `CountTableEntries`, `SyncTableEntries`, `EmptyOrNil`, `GetClassIcon`, `GetClassInfoByClassFilename`, `GetCustomIcon`, `SortMultipleValues`, `CreateCharacterDropdownList`, `Delay`.
- `CustomColors.lua`: `CustomClassBrightColors`.
- `CustomConfig.lua`: `CreateDeleteCharacterConfig` (línea 19).
- `Settings.lua`: `DP_Settings:RefreshConfig` (línea 131) y `DP_Settings:OpenSettingsTab` (línea 138).
- `Settings/GeneralTab/Groups/KeybindingGroup.lua`: el módulo `DP_KeybindingGroup` no tiene usos. El grupo activo es `DP_KeybindingsGroup`.
- `CustomMedias.lua`: `disenchanterplus_a` duplica el icono base. `refresh` y `refresh_a` duplican `wand` y `wand_a`.
- `CustomFrames.lua`: `RedrawCustomCleanButton` tiene un callback vacío en `C_Timer.After`.
- `EventHandler.lua` (línea 23): `GetBuildInfo()` se llama y ninguno de sus valores se usa.
- Producto (fuera del framework): `OnGameTooltipShow` en `Tooltip/EnchantingTooltip.lua` (línea 404) no tiene llamadas.

Verificado y **no** es un fallo: `DP_CustomFunctions:UpdateMemoryUsageForAddon` existe en `CustomFunctions.lua` (línea 357), y `CustomConfig.lua` lo llama con ese mismo nombre. `Colorize`, `ColorizeByValue` y `CustomColors` también existen en `CustomColors.lua`.

#### Duplicados
- `ModuleLoader.lua`: `CreateModule` e `ImportModule` tienen el mismo cuerpo.
- Ventanas: `OpenWindow`, `CloseWindow` e `IsWindowOpened` se repiten en `DisenchantWindow.lua` (línea 537), `EnchantWindow.lua` (403), `IgnoredWindow.lua` (183) y `WelcomeWindow.lua` (292). El arrastre (`OnDragStart`/`OnDragStop`) se repite en tres de ellas.
- Arrastre acoplado: `DP_DisenchantWindow.OnDragStart` (línea 632) llama a `DP_IgnoredWindow.OnDragStart`, y la ventana de ignorados no tiene su propio arrastre activo (`IgnoredWindow.lua`, líneas 67–68 comentadas).
- `UISpecialFrames`: `DisenchantWindow.lua` comprueba si el nombre ya está antes de insertarlo, pero `Settings.lua` (línea 53) lo inserta sin comprobar.
- Números mágicos: `yOffset - 215` aparece dos veces en `IgnoredWindow.lua` (líneas 61 y 247).
- Ajustes: hay 9 funciones `Header` casi idénticas, una por grupo. `ItemQualityDropdownConfig` está duplicada en `DisenchantGroup.lua` (línea 162) y `EnchantGroup.lua` (línea 95).
- `ConfigGroups.lua`: `Get` es un `if/elseif` de 8 ramas por clave. Un registro de grupos lo sustituiría.
- `CustomFrames.lua` (líneas 16 y siguientes): `Spacer` y `HorizontalSpacer` devuelven tablas de AceConfig casi iguales.
- Pestaña de encantado: [EnchantTab.lua](F:/PROYECTOS/PERSONAL/CurseForge/disenchanterPlus/DisenchanterPlus/Modules/Settings/EnchantTab/EnchantTab.lua) (líneas 22–23) usa las claves `disenchant_header` y `disenchant`, nombres de la otra pestaña.
- `EventHandler.lua`: `PlayerLogin` escribe en `db.global.data.characters[key]` y en `db.global.characters[key].info`. Son dos almacenes de personajes que se solapan.

#### Errores
- `CustomFunctions:Delay`: `if not message == nil and message ~= ""` se evalúa como `(not message) == nil`, que siempre es falso. El mensaje nunca se imprime.
- `CustomFunctions:Dump` recurre sin protección contra ciclos. Una tabla con referencias circulares provoca un bucle infinito.
- `CustomSounds:PlayCustomSound`: si `GetSoundFile` devuelve `nil` para un nombre desconocido, se llama a `PlaySoundFile(nil)`.
- `CustomFunctions:GetNumText` compara `num` sin comprobar `nil`.
- `CustomPopup.lua`: las funciones auxiliares `_DP_CreatePopupWindow`, `_DP_CreateContainer`, `_DP_HandleAcceptBtn`, etc. son globales. Deben ser `local`. `DEFAULT_DIALOG_BACKDROP` no se usa.
- `Settings.lua` (línea 28): `AceConfigRegistry` es global, sin `local`.
- `EventHandler.lua` (líneas 9–10): `DisenchanterPlus:Error(...)` y después `error(...)` con el mismo texto.
- Producto (para referencia): `Tooltip/EnchantingTooltip.lua` (líneas 266–269) compara `itemMinLevel` y `levelToCheck` sin comprobar que `GetItemInfo` haya devuelto valor.

#### Acoplamiento en ajustes y ventanas
- `Settings.lua` (líneas 40–100): `OnShow` llama a `DP_DisenchantGroup:CreateSessionIgnoreListItems` y `OnClose` a `DP_DisenchantProcess:StartAutoDisenchant` y `DP_EnchantProcess:OpenEnchantWindow`. Un marco de ajustes genérico debe recibir estos comportamientos como callbacks.
- `GeneralGroup.lua` (línea 87): el texto `"Hide Minimap Icon"` está en inglés fijo, sin pasar por `DP_i18n`.

#### Localización
- `de`, `fr` e `it` tienen frases sin traducir, como `"Delete character data"` o `"Toggle showing title."`.
- Las claves de `DP_i18n` se comparan con valores del cliente en `BagsCheck.lua` (línea 79), `TradeskillCheck.lua` (línea 23) y `EnchantPatterns.lua` (línea 10). Traducirlas afecta a la lógica, así que las claves de lógica deben separarse de los textos de interfaz.
- En AceLocale solo el locale por defecto (`en`) devuelve la clave cuando falta. En los demás, `DP_i18n` devuelve la cadena `"nil"`.

### 4.4 Qué se queda en el addon

- Lógica de desencantado y encantado (`Disenchant/*`, `Enchant/*`).
- Tablas de datos del juego (`Database/*DisenchantTable.lua`, `EnchantPatterns.lua`).
- Tooltips de producto (`Tooltip/*`) y ventanas de desencantado y encantado (`Window/DisenchantWindow.lua`, `EnchantWindow.lua`).
- Integración con bolsas y profesiones (`Bags/*`, `Tradeskill/*`).
- Textos y opciones específicas del producto.
- SavedVariables actuales. Mantener `DisenchanterPlusDB` como valor por defecto evita perder configuraciones de usuarios existentes.
