
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

## Documentos relacionados

- [`AGENTS.md`](../AGENTS.md) — Instrucciones para el agente: workflow de code review
- [`PROGRESS-TRACKER.md`](./PROGRESS-TRACKER.md) — Seguimiento de fases y tareas
- [`FILTER-IMPROVEMENT-PLAN.md`](./FILTER-IMPROVEMENT-PLAN.md) — Plan de mejoras de filtros
- [`CUSTOM_RULES.md`](../CUSTOM_RULES.md) — Reglas del proyecto (flutter analyze obligatorio)
