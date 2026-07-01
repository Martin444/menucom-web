
# Code Review System — Menucom Catalog

Este archivo es el índice del sistema de code reviews. Cada reporte detallado se encuentra en [`docs/code-reviews/`](./code-reviews/).

## Estructura

```
docs/code-reviews/
  cr-YYYY-MM-DD-estado.md
```

### Estados
| Estado | Significado |
|---|---|
| `pendiente` | Review solicitado pero no ejecutado |
| `en-progreso` | Review en curso |
| `completado` | Review finalizado, issues documentados |
| `parcial` | Review parcial (solo ciertas áreas) |

## Reportes

| Fecha | Archivo | Estado |
|---|---|---|---|
| 2026-05-27 | [`cr-2026-05-27-completado.md`](./code-reviews/cr-2026-05-27-completado.md) | 🟢 Completado |
| 2026-05-27 | [`cr-2026-05-27-fase2-completado.md`](./code-reviews/cr-2026-05-27-fase2-completado.md) | 🟢 Completado — Fase 2 implementada |
| 2026-05-29 | [`cr-2026-05-29-pwa-install-button.md`](./code-reviews/cr-2026-05-29-pwa-install-button.md) | 🟢 Completado — PWA Install Button |
| 2026-06-30 | [`cr-2026-06-30-completado.md`](./code-reviews/cr-2026-06-30-completado.md) | 🟢 Completado — Post-analytics + revisión completa |

## Documentos relacionados

### Sistema de Code Review
- [`AGENTS.md`](../AGENTS.md) — Instrucciones para el agente: workflow de code review
- [`PROGRESS-TRACKER.md`](./PROGRESS-TRACKER.md) — Seguimiento de fases y tareas
- [`CUSTOM_RULES.md`](../CUSTOM_RULES.md) — Reglas del proyecto (flutter analyze obligatorio)

### Funcionalidades del Proyecto
- [`PWA-INSTALL-BUTTON.md`](./PWA-INSTALL-BUTTON.md) — Botón de instalación PWA y manifest dinámico
- [`ANONYMOUS_ID_SYSTEM.md`](./ANONYMOUS_ID_SYSTEM.md) — Sistema de identificación anónima persistente
- [`MIGRATION_GUIDE.md`](./MIGRATION_GUIDE.md) — Guía de migración del sistema Anonymous ID
- [`EVENT-SALES-FLOW.md`](./EVENT-SALES-FLOW.md) — Flujo de ventas de eventos

### Arquitectura y Planes
- [`REFACTORING_GUIDE.md`](./REFACTORING_GUIDE.md) — Guía de refactorización a Clean Architecture
- [`FILTER-IMPROVEMENT-PLAN.md`](./FILTER-IMPROVEMENT-PLAN.md) — Plan de mejoras de filtros
