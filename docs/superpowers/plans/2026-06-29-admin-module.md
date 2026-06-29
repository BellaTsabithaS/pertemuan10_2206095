# Admin Module Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add admin-only UI after the existing login flow for dashboard stats, admin orders, status updates, and category creation.

**Architecture:** Keep the existing login/register endpoints. `UserModel.role` decides whether `SplashPage` and `LoginPage` route to customer `HomePage` or `AdminHomePage`. Admin pages use `AdminProvider`, which calls `AdminService`, which calls the existing `ApiService`.

**Tech Stack:** Flutter, Provider, existing `ApiService`, existing design tokens, REST endpoints from Swagger.

---

## File Map

Create:
- `lib/core/services/admin_service.dart`
- `lib/providers/admin_provider.dart`
- `lib/features/admin/admin_home_page.dart`
- `test/admin_flow_test.dart`

Modify:
- `lib/models/user_model.dart`
- `lib/providers/auth_provider.dart`
- `lib/features/auth/login_page.dart`
- `lib/features/splash/splash_page.dart`
- `lib/app.dart`

## Task 1: Admin Role Routing

- [ ] Write failing tests proving `UserModel` parses admin role and `AuthProvider.login()` loads user profile.
- [ ] Implement `UserModel.role` with support for login response role string and profile role object.
- [ ] Update `AuthProvider.login()` to call `getProfile()` after token save so role is available immediately.
- [ ] Route login and splash to `AdminHomePage` when `auth.user?.isAdmin == true`.

## Task 2: Admin Service And Provider

- [ ] Write failing tests for `AdminService.fetchStats`, `fetchOrders`, `updateOrderStatus`, and `createCategory`.
- [ ] Implement endpoints:
  - `GET /dashboard/stats`
  - `GET /orders/admin/all?status=&page=&limit=10`
  - `PUT /orders/{id}/status`
  - `POST /categories`
- [ ] Implement `AdminProvider` loading state, error state, dashboard data, order list, status update, and category create.

## Task 3: Admin UI

- [ ] Add `AdminHomePage` with tabs for dashboard, orders, and categories.
- [ ] Dashboard tab shows totals, low stock, top products, recent orders.
- [ ] Orders tab supports status filter and status update dropdown.
- [ ] Categories tab contains name, description, image URL fields and submit button.

## Task 4: Verification

- [ ] Run `flutter analyze`.
- [ ] Run `flutter test`.
- [ ] Stage only admin-module files and commit with `feat: add admin dashboard flow`.
