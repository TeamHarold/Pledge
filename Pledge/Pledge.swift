import Foundation

public class Pledge<T> {
    private var _semaphore = DispatchSemaphore(value: 0)
    private var _timeout: Double
    
    private var _block: () -> Void = { }
    private var _currentItem: DispatchWorkItem?
    private var _resolve: ((T) -> Void)?
    private var _reject: ((T) -> Void)?
    private var _finally: ((T) -> Void)?
    
    private var _returnedValue: Any?
    var returnedValue: T? {
        get {
            return _returnedValue as! T?
        }
    }
    
    private lazy var resolve: ((T) -> Void) = { arg in
        self._returnedValue = arg
        self._resolve?(arg)
        self._finally?(arg)
        self._semaphore.signal()
    }
    
    private lazy var reject: ((T) -> Void) = { arg in
        self._returnedValue = arg
        self._reject?(arg)
        self._finally?(arg)
        self._semaphore.signal()
    }
    
    init<T>(timeout: Double = 30.0, _ handler: @escaping ((T) -> Void, (T) -> Void) -> Void){
        self._timeout = timeout
        _block = { handler(self.resolve as! (T)->Void, self.reject as! (T)->Void) }
        _currentItem = DispatchWorkItem(qos: .background, flags: .barrier, block: _block)
    }
    
    public func await() -> T? {
        _currentItem = DispatchWorkItem(qos: .background, flags: .barrier, block: _block)
        DispatchQueue.global().async(execute: _currentItem!)
        _ = _semaphore.wait(timeout: DispatchTime.now() + _timeout)
        return returnedValue
    }
    
    func then(_ cb: @escaping (T)->Void) -> Pledge {
        _currentItem?.cancel()
        _resolve = cb
        _currentItem = DispatchWorkItem(qos: .background, flags: .barrier, block: _block)
        DispatchQueue.global().async(execute: _currentItem!)
        return self
    }
    
    func err(_ cb: @escaping (T)->Void) -> Pledge {
        _currentItem?.cancel()
        _reject = cb
        _currentItem = DispatchWorkItem(qos: .background, flags: .barrier, block: _block)
        DispatchQueue.global().async(execute: _currentItem!)
        return self
    }
    
    func finally(_ cb: @escaping (T?)->Void){
        _currentItem?.cancel()
        _finally = cb
        _currentItem = DispatchWorkItem(qos: .background, flags: .barrier, block: _block)
        DispatchQueue.global().async(execute: _currentItem!)
    }
}
