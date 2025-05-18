import Foundation

final class SafeCallback {
    private var isCalled = false
    private let lock = NSLock()

    func call(_ block: () -> Void) {
        lock.lock()
        defer { lock.unlock() }
        guard !isCalled else { return }
        isCalled = true
        block()
    }
}
