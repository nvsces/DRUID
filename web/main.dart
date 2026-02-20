import 'package:druid/druid.dart';

// ---------------------------------------------------------------------------
// Design tokens
// ---------------------------------------------------------------------------

const _bg = '#0f172a';
const _surface = '#1e293b';
const _border = '#334155';
const _text = '#e2e8f0';
const _muted = '#94a3b8';
const _accent = '#7c3aed';
const _accent2 = '#a78bfa';
const _green = '#22c55e';
const _red = '#ef4444';

// ---------------------------------------------------------------------------
// Counter Bloc (state management example)
// ---------------------------------------------------------------------------

sealed class CounterEvent {}

class Increment extends CounterEvent {}

class Decrement extends CounterEvent {}

class Reset extends CounterEvent {}

class CounterState {
  final int count;
  const CounterState(this.count);
}

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterState(0)) {
    on<Increment>((e, emit) => emit(CounterState(state.count + 1)));
    on<Decrement>((e, emit) => emit(CounterState(state.count - 1)));
    on<Reset>((e, emit) => emit(const CounterState(0)));
  }
}

// ---------------------------------------------------------------------------
// Todo Bloc (state management example)
// ---------------------------------------------------------------------------

class TodoItem {
  final String id;
  final String text;
  final bool done;
  const TodoItem({required this.id, required this.text, this.done = false});
  TodoItem copyWith({bool? done}) => TodoItem(id: id, text: text, done: done ?? this.done);
}

sealed class TodoEvent {}

class AddTodo extends TodoEvent {
  final String text;
  AddTodo(this.text);
}

class ToggleTodo extends TodoEvent {
  final String id;
  ToggleTodo(this.id);
}

class RemoveTodo extends TodoEvent {
  final String id;
  RemoveTodo(this.id);
}

class TodoState {
  final List<TodoItem> items;
  const TodoState(this.items);
}

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  int _nextId = 0;

  TodoBloc() : super(const TodoState([])) {
    on<AddTodo>((e, emit) {
      final item = TodoItem(id: '${_nextId++}', text: e.text);
      emit(TodoState([...state.items, item]));
    });
    on<ToggleTodo>((e, emit) {
      final items = state.items.map((t) {
        return t.id == e.id ? t.copyWith(done: !t.done) : t;
      }).toList();
      emit(TodoState(items));
    });
    on<RemoveTodo>((e, emit) {
      emit(TodoState(state.items.where((t) => t.id != e.id).toList()));
    });
  }
}

// ---------------------------------------------------------------------------
// Shared UI helpers
// ---------------------------------------------------------------------------

Widget _pageContainer({required String title, required List<Widget> children}) =>
    Div(
      style: {
        'max-width': '720px',
        'margin': '0 auto',
        'padding': '2rem',
      },
      children: [
        H1(
          style: {
            'font-size': '2rem',
            'font-weight': '700',
            'color': _text,
            'margin-bottom': '1.5rem',
          },
          child: Text(title),
        ),
        ...children,
      ],
    );

Widget _card({required List<Widget> children}) => Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Color(0xFF1e293b),
        border: Border(color: Color(0xFF334155)),
        borderRadius: BorderRadius.circular(12),
      ),
      children: children,
    );

Widget _pill(String label) => Span(
      style: {
        'display': 'inline-block',
        'background': _accent,
        'color': '#fff',
        'padding': '0.2rem 0.75rem',
        'border-radius': '100px',
        'font-size': '0.8rem',
        'font-weight': '600',
      },
      child: Text(label),
    );

// ---------------------------------------------------------------------------
// Pages
// ---------------------------------------------------------------------------

class HomePage extends StatelessWidget {
  const HomePage();

  @override
  Widget build(BuildContext context) {
    return _pageContainer(
      title: 'druid — Navigation Demo',
      children: [
        P(
          style: {'color': _muted, 'margin-bottom': '2rem', 'line-height': '1.7'},
          child: Text(
            'This example demonstrates declarative URL-based routing '
            'and reactive state management (Bloc + Signals) working together.',
          ),
        ),
        Div(
          style: {
            'display': 'grid',
            'grid-template-columns': '1fr 1fr',
            'gap': '1rem',
          },
          children: [
            _homeCard(
              context,
              to: '/counter',
              emoji: '#',
              title: 'Counter',
              desc: 'Bloc state management with increment/decrement.',
            ),
            _homeCard(
              context,
              to: '/todos',
              emoji: '!',
              title: 'Todo List',
              desc: 'CRUD operations with reactive list updates.',
            ),
          ],
        ),
      ],
    );
  }

  Widget _homeCard(
    BuildContext context, {
    required String to,
    required String emoji,
    required String title,
    required String desc,
  }) {
    final router = RouterProvider.of(context);
    return GestureDetector(
      onTap: (_) => router.go(to),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Color(0xFF1e293b),
          border: Border(color: Color(0xFF334155)),
          borderRadius: BorderRadius.circular(12),
        ),
        style: {'cursor': 'pointer', 'transition': 'border-color 0.2s'},
        children: [
          Div(
            style: {
              'font-size': '2rem',
              'margin-bottom': '0.75rem',
              'width': '48px',
              'height': '48px',
              'display': 'flex',
              'align-items': 'center',
              'justify-content': 'center',
              'background': _accent,
              'border-radius': '10px',
              'color': '#fff',
              'font-weight': '800',
            },
            children: [Text(emoji)],
          ),
          H3(
            style: {'color': _text, 'margin-bottom': '0.5rem'},
            child: Text(title),
          ),
          P(
            style: {'color': _muted, 'font-size': '0.9rem'},
            child: Text(desc),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Counter page
// ---------------------------------------------------------------------------

class CounterPage extends StatelessWidget {
  const CounterPage();

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<CounterBloc>(context);
    return _pageContainer(
      title: 'Counter',
      children: [
        _card(
          children: [
            BlocBuilder<CounterBloc, CounterState>(
              bloc: bloc,
              builder: (ctx, state) {
                return Div(
                  style: {
                    'display': 'flex',
                    'flex-direction': 'column',
                    'align-items': 'center',
                    'gap': '1.5rem',
                  },
                  children: [
                    // Count display
                    Div(
                      style: {
                        'font-size': '5rem',
                        'font-weight': '800',
                        'color': state.count >= 0 ? _accent2 : _red,
                        'font-variant-numeric': 'tabular-nums',
                        'transition': 'color 0.2s',
                      },
                      children: [Text('${state.count}')],
                    ),
                    // Buttons
                    Div(
                      style: {
                        'display': 'flex',
                        'gap': '0.75rem',
                      },
                      children: [
                        _counterBtn('-', () => bloc.add(Decrement())),
                        _counterBtn('Reset', () => bloc.add(Reset()),
                            secondary: true),
                        _counterBtn('+', () => bloc.add(Increment())),
                      ],
                    ),
                    // Status text
                    P(
                      style: {'color': _muted, 'font-size': '0.85rem'},
                      child: Text(
                        state.count == 0
                            ? 'Press + or - to change the count'
                            : state.count > 0
                                ? 'Positive: ${state.count}'
                                : 'Negative: ${state.count}',
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _counterBtn(String label, void Function() onTap,
      {bool secondary = false}) {
    return Button(
      onClick: (_) => onTap(),
      style: {
        'padding': '0.6rem 1.5rem',
        'font-size': '1.1rem',
        'font-weight': '700',
        'border': secondary ? '1px solid $_border' : 'none',
        'background': secondary ? 'transparent' : _accent,
        'color': secondary ? _muted : '#fff',
        'border-radius': '10px',
        'cursor': 'pointer',
        'min-width': '60px',
      },
      child: Text(label),
    );
  }
}

// ---------------------------------------------------------------------------
// Todo page
// ---------------------------------------------------------------------------

class TodoPage extends StatefulWidget {
  const TodoPage();

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  late final _inputValue = signal('');

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<TodoBloc>(context);
    return _pageContainer(
      title: 'Todo List',
      children: [
        // Input form
        _card(
          children: [
            Form(
              onSubmit: (event) {
                (event as dynamic).preventDefault();
                final text = _inputValue.value.trim();
                if (text.isNotEmpty) {
                  bloc.add(AddTodo(text));
                  _inputValue.value = '';
                }
              },
              children: [
                Div(
                  style: {'display': 'flex', 'gap': '0.75rem'},
                  children: [
                    Input(
                      type: 'text',
                      placeholder: 'Add a task...',
                      value: _inputValue.value,
                      onInput: (e) {
                        _inputValue.value =
                            ((e as dynamic).target.value as String?) ?? '';
                      },
                      style: {
                        'flex': '1',
                        'padding': '0.7rem 1rem',
                        'background': _bg,
                        'color': _text,
                        'border': '1px solid $_border',
                        'border-radius': '8px',
                        'font-size': '0.95rem',
                        'outline': 'none',
                      },
                    ),
                    Button(
                      type: 'submit',
                      style: {
                        'padding': '0.7rem 1.25rem',
                        'background': _accent,
                        'color': '#fff',
                        'border': 'none',
                        'border-radius': '8px',
                        'font-weight': '600',
                        'cursor': 'pointer',
                        'font-size': '0.95rem',
                      },
                      child: Text('Add'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        // Todo list
        Div(
          style: {'margin-top': '1rem'},
          children: [
            BlocBuilder<TodoBloc, TodoState>(
              bloc: bloc,
              builder: (ctx, state) {
                if (state.items.isEmpty) {
                  return Div(
                    style: {
                      'text-align': 'center',
                      'padding': '3rem 1rem',
                      'color': _muted,
                    },
                    children: [
                      P(
                        style: {'font-size': '1.5rem', 'margin-bottom': '0.5rem'},
                        child: Text('~'),
                      ),
                      P(child: Text('No tasks yet. Add one above!')),
                    ],
                  );
                }

                final done = state.items.where((t) => t.done).length;
                return Div(children: [
                  // Stats bar
                  Div(
                    style: {
                      'display': 'flex',
                      'justify-content': 'space-between',
                      'align-items': 'center',
                      'margin-bottom': '0.75rem',
                      'padding': '0 0.25rem',
                    },
                    children: [
                      Span(
                        style: {'color': _muted, 'font-size': '0.85rem'},
                        child: Text('${state.items.length} tasks'),
                      ),
                      _pill('$done done'),
                    ],
                  ),
                  // Items
                  ...state.items.map((item) => _todoItem(bloc, item)),
                ]);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _todoItem(TodoBloc bloc, TodoItem item) => Div(
        key: item.id,
        style: {
          'display': 'flex',
          'align-items': 'center',
          'gap': '0.75rem',
          'padding': '0.85rem 1rem',
          'background': _surface,
          'border': '1px solid $_border',
          'border-radius': '10px',
          'margin-bottom': '0.5rem',
          'transition': 'opacity 0.2s',
          if (item.done) 'opacity': '0.55',
        },
        children: [
          // Checkbox
          GestureDetector(
            onTap: (_) => bloc.add(ToggleTodo(item.id)),
            child: Div(
              style: {
                'width': '22px',
                'height': '22px',
                'border-radius': '6px',
                'border': item.done
                    ? '2px solid $_green'
                    : '2px solid $_border',
                'background': item.done ? _green : 'transparent',
                'display': 'flex',
                'align-items': 'center',
                'justify-content': 'center',
                'cursor': 'pointer',
                'flex-shrink': '0',
                'color': '#fff',
                'font-size': '0.75rem',
                'font-weight': '700',
              },
              children: [if (item.done) Text('v')],
            ),
          ),
          // Text
          Span(
            style: {
              'flex': '1',
              'color': item.done ? _muted : _text,
              'font-size': '0.95rem',
              if (item.done) 'text-decoration': 'line-through',
            },
            child: Text(item.text),
          ),
          // Delete button
          GestureDetector(
            onTap: (_) => bloc.add(RemoveTodo(item.id)),
            child: Span(
              style: {
                'color': _muted,
                'cursor': 'pointer',
                'font-size': '1.1rem',
                'padding': '0 0.25rem',
              },
              child: Text('x'),
            ),
          ),
        ],
      );
}

// ---------------------------------------------------------------------------
// Todo detail page (demonstrates route params)
// ---------------------------------------------------------------------------

class TodoDetailPage extends StatelessWidget {
  final String id;
  const TodoDetailPage({required this.id});

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<TodoBloc>(context);
    return _pageContainer(
      title: 'Todo Detail',
      children: [
        BlocBuilder<TodoBloc, TodoState>(
          bloc: bloc,
          builder: (ctx, state) {
            final item = state.items.cast<TodoItem?>().firstWhere(
                  (t) => t?.id == id,
                  orElse: () => null,
                );
            if (item == null) {
              return _card(children: [
                P(style: {'color': _muted}, child: Text('Task #$id not found.')),
              ]);
            }
            return _card(
              children: [
                Div(
                  style: {'display': 'flex', 'align-items': 'center', 'gap': '1rem'},
                  children: [
                    _pill(item.done ? 'Done' : 'Pending'),
                    H2(
                      style: {
                        'color': _text,
                        'font-size': '1.3rem',
                        if (item.done) 'text-decoration': 'line-through',
                      },
                      child: Text(item.text),
                    ),
                  ],
                ),
                Div(
                  style: {'margin-top': '1.5rem', 'display': 'flex', 'gap': '0.75rem'},
                  children: [
                    Button(
                      onClick: (_) => bloc.add(ToggleTodo(item.id)),
                      style: {
                        'padding': '0.6rem 1.25rem',
                        'background': item.done ? _muted : _green,
                        'color': '#fff',
                        'border': 'none',
                        'border-radius': '8px',
                        'cursor': 'pointer',
                        'font-weight': '600',
                      },
                      child: Text(item.done ? 'Mark pending' : 'Mark done'),
                    ),
                    Button(
                      onClick: (_) {
                        bloc.add(RemoveTodo(item.id));
                        RouterProvider.of(context).go('/todos');
                      },
                      style: {
                        'padding': '0.6rem 1.25rem',
                        'background': _red,
                        'color': '#fff',
                        'border': 'none',
                        'border-radius': '8px',
                        'cursor': 'pointer',
                        'font-weight': '600',
                      },
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Not found page
// ---------------------------------------------------------------------------

Widget _notFoundPage(BuildContext context, String path) => _pageContainer(
      title: '404',
      children: [
        _card(
          children: [
            P(
              style: {'color': _muted, 'font-size': '1.1rem', 'margin-bottom': '1rem'},
              child: Text('Page "$path" not found.'),
            ),
            Link(
              to: '/',
              style: {'color': _accent2, 'font-size': '0.95rem'},
              child: Text('Go home'),
            ),
          ],
        ),
      ],
    );

// ---------------------------------------------------------------------------
// App shell (layout with nav)
// ---------------------------------------------------------------------------

class AppShell extends StatelessWidget {
  const AppShell();

  @override
  Widget build(BuildContext context) {
    return Div(
      style: {
        'font-family':
            "-apple-system, BlinkMacSystemFont, 'Segoe UI', 'Inter', sans-serif",
        'background': _bg,
        'color': _text,
        'min-height': '100vh',
        'line-height': '1.6',
      },
      children: [
        _buildNav(),
        RouterOutlet(),
      ],
    );
  }

  Widget _buildNav() => Header(
        style: {
          'position': 'sticky',
          'top': '0',
          'z-index': '100',
          'background': 'rgba(15, 23, 42, 0.9)',
          'backdrop-filter': 'blur(12px)',
          'border-bottom': '1px solid $_border',
        },
        children: [
          Div(
            style: {
              'max-width': '720px',
              'margin': '0 auto',
              'padding': '0 2rem',
              'height': '56px',
              'display': 'flex',
              'align-items': 'center',
              'justify-content': 'space-between',
            },
            children: [
              // Logo
              Link(
                to: '/',
                style: {
                  'font-size': '1.2rem',
                  'font-weight': '800',
                  'color': _accent2,
                  'text-decoration': 'none',
                },
                child: Text('druid'),
              ),
              // Nav links
              Nav(
                style: {
                  'display': 'flex',
                  'align-items': 'center',
                  'gap': '0.25rem',
                },
                children: [
                  _navLink('/', 'Home'),
                  _navLink('/counter', 'Counter'),
                  _navLink('/todos', 'Todos'),
                ],
              ),
            ],
          ),
        ],
      );

  Widget _navLink(String to, String label) => Link(
        to: to,
        activeClassName: 'nav-active',
        className: 'nav-link',
        child: Text(label),
      );
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

void main() {
  injectStyleSheet('''
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    #app { width: 100%; }

    .nav-link {
      color: $_muted;
      padding: 0.35rem 0.75rem;
      border-radius: 6px;
      font-size: 0.9rem;
      text-decoration: none;
      transition: color 0.2s, background 0.2s;
    }
    .nav-link:hover {
      color: $_text;
      background: $_surface;
    }
    .nav-active {
      color: $_accent2 !important;
      background: rgba(124, 58, 237, 0.1);
    }

    input::placeholder { color: $_muted; }
    input:focus { border-color: $_accent !important; }
    button:hover { opacity: 0.9; }
  ''');

  runApp(
    BlocProvider(
      create: () => CounterBloc(),
      child: BlocProvider(
        create: () => TodoBloc(),
        child: RouterProvider(
          routes: [
            RouteDefinition(path: '/', builder: (ctx, m) => const HomePage()),
            RouteDefinition(
                path: '/counter', builder: (ctx, m) => const CounterPage()),
            RouteDefinition(
              path: '/todos',
              builder: (ctx, m) => const TodoPage(),
              children: [
                RouteDefinition(
                  path: ':id',
                  builder: (ctx, m) =>
                      TodoDetailPage(id: m.params['id']!),
                ),
              ],
            ),
          ],
          notFound: _notFoundPage,
          child: const AppShell(),
        ),
      ),
    ),
  );
}
