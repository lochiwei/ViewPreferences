import SwiftUI

/// 🅿️ HasDefaultValue
public protocol HasDefaultValue {
    static var defaultValue: Self { get }
}

// ------------------------------------------
//     `HasDefaultValue` conforming types
// ------------------------------------------

/// 🌀 CGSize
extension CGSize: HasDefaultValue {
    public static var defaultValue: Self { .zero }
}

/// 🌀 CGRect
extension CGRect: HasDefaultValue {
    public static var defaultValue: Self { .zero }
}

// -----------------------
//     ViewPreference
// -----------------------

/// 🔸 ViewPreference
@available(macOS 10.15, *)
public enum ViewPreference {
    
    // 將有關 bounds anchor 的資訊放到 view extension methods 的參數中，
    // 盡量讓 method name 不要太長。
    public enum BoundsAnchorType {
        case first
        case last
    }
    
    /// ⭐ ViewPreference type aliases
    public typealias Size = ViewPreference.First<CGSize>
    public typealias FirstBoundsAnchor = ViewPreference.FirstNonNil<Anchor<CGRect>>
    public typealias LastBoundsAnchor  = ViewPreference.LastNonNil<Anchor<CGRect>>
    
    /// 🔸 ViewPreference.First
    public enum First<T: HasDefaultValue>: PreferenceKey {
        public typealias Value = T
        public static var defaultValue: Value { Value.defaultValue }
        public static func reduce(value: inout Value, nextValue: () -> Value) {
            // ⭐ ignore all values other than the first
        }
    }
    
    /// 🔸 ViewPreference.FirstNonNil<T>
    public enum FirstNonNil<T>: PreferenceKey {
        public typealias Value = T?
        public static var defaultValue: Value { nil }
        public static func reduce(value: inout Value, nextValue: () -> Value) {
            value = value ?? nextValue()   // nil or first non-nil value
        }
    }
    
    /// 🔸 ViewPreference.LastNonNil<T>
    public enum LastNonNil<T>: PreferenceKey {
        public typealias Value = T?
        public static var defaultValue: Value { nil }
        public static func reduce(value: inout Value, nextValue: () -> Value) {
            value = nextValue() ?? value   // nil or last non-nil value
        }
    }
}
