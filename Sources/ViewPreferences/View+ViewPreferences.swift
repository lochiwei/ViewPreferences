//
//  View+ViewPreferences.swift
//  
//
//  Created by CHI-WEI LO on 2022/1/14.
//

import SwiftUI

/// 🌀 View + ViewPreference
@available(macOS 12.0, *)
extension View {
    
    /// ⭐ usage: `view.actOnSelfSize { size in ... }`
    public func actOnSelfSize(
        action: @escaping (CGSize) -> Void
    ) -> some View
    {
        // 一般的 view 並不知道自己的 size 資訊，但使用：
        // `.background(GeometryReader{ geo in Color.clear })`
        // 就可以在不影響自己的佈局與外觀下，透過 `geo` (GeometryProxy) 物件
        // 得知自己的 size (geo.size)，然後用 .preference() 回報上層。
        self.background( GeometryReader { geo in
            Color.clear
                // ⭐ 下層回報自己的 size
                .preference(key: ViewPreference.Size.self, value: geo.size)
        })
        // ⭐ 上層得知 size，並用 `action` 處理。
        .onPreferenceChange(ViewPreference.Size.self, perform: action)
    }
    
    // ⭐ local abbreviations
    typealias FBA = ViewPreference.FirstBoundsAnchor
    typealias LBA = ViewPreference.LastBoundsAnchor
    
    // ---------------------------------
    // 下層回報資料的「方法命名原則」：
    // 1. 如果只收集其中一個，用：report...()
    // 2. 如果收集很多個，就用：collect...()
    // ----------------------------------
    
    /// ⭐ report bounds anchor (with anchor type)
    ///    (used when multiple child views report their bounds)
    @ViewBuilder public func report(
        bounds anchorType: ViewPreference.BoundsAnchorType
    ) -> some View {
        switch anchorType {
        case .first:
            // ⭐ 回報 anchor preference
            anchorPreference(key: FBA.self, value: .bounds) { $0 }
        //                        ╰─ 1 ──╯         ╰──2──╯  ╰─3──╯
        // 1. 要回報的 anchor preference (K = FirstBoundsAnchor)
        // 2. 要回報的 anchor 種類 (.bounds)
        // 3. 將 Anchor<A> 轉為要回報的資料： @escaping (Anchor<A>) -> K.Value
        //    如果 Anchor<A> 本身就是要回報的資料 (K.Value)，直接使用 `$0` 就可以。
        case .last:
            anchorPreference(key: LBA.self, value: .bounds) { $0 }
        }
    }
    
    /// ⭐ report bounds anchor
    ///    (used when only one child view reports its bounds)
    public func reportBounds() -> some View {
        // ⭐ 回報 anchor preference
        anchorPreference(key: FBA.self, value: .bounds) { $0 }
        //                    ╰─ 1 ──╯         ╰──2──╯  ╰─3──╯
        // 1. 要回報的 anchor preference (K = FirstBoundsAnchor)
        // 2. 要回報的 anchor 種類 (.bounds)
        // 3. 將 Anchor<A> 轉為要回報的資料： @escaping (Anchor<A>) -> K.Value
        //    如果 Anchor<A> 本身就是要回報的資料 (K.Value)，直接使用 `$0` 就可以。
    }
    
    /// ⭐ background by reported bounds (with anchor type)
    ///    (used when multiple child views report their bounds)
    @ViewBuilder public func background<V: View>(
        bounds anchorType: ViewPreference.BoundsAnchorType,
        @ViewBuilder content:  @escaping (CGRect) -> V
    ) -> some View
    {
        switch anchorType {
        case .first:
            backgroundPreferenceValue(FBA.self) { anchor in
                GeometryReader { geo in
                    if let anchor = anchor { content(geo[anchor]) }
                }
            }
        case .last:
            backgroundPreferenceValue(LBA.self) { anchor in
                GeometryReader { geo in
                    if let anchor = anchor { content(geo[anchor]) }
                }
            }
        }
    }
    
    /// ⭐ background by reported bounds
    ///    (used when only one child view reports its bounds)
    public func backgroundByBounds<V: View>(
        @ViewBuilder content:  @escaping (CGRect) -> V
    ) -> some View
    {
        backgroundPreferenceValue(FBA.self) { anchor in
            GeometryReader { geo in
                if let anchor = anchor { content(geo[anchor]) }
            }
        }
    }
    
    /// ⭐ act on bounds reported
    ///    (used when multiple child views report their bounds)
    @ViewBuilder public func actOnBounds(
        _ anchorType: ViewPreference.BoundsAnchorType,
        action: @escaping (Anchor<CGRect>) -> Void
    ) -> some View
    {
        switch anchorType {
        case .first:
            onPreferenceChange(FBA.self) { anchor in
                if let anchor = anchor { action(anchor) }
            }
        case .last:
            onPreferenceChange(LBA.self) { anchor in
                if let anchor = anchor { action(anchor) }
            }
        }
    }
}
