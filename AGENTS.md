
# Code Review System — Instrucciones para el Agente

Este archivo define el sistema de code review que DEBE seguir el agente en cada sesión. Léelo completo al inicio de cada interacción.

---

## 1. Propósito

Mantener la calidad del código mediante revisiones periódicas, documentadas y trazables. Cada review genera un reporte en `docs/code-reviews/` con los hallazgos, correcciones y pendientes.

---

## 2. Workflow al Iniciar Sesión

1. **Leer este archivo** (`AGENTS.md`)
2. **Leer el índice de reviews** (`docs/CODE-REVIEW.md`)
3. **Identificar el último review**: buscar el archivo más reciente en `docs/code-reviews/cr-*.md`
4. **Verificar tiempo transcurrido** desde la fecha del último review:
   - Si han pasado **>= 2 días** → SUGERIR al usuario hacer un nuevo code review completo con el siguiente mensaje:
     > "Han pasado N días desde el último code review. ¿Quieres que ejecute un code review completo del proyecto?"
   - Si **no han pasado 2 días** → continuar normalmente
5. **Ejecutar un code review solo si el usuario lo autoriza**

---

## 3. Checklist de Code Review

Cada review debe cubrir estos puntos (ordenados por prioridad):

### 3.1 Bugs Críticos
- [ ] Inconsistencias de tipos entre capas (API model → controller → widget)
- [ ] Memory leaks: `TextEditingController`, `AnimationController`, `StreamSubscription` sin dispose
- [ ] Null safety: acceso a campos sin `?.` o null-checks
- [ ] Mutación in-place de listas reactivas (RxList)
- [ ] llamadas a APIs sin try-catch

### 3.2 Arquitectura
- [ ] Controllers con demasiadas responsabilidades (facade excesivo)
- [ ] Lógica de negocio en widgets (debería estar en controller)
- [ ] Dependencias circulares entre controllers
- [ ] Falta de paginación en cargas grandes
- [ ] Estado reactivo mal sincronizado (debouncers vs estado inmediato)

### 3.3 Filtros y Búsqueda (específico del proyecto)
- [ ] Campos del modelo no expuestos como filtros (`isAvailable`, `isFeatured`, `discountPrice`)
- [ ] Normalización de texto para búsqueda (ñ, tildes)
- [ ] Selección múltiple vs única de categorías
- [ ] Debouncer correctamente sincronizado

### 3.4 Performance
- [ ] Rebuilds innecesarios (GetX: usar `GetBuilder` o `Obx` correctamente)
- [ ] Operaciones pesadas en el build (`.map()`, `.where()`, `.toList()`)
- [ ] `const` constructores donde sea posible
- [ ] `withOpacity` → `withValues(alpha:)` (deprecation)

### 3.5 Análisis Estático
- [ ] Ejecutar `fvm flutter analyze` y reportar errores encontrados
- [ ] Imports no utilizados
- [ ] Variables/métodos no utilizados

### 3.6 Código Muerto y Deuda Técnica
- [ ] Comentarios de código legacy
- [ ] TODOs sin resolver
- [ ] Código duplicado
- [ ] Dependencias desactualizadas (`pubspec.yaml`)

### 3.7 Atomic Design y pu_material
- [ ] Widgets nuevos/ modificados deben estar en `pu_material/lib/`, no en `lib/`
- [ ] Ubicación correcta según nivel: `atoms/`, `molecule/`, `organisms/`, o `features/<feature>/ui/`
- [ ] Nomenclatura de archivo: `snake_case` con sufijo de nivel (`_atom`, `_molecule`, `_organism`)
- [ ] Nomenclatura de clase: `PascalCase` — `NombreAtom`, `NombreMolecule`, `NombreOrganism`
- [ ] Los **átomos** son puramente presentacionales: sin lógica de negocio, agnósticos del dominio
- [ ] Las **moléculas** solo combinan átomos; no definen lógica de dominio
- [ ] Los **organismos** pueden tener lógica de dominio y son responsive (`LayoutBuilder`, breakpoints mobile/tablet/desktop)
- [ ] **Features** siguen la estructura: `models/` → `ui/atoms/` → `ui/molecules/` → `ui/organisms/` → `ui/templates/` → `ui/pages/`
- [ ] Barrel exports solo desde `pu_material.dart`; no crear barrel files por subdirectorio
- [ ] Usar `PUColors`, `PUTokens`, `PuTextStyle` en lugar de `Theme.of(context)`
- [ ] Imágenes: usar `PuRobustNetworkImage` con parámetros de optimización (`q_auto,f_auto,w_800`), no `Image.network` directamente
- [ ] Constructores `const` con `super.key` y parámetros `required` para datos obligatorios
- [ ] Sin dependencia directa a GetX desde `pu_material` (es agnóstico del gestor de estado)

---

## 4. Formato de Reportes

### Nombre del archivo
```
docs/code-reviews/cr-YYYY-MM-DD-estado.md
```

### Estados
| Estado | Cuándo usarlo |
|---|---|
| `pendiente` | El usuario pidió agendar un review |
| `en-progreso` | Comenzaste a revisar pero no terminaste |
| `completado` | Review terminado con todos los issues documentados |
| `parcial` | Solo se revisó un área específica (ej: solo widgets, solo filtros) |

### Plantilla del reporte

```markdown
# Code Review — YYYY-MM-DD

**Estado:** completado | en-progreso | parcial | pendiente
**Revisor:** opencode-agent
**Duración:** aprox. X min

---

## Resumen

Breve descripción del estado general del proyecto en esta fecha.

---

## Issues Encontrados

### CRIT-XXX: Título del issue crítico
- **Archivo:** `ruta/al/archivo.dart:linea`
- **Problema:** descripción
- **Impacto:** alto | medio | bajo
- **Solución propuesta:** cómo arreglarlo

### ARCH-XXX: Título arquitectura
...

### PERF-XXX: Título performance
...

### STYLE-XXX: Título estilo
...

---

## Issues Resueltos (desde último review)

| ID | Archivo | Solución |
|---|---|---|

---

## Pendientes para Próximo Review

- [ ] Item 1
- [ ] Item 2

---

## Checklist de Verificación

- [ ] `fvm flutter analyze` ejecutado sin errores
- [ ] Bugs críticos documentados
- [ ] Issues de arquitectura identificados
- [ ] Performance evaluada
- [ ] Código muerto y deuda técnica registrada
- [ ] Atomic Design y cumplimiento de pu_material verificado
```

---

## 5. Post-Review

Después de cada code review:

1. **Actualizar [`docs/CODE-REVIEW.md`](./docs/CODE-REVIEW.md)** — agregar el nuevo reporte a la tabla
2. **Actualizar [`docs/PROGRESS-TRACKER.md`](./docs/PROGRESS-TRACKER.md)** — mover tareas resueltas a completado
3. **Si se encontraron bugs críticos** → priorizar su corrección antes de continuar con otras tareas
4. **Reportar al usuario** los hallazgos principales

---

## 6. Referencias

- [`CUSTOM_RULES.md`](./CUSTOM_RULES.md) — `fvm flutter analyze` obligatorio después de cada cambio
- [`pu_material/lib/`](./pu_material/lib/) — Librería de UI con Atomic Design (atoms, molecules, organisms, features)
- [`docs/PROGRESS-TRACKER.md`](./docs/PROGRESS-TRACKER.md) — Seguimiento de fases y tareas
- [`docs/CODE-REVIEW.md`](./docs/CODE-REVIEW.md) — Índice de todos los code reviews
- [`docs/FILTER-IMPROVEMENT-PLAN.md`](./docs/FILTER-IMPROVEMENT-PLAN.md) — Plan específico de filtros
- [`docs/code-reviews/`](./docs/code-reviews/) — Reportes históricos de code review

---

> **Importante:** Este sistema es parte del proyecto Menucom Catalog. Los code reviews deben ser breves pero completos, priorizando bugs críticos y problemas de arquitectura sobre estilo menor.
