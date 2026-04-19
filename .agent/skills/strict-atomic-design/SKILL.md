---
name: strict-atomic-design
description: Absolute strict Atomic Design architecture for Flutter widgets. Triggers: "refactoriza un diseño", "diseño un widget", "actualiza un widget", "crear componente", "atomic design".
---

# Strict Atomic Design Widget Rule (Strict Enforcement)

This skill ensures that EVERY widget created or modified follows the Atomic Design hierarchy (Page -> Template -> Organism -> Molecule -> Atom).

## 🚀 Activation Triggers
Activate this skill whenever the user requests:
- **Refactorizar un diseño** (Refactoring UI/Layout)
- **Diseñar un widget** (Designing new components)
- **Actualizar un widget** (Modifying existing UI)
- **Crear componente** (Component creation)
- **Atomic Design** (Architecture changes)

## 🏛️ The Hierarchy levels

### 1. Atoms (Basic UI)
- **Definition**: The smallest possible component. Cannot be broken down further.
- **Rules**:
  - NO logic.
  - Custom UI properties only.
  - Usually wraps a Flutter primitive (Text, Icon, Container).
  - Examples: `AtomText`, `AtomIcon`, `AtomButton`, `PriceTag`.
- **Location**: `pu_material/lib/atoms/` or `lib/features/<feature>/ui/atoms/`.

### 2. Molecules (Component Combinations)
- **Definition**: Groups of atoms bonded together to form a functional unit.
- **Rules**:
  - Should have a specific, simple purpose.
  - Can have simple internal UI state (e.g., hover effect).
  - Usually does NOT interact with Business Logic directly (Inputs pass callbacks).
  - Examples: `OrderItemCard`, `SearchField`, `InfoTile`.
- **Location**: `pu_material/lib/molecule/` or `lib/features/<feature>/ui/molecules/`.

### 3. Organisms (Contextual Components)
- **Definition**: Distinct sections of an interface that combine molecules and atoms.
- **Rules**:
  - Can receive specific Models/Entities as parameters.
  - Handles the arrangement of its children.
  - Can be reused across different templates.
  - Examples: `ProductCard`, `OrderSummaryTable`, `CategorySection`.
- **Location**: `pu_material/lib/organisms/` or `lib/features/<feature>/ui/organisms/`.

### 4. Templates (Layout Layouts)
- **Definition**: Page-level components that provide context for functional organisms.
- **Rules**:
  - Defines the "where" (slots/children).
  - NO real data, mostly placeholders or `List<Widget>`.
  - Focuses on responsiveness and overall page layout.
  - Examples: `DashboardTemplate`, `ListDetailTemplate`.
- **Location**: `lib/features/<feature>/ui/templates/`.

### 5. Pages (Stateful Views)
- **Definition**: Specific instances of templates that hook into backend data/state.
- **Rules**:
  - Connects to Controllers/Blocs/Providers.
  - Passes real data and event handlers to templates.
  - One Page per route.
  - Examples: `HomePage`, `OrderDetailPage`.
- **Location**: `lib/features/<feature>/presentation/pages/`.

---

## 🎨 Design Rules (Integration with ui-ux-pro-max)

When creating widgets at any level, you MUST:
1. **Never use generic colors**: Always use `PuColors` or tokens from `PuDesignTokens`.
2. **Typography**: Use `PuStyleFonts` exclusively. No hardcoded `TextStyle`.
3. **Spacing**: Follow the 8pt grid system using `PuDesignTokens` (Gap, Padding).
4. **Visual Excellence**:
   - Add hover states to all clickable molecules/organisms.
   - Use glassmorphism where applicable for premium feel.
   - Smooth transitions (200-300ms) for state changes.

## 📂 File Header Requirement

Every widget file must specify its level in a comment at the top:
```dart
// Level: <Level_Name>
// Description: <Short_Description>
```

---

## 🔌 pu_material.dart Export Standard

The `pu_material.dart` file acts as the library index and MUST group exports by level:
1. Tokens/Utils
2. Atoms
3. Molecules
4. Organisms
5. Feature-specific (if shared)
