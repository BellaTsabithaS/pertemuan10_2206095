# Header Doc

Purpose: Master design spec for Flutter e-commerce UAS rebuild from an empty-project assumption.
Main callers: Human reviewer, future implementation plan, Flutter app bootstrap in `main.dart` and `app.dart`.
Key dependencies: REST API at `https://api-tb-f2wk.onrender.com/api`, Provider, http, SharedPreferences, Hive, flutter_local_notifications, DESIGN.md tokens.
Main/public sections: Scope, design tokens, architecture, Auth/Profile, Product, Cart, Checkout/Orders, Extras, Core/Error Handling, Testing, Phases.
Side effects: This document has no runtime side effects; planned app side effects include HTTP calls, local token/theme/wishlist storage, and local notifications.

# Flutter E-Commerce UAS Design Spec

Date: 2026-06-28
Status: Approved for written spec review
Approach: Modular minimal, full module spec in one document

## 1. Scope And Assumptions

This project is treated as a clean rebuild. Existing app code can be replaced during implementation. This spec does not require preserving the old local CRUD flow.

The app is a Flutter mobile e-commerce application that consumes this REST API:

```txt
https://api-tb-f2wk.onrender.com/api
```

Target user role:

```txt
Customer
```

Testing account:

```txt
Email: mahasiswa@test.com
Password: test123456
```

Required final deliverables:

```txt
GitHub repository
APK release
README
At least 5 screenshots
Demo video 3-5 minutes
```

Feature scope:

```txt
Auth and profile
Product catalog
Product detail and reviews
Cart
Checkout
Order history
Order detail
Wishlist local storage
Dark mode
Local notification after successful checkout
```

Out of scope:

```txt
Admin dashboard
Payment gateway
Offline-first API cache
Product CRUD
Complex analytics
```

## 2. Design System And Theme Tokens

The visual system must follow `DESIGN.md`. Implementation should convert the design values into Flutter theme tokens so pages do not hardcode colors, spacing, radius, or typography.

Target files:

```txt
lib/core/theme/app_colors.dart
lib/core/theme/app_text_styles.dart
lib/core/theme/app_spacing.dart
lib/core/theme/app_radius.dart
lib/core/theme/app_theme.dart
```

### Color Tokens

Use these tokens from `DESIGN.md`:

```txt
primary: #0066cc
primaryFocus: #0071e3
primaryOnDark: #2997ff
ink: #1d1d1f
body: #1d1d1f
bodyOnDark: #ffffff
bodyMuted: #cccccc
inkMuted80: #333333
inkMuted48: #7a7a7a
dividerSoft: #f0f0f0
hairline: #e0e0e0
canvas: #ffffff
canvasParchment: #f5f5f7
surfacePearl: #fafafc
surfaceTile1: #272729
surfaceTile2: #2a2a2c
surfaceTile3: #252527
surfaceBlack: #000000
surfaceChipTranslucent: #d2d2d7
onPrimary: #ffffff
onDark: #ffffff
```

Rules:

```txt
Use primary blue for all main interactive actions.
Do not introduce a second brand accent color.
Use status colors only for order status chips.
Use near-black surfaces for dark mode.
Use no decorative gradients.
Use no card/button/text shadows.
Allow soft shadow only on product images.
```

### Typography Tokens

Flutter should use system fonts:

```txt
fontFamily: system default, Apple-style where available
```

Recommended text styles:

```txt
heroDisplay: 56, weight 600, height 1.07
displayLarge: 40, weight 600, height 1.10
displayMedium: 34, weight 600, height 1.47
lead: 28, weight 400, height 1.14
tagline: 21, weight 600, height 1.19
bodyStrong: 17, weight 600, height 1.24
body: 17, weight 400, height 1.47
caption: 14, weight 400, height 1.43
captionStrong: 14, weight 600, height 1.29
buttonLarge: 18, weight 300, height 1.0
buttonUtility: 14, weight 400, height 1.29
finePrint: 12, weight 400, height 1.0
navLink: 12, weight 400, height 1.0
```

Mobile scaling:

```txt
Hero text can reduce to 40, 34, or 28 based on width.
Body remains readable, close to 17.
Do not scale font directly from viewport width.
```

### Spacing And Radius Tokens

Spacing:

```txt
xxs: 4
xs: 8
sm: 12
md: 17
lg: 24
xl: 32
xxl: 48
section: 80
```

Radius:

```txt
none: 0
xs: 5
sm: 8
md: 11
lg: 18
pill: 9999
full: 9999
```

### Component Tokens

Primary button:

```txt
Blue background
White text
Pill radius
Padding 11 vertical, 22 horizontal
Disabled when loading or invalid
```

Secondary button:

```txt
Transparent or white background
Blue text
Blue or soft border
Pill radius
```

Product card:

```txt
White or dark surface by theme
Hairline border
Radius 18
No card shadow
Product image centered
Product image may use one soft shadow
```

Search input:

```txt
White surface
Pill radius
Height 44
Body text style
Leading search icon
```

Sticky total bar:

```txt
Parchment or near-black surface
Subtle hairline
No drop shadow
CTA pill on right or bottom
```

Bottom navigation:

```txt
Low chrome
Small icon and label
Active color primary blue
Cart tab shows badge
```

## 3. App Architecture

Use a modular minimal structure:

```txt
lib/
  main.dart
  app.dart

  core/
    constants/
      api_constants.dart
      app_constants.dart
    helpers/
      currency_helper.dart
      date_helper.dart
      snackbar_helper.dart
    services/
      api_service.dart
      auth_service.dart
      product_service.dart
      review_service.dart
      cart_service.dart
      order_service.dart
      storage_service.dart
      notification_service.dart
      wishlist_service.dart
    theme/
      app_colors.dart
      app_text_styles.dart
      app_spacing.dart
      app_radius.dart
      app_theme.dart
    widgets/
      loading_widget.dart
      error_state_widget.dart
      empty_state_widget.dart
      product_card.dart

  models/
    user_model.dart
    product_model.dart
    category_model.dart
    cart_item_model.dart
    order_model.dart
    review_model.dart

  providers/
    auth_provider.dart
    product_provider.dart
    cart_provider.dart
    order_provider.dart
    wishlist_provider.dart
    theme_provider.dart

  features/
    splash/
      splash_page.dart
    auth/
      login_page.dart
      register_page.dart
    home/
      home_page.dart
    product/
      product_detail_page.dart
    cart/
      cart_page.dart
    checkout/
      checkout_page.dart
      order_success_page.dart
    order/
      order_history_page.dart
      order_detail_page.dart
    profile/
      profile_page.dart
    wishlist/
      wishlist_page.dart
```

Dependency direction:

```txt
Page -> Provider -> Service -> ApiService or StorageService -> API/local storage
```

Rules:

```txt
main.dart only initializes Flutter, Hive, notifications, then runs App.
app.dart registers providers and MaterialApp.
Pages do not call http directly.
Services do not contain UI code.
Providers hold UI-facing state and call services.
Models parse API/local storage data defensively.
All created/modified files include a short header doc.
```

Navigation:

```txt
Splash -> Login or Home
Login -> Home or Register
Register -> Login
Home -> Product Detail, Cart, Wishlist, Profile, Orders
Product Detail -> Cart update, Review update, Wishlist toggle
Cart -> Checkout
Checkout -> Order Success
Order Success -> Order History
Order History -> Order Detail
Profile -> Theme toggle, Logout
```

Preferred navigation implementation:

```txt
Navigator and MaterialPageRoute for minimal dependency.
No new routing dependency unless implementation proves it is necessary.
```

## 4. Module 1 - Auth And Profile

Files:

```txt
features/splash/splash_page.dart
features/auth/login_page.dart
features/auth/register_page.dart
features/profile/profile_page.dart
providers/auth_provider.dart
providers/theme_provider.dart
core/services/auth_service.dart
core/services/storage_service.dart
models/user_model.dart
```

API:

```txt
POST /auth/register
POST /auth/login
GET /auth/profile
PUT /auth/profile
```

AuthProvider state:

```txt
User? user
String? token
bool isLoading
String? errorMessage
```

AuthProvider methods:

```txt
register(name, email, password)
login(email, password)
logout()
getProfile()
updateProfile(name, phone)
checkLoginStatus()
```

Splash behavior:

```txt
Read token from SharedPreferences.
If token is missing, open Login.
If token exists, call profile API.
If valid, open Home.
If invalid or 401, clear token and open Login.
```

Register behavior:

```txt
Validate name, email, password.
POST /auth/register.
Show success or API error.
On success, navigate to Login.
```

Login behavior:

```txt
Validate email and password.
POST /auth/login.
Store access_token in SharedPreferences.
Fetch or store user data if response provides it.
Navigate to Home.
```

Profile behavior:

```txt
Show name, email, phone.
Allow editing name and phone.
PUT /auth/profile on save.
Show dark mode toggle.
Logout clears token and returns to Login.
```

Validation:

```txt
Name required.
Email must be valid.
Password minimum 6 characters.
Phone optional; if filled, should be numeric and reasonable length.
Buttons disabled while loading or invalid.
```

UI:

```txt
Auth pages use parchment background.
Forms use clean white surface with hairline border.
Inputs use pill-like Apple search/input grammar.
Primary actions use blue pill buttons.
Profile uses settings-style sections.
Logout is separated from normal profile updates.
```

Acceptance criteria:

```txt
User can register.
User can login.
Token is stored locally.
Auto-login works after app restart.
Profile appears from API.
Profile update works.
Dark mode toggle works from Profile.
Logout clears token and returns to Login.
Invalid session logs user out.
```

## 5. Module 2 - Product Catalog

Files:

```txt
features/home/home_page.dart
features/product/product_detail_page.dart
providers/product_provider.dart
models/product_model.dart
models/category_model.dart
models/review_model.dart
core/services/product_service.dart
core/services/review_service.dart
core/widgets/product_card.dart
core/widgets/loading_widget.dart
core/widgets/error_state_widget.dart
core/widgets/empty_state_widget.dart
```

API:

```txt
GET /products?search=laptop&category=<id>&sort=price_asc&page=1
GET /products/:id
GET /categories
GET /reviews/product/:productId
POST /reviews/product/:productId
POST /cart
```

ProductProvider state:

```txt
List<Product> products
List<Category> categories
Product? selectedProduct
List<Review> reviews
bool isLoading
bool isLoadingMore
String searchQuery
String selectedCategory
String selectedSort
int currentPage
bool hasMore
String? errorMessage
```

ProductProvider methods:

```txt
fetchProducts()
loadMoreProducts()
searchProducts(query)
filterByCategory(categoryId)
sortProducts(sort)
fetchProductDetail(productId)
fetchCategories()
fetchProductReviews(productId)
addReview(productId, rating, comment)
```

Product list behavior:

```txt
Load products page 1 on Home open.
Fetch categories for filter.
Search uses short debounce.
Search/filter/sort refresh page 1.
Infinite scroll loads next page while hasMore is true.
If API returns empty data for next page, set hasMore false.
```

Product detail behavior:

```txt
Fetch product detail.
Fetch product reviews.
Show product image, name, description, price, stock, category, rating, review count.
Allow add to cart.
Allow add review if logged in.
Allow wishlist toggle through WishlistProvider.
```

UI:

```txt
Home background uses parchment.
Product grid uses store utility cards.
Product card shows image, name, price in Rupiah, category, wishlist icon.
Search input is pill-shaped.
Filter and sort use pill chips or compact dropdown.
Product detail is product-first with large centered image.
CTA uses primary blue pill.
Loading list uses shimmer-style card placeholders.
Empty and error states use shared widgets.
```

Acceptance criteria:

```txt
Products appear from API.
Search works.
Category filter works.
Sorting works.
Pagination works.
Price appears in Rupiah.
Product detail appears completely.
Reviews appear.
User can add review.
User can add product to cart.
Wishlist toggle updates local state.
```

## 6. Module 3 - Cart

Files:

```txt
features/cart/cart_page.dart
providers/cart_provider.dart
models/cart_item_model.dart
core/services/cart_service.dart
```

API:

```txt
GET /cart
POST /cart
PUT /cart/:id
DELETE /cart/:id
DELETE /cart
```

CartProvider state:

```txt
List<CartItem> cartItems
bool isLoading
bool isUpdating
String? errorMessage
int totalItems
num grandTotal
```

CartProvider methods:

```txt
fetchCart()
addToCart(productId, quantity)
updateQuantity(cartItemId, quantity)
removeItem(cartItemId)
clearCart()
calculateTotal()
```

Behavior:

```txt
Fetch cart after login and when Cart tab opens.
Add to cart from product detail.
Quantity plus/minus updates API.
Minimum quantity is 1.
Remove item asks for confirmation.
Clear cart asks for confirmation.
Grand total is calculated from cart items after successful response.
Cart badge uses totalItems.
Unauthorized responses trigger logout flow.
```

Rollback rule:

```txt
If quantity update fails, restore previous quantity in UI and show error.
```

UI:

```txt
Cart page uses parchment background.
Cart item uses utility card: radius 18, hairline border, no shadow.
Product image uses small product-shadow.
Quantity control uses 44px icon buttons.
Grand total appears in sticky total bar.
Checkout CTA uses primary blue pill.
Empty cart state includes CTA back to Home.
```

Acceptance criteria:

```txt
Cart items appear from API.
Quantity can increase and decrease.
Item can be removed.
Cart can be cleared with confirmation.
Grand total is correct.
Cart badge shows item count.
Checkout disabled when cart is empty.
Empty state appears when cart is empty.
```

## 7. Module 4 - Checkout And Orders

Files:

```txt
features/checkout/checkout_page.dart
features/checkout/order_success_page.dart
features/order/order_history_page.dart
features/order/order_detail_page.dart
providers/order_provider.dart
models/order_model.dart
core/services/order_service.dart
core/services/notification_service.dart
```

API:

```txt
POST /orders
GET /orders?page=1
GET /orders/:id
```

OrderProvider state:

```txt
List<Order> orders
Order? selectedOrder
bool isLoading
bool isSubmitting
int currentPage
bool hasMore
String? errorMessage
```

OrderProvider methods:

```txt
checkout(address, note)
fetchOrders()
loadMoreOrders()
fetchOrderDetail(orderId)
```

Checkout behavior:

```txt
Use current CartProvider items as summary.
Validate shipping address.
Show confirmation dialog before submit.
POST /orders.
On success, refresh cart.
On success, show local notification.
On success, navigate to OrderSuccessPage.
On failure, stay on Checkout and show API error.
Unauthorized responses trigger logout flow.
```

Checkout validation:

```txt
Shipping address required.
Shipping address minimum 10 characters.
Note optional.
Submit disabled while loading.
```

Order history behavior:

```txt
Fetch first page on open.
Support pull refresh.
Support load more while hasMore true.
Show order number as first 8 characters from UUID.
Tap order to open detail.
```

Order detail behavior:

```txt
Fetch order by id.
Show status, shipping address, note, date, items, unit prices, subtotals, total.
Use API total if available.
Fallback to calculated item total if API total is missing.
```

Status colors:

```txt
Pending -> muted amber
Processing -> muted blue
Shipped -> muted purple
Delivered -> muted green
Cancelled -> muted red
```

The status colors are allowed exceptions to the single-accent rule because the assignment requires distinct status colors.

UI:

```txt
Checkout uses clean summary card and form sections.
Total uses sticky total bar.
Order success is minimal with headline, short body, and CTA to history.
Order history uses utility cards with status chip.
Order detail uses separated information sections with no heavy decoration.
```

Acceptance criteria:

```txt
Checkout requires valid address.
Confirmation appears before submit.
Successful checkout creates order.
Local notification appears only after successful checkout.
Order success page appears.
Order history appears.
Order pagination works.
Order status has distinct colors.
Order detail appears completely.
Order total matches items/API total.
```

## 8. Module 5 - Wishlist, Dark Mode, Notification

Files:

```txt
features/wishlist/wishlist_page.dart
providers/wishlist_provider.dart
providers/theme_provider.dart
core/services/wishlist_service.dart
core/services/notification_service.dart
core/services/storage_service.dart
```

### Wishlist

Storage:

```txt
Hive
```

Stored product snapshot:

```txt
id
name
price
imageUrl
categoryName
stock
```

WishlistProvider state:

```txt
List<Product> wishlistProducts
bool isLoading
String? errorMessage
```

WishlistProvider methods:

```txt
loadWishlist()
addWishlist(product)
removeWishlist(productId)
toggleWishlist(product)
isWishlisted(productId)
```

Wishlist behavior:

```txt
Wishlist is local only.
Toggle from product card and product detail.
Wishlist page reuses ProductCard.
Removing from wishlist updates Hive and provider state.
Data persists after app restart.
```

Wishlist UI:

```txt
Same grid language as Home.
Empty state has CTA back to Home.
Wishlist icon uses circular chip.
```

### Dark Mode

Storage:

```txt
SharedPreferences
```

ThemeProvider state:

```txt
bool isDarkMode
bool isLoading
```

ThemeProvider methods:

```txt
loadTheme()
toggleTheme()
saveTheme()
```

Dark mode behavior:

```txt
Load theme before or during App startup.
Profile toggle updates ThemeMode in realtime.
Preference persists after app restart.
Dark theme uses DESIGN.md near-black surfaces.
Dark theme keeps primary action blue.
```

### Local Notification

Package:

```txt
flutter_local_notifications
```

Initialization:

```txt
Initialize before runApp.
Create Android notification channel once.
Request permission when platform requires it.
```

Trigger:

```txt
Only after POST /orders succeeds.
```

Message:

```txt
Title: Pesanan Berhasil
Body: Pesanan kamu berhasil dibuat. Cek riwayat pesanan untuk melihat detailnya.
```

Fallback:

```txt
If permission is denied, checkout still succeeds.
If notification fails, log/debug only and do not block checkout.
```

Acceptance criteria:

```txt
Product can be added to wishlist.
Product can be removed from wishlist.
Wishlist persists after app close.
Wishlist page displays favorite products.
Dark mode toggle works.
Theme changes in realtime.
Theme preference persists.
Notification appears after checkout success.
Notification does not appear after checkout failure.
```

## 9. Core Services And Error Handling

### ApiService

Responsibilities:

```txt
Store base URL.
Wrap http get/post/put/delete.
Attach Content-Type and Authorization headers.
Apply request timeout.
Decode JSON once.
Convert API and network failures into AppException.
```

Base URL:

```txt
https://api-tb-f2wk.onrender.com/api
```

Auth header:

```txt
Authorization: Bearer <token>
Content-Type: application/json
```

AppException:

```txt
message
statusCode
isUnauthorized
```

Response mapping:

```txt
200/201 -> success
400 -> validation error message from API
401 -> unauthorized, clear token and navigate Login
403 -> forbidden message
404 -> not found message
500 -> server error message
timeout -> connection slow message
SocketException -> no internet message
unknown -> fallback message
```

Global behavior:

```txt
Loading state shows loader or shimmer.
Empty data shows EmptyStateWidget.
Recoverable error shows snackbar or ErrorStateWidget.
Unauthorized error clears token and redirects to Login.
Buttons are disabled during loading.
Failed images show placeholder.
```

### Helpers

Currency:

```txt
formatRupiah(num value)
```

Format:

```txt
Rp 12.000
```

Date:

```txt
formatDate(DateTime date)
```

Format:

```txt
28 Juni 2026
```

Snackbar:

```txt
showSuccess(context, message)
showError(context, message)
showInfo(context, message)
```

### Query And Performance Reasoning

The app does not define database queries directly. It consumes backend REST endpoints. Client-side request design still follows minimum cost:

```txt
Search/filter/sort are sent to API, not filtered over all pages locally.
Pagination fetches one page at a time.
Infinite scroll stops when hasMore is false.
Cart/order updates call exact item endpoints instead of reloading unrelated modules.
Wishlist stores only compact product snapshots locally.
Profile fetch is only used for session validation and profile page data.
```

Trade-offs:

```txt
No offline product cache keeps implementation smaller and avoids stale API data.
No local denormalized order cache avoids mismatch with backend order status.
Hive wishlist is local-only because spec does not require wishlist API sync.
```

Performance risks avoided:

```txt
Avoid fetching all products for search.
Avoid N+1 detail calls in product list.
Avoid repeated cart refetch for every local UI calculation.
Avoid blocking checkout success on notification permission.
Avoid loading all orders at once.
```

## 10. Testing Strategy

Automated tests:

```txt
currency_helper_test.dart validates Rupiah formatting.
product_model_test.dart validates ProductModel parsing with missing optional fields.
order_model_test.dart validates order total fallback and status mapping.
```

Manual API flow checklist:

```txt
Register with valid/invalid input.
Login with test account.
Restart app and confirm auto-login.
Open profile and update data.
Search products.
Filter products.
Sort products.
Open product detail.
Add review.
Add product to cart.
Update cart quantity.
Delete cart item.
Clear cart.
Checkout with invalid address.
Checkout with valid address.
Confirm notification after success.
Open order history.
Open order detail.
Toggle wishlist and restart app.
Toggle dark mode and restart app.
Logout and confirm token cleared.
```

Build checks:

```txt
flutter analyze
flutter test
flutter build apk --release
```

## 11. Implementation Phases

Phase 1 - Foundation:

```txt
Add dependencies.
Create app shell.
Create theme token files from DESIGN.md.
Create ApiService, StorageService, AppException.
Create shared loading/error/empty widgets.
Create SplashPage and bottom navigation shell.
```

Phase 2 - Auth And Profile:

```txt
UserModel.
AuthService.
AuthProvider.
LoginPage.
RegisterPage.
ProfilePage.
Token persistence.
Auto-login.
Logout.
Profile update.
```

Phase 3 - Product:

```txt
ProductModel, CategoryModel, ReviewModel.
ProductService and ReviewService.
ProductProvider.
HomePage product list.
Search/filter/sort/pagination.
ProductDetailPage.
Review list and submit.
Add to cart entry point.
```

Phase 4 - Cart:

```txt
CartItemModel.
CartService.
CartProvider.
CartPage.
Quantity update.
Remove item.
Clear cart.
Cart badge.
Checkout navigation.
```

Phase 5 - Checkout And Orders:

```txt
OrderModel.
OrderService.
OrderProvider.
CheckoutPage.
OrderSuccessPage.
OrderHistoryPage.
OrderDetailPage.
Notification trigger after checkout success.
```

Phase 6 - Extras:

```txt
Hive wishlist setup.
WishlistService.
WishlistProvider.
WishlistPage.
ThemeProvider.
Dark mode persistence.
Notification permission handling.
```

Phase 7 - Finalization:

```txt
Polish UI consistency against DESIGN.md.
Run analyze and tests.
Fix release build issues.
Write README.
Capture screenshots.
Build APK release.
Prepare demo video flow.
```

## 12. Final Acceptance Checklist

```txt
User can register.
User can login.
Token is stored.
Auto-login works.
User can logout.
User can view profile.
User can update profile.
Products appear from API.
Search works.
Category filter works.
Sorting works.
Product pagination works.
Product detail appears.
Reviews appear.
User can add review.
User can add product to cart.
Cart appears from API.
Cart quantity can be updated.
Cart item can be deleted.
Cart can be cleared.
Grand total is correct.
Checkout succeeds.
Order success page appears.
Local notification appears after checkout success.
Order history appears.
Order detail appears.
Wishlist local storage works.
Wishlist persists after restart.
Dark mode works.
Dark mode persists after restart.
UI follows DESIGN.md tokens.
flutter analyze passes.
flutter test passes.
APK release builds.
README is complete.
At least 5 screenshots are available.
Demo video is available.
```

## 13. Open Risks

```txt
API response fields may differ from assignment text.
API can be slow or unavailable because it is hosted remotely.
Notification permission behavior differs by platform and Android version.
Image URLs can be missing or invalid.
Order and cart response shape may require parser adjustment.
```

Mitigations:

```txt
Parse models defensively.
Show error and empty states instead of crashing.
Keep network timeout handling in ApiService.
Use placeholder image fallback.
Do manual API flow checks before release build.
Do not block checkout success on notification failure.
```
