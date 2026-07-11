# Recipes R1–R14

Every recipe shows real code from this repo (branch `enh/swift-6`). Copy the pattern exactly. After each batch, build (see verification.md).

---

## R1 — `@MainActor` on view models and UI managers

**When:** an `ObservableObject` view model, a manager that drives UI (HUD, analytics, window/toolbar), or a class whose state is only ever touched from the main thread.

```swift
// BEFORE
final class ScreenHeaderViewModel: ObservableObject { ... }

// AFTER
@MainActor
final class ScreenHeaderViewModel: ObservableObject { ... }
```

Real examples: `Carson/classes/SwiftUI Helpers/Components/ScreenHeader/ScreenHeaderViewModel.swift`, `Carson/classes/ui/Account/Delete/DeleteAccountViewModel.swift`, `Carson/classes/managers/Progress/ProgressManager.swift`, `Carson/classes/managers/analytics/AnalyticsService.swift`, `Carson/classes/managers/Repository/UserInfoRepository.swift`.

**Pitfalls:**
- Every caller of the type's methods/init must itself be on the MainActor. If a caller now errors, fix the caller with R3 — do not remove the `@MainActor`.
- Do not add `@MainActor` to API clients, Realm models, or ObjectMapper models — those are not UI-bound (use R2/R7/opt-outs).

---

## R2 — real `Sendable` conformance on value types and stateless classes

**When:** `type 'X' does not conform to the 'Sendable' protocol` and X is an enum, a struct with only value-type/Sendable fields, or a `final class` with no mutable state (`let`-only stored properties).

```swift
// BEFORE
enum ImageDataType: Hashable, Equatable { ... }
struct InitialsViewModel {
    let text: String?
    let textAttributes: [NSAttributedString.Key: Any]?
}
final class ApiErrorCodeTransform: TransformType { ... }

// AFTER
enum ImageDataType: Hashable, Equatable, Sendable { ... }
struct InitialsViewModel: Sendable {
    let text: String?
    let textAttributes: [NSAttributedString.Key: Any & Sendable]?
}
final class ApiErrorCodeTransform: TransformType, Sendable { ... }
```

Real examples: `Carson/classes/api/Image/UIImageView+DataType.swift`, `Carson/classes/api/Errors/ApiError.Code.swift`, `Carson/classes/api/Utils/ApiErrorArrayTransform.swift` (and the other `Carson/classes/api/Utils/*Transform.swift` files).

**Pitfalls:**
- If adding `Sendable` produces new errors about a stored property, fix that property's type first (often `Any` → `Any & Sendable`, or a `var` that can become `let`).
- Never add `Sendable` to a Realm `Object` subclass or a class with `var` stored properties — that's opt-outs territory or a design problem.

---

## R3 — bridge with `Task { @MainActor in }`

**When:** a synchronous, non-isolated context (RxSwift `.do`/`.subscribe` side effect, a nonisolated function, a background callback) must call MainActor-isolated code, and the caller does NOT need the result.

```swift
// BEFORE (Carson/classes/api/Clients/UserApi.swift)
.do { userInfo in
    AnalyticsService.KeyUpdates.trackUserInfoSaltoKeyUpdate(userInfo)
}

// AFTER
.do { userInfo in
    Task { @MainActor in
        AnalyticsService.KeyUpdates.trackUserInfoSaltoKeyUpdate(userInfo)
    }
}
```

```swift
// BEFORE (Carson/classes/managers/Progress/MBProgressHUD/UIViewController+MBProgressHUD.swift)
func showProgressHUD(_ state: ProgressHUDState, dismissDelay: TimeInterval? = nil) {
    ProgressManager.showHUD(state: state, dismissDelay: dismissDelay)
}

// AFTER
func showProgressHUD(_ state: ProgressHUDState, dismissDelay: TimeInterval? = nil) {
    Task { @MainActor in
        ProgressManager.showHUD(state: state, dismissDelay: dismissDelay)
    }
}
```

**Pitfalls:**
- The wrapped code runs asynchronously (a beat later). Do NOT use R3 when the caller needs the result synchronously or ordering matters — instead mark the calling function `@MainActor` (R1/R4).
- Do NOT wrap code that is already on the MainActor (e.g. inside `application(_:didFinishLaunching…)` or a `@MainActor` type) — call it directly.
- Values captured by the closure must be Sendable — capture `let` copies before the `Task` if needed (R6).

---

## R4 — `@MainActor` on protocol conformances and extensions

**When:** `…cannot be used to satisfy nonisolated protocol requirement` or `conformance of 'X' to protocol 'Y' crosses into main actor-isolated code`, and the conforming type is a UIKit/SwiftUI type.

```swift
// BEFORE
extension UILabel: XIBLocalizable { ... }
final class BmxAuthViewController: UIViewController, ProgressHudPresenter, BackButtonHandlerProtocol
extension CircleActionButton: Equatable { ... }

// AFTER — isolate the conformance itself
extension UILabel: @MainActor XIBLocalizable { ... }
final class BmxAuthViewController: UIViewController, ProgressHudPresenter, @MainActor BackButtonHandlerProtocol
extension CircleActionButton: @MainActor Equatable { ... }
```

Real examples: `Carson/classes/extensions/Localizable/Localizable.swift` (15 UIKit extensions), `Carson/classes/ui/Authentication/BmxAuthViewController.swift`, `Carson/classes/SwiftUI Helpers/Components/CircleActionButton.swift`.

For a single computed property in a `Reactive` extension, annotate just the member:

```swift
extension Reactive where Base: BackgroundManager {
    @MainActor
    var tasksCount: Observable<Int> { ... }
}
```

**Pitfalls:**
- `@MainActor` conformances require every use of the protocol requirement to be on the MainActor. If a non-main call site errors afterwards, the NEXT build reports `main actor-isolated conformance of 'X' to 'Y' cannot be used in nonisolated context [#IsolatedConformances]` at that call site — fix the caller (R1/R3), don't remove the conformance isolation.
- When a class both is `@MainActor` and declares conformances inline, BOTH annotations are needed: `@MainActor final class AuthCoordinator: @MainActor BaseCoordinatorProtocol, ClassName { … }`. Annotate only the protocols the compiler names; leave trivial ones (`ClassName`) unannotated — marking `ClassName` `@MainActor` breaks `deinit { LogsManager.logDeiniting(self) }`.
- The compiler names ONE protocol per error even when several in the list need it. If the flagged protocol *inherits* others (`protocol A: B, C`), annotating `A` covers `B`/`C` too — do not hunt for them separately.
- For a delegate protocol, check which queue the SDK actually calls back on before choosing `@MainActor` vs `nonisolated`: `CBCentralManager(delegate:queue: nil)` → main queue → `@MainActor` is correct; `AVCaptureVideoDataOutput` with a custom `DispatchQueue(label:)` → background → the conformance methods must stay `nonisolated` and bridge inward with R3.

---

## R5 — Sendable payload dictionaries (`[AnyHashable: Any & Sendable]` / `RouteParameters`)

**When:** coordinator routing or push-notification payloads (`userInfo`) fail Sendable checks crossing into MainActor code.

```swift
// BEFORE
func activate(_ screen: AppScreen?, userInfo: [AnyHashable: Any]?, animated: Bool)
func finish(_ screen: AppScreen?, userInfo: [AnyHashable: Any]?, animated: Bool)

// AFTER (current state of Carson/classes/ui/Base/Coordinator.swift)
func activate(_ screen: AppScreen?, userInfo: RouteParameters?, animated: Bool)
func finish(_ screen: AppScreen?, userInfo: RouteParameters?, animated: Bool)
```

`RouteParameters` is defined in `Carson/classes/ui/Main/ScreenRoute.swift` and is exactly the Sendable dictionary:

```swift
public typealias RouteParameters = [AnyHashable: any RouteValue]
public typealias RouteValue = AnySendableValue
public typealias AnySendableValue = Any & Sendable
```

Prefer `RouteParameters` in coordinator/routing code; spell out `[AnyHashable: Any & Sendable]` only where the typealias is not visible (e.g. push payloads outside the routing layer).

Same change applies to `extraViewControllers(for:userInfo:)` (`Carson/classes/ui/Base/BaseCoordinator.swift`), `handleRemoteNotification(_:)` / `handleNotification(_:)` (`Carson/classes/AppCoordinator.swift`, `Carson/classes/managers/Notifications/PushManager.swift`, every `ActiveScreenViewModelProtocol` implementer), and local `let userInfo: [AnyHashable: Any & Sendable] = [...]` literals.

**Pitfall — batch rule:** changing the protocol breaks every conforming coordinator (~40 files). Grep for the old signature and update ALL of them in the same batch, then build once:
`grep -rln "userInfo: \[AnyHashable: Any\]?" Carson/classes`

---

## R6 — make the crossing value itself Sendable

**When:** `sending 'x' risks causing data races` or a non-Sendable value is captured/passed across a boundary, and R2 on its type isn't appropriate.

Techniques, in order:
1. **Capture an immutable copy before the closure:** `let title = model.title` then use `title` inside the `Task`/closure instead of `model`.
2. **Replace a mutable/isolated default with a constant:**

```swift
// BEFORE (Carson/classes/extensions/Rx/ThrottledTap+Carson.swift)
func throttledTap(_ dueTime: RxTimeInterval = RxUtilsDefaults.tapThrottle) -> ControlEvent<Void>
// AFTER
func throttledTap(_ dueTime: RxTimeInterval = Timing.tapThrottleInterval) -> ControlEvent<Void>

// BEFORE (UIViewController+MBProgressHUD.swift) — MainActor-isolated default value
func hideProgressHUD(animated: Bool = UIApplication.isAnimationEnabled)
// AFTER
func hideProgressHUD(animated: Bool = true)
```

3. **Extract primitive fields** (Int/String ids) and pass those instead of the whole object — mandatory for Realm objects.

---

## R7 — static mutable state

**When:** `static property '…' is not concurrency-safe because it is nonisolated global shared mutable state`.

Try in order:
1. `static var` → `static let` if it is never reassigned:

```swift
// BEFORE (Carson/classes/SwiftUI Helpers/Extensions/Animation+Extentions.swift)
static var carsonStandard: Animation = .easeInOut(duration: Timing.animationDurationStandard)
// AFTER
static let carsonStandard: Animation = .easeInOut(duration: Timing.animationDurationStandard)
```

2. If it is a `let` but its type is not Sendable → make the type Sendable (R2), or move the property into a `@MainActor` type if UI-bound (R1).
3. If genuinely immutable-in-practice but the compiler can't prove it → `nonisolated(unsafe)` with a justification comment (see opt-outs.md):

```swift
// AFTER (Carson/classes/api/Errors/ApiError.Code.swift)
final class ApiErrorCodeTransform: TransformType, Sendable {
    nonisolated(unsafe) static let shared = ApiErrorCodeTransform()
}
```

---

## R8 — wrap legacy completion handlers with continuations

**When:** new async code must call an old completion-handler API (SDK callbacks etc.). Do NOT retrofit this onto working RxSwift code — Rx stays Rx.

```swift
func unlockDoor(id: Int) async throws -> UnlockResult {
    try await withCheckedThrowingContinuation { continuation in
        legacyUnlock(id: id) { result, error in
            if let error {
                continuation.resume(throwing: error)
            } else {
                continuation.resume(returning: result)
            }
        }
    }
}
```

**Rules:** resume exactly once on every path; route any UI update after the `await` through `await MainActor.run { ... }` or a `@MainActor` function.

---

## R9 — `DateFormatter` subclasses

**When:** a formatter subclass fails Sendable checks. Formatters here are configured once at init and only read afterwards.

```swift
// AFTER (Carson/classes/extensions/Foundation/DateFormatter+Carson.swift)
final class MessageDateFormatter: DateFormatter, @unchecked Sendable { ... }
```

Add `@unchecked Sendable` to the subclass declaration; do not restructure the formatter.

---

## R10 — Alamofire `Parameters` typealias

**When:** errors around Alamofire's `Parameters` (`[String: Any]` without Sendable) in the network framework.

The project already defines its own alias — use it instead of Alamofire's:

```swift
// Current state of Carson/classes/api/NetworkFramework/API/APIRequest.swift
typealias APIParameters = [String: any Any] // Parameters from alamofire is Sendable, but Object Mapper is not support Sendable yet -> So we use own type without Sendable

// BEFORE
typealias SetParameters = (inout Parameters) -> Void
@Lazy private(set) var query: Parameters?
// AFTER
typealias SetParameters = (inout APIParameters) -> Void
@Lazy private(set) var query: APIParameters?
```

Semantics are identical; this only removes the dependency on Alamofire's `Parameters` alias, which conflicts with ObjectMapper's lack of Sendable support.

---

## R11 — `nonisolated(unsafe) let` rebind before a closure boundary

**When:** `sending 'x' risks causing data races`, `sending value of non-Sendable type '…' risks causing data races`, or `task or actor-isolated value cannot be sent` — a non-Sendable value (captured object, function parameter, loop variable, closure, or `self`) crosses into a `Task { }`, a nested Rx closure, or a `MainActor.assumeIsolated { }` block, and R1/R2/R6 don't apply. This was the single most-used recipe in the late phase of the Carson migration.

Rebind the value to a `nonisolated(unsafe) let` local IMMEDIATELY before the closure that "sends" it, then use the rebound name inside:

```swift
// Nested Rx closures re-capturing an outer capture (DocumentListViewModel.swift)
.flatMap { [weak self, api, realm, coordinator] result -> Maybe<Bool> in
    nonisolated(unsafe) let api = api
    nonisolated(unsafe) let realm = realm
    // inner .flatMap closures below may now use api/realm freely
    ...
}

// SDK completion handler bridging self + result into a Task (ButterflyMxApi.swift)
BMXCoreKit.shared.authorize(withAuthProvider: auth) { [weak self] result in
    nonisolated(unsafe) let selfRef = self
    nonisolated(unsafe) let result = result
    Task { @MainActor in
        selfRef?.isLoggedIn.accept(...)
    }
}

// Loop variable captured by a Quick DSL closure (OCRScanner_Spec.swift)
for testCase in successfulRecipients {
    nonisolated(unsafe) let testCase = testCase
    itOnce("...") { ... uses testCase ... }
}

// Rx observer callback captured by an inner Task/completion (FIRMessaging+Rx.swift and ~8 other files)
Single<String>.create { observer in
    nonisolated(unsafe) let observer = observer
    someSDK.call { result in
        Task { @MainActor in observer(.success(result)) }
    }
    return Disposables.create()
}
```

**Why it's safe here:** these values are only ever used on one thread at a time (Rx chains on `ConcurrentMainScheduler`, one-shot SDK completions, sequential test setup); the region checker just can't prove it across the nested-closure hop.

**Pitfalls:**
- Rebinding `self` kills implicit-`self` inside the closure. `#selector(onCallTimeout)` then errors with `implicit use of 'self' in closure` — qualify it: `#selector(BMXCallHandler.onCallTimeout)`.
- Do NOT use `[weak self]` (or `[x]`) on the `Task`'s own capture list AND a rebind together — capture nothing on the Task and reference only the rebound local.
- `Task { @MainActor [command] in … }` (capturing a Sendable value copy in the capture list) is a lighter alternative when the value's TYPE is Sendable but the compiler flags a captured `var` — prefer that over a rebind (see `RxSwift+Progress.swift`).
- Fix ONE value per error message; the next build may flag a sibling value in the same closure (`api` first, `realm` next). That's normal — rebind each as reported.

---

## R12 — `deinit` touching non-Sendable stored properties

**When:** `cannot access property '…' with a non-Sendable type '…' from nonisolated deinit`, or a `deinit` calls a `@MainActor` method. `deinit` is ALWAYS nonisolated by default, even in a `@MainActor` class.

**Option A — `isolated deinit` (preferred).** Works when the class is a ROOT Swift class (no `NSObject`/UIKit superclass; protocol conformances are fine) and is `@MainActor`-isolated:

```swift
// Carson/classes/ui/Buttons/PropertyButton/PropertyViewModel.swift
@MainActor final class PropertyViewModel: ClassName {
    isolated deinit {
        revertBuildingIdSelectionIfNeeded()   // @MainActor method — OK in isolated deinit
        LogsManager.logDeiniting(self)
    }
}

// Carson Unit Tests/…/SearchBarViewModel.swift
isolated deinit { subscribers.removeAll() }   // Set<AnyCancellable>

// Carson/classes/ui/Dashboard/DashboardViewModel.swift
isolated deinit { if let appNotificationToken { NotificationCenter.default.removeObserver(appNotificationToken) } }
```

**Option B — extract values, then a `Task` that does NOT capture `self`.** Required when the class has a non-root superclass (NSObject/UIView/…), where `isolated deinit` is unavailable. Capturing `self` strongly in an escaping Task from deinit would resurrect a partially-deallocated object — copy out only what's needed:

```swift
// Carson/classes/ui/Custom/FlowSnackbar/FlowSnackbar.swift
deinit {
    let tagsToRemove = Set(scheduledItems.map { $0.tag })   // plain value copy is fine
    Task { @MainActor in
        let contentView = Self.contentView   // @MainActor statics must be read INSIDE the Task
        ...cleanup using tagsToRemove/contentView, never self...
    }
}
```

**Pitfall:** in Option B, reading a `@MainActor` static in the deinit body itself also errors — move the read inside the `Task`.

---

## R13 — `MainActor.assumeIsolated` + `UncheckedSendableBox`

**When:** synchronous code is genuinely ON the main thread but the compiler can't see it (Rx chains subscribed on `ConcurrentMainScheduler`, Quick test bodies, `Thread.isMainThread`-guarded paths), and it must touch `@MainActor` state — R3's async hop would break ordering or a needed return value.

```swift
// Simple case — perform isolated work synchronously (UserApi.swift)
.do { userInfo in
    // perform(_:retry:) defaults to ConcurrentMainScheduler, so this observer is on main.
    nonisolated(unsafe) let userInfo = userInfo   // R11 for the crossing value
    MainActor.assumeIsolated {
        AnalyticsService.KeyUpdates.trackUserInfoSaltoKeyUpdate(userInfo)
    }
}
```

`assumeIsolated`'s closure RETURN type must be Sendable. When you need a non-Sendable result out, box it:

```swift
// Carson/classes/extensions/Rx/RxSwift+Resubscribe.swift, DebugViewController.swift, PaginatedFetcher_Spec.swift
private struct UncheckedSendableBox<T>: @unchecked Sendable { let value: T }

let observable = MainActor.assumeIsolated {
    UncheckedSendableBox(value: UIApplication.shared.rx.didLeaveBackground)
}.value   // unwrapped immediately, same thread — never actually shared
```

**Pitfalls:**
- `assumeIsolated` CRASHES at runtime if actually off-main — only use where main-thread execution is guaranteed by a scheduler/subscription contract, and say which one in a comment.
- To build a MainActor value from a background thread synchronously, `DispatchQueue.main.sync` no longer works either (its generic return also requires Sendable) — use `DispatchQueue.main.async` + `DispatchQueue` semaphore + `nonisolated(unsafe) var result` (see `RxSwift+Resubscribe.swift`).

---

## R14 — Quick/Nimble test-target playbook

**When:** any Swift 6 error inside `Carson Unit Tests/**/_Spec.swift` (or an equivalent Quick-based test target).

**Hard constraint:** `QuickSpec.spec()` is declared `open class func spec() {}` (nonisolated) in the Quick package. You CANNOT mark the override or the spec class `@MainActor` — Swift forbids overriding a nonisolated method with an isolated one. All fixes go inside.

Apply in this order:

1. **Shared setup helper → wrap its whole body once.** Most specs funnel MainActor-touching setup through one `private static func setupXxxViewController(...)`. Wrap that body in `MainActor.assumeIsolated { … }` (R13) — one edit fixes every call site. Tests run on main, so the assume is safe.
2. **No helper → wrap the inline closure body** (`activate:`, `getVC:`, `it`/`itOnce` body). A closure that must RETURN a value works too: `nonisolated(unsafe) let scheduler = scheduler` then `return MainActor.assumeIsolated { … return UIHostingController(...) }`.
3. **Static fixtures/mock data** (`static let mocked… = X.mockedArray(...)`) → `nonisolated(unsafe)` (opt-outs §4).
4. **Loop variables / parameters flagged as "sending"** → R11 rebind before the DSL closure.
5. **Shared `Utils`/`Environment` enums** whose members are all main-thread test plumbing → `@MainActor` on the whole enum is fine (they're not QuickSpec subclasses); keep truly nonisolated members (`ProcessInfo` reads) explicitly `nonisolated`.

**Tooling trap:** SwiftLint 0.51's parser predates `nonisolated(unsafe)` — `private nonisolated(unsafe) static let` makes `test_case_accessibility` false-positive as error. Required order is `nonisolated(unsafe) private static let`, but SwiftFormat's `modifierOrder` flips it back. See hard-cases.md §Tooling for the directive dance.
