import Foundation

final class SafeCallback {
    private var isCalled = false
    private let lock = NSLock()

    func call(_ block: () -> Void) {
        lock.lock()
        guard !isCalled else {
            lock.unlock()
            return
        }
        isCalled = true
        lock.unlock()
        block()
    }
}
