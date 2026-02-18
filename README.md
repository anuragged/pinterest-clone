
# anurag_pinterest — Pinterest Clone


# 5-minute demo (iOS Simulator) — GDrive Link:

https://drive.google.com/file/d/1032qZCEjz295DfH7-Ek3_YxgcBfSfAVJ/view?usp=sharing

APK / iOS build link:

https://drive.google.com/file/d/1WA4btztyJwgU3mMIxXEuMxICt2wG6jWz/view?usp=sharing

Pinterest Clone — Image Discovery Platform is a Flutter-based, cross-platform app that reproduces the core Pinterest experience: a masonry image feed, pin detail pages, search, creation flow, notifications, and profile/boards.

This README documents the tech stack, architecture, API wiring, image-loading strategy, ranking logic, and developer notes. A placeholder for a 5-minute iOS demo script and an APK link is provided below.

--

**Quick links**

- `pubspec.yaml`: [pubspec.yaml](pubspec.yaml)
- App entrypoint: [lib/main.dart](lib/main.dart)
- Root widget: [lib/app.dart](lib/app.dart)
- Network service: [lib/services/network_service.dart](lib/services/network_service.dart)
- Pexels API source: [lib/data/sources/pexels_api_service.dart](lib/data/sources/pexels_api_service.dart)
- Feed provider: [lib/presentation/providers/feed_provider.dart](lib/presentation/providers/feed_provider.dart)
- Pin UI: [lib/presentation/widgets/pin_card.dart](lib/presentation/widgets/pin_card.dart)
- Router: [lib/core/router/app_router.dart](lib/core/router/app_router.dart)

--

## Tech stack

- Flutter (Dart SDK constraint: `^3.6.0`)
- State management: `flutter_riverpod`
- Navigation: `go_router`
- HTTP client: `dio`
- Image caching: `cached_network_image`
- UI: Material 3, `flutter_staggered_grid_view` for masonry layouts, `shimmer` for placeholders
- Auth (third-party): `clerk_flutter` (Clerk used at app root)

Dependencies are declared in [pubspec.yaml](pubspec.yaml).

--

## High-level architecture

Clean separation between presentation, domain, and data layers:

- `lib/presentation/` — UI: screens, providers (Riverpod), reusable widgets.
- `lib/domain/` — Entities, repository interfaces, and use-cases (e.g., `GetFeedPins`).
- `lib/data/` — Data sources and repository implementations (e.g., `PexelsApiService`, `PinRepositoryImpl`, `LocalCacheService`).
- `lib/services/` — App-wide services (e.g., `NetworkService` wrapping `Dio`).

This structure keeps UI decoupled from networking and business logic for easier testing and iteration.

--

## API wiring & data flow

1. Presentation requests data from a provider/use-case (e.g., `feedProvider` calls `GetFeedPins`).
2. `GetFeedPins` calls the repository (`PinRepositoryImpl`).
3. `PinRepositoryImpl` delegates to `PexelsApiService` to fetch photos from the Pexels API.
4. `PexelsApiService` uses `NetworkService.pexels` (a configured `Dio` instance). If Pexels returns HTTP 429 (quota), the service falls back to Unsplash via `NetworkService.unsplash`.
5. Responses are parsed into `PinModel`, then converted/enriched into domain `Pin` entities using `LocalCacheService` (adds local saves/clicks and caching).

Key config: API keys and endpoints live in `lib/core/constants/api_constants.dart` — replace placeholders with real keys when deploying.

--

## Image loading & performance

Strategies used:

- `cached_network_image`: in-memory and on-disk caching. Subsequent views load from cache instead of re-downloading.
- Thumbnails: feed and search use API-provided thumbnails (`thumbnailUrl`) to reduce download size and decoding time.
- Lazy build: the masonry `SliverMasonryGrid` only constructs visible children; images load when widgets are built.
- Scroll prefetching: `HomeScreen` triggers `feedProvider.loadMore()` when reaching 70% scroll (`ApiConstants.prefetchThreshold`) to warm up the next page.
- Shimmer placeholders with `pin.avgColor` reduce perceived latency while images decode.
- In-memory `_pinCache` in `PinRepositoryImpl` and `LocalCacheService` reduce redundant network/parse work.

These combined approaches improve both actual and perceived performance.

--

## Network resilience

- Timeouts: `connectTimeout` and `receiveTimeout` are set in `NetworkService` to avoid hanging requests.
- Retry: a custom `_RetryInterceptor` retries once on transient network errors (connection/timeouts).
- Fallback: Pexels is primary; on quota errors (429) Unsplash is used as a fallback source.

--

## Recommendation & ranking logic

Lightweight, explainable ranking in `lib/domain/usecases/recommendation_engine.dart`:

- Base score: `Pin.recommendationScore` (combines saves, clicks, recency decay).
- Personalization: saved pins' photographer IDs infer user interests — pins matching these get a fixed boost (+5.0) before sorting.
- Cold start: trending ranking by score.

This approach is deterministic and safe for demos; production can replace it with server-side or ML models.

--

## Local cache & optimistic UI

- `LocalCacheService` stores saved pins, boards, click/save counters, and search history for the session.
- `PinRepositoryImpl` keeps an in-memory `_pinCache` for quick lookups.
- Save/unsave actions update UI optimistically and persist to the local cache for instant feedback.

--

## Developer notes & next steps

- Replace API key placeholders in `lib/core/constants/api_constants.dart` and Clerk keys in `lib/main.dart` before release.
- For persistence, consider Hive/SQLite or server-side storage to persist saved pins and preferences.
- To improve recommendations, add embeddings + nearest-neighbor search or a server-side ranking API.
- Add CI (GitHub Actions) to run `flutter analyze` and `flutter test` on PRs.

