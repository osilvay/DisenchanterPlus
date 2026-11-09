# DisenchanterPlus - Análisis Completo de Arquitectura

**Versión del Addon**: 3.0.0.0  
**Fecha de Análisis**: 3 de mayo de 2026  
**Plataformas Soportadas**: Classic WoW Forever (Camelot 1.60.x)

---

## 0. REGLAS DE TRABAJO (IMPORTANTE)

- **NUNCA subir nada a git**: no hacer `git commit`, `git push`, `git tag` ni ninguna otra operación que escriba en el repositorio remoto o cree historial. El usuario gestiona git manualmente.
- Se permite leer el estado del repositorio (`git status`, `git diff`, `git log`) para contexto, pero los cambios se dejan únicamente en el working tree.

---

## 1. ESTRUCTURA GENERAL DEL ADDON

```
DisenchanterPlus/
├── Bindings.xml                    # Definición de keybindings
├── DisenchanterPlus.lua            # Archivo principal (nucleo del addon)
├── DisenchanterPlus_Camelot.toc    # Tabla de contenidos (TOC) para Classic WoW Forever 1.60.x
├── embeds.xml                      # Inclusión de librerías Ace3
├── pkgmeta.yaml                    # Configuración del empaquetador
├── CHANGELOG.md                    # Historial de cambios
├── README.md                       # Documentación del usuario
├── LICENSE                         # Licencia del proyecto
├── Doc/                            # Documentación interna
├── Images/                         # Recursos gráficos (iconos, texturas)
├── Libs/                           # Librerías Ace3 (3.0+) y extensiones
├── Locale/                         # Sistema de localización multiidioma
├── Modules/                        # Núcleo de módulos funcionales
├── Release/                        # Compilaciones empaquetadas
├── Sounds/                         # Efectos de sonido del addon
└── Sources/                        # Código fuente de WoW UI

```

### Propósito del Addon

DisenchanterPlus es una herramienta completa para gestionar el desencantamiento de objetos en World of Warcraft. Proporciona:

- Visualización de materiales esperados antes de desenchantar
- Auto-desencantamiento automático con filtros personalizables
- Encantamiento en masa de múltiples objetos
- Integración con Auctionator para precios de materiales
- Gestión de base de datos de historial de desencantamiento
- Configuración extensiva mediante interfaz gráfica (AceGUI)

---

## 2. ARCHIVO PRINCIPAL: DisenchanterPlus.lua

**Ubicación**: `/DisenchanterPlus.lua`  
**Rol**: Punto de entrada y núcleo del addon  
**Dependencias**: LibStub, Ace3 Framework

### Inicialización del Addon

```lua
-- Define la clase principal que hereda de AceAddon
DisenchanterPlus = LibStub("AceAddon-3.0"):NewAddon(
  "DisenchanterPlus",
  "AceConsole-3.0",    -- Soporte de comandos de chat
  "AceEvent-3.0",      -- Sistema de eventos
  "AceTimer-3.0",      -- Timers
  "AceComm-3.0",       -- Comunicación inter-addon
  "AceBucket-3.0"      -- Agrupación de eventos
)
```

### Métodos Principales

#### `OnInitialize()`

- Inicializa la base de datos con AceDB-3.0
- Crea la clave única del jugador: `"NombrePersonaje - NombreReino"`
- Configura valores por defecto del minimap
- Registra eventos temprano mediante `DP_EventHandler:RegisterEarlyEvents()`

```lua
function DisenchanterPlus:OnInitialize()
  DisenchanterPlus.db = LibStub("AceDB-3.0"):New("DisenchanterPlusDB", DP_SettingsDefaults:Load(), true)
  DisenchanterPlus.key = UnitName("player") .. " - " .. GetRealmName()
  DisenchanterPlus.started = false
  DP_EventHandler:RegisterEarlyEvents()
end
```

#### `OnEnable()`

- Actualmente no implementado (extensible para futuro)

### Sistema de Mensajería

El addon proporciona métodos para diferentes niveles de logging coloreado:

| Método         | Color           | Uso                        |
| -------------- | --------------- | -------------------------- |
| `Print(msg)`   | Púrpura + Texto | Mensajes normales          |
| `Error(msg)`   | Rojo            | Errores críticos           |
| `Warning(msg)` | Naranja         | Advertencias               |
| `Info(msg)`    | Cian            | Información importante     |
| `Debug(msg)`   | Amarillo        | Debug (solo si habilitado) |
| `Log(msg)`     | Gris            | Logs detallados            |
| `Time(msg)`    | Verde           | Timestamps                 |
| `Dump(msg)`    | Gris claro      | Volcado de estructuras     |

### Propiedades de Detección de Cliente

```lua
DisenchanterPlus.IsMainline      -- Retail/Mainline (excluye Forever)
DisenchanterPlus.IsForever       -- Classic WoW Forever (build 1.60.x, reporta project ID Mainline)
DisenchanterPlus.IsClassic       -- Classic Era (incluye Forever)
DisenchanterPlus.IsEra           -- Classic Era (no estacional)
DisenchanterPlus.IsEraSeasonal   -- Classic Era estacional (SoD)
DisenchanterPlus.IsHardcore      -- Realm Hardcore
```

### Sistema de Bases de Datos

La base de datos se estructura en tres niveles con AceDB-3.0:

- **profile**: Configuración por perfil (minimap)
- **global**: Datos globales de caracteres e items
- **char**: Datos específicos del personaje (general, advanced)

---

## 3. SISTEMA DE MÓDULOS

El addon utiliza un patrón **module loader** personalizado para gestionar dependencias entre módulos.

### ModuleLoader.lua

**Ubicación**: `/Modules/ModuleLoader.lua`  
**Rol**: Gestor central de módulos  
**Acceso**: Único módulo público en el namespace global

```lua
DP_ModuleLoader = {}
```

#### Métodos Principales

```lua
-- Crear o recuperar módulo
function DP_ModuleLoader:CreateModule(name)
  -- Devuelve { private = {} } si no existe
end

-- Importar módulo (sin crear si no existe)
function DP_ModuleLoader:ImportModule(name)
  -- Devuelve el módulo o {}
end
```

#### Patrón de Uso

```lua
-- En cada módulo
local DP_MiModulo = DP_ModuleLoader:CreateModule("DP_MiModulo")
local DP_OtroModulo = DP_ModuleLoader:ImportModule("DP_OtroModulo")
```

### Arquitectura General de Módulos

Todos los módulos siguen este patrón:

```lua
---@class DP_NombreModulo
local DP_NombreModulo = DP_ModuleLoader:CreateModule("DP_NombreModulo")

-- Tabla privada (opcional)
local _DP_NombreModulo = {}

-- Importar dependencias
local DP_OtroModulo = DP_ModuleLoader:ImportModule("DP_OtroModulo")

-- Métodos públicos
function DP_NombreModulo:MetodoPublico()
  -- Implementación
end

-- Métodos privados
function _DP_NombreModulo:MetodoPrivado()
  -- Implementación
end
```

---

## 4. MÓDULOS PRINCIPALES EN /Modules/

### 4.1 MÓDULOS DE NIVEL SUPERIOR (Raíz de /Modules/)

#### **EventHandler.lua**

- **Clase**: `DP_EventHandler`
- **Rol**: Registra eventos WoW tempranos
- **Función Principal**: `RegisterEarlyEvents()`
- **Eventos Registrados**:
  - `PLAYER_LOGIN` → Inicializa el addon cuando el jugador ingresa
- **Funciones Clave**:
  - `PlayerLogin()` - Recoge info del jugador (clase, raza, reino, locale, etc.)
  - Populamos `DisenchanterPlus.db.global.characters[key]` con datos del personaje
  - Resetea lista de items ignorados por sesión

#### **Init.lua**

- **Clase**: `DP_Init`
- **Rol**: Inicializador principal del addon
- **Función Principal**: `Initialize()`
- **Flujo de Inicialización**:
  1. Minimap Icon → `DP_MinimapIcon:Initialize()`
  2. Slash Commands → `DP_SlashCommands:RegisterSlashCommands()`
  3. Settings → `DP_Settings:Initialize()`
  4. Database → `DP_Database:Initialize()`
  5. Tooltip → `DP_EnchantingTooltip:Initialize()`
  6. Events → `DP_DisenchanterPlusEvents:Initialize()`
  7. Enchant Process → `DP_EnchantProcess:Initialize()` (con delay de 1s)

#### **SlashCommands.lua**

- **Clase**: `DP_SlashCommands`
- **Rol**: Gestor de comandos de chat
- **Comandos Registrados**:
  - `/disenchanterplus` o `/dplus` - Comando principal
- **Subcomandos**:
  - `config` - Abre ventana de configuración
  - `minimap` - Alterna visibilidad del icono de minimapa
  - Otros comandos muestran ayuda

#### **VersionCheck.lua**

- **Clase**: No definida (singleton)
- **Rol**: Verifica versiones de addon
- **Detección de Cliente**: Define propiedades de cliente (`IsMainline`, `IsClassic`, etc.)

#### **MinimapIcon.lua**

- **Clase**: `DP_MinimapIcon`
- **Rol**: Gestiona el icono del minimapa mediante LibDBIcon
- **Funciones Clave**:
  - `Initialize()` - Registra con LibDBIcon
  - `CreateDataBrokerObject()` - Define comportamiento de clics
  - `ToggleVisibility()` - Alterna visibilidad
  - `UpdateIcon()` - Actualiza icono dinámicamente
- **Comportamiento**:
  - Click izquierdo → Abre ventana de desencantamiento
  - Click izquierdo + Shift → Inicia desencantamiento automático
  - Click derecho → Abre configuración

#### **Database.lua**

- **Clase**: `DP_Database`
- **Rol**: Gestor de datos de items y materiales de encantamiento
- **Datos Almacenados**: Items de encantamiento (polvos, esencias, fragmentos, cristales)
- **Funciones Clave**:
  - `Initialize()` - Prepara datos de base de datos
  - `GetExpectedDisenchantData()` - Devuelve datos esperados de desencantamiento
  - `GetEnchantingItemType()` - Identifica tipo de material de encantamiento
- **Item Categories**:
  - Dusts (Polvos): Strange Dust, Soul Dust, Vision Dust, etc.
  - Essences (Esencias): Lesser/Greater Magic, Astral, Mystic, Nether, Eternal
  - Shards (Fragmentos): Glimmering, Glowing, Radiant, Brilliant, Prismatic, Dream
  - Crystals (Cristales): Nexus, Void, Abyss

---

### 4.2 SUBCARPETA: /Modules/Events/

#### **DisenchanterPlusEvents.lua**

- **Clase**: `DP_DisenchanterPlusEvents`
- **Rol**: Concentrador de eventos WoW del addon
- **Eventos Registrados**:
  - Spell Cast Events:
    - `UNIT_SPELLCAST_SENT` - Envío de hechizo
    - `UNIT_SPELLCAST_START` - Inicio de casting
    - `UNIT_SPELLCAST_STOP` - Parada de casting
    - `UNIT_SPELLCAST_SUCCEEDED` - Hechizo exitoso
    - `UNIT_SPELLCAST_FAILED` - Hechizo fallido
    - `UNIT_SPELLCAST_INTERRUPTED` - Hechizo interrumpido
  - Loot Events:
    - `LOOT_READY` - Botín disponible
    - `LOOT_CLOSED` - Botín cerrado
  - Inventory Events:
    - `BAG_UPDATE` - Cambios en bolsas
    - `ITEM_LOCKED` - Item bloqueado
  - Combat Events:
    - `PLAYER_REGEN_DISABLED` - Entró en combate
    - `PLAYER_REGEN_ENABLED` - Salió de combate
  - Classic-Only Events:
    - `CRAFT_SHOW` - Ventana de craft abierta
    - `CRAFT_CLOSE` - Ventana de craft cerrada
- **Inicializa**: LootProcess, DisenchantProcess

---

### 4.3 SUBCARPETA: /Modules/Disenchant/

#### **DisenchantProcess.lua**

- **Clase**: `DP_DisenchantProcess`
- **Rol**: Núcleo de la lógica de desencantamiento
- **Estado Global**:
  - `disenchanting` - ¿Se está desencantando actualmente?
  - `itemToDisenchant` - Item actual a desenchantar
  - `autoDisenchantStatus` - ¿Auto-desencantamiento habilitado?
- **Funciones Principales**:
  - `Initialize()` - Inicializa y comienza auto-desencantamiento
  - `StartAutoDisenchant()` - Inicia proceso automático
  - `SetAutoDisenchantStatus()` - Activa/desactiva auto-desencantamiento
  - `AddSessionIgnoredItem()` - Añade item a lista de ignorados de sesión
  - `UnitSpellCastSent()` - Maneja inicio de hechizo
  - `UnitSpellCastStart()` - Maneja inicio de casting
  - `UnitSpellCastStop()` - Maneja parada de casting
- **Flujo de Desencantamiento**:
  1. Obtiene item de bolsas mediante `DP_BagsCheck`
  2. Verifica tradeskill mediante `DP_TradeSkillCheck`
  3. Abre ventana de desencantamiento via `DP_DisenchantWindow`
  4. Castea hechizo Disenchant (ID: 13262)
  5. Espera confirmación del usuario
  6. Procesa loot después del hechizo
- **Integraciones**:
  - `DP_DisenchantGroup` - Gestión de listas ignoradas
  - `DP_DisenchantWindow` - UI de desencantamiento
  - `DP_TradeSkillCheck` - Verificación de profesión
  - `DP_BagsCheck` - Búsqueda de items

#### **LootProcess.lua**

- **Clase**: `DP_LootProcess`
- **Rol**: Procesa el botín obtenido del desencantamiento
- **Funciones Principales**:
  - `Initialize()` - Inicializa módulo
  - `LootReady()` - Procesa loot cuando está listo
  - `LootClosed()` - Maneja cierre de ventana de loot
  - `UnitSpellCastSucceeded()` - Triggered cuando hechizo es exitoso
- **Seguridad**:
  - Límite máximo de 1000 items de loot para evitar loops infinitos
  - Protección contra errores en obtención de links de loot
  - Detección de conflictos de looting (LootingInProgress)
- **Datos Procesados**:
  - Obtiene itemID, link, cantidad y tipo de slot
  - Actualiza base de datos global de items looteados

---

### 4.4 SUBCARPETA: /Modules/Enchant/

#### **EnchantProcess.lua**

- **Clase**: `DP_EnchantProcess`
- **Rol**: Gestor del proceso de encantamiento en masa
- **Estado Global**:
  - `IsTradeSkillKnown` - ¿Jugador tiene profesión Encantamiento?
  - `IsCorrectTradeSkill` - ¿Se está usando Encantamiento?
  - `IsCraftingWindowOpen` - ¿Ventana de encantamiento abierta?
- **Funciones Principales**:
  - `Initialize()` - Verifica profesión de encantamiento
  - `CheckTradeskill()` - Obtiene info de profesión
  - `OpenEnchantWindow()` - Abre ventana de encantamiento en masa
  - `EnchantItem()` - Encanta item individual
  - `StartAutoEnchant()` - Inicia encantamiento automático
  - `IsCraftingWindowOpen()` - Retorna estado de ventana
- **Integraciones**:
  - `DP_EnchantWindow` - UI de encantamiento
  - `DP_TradeSkillCheck` - Verificación de profesión
  - `DP_BagsCheck` - Búsqueda de items

---

### 4.5 SUBCARPETA: /Modules/Window/

#### **DisenchantWindow.lua**

- **Clase**: `DP_DisenchantWindow`
- **Rol**: UI principal para desencantamiento
- **Funciones Principales**:
  - `Initialize()` - Crea y configura ventana
  - `OpenDisenchantWindow()` - Muestra ventana
  - `CloseDisenchantWindow()` - Cierra ventana
  - `IsWindowOpened()` - Retorna si está abierta
  - `UpdateWindowContent()` - Refresca contenido
  - `ShowItemsList()` - Muestra lista de items a desenchantar
- **Características**:
  - Backdrop personalizado con colores del addon
  - Lista de items con materiales esperados
  - Botones: Accept, Cancel, Ignore
  - Efectos de sonido personalizados al abrir/cerrar
  - Integración con DP_CustomSounds
  - Integración con DP_CustomMedias para texturas

#### **EnchantWindow.lua**

- **Clase**: `DP_EnchantWindow`
- **Rol**: UI para encantamiento en masa
- **Funciones Análogas** a DisenchantWindow:
  - Gestión de ventana de encantamiento
  - Filtrado de items por tipo de encantamiento
  - Verificación de materiales disponibles
  - Aplicación de encantamientos en lote

#### **IgnoredWindow.lua**

- **Clase**: `DP_IgnoredWindow`
- **Rol**: Gestiona UI de items ignorados
- **Funciones Principales**:
  - `OpenIgnoredWindow()` - Muestra lista de items ignorados
  - `AddToIgnoreList()` - Añade item a lista permanente
  - `RemoveFromIgnoreList()` - Elimina item de lista permanente
  - `ClearSessionIgnoreList()` - Limpia items ignorados por sesión

---

### 4.6 SUBCARPETA: /Modules/Settings/

El sistema de configuración usa AceConfig-3.0 y AceGUI-3.0 para una interfaz moderna.

#### **Settings.lua**

- **Clase**: `DP_Settings`
- **Rol**: Inicializador y gestor de la ventana de configuración
- **Funciones Principales**:
  - `Initialize()` - Registra tabla de opciones con AceConfig
  - `DrawSettingsFrame()` - Crea y renderiza ventana de configuración
- **Estructura**:
  - Registra con `AceConfigRegistry`
  - Abre con `AceConfigDialog`
  - Crea frame AceGUI con layout "Fill"
- **Callbacks**:
  - `OnShow` - Reproduce sonido de apertura, actualiza listas
  - `OnClose` - Reproduce sonido de cierre, continúa auto-desencantamiento

#### **SettingsDefaults.lua**

- **Clase**: `DP_SettingsDefaults`
- **Rol**: Define todos los valores por defecto
- **Estructura de Base de Datos**:

```lua
{
  profile = {
    minimap = {
      hide = false,
      minimapPos = 220
    }
  },
  global = {
    data = {           -- Estadísticas globales
      items = {},
      dusts = {},
      essences = {},
      shards = {},
      crystals = {},
      unknown = {}
    },
    characters = {}    -- Info de personajes
  },
  char = {             -- Datos por personaje
    advanced = {
      debug = false
    },
    general = {
      disableAll = false,
      disenchanProcessEnabled = true,
      tooltipsEnabled = true,
      keybindingEnabled = false,
      acceptDisenchant = nil,
      pressKeyDown = "1_none",
      showTitle = true,
      showItemID = false,
      zeroValues = true,
      itemsToShow = 5,
      showExpectedEssences = true,
      showRealEssences = true,
      autoDisenchantEnabled = true,
      autoDisenchantDbTimeout = 10,
      itemQuality = { ["2"] = true, ["3"] = true, ["4"] = true },
      disenchantFrameOffset = { xOffset = 0, yOffset = 200 },
      enchantFrameOffset = { xOffset = 0, yOffset = 200 },
      permanentIgnoredItems = {},
      sessionIgnoredItems = {},
      onlySoulbound = false,
      showItemQuality = true,
      auctionatorIntegration = false,
      enchantEnabled = true,
      filterWithoutMaterials = false,
      enchantItemQuality = { ["2"] = true, ["3"] = true, ["4"] = true },
      enchantCraftType = { ["1"] = true, ["2"] = true, ["3"] = true, ["4"] = true }
    }
  }
}
```

#### **ConfigGroups.lua**

- **Clase**: `DP_ConfigGroups`
- **Rol**: Genera estruturas de configuración para AceConfig

#### Subcarpetas de Settings:

##### **/Modules/Settings/GeneralTab/**

- `GeneralTab.lua` - Contenedor principal de configuración general
- `Groups/GeneralGroup.lua` - Grupo de opciones generales
- `Groups/KeybindingGroup.lua` - Configuración de keybindings

##### **/Modules/Settings/AdvancedTab/**

- `AdvancedTab.lua` - Contenedor de opciones avanzadas
- `Groups/AdvancedGroup.lua` - Debug, logging, opciones avanzadas
- `Groups/IntegrationGroup.lua` - Integraciones con otros addons

##### **/Modules/Settings/DisenchantTab/**

- `DisenchantTab.lua` - Opciones de desencantamiento
- `Groups/DisenchantGroup.lua` - Configuración de filtros, calidades, listas ignoradas

##### **/Modules/Settings/EnchantTab/**

- `EnchantTab.lua` - Opciones de encantamiento
- `Groups/EnchantGroup.lua` - Configuración de encantamiento en masa

##### **/Modules/Settings/TooltipsTab/**

- `TooltipsTab.lua` - Configuración de tooltips
- `Groups/TooltipsGroup.lua` - Opciones de información en tooltips

##### **/Modules/Settings/KeybindingsTab/**

- `KeybindingsTab.lua` - Configuración de teclas
- `Groups/KeybindingsGroup.lua` - Definición de keybindings

##### **/Modules/Settings/MaintenanceTab/**

- `MaintenanceTab.lua` - Herramientas de mantenimiento
- `Groups/DatabaseGroup.lua` - Opciones de limpieza/consolidación de BD

---

### 4.7 SUBCARPETA: /Modules/Custom/

Módulos utilitarios y de soporte para UI y funciones generales.

#### **CustomFunctions.lua**

- **Clase**: `DP_CustomFunctions`
- **Rol**: Utilidades de Lua generales
- **Funciones Principales**:
  - `Dump(o)` - Convierte tabla a string legible
  - `RemoveDuplicationsInTable(t)` - Elimina duplicados
  - `TableHasValue(t, v)` - Busca valor en tabla
  - `TableHasKey(t, k)` - Busca clave en tabla
  - `IsKeyPressed(keyCombo)` - Detecta combinación de teclas
  - `Split(s, pattern)` - Divide string
  - `GetItemLink()` - Obtiene link de item

#### **CustomColors.lua**

- **Clase**: `DP_CustomColors`
- **Rol**: Paleta de colores personalizada
- **Funciones Principales**:
  - `CustomClassColors(class)` - Colores de clases (DRUID, MAGE, etc.)
  - `CustomClassBrightColors(class)` - Colores brillantes
  - `CustomQualityColors(quality)` - Colores de calidad de items
  - `CustomMaterialColors(material)` - Colores de materiales

#### **CustomFrames.lua**

- **Clase**: `DP_CustomFrames`
- **Rol**: Creación de elementos UI personalizados
- **Funciones Principales**:
  - `HorizontalSpacer(order, width)` - Espaciador horizontal
  - `Spacer(order, hidden)` - Espaciador vertical
  - `CreateTab(parent, name, index, text, active, w, h)` - Tab personalizado
  - Elementos AceGUI personalizados

#### **CustomSounds.lua**

- **Clase**: `DP_CustomSounds`
- **Rol**: Gestor de efectos de sonido
- **Sonidos Disponibles**:
  - `MoneyDialogClose` - Cierre de diálogo de dinero
  - `WindowClose` - Cierre de ventana genérica
  - `WindowOpen` - Apertura de ventana genérica
  - `TabChange` - Cambio de pestaña
  - `ChatScrollButton` - Scroll de chat
- **Funciones Principales**:
  - `PlayCustomSound(name)` - Reproduce efecto de sonido
  - `GetSoundFile(name)` - Obtiene ruta de archivo

#### **CustomMedias.lua**

- **Clase**: `DP_CustomMedias`
- **Rol**: Gestor de recursos multimedia (texturas, fuentes)
- **Funciones Principales**:
  - `RegisterCustomMedias()` - Registra con LibSharedMedia
  - `GetMediaFile(name)` - Obtiene ruta de archivo multimedia
  - Soporta texturas personalizadas para UI

#### **CustomPopup.lua**

- **Clase**: `DP_CustomPopup`
- **Rol**: Cuadros de diálogo y confirmaciones
- **Funciones Principales**:
  - `ShowPopup(message, confirmFn, cancelFn)` - Muestra popup
  - `IsOpened()` - Retorna si popup está abierto
  - `CancelPopup()` - Cierra popup actual

#### **CustomConfig.lua**

- **Clase**: `DP_CustomConfig`
- **Rol**: Generadores de configuraciones para AceConfig
- **Funciones Principales**:
  - `CreateDeleteCharacterConfig()` - Config para eliminar datos de personaje
  - `GenerateMemoryConfig()` - Config de uso de memoria
  - Otros generadores de opciones

---

### 4.8 SUBCARPETA: /Modules/Tooltip/

#### **EnchantingTooltip.lua**

- **Clase**: `DP_EnchantingTooltip`
- **Rol**: Añade información de encantamiento a tooltips
- **Funciones Principales**:
  - `Initialize()` - Hookea GameTooltip
  - `ShowTooltip(itemInfo)` - Muestra información de materiales esperados
  - `OnGameTooltipSetItem()` - Callback de hook
- **Información Mostrada**:
  - Materiales esperados del desencantamiento
  - Precios de Auctionator (si habilitado)
  - Descripción de ítems de encantamiento

---

### 4.9 SUBCARPETA: /Modules/Tradeskill/

#### **TradeSkillCheck.lua**

- **Clase**: `DP_TradeSkillCheck`
- **Rol**: Verificación de profesiones de encantamiento
- **Funciones Principales**:
  - `GetTradeSkill()` - Obtiene info de profesión de Encantamiento
  - `FindTradeSkillBySpellID(spellID)` - Busca profesión por ID de hechizo
  - `GetTradeSkillLevel()` - Obtiene nivel de profesión
- **Spell IDs Soportados**:
  - 13262 (Disenchant - Classic)
  - 7411, 7412, 7413 (Enchant spells)
  - 13920, 28029, 51313, 74258 (Otros encantamientos por expansión)
- **Compatibilidad**: Maneja diferentes APIs según cliente (Forever/Camelot y Classic)

---

### 4.10 SUBCARPETA: /Modules/Bags/

#### **BagsCheck.lua**

- **Clase**: `DP_BagsCheck`
- **Rol**: Búsqueda e iteración de items en bolsas
- **Funciones Principales**:
  - `GetItemFromBag()` - Obtiene primer item a desenchantar
  - `ItemsInBags()` - Cuenta total de items a desenchantar
  - `ItemInBag(bagIndex, sessionIgnored, permanentIgnored)` - Busca items en bolsa específica
- **Filtrado**:
  - Excluye items en lista de ignorados (sesión y permanente)
  - Verifica calidad del item (común, poco común, raro, épico)
  - Ignora Enchanting Vellums (ID: 38682) si es necesario
  - Verifica si item es soulbound

---

### 4.11 SUBCARPETA: /Modules/Database/

Tablas de datos de desencantamiento para cada expansión.

#### **ClassicDisenchantTable.lua**

- **Clase**: `DP_ClassicDisenchantTable`
- **Contenido**: Tabla de materiales esperados para Classic WoW
- **Estructura**:
  ```lua
  PercentByQualityAndLevel = {
    [itemLevel] = {
      [2] = { dusts = {}, essences = {} },  -- Uncommon
      [3] = { dusts = {}, essences = {} },  -- Rare
      [4] = { dusts = {}, essences = {} }   -- Epic
    }
  }
  ```

#### **EnchantPatterns.lua**

- **Clase**: `DP_EnchantPatterns`
- **Contenido**: Patrones de encantamientos disponibles
- **Estructura**: Encantamientos agrupados por tipo (Armor, Weapon, Enchanting Vellum)

---

## 5. SISTEMA DE LOCALIZACIÓN (Locale/)

El addon soporta múltiples idiomas mediante **AceLocale-3.0**.

### Estructura

```
Locale/
├── Locales.xml               # Incluye archivos de localización
├── localization.en.lua       # English
├── localization.de.lua       # Deutsch
├── localization.es.lua       # Español
├── localization.fr.lua       # Français
├── localization.it.lua       # Italiano
├── globalstrings.lua         # Strings globales de WoW
└── Locale.xlsx              # Spreadsheet de traducción
```

### Sistema de Localización

```lua
local L = LibStub("AceLocale-3.0"):GetLocale("DisenchanterPlus")
-- Uso: L["Texto a traducir"]
```

### Idiomas Soportados

- **enUS** - English (por defecto)
- **deDE** - Deutsch
- **esES** - Español
- **frFR** - Français
- **itIT** - Italiano

### Strings Localizados

- UI: Botones, tabs, títulos de ventanas
- Mensajes: Confirmaciones, advertencias, errores
- Comandos: Nombres y descripciones de slash commands
- Items: Nombres de profesiones, tipos de items

---

## 6. SISTEMA DE LIBRERÍAS (Libs/)

DisenchanterPlus utiliza Ace3 Framework con extensiones adicionales:

### 6.1 Ace3 Framework

| Librería                  | Rol                                            |
| ------------------------- | ---------------------------------------------- |
| **AceAddon-3.0**          | Inicialización y ciclo de vida del addon       |
| **AceConsole-3.0**        | Sistema de comandos de chat (`/dplus`)         |
| **AceEvent-3.0**          | Registro y manejo de eventos WoW               |
| **AceTimer-3.0**          | Timers y delays (`C_Timer.After`)              |
| **AceDB-3.0**             | Persistencia de configuración (SavedVariables) |
| **AceDBOptions-3.0**      | Opciones de perfiles de BD                     |
| **AceGUI-3.0**            | Framework de UI (ventanas, widgets)            |
| **AceConfig-3.0**         | Sistema de configuración declarativa           |
| **AceConfigCmd-3.0**      | Soporte de línea de comandos para config       |
| **AceConfigDialog-3.0**   | Panel de configuración visual                  |
| **AceConfigRegistry-3.0** | Registro de tablas de opciones                 |
| **AceComm-3.0**           | Comunicación inter-addon                       |
| **AceBucket-3.0**         | Agrupación de eventos                          |
| **AceLocale-3.0**         | Sistema de localización                        |
| **AceSerializer-3.0**     | Serialización de datos                         |
| **AceTab-3.0**            | Gestión de tabs                                |
| **AceHook-3.0**           | Hooking de funciones (script/method)           |

### 6.2 Librerías Externas

| Librería                | Rol                             |
| ----------------------- | ------------------------------- |
| **LibStub**             | Sistema de carga de librerías   |
| **CallbackHandler-1.0** | Sistema de callbacks            |
| **LibDataBroker-1.1**   | Framework para datos en UI      |
| **LibDBIcon-1.0**       | Icono del minimap integrable    |
| **LibCandyBar-3.0**     | Barras de progreso              |
| **LibSharedMedia-3.0**  | Recursos multimedia compartidos |
| **LibDropdown-1.0**     | Dropdowns mejorados             |
| **HereBeDragons-2.0**   | Sistema de coordenadas de mapas |

### embeds.xml

El archivo `embeds.xml` incluye todas estas librerías en el orden correcto de dependencias:

```xml
<Ui>
  <!-- LibStub debe ser primero -->
  <Script file="Libs\LibStub\LibStub.lua"/>

  <!-- Dependencias base -->
  <Include file="Libs\CallbackHandler-1.0\CallbackHandler-1.0.xml"/>
  <Include file="Libs\AceAddon-3.0\AceAddon-3.0.xml"/>

  <!-- Sistemas de eventos y datos -->
  <Include file="Libs\AceEvent-3.0\AceEvent-3.0.xml"/>
  <Include file="Libs\AceTimer-3.0\AceTimer-3.0.xml"/>

  <!-- Persistencia y configuración -->
  <Include file="Libs\AceDB-3.0\AceDB-3.0.xml"/>
  <Include file="Libs\AceDBOptions-3.0\AceDBOptions-3.0.xml"/>

  <!-- Comunicación -->
  <Include file="Libs\AceConsole-3.0\AceConsole-3.0.xml"/>
  <Include file="Libs\AceLocale-3.0\AceLocale-3.0.xml"/>
  <Include file="Libs\AceComm-3.0\AceComm-3.0.xml"/>
  <Include file="Libs\AceBucket-3.0\AceBucket-3.0.xml"/>

  <!-- UI Framework -->
  <Include file="Libs\AceGUI-3.0\AceGUI-3.0.xml"/>
  <Include file="Libs\AceConfig-3.0\AceConfig-3.0.xml"/>

  <!-- Librerías externas -->
  <Script file="Libs\LibDataBroker-1.1\LibDataBroker-1.1.lua"/>
  <Script file="Libs\LibDBIcon-1.0\LibDBIcon-1.0.lua"/>
  <Script file="Libs\LibCandyBar-3.0\LibCandyBar-3.0.lua"/>
  <Script file="Libs\LibSharedMedia-3.0\LibSharedMedia-3.0.lua"/>
  <Script file="Libs\LibDropdown-1.0\LibDropdown-1.0.lua"/>

  <!-- Mapas y coordenadas -->
  <Script file="Libs\HereBeDragons-2.0\HereBeDragons-2.0.lua"/>
  <Script file="Libs\HereBeDragons-2.0\HereBeDragons-Pins-2.0.lua"/>
  <Script file="Libs\HereBeDragons-2.0\HereBeDragons-Migrate.lua"/>
</Ui>
```

---

## 7. ARCHIVOS DE CONFIGURACIÓN

### 7.1 DisenchanterPlus_Camelot.toc

El archivo Table of Contents que WoW lee para cargar el addon en Classic WoW Forever (Camelot):

```
## Interface: 16001                    # Interface Forever (1.60.x)
## Title: |cffe1e1e1Disenchanter|r |cffed6bffPlus|r |cff9191a1v3.0.0.0|r
## Version: 3.0.0.0
## Notes: Disenchanter tool for wow classic era
## Author: osilvay
## SavedVariables: DisenchanterPlusDB  # Clave de BD persistente
## OptionalDeps: Ace3, CallbackHandler-1.0, LibStub
## IconTexture: Interface\AddOns\DisenchanterPlus\Images\Menus\disenchanterplus.tga
## DefaultState: enabled
## LoadOnDemand: 0                     # Cargar al iniciar (no bajo demanda)
```

**Orden de Carga**:

1. `embeds.xml` - Librerías (LibStub, Ace3, etc.)
2. `Modules\ModuleLoader.lua` - Sistema de módulos
3. `Modules\VersionCheck.lua` - Detección de versión
4. `Locale\Locales.xml` - Localización
5. Todos los módulos (en orden específico)
6. `DisenchanterPlus.lua` - Archivo principal

### 7.2 pkgmeta.yaml

Configuración del empaquetador CurseForge/WoWUP:

```yaml
package-as: DisenchanterPlus # Nombre del paquete
manual-changelog: CHANGELOG.md # Changelog manual
ignore: # Archivos a excluir
  - Doc
  - Patches
  - Release
  - .gitignore
  - .version
  - DisenchanterPlus.toc
  - packager.bat
  - packagerExclusions.lst
```

### 7.3 Bindings.xml

Define keybindings del addon:

```xml
<Bindings>
  <Binding name="DISENCHANTER_PLUS_ACCEPT_DISENCHANT">
    <!-- Keybinding para aceptar desencantamiento -->
  </Binding>
  <Binding name="DISENCHANTER_PLUS_CANCEL_DISENCHANT">
    <!-- Keybinding para cancelar desencantamiento -->
  </Binding>
  <Binding name="DISENCHANTER_PLUS_IGNORE_DISENCHANT">
    <!-- Keybinding para ignorar item -->
  </Binding>
</Bindings>
```

---

## 8. SISTEMA DE CARGA DE MÓDULOS

### Flujo de Inicialización Completo

```
1. WoW Inicia Addon
   ↓
2. Carga TOC (DisenchanterPlus_Camelot.toc)
   ├─ embeds.xml (Librerías Ace3)
   ├─ ModuleLoader.lua (Sistema de módulos)
   ├─ VersionCheck.lua (Detección cliente)
   └─ Locale/Locales.xml (Idiomas)
   ↓
3. Carga Módulos (en orden del TOC)
   ├─ EventHandler.lua
   ├─ Init.lua
   ├─ MinimapIcon.lua
   ├─ SlashCommands.lua
   ├─ Events/* (Disenchant/Enchant events)
   ├─ Settings/* (Tabs y grupos)
   ├─ Window/* (UIs)
   ├─ Custom/* (Utilidades)
   ├─ Disenchant/*
   ├─ Enchant/*
   ├─ Tooltip/*
   ├─ Tradeskill/*
   ├─ Bags/*
   └─ Database/*
   ↓
4. Carga DisenchanterPlus.lua
   ├─ Crea tabla global DisenchanterPlus
   ├─ Hereda de AceAddon-3.0
   └─ Llama OnInitialize()
   ↓
5. DisenchanterPlus:OnInitialize()
   ├─ Crea DB con AceDB-3.0
   ├─ Registra clave única
   └─ Llama DP_EventHandler:RegisterEarlyEvents()
   ↓
6. Event: PLAYER_LOGIN
   ├─ DP_EventHandler:PlayerLogin()
   ├─ Recaba info del jugador
   └─ Llama DP_Init:Initialize()
   ↓
7. DP_Init:Initialize()
   ├─ DP_MinimapIcon:Initialize()
   ├─ DP_SlashCommands:RegisterSlashCommands()
   ├─ DP_Settings:Initialize()
   ├─ DP_Database:Initialize()
   ├─ DP_EnchantingTooltip:Initialize()
   ├─ DP_DisenchanterPlusEvents:Initialize()
   │  ├─ DP_LootProcess:Initialize()
   │  └─ DP_DisenchantProcess:Initialize()
   └─ (delay 1s) DP_EnchantProcess:Initialize()
   ↓
8. Addon Listo
   ├─ Print "Initialized v3.0.0.0"
   ├─ Set DisenchanterPlus.started = true
   └─ Sistema esperando eventos WoW
```

### Patrón de Carga de Módulos

Cada módulo sigue este patrón:

```lua
-- 1. Crear módulo
local DP_MiModulo = DP_ModuleLoader:CreateModule("DP_MiModulo")

-- 2. Importar dependencias
local DP_OtroModulo = DP_ModuleLoader:ImportModule("DP_OtroModulo")

-- 3. Métodos públicos
function DP_MiModulo:MetodoPublico()
  -- Accesible desde otros módulos
end

-- 4. Métodos privados (opcional)
local _DP_MiModulo = {}
function _DP_MiModulo:MetodoPrivado()
  -- Solo dentro de este módulo
end
```

---

## 9. SISTEMA DE EVENTOS WoW

### Eventos Registrados

El addon monitorea estos eventos WoW importantes:

#### Ciclo de Vida del Addon

- `PLAYER_LOGIN` - Jugador ingresa en el juego
- `PLAYER_LOGOUT` - Jugador sale del juego

#### Casting de Hechizos

- `UNIT_SPELLCAST_SENT` - Se envía hechizo
- `UNIT_SPELLCAST_START` - Inicia casting
- `UNIT_SPELLCAST_STOP` - Para casting
- `UNIT_SPELLCAST_SUCCEEDED` - Hechizo exitoso (genera loot)
- `UNIT_SPELLCAST_FAILED` - Hechizo falló
- `UNIT_SPELLCAST_INTERRUPTED` - Hechizo interrumpido

#### Loot

- `LOOT_READY` - Botín disponible para looting
- `LOOT_CLOSED` - Ventana de loot cerrada

#### Inventario

- `BAG_UPDATE` - Cambio en bolsas
- `ITEM_LOCKED` - Item está bloqueado

#### Combat

- `PLAYER_REGEN_DISABLED` - Entró en combate
- `PLAYER_REGEN_ENABLED` - Salió de combate

#### Crafting (Classic Solo)

- `CRAFT_SHOW` - Ventana de craft abierta
- `CRAFT_CLOSE` - Ventana de craft cerrada

---

## 10. SISTEMA DE CONFIGURACIÓN/SETTINGS

### Estructura de AceConfig

El addon utiliza AceConfig-3.0 con estructura de árbol (`childGroups = "tree"`):

```
DisenchanterPlus Settings
├── General Tab
│   ├── General Group
│   └── Keybinding Group
├── Enchant Tab
│   └── Enchant Group
├── Disenchant Tab
│   └── Disenchant Group
├── Tooltips Tab
│   └── Tooltips Group
├── Keybindings Tab
│   └── Keybindings Group
├── Advanced Tab
│   ├── Advanced Group
│   └── Integration Group
└── Maintenance Tab
    └── Database Group
```

### Opciones Principales

#### General Settings

- Auto-Disenchant habilitado/deshabilitado
- Mostrar título de item
- Mostrar ID de item
- Calidades a desenchantar (Poco Común, Raro, Épico)
- Solo items soulbound
- Items a mostrar en ventana

#### Enchant Settings

- Encantamiento habilitado/deshabilitado
- Tipos de encantamiento a aplicar
- Calidades de items a enchant
- Filtrado sin materiales

#### Disenchant Settings

- Listas de items ignorados (permanente y sesión)
- Calidades filtradas
- Timeout de auto-desencantamiento

#### Advanced Settings

- Debug mode
- Integración con otros addons (Auctionator)
- Información técnica de memoria

#### Maintenance Settings

- Limpiar base de datos
- Consolidar datos
- Eliminar datos de personaje

---

## 11. RELACIONES ENTRE MÓDULOS

### Diagrama de Dependencias

```
DisenchanterPlus (Main)
│
├─→ DP_EventHandler
│   └─→ DP_Init
│       ├─→ DP_Settings
│       │   ├─→ AceConfigDialog-3.0
│       │   ├─→ AceGUI-3.0
│       │   └─→ [Todos los Tab modules]
│       ├─→ DP_MinimapIcon
│       │   ├─→ LibDBIcon-1.0
│       │   ├─→ DP_CustomColors
│       │   ├─→ DP_CustomMedias
│       │   └─→ DP_DisenchantProcess
│       ├─→ DP_SlashCommands
│       ├─→ DP_Database
│       │   ├─→ DP_ClassicDisenchantTable
│       │   └─→ DP_EnchantPatterns
│       ├─→ DP_EnchantingTooltip
│       │   ├─→ DP_Database
│       │   ├─→ DP_CustomFunctions
│       │   └─→ DP_CustomColors
│       └─→ DP_DisenchanterPlusEvents
│           ├─→ DP_LootProcess
│           │   ├─→ DP_Database
│           │   └─→ DP_TradeSkillCheck
│           └─→ DP_DisenchantProcess
│               ├─→ DP_DisenchantWindow
│               │   ├─→ DP_CustomFunctions
│               │   ├─→ DP_CustomSounds
│               │   ├─→ DP_Database
│               │   ├─→ DP_CustomMedias
│               │   └─→ DP_IgnoredWindow
│               ├─→ DP_TradeSkillCheck
│               └─→ DP_BagsCheck
│
├─→ DP_EnchantProcess
│   ├─→ DP_EnchantWindow
│   ├─→ DP_TradeSkillCheck
│   └─→ DP_BagsCheck
│
└─→ Librerías Externas
    ├─→ AceAddon-3.0
    ├─→ AceConsole-3.0
    ├─→ AceEvent-3.0
    ├─→ AceTimer-3.0
    ├─→ AceDB-3.0
    ├─→ AceConfig-3.0
    ├─→ AceGUI-3.0
    ├─→ AceLocale-3.0
    ├─→ LibStub
    ├─→ LibDBIcon-1.0
    └─→ [Otros...]
```

### Flujo de Desencantamiento

```
Usuario abre ventana
    ↓
DP_MinimapIcon:OnClick()
    ↓
DP_DisenchantWindow:OpenDisenchantWindow()
    ↓
DP_BagsCheck:GetItemFromBag() [busca items]
    ↓
DP_DisenchantWindow:ShowItemsList() [muestra UI]
    ↓
Usuario acepta
    ↓
DP_DisenchantProcess:UnitSpellCastSent() [detecta hechizo]
    ↓
Hechizo Disenchant castea
    ↓
DP_DisenchanterPlusEvents:UnitSpellCastSucceeded()
    ↓
DP_LootProcess:LootReady() [procesa loot]
    ↓
Loot procesado, stats actualizadas
    ↓
DP_DisenchantProcess:StartAutoDisenchant() [continúa o cierra]
```

### Flujo de Encantamiento

```
Usuario abre ventana de enchant
    ↓
DP_EnchantProcess:Initialize()
    ↓
DP_TradeSkillCheck:GetTradeSkill() [verifica profesión]
    ↓
DP_EnchantWindow:OpenEnchantWindow()
    ↓
DP_BagsCheck:GetItemFromBag() [busca items]
    ↓
DP_EnchantWindow:ShowItemsList() [muestra opciones]
    ↓
Usuario selecciona enchant y confirma
    ↓
DP_EnchantProcess:EnchantItem()
    ↓
Hechizo de encantamiento castea
    ↓
Encantamiento se aplica
    ↓
Continúa con siguiente item o cierra
```

---

## 12. RECURSOS Y ASSETS

### Images/ - Recursos Gráficos

```
Images/
├── CraftTypes/     # Iconos de tipos de craft
├── Icons/          # Iconos del addon
├── Inventory/      # Iconos de inventario
├── Menus/          # Iconos de menú
├── Qualities/      # Iconos de calidades (poco común, raro, etc.)
└── Textures/       # Texturas para UI (tabs, backdrops)
```

### Sounds/ - Efectos de Sonido

```
Sounds/
├── CharacterSheetOpen.ogg   # Apertura de ventana
├── CharacterSheetClose.ogg  # Cierre de ventana
├── MoneyDialogClose.ogg     # Cierre de diálogo
├── TabChange.ogg            # Cambio de pestaña
└── ChatScrollButton.ogg     # Scroll
```

### Doc/ - Documentación

Contiene documentación interna y apuntes de desarrollo.

---

## 13. RESUMEN DE TODOS LOS MÓDULOS

| Módulo | Ubicación | Rol |
| --- | --- | --- |
| `DP_ModuleLoader` | `Modules/ModuleLoader.lua` | Sistema de carga de módulos |
| `DP_EventHandler` | `Modules/EventHandler.lua` | Registrador de eventos tempranos |
| `DP_Init` | `Modules/Init.lua` | Inicializador principal |
| `DP_SlashCommands` | `Modules/SlashCommands.lua` | Comandos de chat |
| `DP_MinimapIcon` | `Modules/MinimapIcon.lua` | Icono del minimap |
| `DP_Database` | `Modules/Database.lua` | Gestor de items de encantamiento |
| `DP_ClassicDisenchantTable` | `Modules/Database/ClassicDisenchantTable.lua` | Tabla de desencantamiento Classic |
| `DP_EnchantPatterns` | `Modules/Database/EnchantPatterns.lua` | Patrones de encantamiento |
| `DP_DisenchanterPlusEvents` | `Modules/Events/DisenchanterPlusEvents.lua` | Centralizador de eventos |
| `DP_DisenchantProcess` | `Modules/Disenchant/DisenchantProcess.lua` | Lógica de desencantamiento |
| `DP_LootProcess` | `Modules/Disenchant/LootProcess.lua` | Procesamiento de loot |
| `DP_EnchantProcess` | `Modules/Enchant/EnchantProcess.lua` | Lógica de encantamiento |
| `DP_DisenchantWindow` | `Modules/Window/DisenchantWindow.lua` | UI de desencantamiento |
| `DP_EnchantWindow` | `Modules/Window/EnchantWindow.lua` | UI de encantamiento |
| `DP_IgnoredWindow` | `Modules/Window/IgnoredWindow.lua` | UI de items ignorados |
| `DP_Settings` | `Modules/Settings/Settings.lua` | Inicializador de config |
| `DP_SettingsDefaults` | `Modules/Settings/SettingsDefaults.lua` | Valores por defecto |
| `DP_ConfigGroups` | `Modules/Settings/ConfigGroups.lua` | Generador de opciones |
| `DP_GeneralGroup` | `Modules/Settings/GeneralTab/Groups/GeneralGroup.lua` | Opciones generales |
| `DP_DisenchantGroup` | `Modules/Settings/DisenchantTab/Groups/DisenchantGroup.lua` | Opciones de desencantamiento |
| `DP_EnchantGroup` | `Modules/Settings/EnchantTab/Groups/EnchantGroup.lua` | Opciones de encantamiento |
| `DP_TooltipGroup` | `Modules/Settings/TooltipsTab/Groups/TooltipsGroup.lua` | Opciones de tooltips |
| `DP_KeybindingsGroup` | `Modules/Settings/KeybindingsTab/Groups/KeybindingsGroup.lua` | Opciones de keybindings |
| `DP_AdvancedGroup` | `Modules/Settings/AdvancedTab/Groups/AdvancedGroup.lua` | Opciones avanzadas |
| `DP_IntegrationGroup` | `Modules/Settings/AdvancedTab/Groups/IntegrationGroup.lua` | Integraciones |
| `DP_DatabaseGroup` | `Modules/Settings/MaintenanceTab/Groups/DatabaseGroup.lua` | Mantenimiento de BD |
| `DP_CustomFunctions` | `Modules/Custom/CustomFunctions.lua` | Utilidades Lua |
| `DP_CustomColors` | `Modules/Custom/CustomColors.lua` | Paleta de colores |
| `DP_CustomFrames` | `Modules/Custom/CustomFrames.lua` | Elementos UI personalizados |
| `DP_CustomSounds` | `Modules/Custom/CustomSounds.lua` | Gestor de sonidos |
| `DP_CustomMedias` | `Modules/Custom/CustomMedias.lua` | Gestor de recursos multimedia |
| `DP_CustomPopup` | `Modules/Custom/CustomPopup.lua` | Cuadros de diálogo |
| `DP_CustomConfig` | `Modules/Custom/CustomConfig.lua` | Generadores de config |
| `DP_EnchantingTooltip` | `Modules/Tooltip/EnchantingTooltip.lua` | Info en tooltips |
| `DP_TradeSkillCheck` | `Modules/Tradeskill/TradeSkillCheck.lua` | Verificación de profesiones |
| `DP_BagsCheck` | `Modules/Bags/BagsCheck.lua` | Búsqueda en bolsas |

---

## 14. CONFIGURACIÓN DE PERSISTENCIA (SavedVariables)

### Clave de Base de Datos

```
DisenchanterPlusDB
```

### Estructura de Datos Persistentes

```
DisenchanterPlusDB = {
  profileKeys = {
    [characterKey] = "Default"  -- Perfil activo por personaje
  },
  profiles = {
    Default = {                 -- Perfil por defecto
      minimap = {
        hide = false,
        minimapPos = 220        -- Posición en minimapa
      }
    }
  },
  global = {
    data = {
      items = {},              -- Items desencantados
      dusts = {},              -- Polvos obtenidos
      essences = {},           -- Esencias obtenidas
      shards = {},             -- Fragmentos obtenidos
      crystals = {},           -- Cristales obtenidos
      unknown = {}             -- Materiales desconocidos
    },
    characters = {             -- Info de personajes
      [characterKey] = {
        info = {
          realm, realmID, name, level, class, race, faction, locale
        }
      }
    }
  },
  charOptions = {
    [characterKey] = {         -- Opciones por personaje
      advanced = { debug = false },
      general = {
        -- Ver DP_SettingsDefaults para lista completa
        autoDisenchantEnabled = true,
        tooltipsEnabled = true,
        itemQuality = { ["2"] = true, ["3"] = true, ["4"] = true },
        -- ... más opciones
      }
    }
  }
}
```

---

## 15. FLUJO TÍPICO DE USO

### Sesión de Auto-Desencantamiento

1. **Usuario lanza el addon**
   - Se ejecuta inicialización (`DP_Init:Initialize()`)
   - Addon espera eventos WoW

2. **Usuario abre bolsa con items desencantables**
   - Evento `BAG_UPDATE` dispara
   - `DP_DisenchantProcess` detecta cambios

3. **Usuario activa auto-desencantamiento**
   - `/dplus config` → General → Auto-Disenchant ON
   - O shift-click minimap icon

4. **Addon busca primer item**
   - `DP_BagsCheck:GetItemFromBag()` busca en bolsas 0-4
   - Filtra por calidad, lista ignorada, soulbound
   - Devuelve primer item válido

5. **Muestra UI de desencantamiento**
   - `DP_DisenchantWindow:ShowItemsList()`
   - Muestra materiales esperados
   - Presenta botones: Accept, Cancel, Ignore

6. **Usuario confirma desencantamiento**
   - Click "Accept"
   - `DP_DisenchantProcess:UnitSpellCastSent()` detecta inicio
   - Castea hechizo Disenchant (ID 13262)

7. **Se procesa el botín**
   - `LOOT_READY` dispara cuando botín está disponible
   - `DP_LootProcess:LootReady()` procesa items
   - Actualiza estadísticas globales
   - Loop: regresa a paso 4

8. **Sessión cierra**
   - Usuario presiona escape o cierra ventana
   - `DP_DisenchantProcess:StartAutoDisenchant(true)` continúa en background

---

## 16. PUNTOS DE EXTENSIÓN

El addon fue diseñado para ser extensible:

### Añadir Nuevo Idioma

1. Crear `Locale/localization.XX.lua`
2. Copiar estructura de `localization.en.lua`
3. Traducir strings
4. Registrar con AceLocale-3.0

### Añadir Nuevo Tab de Configuración

1. Crear `Modules/Settings/MiTab/MiTab.lua`
2. Crear `Modules/Settings/MiTab/Groups/MiTabGroup.lua`
3. Registrar en `DP_Settings._CreateSettingsTable()`

### Integración con Otros Addons

1. Usar `DP_IntegrationGroup` para opciones
2. Importar módulo del otro addon
3. Registrar callbacks según sea necesario

### Añadir Nuevos Tipos de Items

1. Extender tablas de desencantamiento:
   - `DP_ClassicDisenchantTable`
2. Actualizar `DP_Database:GetEnchantingItemType()`

---

## CONCLUSIÓN

DisenchanterPlus es un addon bien estructurado que utiliza el framework Ace3 de manera experta. Su arquitectura modular permite fácil mantenimiento y extensión. El sistema de módulos personalizado proporciona un patrón limpio de dependencias, y la separación de responsabilidades es clara entre UI, lógica de negocio, y utilidades. El addon está completamente localizado y optimizado para múltiples versiones de WoW.
