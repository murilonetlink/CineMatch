# CineMatch

Aplicativo Flutter para decidir o que assistir em conjunto. Cada usuário desliza filmes e séries (estilo Tinder); quando dois usuários curtem o mesmo título, acontece um **match**. Os matches podem ser marcados como assistidos e avaliados.

## Funcionalidades

- Cadastro e login por nome de usuário e senha (hash SHA-256)
- Swipe de filmes e séries populares (TMDB, em pt-BR)
- Detecção de match quando dois usuários curtem o mesmo título
- Lista de matches com marcação de "já assistimos"
- Avaliações com nota e comentário por match
- Tema escuro com acentos em neon

## Tecnologias

- Flutter / Dart
- Supabase (banco de dados)
- TMDB API (catálogo de filmes e séries)
- `provider`, `flutter_card_swiper`, `cached_network_image`, `google_fonts`

## Estrutura

```
lib/
  models/      # User, Media, MatchModel, Review
  providers/   # Estado de autenticação
  screens/     # Login, Swipe, Matches, Detalhes, Avaliação
  services/    # Integração com Supabase e TMDB
  theme/       # Tema do app
  widgets/     # SwipeCard, MatchDialog
```

## Como rodar

1. Instale o [Flutter](https://docs.flutter.dev/get-started/install).
2. Obtenha uma chave da [API do TMDB](https://www.themoviedb.org/settings/api) e crie um projeto no [Supabase](https://supabase.com) com as tabelas `users`, `swipes`, `matches` e `reviews`.
3. Copie `env.example.json` para `env.json` e preencha com suas chaves (o arquivo é ignorado pelo git):

   ```json
   {
     "TMDB_API_KEY": "...",
     "SUPABASE_URL": "https://seu-projeto.supabase.co",
     "SUPABASE_ANON_KEY": "..."
   }
   ```

4. Instale as dependências e execute:

   ```bash
   flutter pub get
   flutter run --dart-define-from-file=env.json
   ```

Use apenas a chave `anon` do Supabase no app; nunca a `service_role`.