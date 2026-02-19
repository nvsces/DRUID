import 'dart:js_interop';
import 'dart:convert';
import 'package:web/web.dart' as web;
import 'package:druid/druid.dart';

// ---------------------------------------------------------------------------
// Avatar Bloc
// ---------------------------------------------------------------------------

sealed class AvatarEvent {}

class FetchAvatar extends AvatarEvent {}

sealed class AvatarState {}

class AvatarIdle extends AvatarState {
  final String url;
  AvatarIdle(this.url);
}

class AvatarLoading extends AvatarState {}

class AvatarLoaded extends AvatarState {
  final String url;
  AvatarLoaded(this.url);
}

class AvatarError extends AvatarState {
  final String message;
  AvatarError(this.message);
}

class AvatarBloc extends Bloc<AvatarEvent, AvatarState> {
  AvatarBloc() : super(AvatarIdle('avatar.jpg')) {
    on<FetchAvatar>(_onFetch);
  }

  Future<void> _onFetch(
      FetchAvatar event, void Function(AvatarState) emit) async {
    emit(AvatarLoading());
    try {
      // final response = await web.window.fetch(
      //   'https://service.image.ru'.toJS,
      // ).toDart;
      // final text = await response.text().toDart;
      // final json = jsonDecode(text.toDart) as Map<String, dynamic>;
      final json = {
        "avatar_url": "https://i.ytimg.com/vi/q5G7h-Ks3to/maxresdefault.jpg"
      };
      emit(AvatarLoaded(json['avatar_url'] as String));
    } catch (e) {
      emit(AvatarError('Не удалось загрузить'));
    }
  }
}

const _css = '''
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

:root {
  --bg:        #0a0a0f;
  --bg2:       #111118;
  --bg3:       #16161f;
  --border:    #1e1e2e;
  --text:      #e2e8f0;
  --muted:     #64748b;
  --accent:    #7c3aed;
  --accent2:   #a855f7;
  --accent-glow: rgba(124, 58, 237, 0.25);
  --blue:      #3b82f6;
  --green:     #22c55e;
  --radius:    16px;
}

html { scroll-behavior: smooth; }

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Inter', sans-serif;
  background: var(--bg);
  color: var(--text);
  min-height: 100vh;
  line-height: 1.6;
}

#app { width: 100%; }

a { text-decoration: none; color: inherit; }

/* ── Navbar ── */
.navbar {
  position: sticky;
  top: 0;
  z-index: 100;
  background: rgba(10, 10, 15, 0.85);
  backdrop-filter: blur(12px);
  border-bottom: 1px solid var(--border);
}

.navbar-inner {
  max-width: 1100px;
  margin: 0 auto;
  padding: 0 2rem;
  height: 64px;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.logo {
  font-size: 1.4rem;
  font-weight: 800;
  background: linear-gradient(135deg, var(--accent2), var(--blue));
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.nav-links {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.nav-link {
  color: var(--muted);
  padding: 0.4rem 0.75rem;
  border-radius: 8px;
  font-size: 0.9rem;
  transition: color 0.2s, background 0.2s;
}
.nav-link:hover { color: var(--text); background: var(--bg3); }

.nav-cta {
  background: var(--accent);
  color: #fff;
  padding: 0.45rem 1rem;
  border-radius: 8px;
  font-size: 0.9rem;
  font-weight: 600;
  transition: background 0.2s, transform 0.1s;
}
.nav-cta:hover { background: var(--accent2); transform: translateY(-1px); }

/* ── Sections ── */
.section { padding: 5rem 2rem; }
.section-dark { background: var(--bg2); }

.section-inner {
  max-width: 1100px;
  margin: 0 auto;
  display: flex;
  flex-direction: column;
  gap: 3rem;
}

.section-header {
  text-align: center;
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.section-desc { color: var(--muted); font-size: 1.05rem; max-width: 520px; margin: 0 auto; }

h2 { font-size: 2rem; font-weight: 700; line-height: 1.2; }
h3 { font-size: 1.1rem; font-weight: 600; margin-bottom: 0.4rem; }

.accent {
  background: linear-gradient(135deg, var(--accent2), var(--blue));
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

/* ── Buttons ── */
.btn-primary {
  display: inline-block;
  background: linear-gradient(135deg, var(--accent), var(--accent2));
  color: #fff;
  padding: 0.75rem 1.75rem;
  border-radius: 10px;
  font-size: 0.95rem;
  font-weight: 600;
  transition: opacity 0.2s, transform 0.1s;
  box-shadow: 0 4px 20px var(--accent-glow);
}
.btn-primary:hover { opacity: 0.9; transform: translateY(-2px); }

.btn-outline {
  display: inline-block;
  background: transparent;
  color: var(--text);
  padding: 0.75rem 1.75rem;
  border-radius: 10px;
  font-size: 0.95rem;
  font-weight: 500;
  border: 1px solid var(--border);
  transition: border-color 0.2s, background 0.2s;
}
.btn-outline:hover { border-color: var(--accent); background: var(--accent-glow); }

.btn-ghost {
  display: inline-block;
  color: var(--muted);
  padding: 0.75rem 1.75rem;
  border-radius: 10px;
  font-size: 0.95rem;
  border: 1px solid var(--border);
  transition: color 0.2s, border-color 0.2s;
}
.btn-ghost:hover { color: var(--text); border-color: var(--muted); }

/* ── Hero ── */
.hero {
  padding: 6rem 2rem 5rem;
  position: relative;
  overflow: hidden;
}
.hero::before {
  content: '';
  position: absolute;
  top: -200px; right: -200px;
  width: 600px; height: 600px;
  background: radial-gradient(circle, rgba(124,58,237,0.12), transparent 70%);
  pointer-events: none;
}

.hero-inner {
  max-width: 1100px;
  margin: 0 auto;
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 4rem;
  align-items: center;
}

.hero-content {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.hero-badge {
  display: inline-flex;
  align-items: center;
  gap: 0.4rem;
  background: var(--bg3);
  border: 1px solid var(--border);
  border-radius: 100px;
  padding: 0.35rem 1rem;
  font-size: 0.85rem;
  color: var(--muted);
  width: fit-content;
}

.hero-content h1 {
  font-size: 2.8rem;
  font-weight: 800;
  line-height: 1.15;
}

.hero-desc { color: var(--muted); font-size: 1.05rem; max-width: 480px; }

.hero-stats {
  display: flex;
  gap: 2.5rem;
}

.stat-item { display: flex; flex-direction: column; gap: 0.1rem; }
.stat-value { font-size: 1.8rem; font-weight: 800; color: var(--text); }
.stat-label { font-size: 0.8rem; color: var(--muted); text-transform: uppercase; letter-spacing: 0.05em; }

.hero-actions { display: flex; gap: 0.75rem; flex-wrap: wrap; }

/* ── Avatar ── */
.hero-visual {
  display: flex;
  justify-content: center;
  align-items: center;
}

.avatar-wrapper {
  position: relative;
  width: 280px;
  height: 280px;
}

.avatar-circle {
  width: 220px;
  height: 220px;
  border-radius: 50%;
  border: 2px solid var(--border);
  object-fit: cover;
  display: block;
  margin: 30px auto 0;
  box-shadow: 0 0 60px var(--accent-glow);
  transition: opacity 0.2s, transform 0.2s, box-shadow 0.2s;
}

.avatar-click-area {
  cursor: pointer;
  display: block;
  width: fit-content;
  margin: 0 auto;
}

.avatar-click-area:hover .avatar-circle {
  transform: translateY(-4px) scale(1.03);
  box-shadow: 0 0 80px var(--accent-glow);
}

.avatar-loading { opacity: 0.5; }
.avatar-error   { filter: grayscale(1); opacity: 0.6; }

.avatar-hint {
  text-align: center;
  font-size: 0.75rem;
  color: var(--muted);
  margin-top: 0.5rem;
}

.tech-badges {
  position: absolute;
  inset: 0;
  pointer-events: none;
}

.tech-badge {
  position: absolute;
  background: var(--bg3);
  border: 1px solid var(--border);
  border-radius: 8px;
  padding: 0.35rem 0.75rem;
  font-size: 0.8rem;
  font-weight: 600;
  white-space: nowrap;
}
.tech-badge.flutter { top: 10px; right: 0; color: #54c5f8; border-color: rgba(84,197,248,0.3); }
.tech-badge.dart    { bottom: 60px; left: -10px; color: #00b4ab; border-color: rgba(0,180,171,0.3); }
.tech-badge.firebase { bottom: 10px; right: 10px; color: #ffca28; border-color: rgba(255,202,40,0.3); }

/* ── Features ── */
.features-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 1.25rem;
}

.feature-card {
  background: var(--bg3);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  padding: 1.75rem 1.5rem;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  transition: border-color 0.2s, transform 0.2s;
}
.feature-card:hover { border-color: var(--accent); transform: translateY(-4px); }

.feature-icon {
  font-size: 2rem;
  margin-bottom: 0.25rem;
}
.feature-card h3 { color: var(--text); }
.feature-card p  { color: var(--muted); font-size: 0.9rem; }

/* ── Prices ── */
.prices-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1.5rem;
  align-items: start;
}

.price-card {
  background: var(--bg3);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  padding: 2rem;
  display: flex;
  flex-direction: column;
  gap: 1rem;
  position: relative;
  transition: transform 0.2s;
}
.price-card:hover { transform: translateY(-4px); }

.price-card.popular {
  border-color: var(--accent);
  background: linear-gradient(160deg, rgba(124,58,237,0.08), var(--bg3));
  box-shadow: 0 8px 40px var(--accent-glow);
}

.badge {
  position: absolute;
  top: -12px;
  left: 50%;
  transform: translateX(-50%);
  background: linear-gradient(135deg, var(--accent), var(--accent2));
  color: #fff;
  font-size: 0.75rem;
  font-weight: 700;
  padding: 0.2rem 0.9rem;
  border-radius: 100px;
  white-space: nowrap;
}

.price-card h3 { color: var(--text); font-size: 1.15rem; }

.price-amount {
  display: flex;
  align-items: baseline;
  gap: 0.4rem;
}
.price-num { font-size: 2rem; font-weight: 800; color: var(--text); }
.price-period { color: var(--muted); font-size: 0.9rem; }

.price-desc { color: var(--muted); font-size: 0.9rem; }

.price-features {
  list-style: none;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.price-feature {
  display: flex;
  align-items: flex-start;
  gap: 0.5rem;
  font-size: 0.9rem;
  color: var(--muted);
}

.check {
  color: var(--green);
  font-weight: 700;
  flex-shrink: 0;
  margin-top: 0.05em;
}

/* ── Tech stack ── */
.tech-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 0.75rem;
  justify-content: center;
}

.tech-chip {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  background: var(--bg3);
  border: 1px solid var(--border);
  border-radius: 100px;
  padding: 0.5rem 1.1rem;
  transition: border-color 0.2s, background 0.2s;
}
.tech-chip:hover { border-color: var(--accent); background: var(--accent-glow); }

.tech-emoji { font-size: 1rem; }
.tech-name { font-size: 0.9rem; font-weight: 500; }

/* ── Reviews ── */
.reviews-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1.5rem;
}

.review-card {
  background: var(--bg3);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  padding: 1.75rem;
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  transition: border-color 0.2s;
}
.review-card:hover { border-color: var(--accent); }

.review-header {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.avatar {
  width: 44px;
  height: 44px;
  border-radius: 50%;
  background: linear-gradient(135deg, var(--accent), var(--blue));
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.85rem;
  font-weight: 700;
  color: #fff;
  flex-shrink: 0;
}

.review-name { font-size: 0.95rem; font-weight: 600; }
.review-role { font-size: 0.8rem; color: var(--muted); }

.stars { color: #f59e0b; font-size: 0.95rem; letter-spacing: 1px; }
.review-text { color: var(--muted); font-size: 0.9rem; line-height: 1.65; }

/* ── Footer ── */
.footer {
  background: var(--bg2);
  border-top: 1px solid var(--border);
  padding: 5rem 2rem 2rem;
}

.footer-inner {
  max-width: 1100px;
  margin: 0 auto;
  display: flex;
  flex-direction: column;
  gap: 3rem;
}

.footer-cta {
  text-align: center;
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
  align-items: center;
}

.footer-cta h2 { font-size: 2rem; }
.footer-cta p  { color: var(--muted); max-width: 480px; }

.footer-actions {
  display: flex;
  gap: 0.75rem;
  flex-wrap: wrap;
  justify-content: center;
}

.footer-bottom {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding-top: 2rem;
  border-top: 1px solid var(--border);
  color: var(--muted);
  font-size: 0.85rem;
}

.footer-socials { display: flex; gap: 1.5rem; }

.social-link {
  color: var(--muted);
  transition: color 0.2s;
}
.social-link:hover { color: var(--accent2); }

/* ── Responsive ── */
@media (max-width: 900px) {
  .hero-inner { grid-template-columns: 1fr; text-align: center; }
  .hero-visual { display: none; }
  .hero-stats { justify-content: center; }
  .hero-actions { justify-content: center; }
  .hero-badge { margin: 0 auto; }
  .hero-desc { margin: 0 auto; }
  .features-grid { grid-template-columns: repeat(2, 1fr); }
  .prices-grid { grid-template-columns: 1fr; max-width: 440px; margin: 0 auto; }
  .reviews-grid { grid-template-columns: 1fr; max-width: 520px; margin: 0 auto; }
}

@media (max-width: 600px) {
  .nav-links .nav-link { display: none; }
  .hero-content h1 { font-size: 2rem; }
  .features-grid { grid-template-columns: 1fr; }
  .footer-bottom { flex-direction: column; gap: 1rem; text-align: center; }
}
''';

// ---------------------------------------------------------------------------
// Reusable helpers
// ---------------------------------------------------------------------------

Widget _navLink(String href, String label) => A(
      href: href,
      className: 'nav-link',
      child: Text(label),
    );

Widget _techChip(String emoji, String name) => Div(
      className: 'tech-chip',
      children: [
        Span(className: 'tech-emoji', child: Text(emoji)),
        Span(className: 'tech-name', child: Text(name)),
      ],
    );

Widget _stars() => Span(
      className: 'stars',
      child: Text('★★★★★'),
    );

Widget _reviewCard({
  required String initials,
  required String name,
  required String role,
  required String text,
}) =>
    Div(
      className: 'review-card',
      children: [
        Div(
          className: 'review-header',
          children: [
            Div(className: 'avatar', children: [Text(initials)]),
            Div(
              className: 'review-meta',
              children: [
                Div(className: 'review-name', children: [Text(name)]),
                Div(className: 'review-role', children: [Text(role)]),
              ],
            ),
          ],
        ),
        _stars(),
        P(className: 'review-text', child: Text(text)),
      ],
    );

Widget _featureCard({
  required String emoji,
  required String title,
  required String desc,
}) =>
    Div(
      className: 'feature-card',
      children: [
        Div(className: 'feature-icon', children: [Text(emoji)]),
        H3(child: Text(title)),
        P(child: Text(desc)),
      ],
    );

Widget _priceCard({
  required String title,
  required String price,
  required String period,
  required String desc,
  required List<String> items,
  bool popular = false,
}) =>
    Div(
      className: popular ? 'price-card popular' : 'price-card',
      children: [
        if (popular) Div(className: 'badge', children: [Text('Популярный')]),
        H3(child: Text(title)),
        Div(
          className: 'price-amount',
          children: [
            Span(className: 'price-num', child: Text(price)),
            Span(className: 'price-period', child: Text(period)),
          ],
        ),
        P(className: 'price-desc', child: Text(desc)),
        Ul(
          className: 'price-features',
          children: [
            for (final item in items)
              Li(
                className: 'price-feature',
                children: [
                  Span(className: 'check', child: Text('✓')),
                  Text(item),
                ],
              ),
          ],
        ),
        A(
          href: 'https://t.me/geexman',
          target: '_blank',
          className: popular ? 'btn-primary' : 'btn-outline',
          child: Text('Записаться'),
        ),
      ],
    );

// ---------------------------------------------------------------------------
// Landing page
// ---------------------------------------------------------------------------

class LandingPage extends StatelessWidget {
  const LandingPage();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: () => AvatarBloc(),
      child: _LandingContent(),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero section — uses AvatarBloc via BlocProvider + BlocBuilder
// ---------------------------------------------------------------------------

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<AvatarBloc>(context);
    return BlocBuilder<AvatarBloc, AvatarState>(
      bloc: bloc,
      builder: (ctx, state) {
        final String avatarSrc;
        final String avatarClass;
        final String hint;

        if (state is AvatarLoading) {
          avatarSrc = 'avatar.jpg';
          avatarClass = 'avatar-circle avatar-loading';
          hint = 'Загрузка…';
        } else if (state is AvatarLoaded) {
          avatarSrc = state.url;
          avatarClass = 'avatar-circle';
          hint = 'Кликни ещё раз';
        } else if (state is AvatarError) {
          avatarSrc = 'avatar.jpg';
          avatarClass = 'avatar-circle avatar-error';
          hint = state.message;
        } else {
          // AvatarIdle
          avatarSrc = (state as AvatarIdle).url;
          avatarClass = 'avatar-circle';
          hint = 'Кликни для обновления';
        }

        return Section(
          className: 'hero',
          children: [
            Div(
              className: 'hero-inner',
              children: [
                Div(
                  className: 'hero-content',
                  children: [
                    Div(
                      className: 'hero-badge',
                      children: [
                        Span(child: Text('🚀')),
                        Text(' Flutter Developer & Mentor'),
                      ],
                    ),
                    H1(
                      children: [
                        Text('Ментор по '),
                        Span(className: 'accent', child: Text('Flutter')),
                        Text(' и мобильной разработке'),
                      ],
                    ),
                    P(
                      className: 'hero-desc',
                      child: Text(
                        'Помогаю разработчикам освоить Flutter с нуля или '
                        'перейти на следующий уровень. Практические занятия, '
                        'code review и персональный подход.',
                      ),
                    ),
                    Div(
                      className: 'hero-stats',
                      children: [
                        _heroStat('0+', 'Учеников'),
                        _heroStat('0+', 'Лет опыта'),
                        _heroStat('0+', 'Проектов'),
                      ],
                    ),
                    Div(
                      className: 'hero-actions',
                      children: [
                        A(
                          href: 'https://t.me/geexman',
                          target: '_blank',
                          className: 'btn-primary',
                          child: Text('Записаться на занятие'),
                        ),
                        A(
                          href: '#services',
                          className: 'btn-ghost',
                          child: Text('Узнать об услугах'),
                        ),
                      ],
                    ),
                  ],
                ),
                Div(
                  className: 'hero-visual',
                  children: [
                    Div(
                      className: 'avatar-wrapper',
                      children: [
                        Div(
                          className: 'avatar-click-area',
                          onClick: (_) => bloc.add(FetchAvatar()),
                          children: [
                            Img(
                              src: avatarSrc,
                              alt: 'Дмитрий Шаныгин',
                              className: avatarClass,
                            ),
                          ],
                        ),
                        Div(
                          className: 'avatar-hint',
                          children: [Text(hint)],
                        ),
                        Div(
                          className: 'tech-badges',
                          children: [
                            Div(
                                className: 'tech-badge flutter',
                                children: [Text('Flutter')]),
                            Div(
                                className: 'tech-badge dart',
                                children: [Text('Dart')]),
                            Div(
                                className: 'tech-badge firebase',
                                children: [Text('Firebase')]),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _heroStat(String value, String label) => Div(
        className: 'stat-item',
        children: [
          Div(className: 'stat-value', children: [Text(value)]),
          Div(className: 'stat-label', children: [Text(label)]),
        ],
      );
}

class _LandingContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Div(
      className: 'landing',
      children: [
        _buildNav(),
        _buildHero(),
        _buildAbout(),
        _buildServices(),
        _buildStack(),
        _buildReviews(),
        _buildFooter(),
      ],
    );
  }

  Widget _buildNav() => Header(
        className: 'navbar',
        children: [
          Div(
            className: 'navbar-inner',
            children: [
              A(
                href: '#',
                className: 'logo',
                child: Text('geexman'),
              ),
              Nav(
                className: 'nav-links',
                children: [
                  _navLink('#about', 'Обо мне'),
                  _navLink('#services', 'Услуги'),
                  _navLink('#stack', 'Стек'),
                  _navLink('#reviews', 'Отзывы'),
                  A(
                    href: 'https://t.me/geexman',
                    target: '_blank',
                    className: 'nav-cta',
                    child: Text('Записаться'),
                  ),
                ],
              ),
            ],
          ),
        ],
      );

  Widget _buildHero() => _HeroSection();

  Widget _buildAbout() => Section(
        id: 'about',
        className: 'section',
        children: [
          Div(
            className: 'section-inner',
            children: [
              Div(
                className: 'section-header',
                children: [
                  H2(children: [
                    Text('Почему именно '),
                    Span(className: 'accent', child: Text('я?')),
                  ]),
                  P(
                    className: 'section-desc',
                    child: Text(
                      'Практический опыт и индивидуальный подход — '
                      'ключ к быстрому росту.',
                    ),
                  ),
                ],
              ),
              Div(
                className: 'features-grid',
                children: [
                  _featureCard(
                    emoji: '💼',
                    title: 'Практический опыт',
                    desc:
                        'Работаю над реальными коммерческими Flutter-приложениями. '
                        'Знаю, что нужно индустрии.',
                  ),
                  _featureCard(
                    emoji: '🎯',
                    title: 'Индивидуальный подход',
                    desc: 'Программа адаптируется под ваш текущий уровень '
                        'и конкретные цели.',
                  ),
                  _featureCard(
                    emoji: '🔍',
                    title: 'Code Review',
                    desc: 'Детальный разбор вашего кода с указанием лучших '
                        'практик и антипаттернов.',
                  ),
                  _featureCard(
                    emoji: '⚡',
                    title: 'Быстрый результат',
                    desc: 'Структурированная программа обучения даёт '
                        'результат уже с первых занятий.',
                  ),
                ],
              ),
            ],
          ),
        ],
      );

  Widget _buildServices() => Section(
        id: 'services',
        className: 'section section-dark',
        children: [
          Div(
            className: 'section-inner',
            children: [
              Div(
                className: 'section-header',
                children: [
                  H2(children: [
                    Text('Мои '),
                    Span(className: 'accent', child: Text('услуги')),
                  ]),
                  P(
                    className: 'section-desc',
                    child: Text(
                      'Выберите формат, который подходит именно вам.',
                    ),
                  ),
                ],
              ),
              Div(
                className: 'prices-grid',
                children: [
                  _priceCard(
                    title: 'Индивидуальное занятие',
                    price: '2 500 ₽',
                    period: '/ занятие',
                    desc: 'Час один на один с записью сессии',
                    items: [
                      'Разбор конкретной темы',
                      'Запись занятия',
                      'Материалы и ссылки',
                      'Ответы на вопросы',
                    ],
                  ),
                  _priceCard(
                    title: 'Менторинг',
                    price: '15 000 ₽',
                    period: '/ месяц',
                    desc: '4 занятия + поддержка в мессенджере',
                    items: [
                      '4 занятия в месяц',
                      'Поддержка 24/7 в Telegram',
                      'Code review проектов',
                      'Персональный план обучения',
                      'Помощь с карьерой',
                    ],
                    popular: true,
                  ),
                  _priceCard(
                    title: 'Консультация',
                    price: '5 000 ₽',
                    period: '/ разово',
                    desc: 'Аудит кода и архитектурные рекомендации',
                    items: [
                      'Аудит вашего проекта',
                      'Рекомендации по архитектуре',
                      'Письменный отчёт',
                      'Ответы на вопросы',
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      );

  Widget _buildStack() => Section(
        id: 'stack',
        className: 'section',
        children: [
          Div(
            className: 'section-inner',
            children: [
              Div(
                className: 'section-header',
                children: [
                  H2(children: [
                    Text('Технологический '),
                    Span(className: 'accent', child: Text('стек')),
                  ]),
                  P(
                    className: 'section-desc',
                    child: Text(
                      'Инструменты и технологии, которые я преподаю.',
                    ),
                  ),
                ],
              ),
              Div(
                className: 'tech-grid',
                children: [
                  _techChip('💙', 'Flutter'),
                  _techChip('🎯', 'Dart'),
                  _techChip('🔥', 'Firebase'),
                  _techChip('🧱', 'BLoC'),
                  _techChip('📦', 'Provider'),
                  _techChip('🪝', 'Riverpod'),
                  _techChip('🌐', 'REST API'),
                  _techChip('📡', 'GraphQL'),
                  _techChip('🧪', 'Testing'),
                  _techChip('⚙️', 'CI/CD'),
                  _techChip('✨', 'Animations'),
                  _techChip('🏗️', 'Clean Architecture'),
                ],
              ),
            ],
          ),
        ],
      );

  Widget _buildReviews() => Section(
        id: 'reviews',
        className: 'section section-dark',
        children: [
          Div(
            className: 'section-inner',
            children: [
              Div(
                className: 'section-header',
                children: [
                  H2(children: [
                    Text('Отзывы '),
                    Span(className: 'accent', child: Text('учеников')),
                  ]),
                  P(
                    className: 'section-desc',
                    child: Text(
                      'Что говорят те, кто уже прошёл обучение.',
                    ),
                  ),
                ],
              ),
              Div(
                className: 'reviews-grid',
                children: [
                  _reviewCard(
                    initials: 'АК',
                    name: 'Алексей К.',
                    role: 'Junior Flutter Developer',
                    text:
                        'За 2 месяца я с нуля освоил Flutter и уже сделал своё первое '
                        'приложение. Дмитрий очень доступно объясняет сложные вещи и всегда '
                        'готов помочь. Рекомендую!',
                  ),
                  _reviewCard(
                    initials: 'МС',
                    name: 'Мария С.',
                    role: 'Middle Flutter Developer',
                    text:
                        'Благодаря менторингу Дмитрия я прошла собеседование в компанию '
                        'мечты. Код-ревью помогло мне исправить множество скрытых ошибок '
                        'в архитектуре проекта.',
                  ),
                  _reviewCard(
                    initials: 'ИТ',
                    name: 'Игорь Т.',
                    role: 'Flutter Developer',
                    text:
                        'Code review от Дмитрия — это невероятно полезно. После его '
                        'замечаний я полностью пересмотрел подход к написанию кода. '
                        'Качество работ выросло на порядок.',
                  ),
                ],
              ),
            ],
          ),
        ],
      );

  Widget _buildFooter() => Footer(
        className: 'footer',
        children: [
          Div(
            className: 'footer-inner',
            children: [
              Div(
                className: 'footer-cta',
                children: [
                  H2(children: [
                    Text('Готовы начать свой путь в '),
                    Span(className: 'accent', child: Text('Flutter?')),
                  ]),
                  P(
                    child: Text(
                      'Запишитесь на бесплатную вводную встречу — '
                      'обсудим ваши цели и составим план.',
                    ),
                  ),
                  Div(
                    className: 'footer-actions',
                    children: [
                      A(
                        href: 'https://t.me/geexman',
                        target: '_blank',
                        className: 'btn-primary',
                        child: Text('Написать в Telegram'),
                      ),
                      A(
                        href: 'mailto:dmitry@geexman.dev',
                        className: 'btn-outline',
                        child: Text('dmitry@geexman.dev'),
                      ),
                    ],
                  ),
                ],
              ),
              Div(
                className: 'footer-bottom',
                children: [
                  Span(child: Text('© 2026 geexman. Все права защищены.')),
                  Div(
                    className: 'footer-socials',
                    children: [
                      A(
                        href: 'https://t.me/geexman',
                        target: '_blank',
                        className: 'social-link',
                        child: Text('Telegram'),
                      ),
                      A(
                        href: 'mailto:dmitry@geexman.dev',
                        className: 'social-link',
                        child: Text('Email'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      );
}

void main() {
  injectStyleSheet(_css);
  runApp(const LandingPage());
}
