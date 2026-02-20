import 'package:test/test.dart';
import 'package:druid/src/navigation/route.dart';
import 'package:druid/src/widgets/widget.dart';
import 'package:druid/src/widgets/context.dart';
import 'package:druid/src/widgets/text.dart';

void main() {
  Widget _builder(BuildContext c, RouteMatch m) => Text(m.fullPath);

  group('matchRoute', () {
    test('matches root path /', () {
      final routes = [RouteDefinition(path: '/', builder: _builder)];
      final match = matchRoute('/', routes);
      expect(match, isNotNull);
      expect(match!.fullPath, equals('/'));
    });

    test('matches literal path /about', () {
      final routes = [
        RouteDefinition(path: '/', builder: _builder),
        RouteDefinition(path: '/about', builder: _builder),
      ];
      final match = matchRoute('/about', routes);
      expect(match, isNotNull);
      expect(match!.fullPath, equals('/about'));
    });

    test('captures single path param', () {
      final routes = [
        RouteDefinition(path: '/users/:id', builder: _builder),
      ];
      final match = matchRoute('/users/42', routes);
      expect(match, isNotNull);
      expect(match!.params['id'], equals('42'));
      expect(match.fullPath, equals('/users/42'));
    });

    test('captures multiple path params', () {
      final routes = [
        RouteDefinition(path: '/users/:userId/posts/:postId', builder: _builder),
      ];
      final match = matchRoute('/users/5/posts/99', routes);
      expect(match, isNotNull);
      expect(match!.params['userId'], equals('5'));
      expect(match.params['postId'], equals('99'));
    });

    test('returns null for unmatched path (404)', () {
      final routes = [RouteDefinition(path: '/', builder: _builder)];
      final match = matchRoute('/nonexistent', routes);
      expect(match, isNull);
    });

    test('returns null for empty routes list', () {
      final match = matchRoute('/anything', []);
      expect(match, isNull);
    });

    test('matches nested child routes', () {
      final routes = [
        RouteDefinition(
          path: '/users',
          builder: _builder,
          children: [
            RouteDefinition(path: ':id', builder: _builder),
          ],
        ),
      ];
      final match = matchRoute('/users/42', routes);
      expect(match, isNotNull);
      expect(match!.fullPath, equals('/users'));
      expect(match.child, isNotNull);
      expect(match.child!.params['id'], equals('42'));
      expect(match.child!.fullPath, equals('/users/42'));
    });

    test('deeply nested routes', () {
      final routes = [
        RouteDefinition(
          path: '/users',
          builder: _builder,
          children: [
            RouteDefinition(
              path: ':id',
              builder: _builder,
              children: [
                RouteDefinition(path: 'posts', builder: _builder),
              ],
            ),
          ],
        ),
      ];
      final match = matchRoute('/users/42/posts', routes);
      expect(match, isNotNull);
      expect(match!.child, isNotNull);
      expect(match.child!.child, isNotNull);
      expect(match.child!.child!.params['id'], equals('42'));
      expect(match.child!.child!.fullPath, equals('/users/42/posts'));
    });

    test('child route with empty path matches parent exactly', () {
      final routes = [
        RouteDefinition(
          path: '/users',
          builder: _builder,
          children: [
            RouteDefinition(path: '', builder: _builder),
            RouteDefinition(path: ':id', builder: _builder),
          ],
        ),
      ];

      // /users should match parent + empty-path child
      final match = matchRoute('/users', routes);
      expect(match, isNotNull);
      // The parent consumes 'users', empty child consumes nothing — full match
      expect(match!.fullPath, equals('/users'));
    });

    test('passes query params to match', () {
      final routes = [
        RouteDefinition(path: '/search', builder: _builder),
      ];
      final match = matchRoute(
        '/search',
        routes,
        queryParams: {'q': 'dart', 'page': '1'},
      );
      expect(match, isNotNull);
      expect(match!.queryParams['q'], equals('dart'));
      expect(match.queryParams['page'], equals('1'));
    });

    test('first matching route wins', () {
      final routes = [
        RouteDefinition(path: '/a', builder: _builder),
        RouteDefinition(path: '/a', builder: (c, m) => Text('second')),
      ];
      final match = matchRoute('/a', routes);
      expect(match, isNotNull);
      // Should match the first one
      expect(match!.route, same(routes[0]));
    });

    test('wildcard * matches any single segment', () {
      final routes = [
        RouteDefinition(path: '/files/*', builder: _builder),
      ];
      final match = matchRoute('/files/readme', routes);
      expect(match, isNotNull);
      expect(match!.params, isEmpty); // wildcard does not capture
    });

    test('does not match if too few URL segments', () {
      final routes = [
        RouteDefinition(path: '/a/b/c', builder: _builder),
      ];
      final match = matchRoute('/a/b', routes);
      expect(match, isNull);
    });

    test('does not match if extra URL segments and no children', () {
      final routes = [
        RouteDefinition(path: '/a', builder: _builder),
      ];
      final match = matchRoute('/a/b', routes);
      expect(match, isNull);
    });

    test('decodes URI-encoded path params', () {
      final routes = [
        RouteDefinition(path: '/search/:query', builder: _builder),
      ];
      final match = matchRoute('/search/hello%20world', routes);
      expect(match, isNotNull);
      expect(match!.params['query'], equals('hello world'));
    });

    test('params propagate to nested children', () {
      final routes = [
        RouteDefinition(
          path: '/org/:orgId',
          builder: _builder,
          children: [
            RouteDefinition(
              path: 'team/:teamId',
              builder: _builder,
            ),
          ],
        ),
      ];
      final match = matchRoute('/org/acme/team/dev', routes);
      expect(match, isNotNull);
      expect(match!.child, isNotNull);
      expect(match.child!.params['orgId'], equals('acme'));
      expect(match.child!.params['teamId'], equals('dev'));
    });
  });

  group('parseQueryParams', () {
    test('parses standard query string', () {
      final params = parseQueryParams('/users?tab=posts&sort=asc');
      expect(params['tab'], equals('posts'));
      expect(params['sort'], equals('asc'));
    });

    test('returns empty map for no query', () {
      expect(parseQueryParams('/users'), isEmpty);
    });

    test('returns empty map for trailing ?', () {
      expect(parseQueryParams('/users?'), isEmpty);
    });

    test('decodes URI components', () {
      final params = parseQueryParams('/search?q=hello%20world');
      expect(params['q'], equals('hello world'));
    });

    test('handles key-only params', () {
      final params = parseQueryParams('/page?debug');
      expect(params['debug'], equals(''));
    });

    test('handles multiple = signs in value', () {
      final params = parseQueryParams('/page?expr=a=b');
      expect(params['expr'], equals('a=b'));
    });
  });

  group('extractPath', () {
    test('strips query string', () {
      expect(extractPath('/users?tab=posts'), equals('/users'));
    });

    test('returns full path when no query', () {
      expect(extractPath('/users/42'), equals('/users/42'));
    });

    test('returns root path', () {
      expect(extractPath('/'), equals('/'));
    });

    test('handles empty string', () {
      expect(extractPath(''), equals(''));
    });
  });

  group('RouteDefinition', () {
    test('can be const-constructed', () {
      const route = RouteDefinition(path: '/test');
      expect(route.path, equals('/test'));
      expect(route.builder, isNull);
      expect(route.redirect, isNull);
      expect(route.children, isEmpty);
      expect(route.guards, isEmpty);
    });

    test('supports guards', () {
      bool allowed = true;
      final guard = (RouteMatch m) => allowed;
      final route = RouteDefinition(
        path: '/admin',
        builder: _builder,
        guards: [guard],
      );
      expect(route.guards, hasLength(1));
      expect(route.guards[0](RouteMatch(
        route: route,
        fullPath: '/admin',
        params: {},
      )), isTrue);

      allowed = false;
      expect(route.guards[0](RouteMatch(
        route: route,
        fullPath: '/admin',
        params: {},
      )), isFalse);
    });
  });
}
