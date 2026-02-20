# druid Architecture

Фреймворк состоит из **4 слоёв**, которые работают в цепочке:

```
Signal (реактивность)
  → Widget (компоновка)
  → VNode (виртуальный DOM)
  → DOM (реальный браузер)
```

---

## Слой 1: Реактивность — `lib/src/core/signal.dart`

**Signal → Computed → Effect**

- `Signal<T>` — хранит состояние, уведомляет подписчиков при изменении
- `Computed<T>` — вычисляемое значение с кешированием; пересчитывается только когда зависимость изменилась
- `Effect` — запускает сайд-эффект при изменении зависимостей (через `scheduleMicrotask` — батчинг)

**Ключевой механизм**: `_trackingStack` — глобальный стек. Когда `Effect` или `Computed` читает `.value` сигнала, сигнал автоматически регистрирует их как подписчиков. Граф зависимостей строится **автоматически** во время выполнения.

```dart
final count = signal(0);
final doubled = computed(() => count.value * 2);
final e = effect(() => print('Count: ${count.value}'));

count.value = 5; // doubled и effect обновятся через microtask
```

---

## Слой 2: Virtual DOM

### `lib/src/vdom/vnode.dart`

Sealed иерархия:
- `VElement` — HTML-элемент: тег + Map пропсов + список детей
- `VText` — текстовый узел

Пропсы `VElement` могут быть:
- `String` — HTML-атрибуты
- `EventHandler` (`void Function(Object)`) — обработчики событий
- `Map<String, String>` — inline-стили
- `bool` — булевые атрибуты

### `lib/src/vdom/differ.dart`

O(n) алгоритм сравнения двух VNode-деревьев → список `Patch`-ей:

| Ситуация | Патч |
|----------|------|
| Разные типы узлов | `PatchReplace` |
| Текст изменился | `PatchText` |
| Разные теги | `PatchReplace` |
| Одинаковый тег | `PatchSetProp` / `PatchRemoveProp` + рекурсия по детям |
| Новый ребёнок | `PatchInsertChild` |
| Удалённый ребёнок | `PatchRemoveChild` |
| Перемещение (keyed) | `PatchMoveChild` |

Дети с `key` сопоставляются по ключу, без `key` — по позиции.

### `lib/src/vdom/patcher.dart`

Применяет `Patch`-и к реальному DOM через `package:web`:

- `mount(vnode)` — создаёт DOM-поддерево из VNode
- `applyPatches(node, patches)` — минимально мутирует DOM
- Обработчики событий кешируются через `Expando` — не накапливаются

---

## Слой 3: Виджеты — `lib/src/widgets/`

### `widget.dart`

- `Widget` — базовый класс, метод `toVNode(BuildContext)`
- `StatelessWidget` — переопределяет `build()`, без состояния
- `StatefulWidget` + `State` — полный lifecycle:
  - `initState()` — вызывается один раз при создании (здесь инициализировать сигналы)
  - `build()` — описывает UI
  - `dispose()` — очистка ресурсов

### `html.dart`

Типизированные обёртки над HTML-элементами:

| Категория | Виджеты |
|-----------|---------|
| Контейнеры | `Div`, `Span`, `Section`, `Article`, `Header`, `Footer`, `Main`, `Nav` |
| Заголовки | `H1`, `H2`, `H3`, `H4` |
| Текст | `P`, `Strong`, `Em`, `Small`, `Code`, `Pre`, `Hr`, `Br` |
| Интерактив | `Button`, `Input`, `Textarea`, `Select`, `Option` |
| Форма | `Form`, `Label` |
| Списки | `Ul`, `Ol`, `Li` |
| Медиа | `A`, `Img` |
| Таблицы | `Table`, `Thead`, `Tbody`, `Tr`, `Th`, `Td` |

---

## Слой 4: App runner — `lib/src/app.dart`

`runApp(Widget root)` создаёт `Effect`, который оборачивает `_render()`.
Effect читает сигналы во время билда — при их изменении перерисовка происходит автоматически.

**Жизненный цикл StatefulWidget в `_AppRunner`:**
- Первый рендер: `createState()` → `initState()` → `build()`
- Последующие рендеры: переиспользует State → `build()`
- Удаление: `dispose()`

---

## Цикл обновления UI

### Шаг 1 — Первый рендер: автоматическая подписка на сигналы

`runApp()` создаёт один `Effect`, оборачивающий `_render()`. Effect сразу выполняется синхронно и добавляет себя в `_trackingStack`. Любой сигнал, чьё `.value` читается во время рендера, видит это и регистрирует зависимость:

```dart
// signal.dart
T get value {
  if (_trackingStack.isNotEmpty) {
    _trackingStack.last._track(this); // ← автоматическая подписка
  }
  return _value;
}
```

После первого рендера `_renderEffect` знает обо всех сигналах, которые участвовали в построении дерева.

### Шаг 2 — Изменение сигнала

```dart
count.value = 1;
```

Signal оповещает всех подписчиков. `Effect._run()` **не запускает рендер немедленно** — он ставит себя в очередь:

```dart
// signal.dart
void _run() {
  _pendingEffects.add(this);
  _scheduleFlush(); // scheduleMicrotask(_flush)
}
```

Батчинг: если за один синхронный тик изменить несколько сигналов — рендер произойдёт один раз.

### Шаг 3 — Microtask: переподписка и новый VNode

```dart
// signal.dart
void _flush() {
  final batch = List<Effect>.from(_pendingEffects);
  _pendingEffects.clear();
  for (final e in batch) {
    e._execute(); // → _render()
  }
}
```

`_execute()` сначала сбрасывает все старые зависимости (`_clearUpstreams`), затем заново запускает `_render()` — тем самым **переподписывается** на актуальный набор сигналов. Это важно: если условный рендер (`if/else`) поменял набор читаемых сигналов, граф зависимостей обновится корректно.

### Шаг 4 — Diff + Patch DOM

```dart
// app.dart
final patches = diff(_currentVNode, newVNode);
if (patches.isNotEmpty) {
  _currentDom = patcher.applyPatches(_currentDom!, patches, newVNode);
}
```

`diff()` сравнивает старое и новое VNode-дерево за O(n) и возвращает минимальный список патчей. `applyPatches` применяет только реально изменившиеся узлы.

### Полная схема

```
State.initState()
  count = signal(0) ──────────────────────────────────┐
                                                       │
runApp()                                               │
  └─ effect(_render)  ← синхронный первый запуск       │
       └─ _buildWidget(root)                           │
            └─ state.build(ctx)                        │
                 └─ читает count.value ────────────────┘──► регистрирует зависимость
                                                       │
                                               count.value = 1
                                                       │
                                         Signal уведомляет Effect
                                                       │
                                           scheduleMicrotask
                                                       │
                                        _flush() → _render()
                                                       │
                                    diff(oldVNode, newVNode) → Patches
                                                       │
                                       applyPatches() → DOM
```

### Ключевые свойства механизма

| Свойство | Реализация |
|---|---|
| Автоматическая подписка | `_trackingStack` при чтении `.value` |
| Батчинг изменений | `scheduleMicrotask` — один рендер на тик |
| Минимальные обновления DOM | `diff` возвращает только изменения |
| Динамическая переподписка | `_clearUpstreams()` перед каждым рендером |

---

## Итоговый поток данных

```
[Изменение состояния]
  count.value++
    ↓
  Signal уведомляет подписчиков
    ↓
  Effect помечается как грязный
    ↓
  scheduleMicrotask → _render()
    ↓
  build() → Widget tree → VNode tree (новый)
    ↓
  diff(старый VNode, новый VNode) → Patches
    ↓
  applyPatches() → минимальные DOM-мутации
```

### Пример: Counter (`web/main.dart`)

```dart
class _CounterState extends State<Counter> {
  late final count = signal(0);   // Signal layer

  @override
  Widget build(BuildContext context) {
    return Div(children: [
      H1(child: Text('Count: ${count.value}')),   // читает signal → зависимость
      Button(
        onClick: (_) => count.value++,            // мутирует signal → триггер
        child: Text('+'),
      ),
    ]);
  }
}
```

При клике:
1. `count.value++` → Signal уведомляет Effect
2. `microtask` → `_render()`
3. `diff` находит изменение в тексте H1
4. `PatchText("Count: 1")` → `textContent = "Count: 1"`

Только один текстовый узел обновляется в DOM.

---

## Ключевые паттерны

| Паттерн | Зачем | Где |
|---------|-------|-----|
| Fine-grained reactivity | Перерисовывать только изменившееся | `_trackingStack` в signal.dart |
| Virtual DOM diffing | Минимум DOM-мутаций | differ.dart |
| Lazy evaluation | Нет лишних вычислений | Computed кеширует до `_dirty` |
| Effect batching | Коалесценция изменений | `scheduleMicrotask` |
| Event handler caching | Нет утечек памяти | `Expando` в patcher.dart |
| Keyed reconciliation | Сохранение идентичности в списках | differ.dart keyed children |
| Immutable widgets | Предсказуемость | const конструкторы |
| State persistence | State живёт между рендерами | `_stateByType` в app.dart |
