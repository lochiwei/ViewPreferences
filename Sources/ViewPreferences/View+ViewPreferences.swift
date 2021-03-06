//
//  View+ViewPreferences.swift
//  
//
//  Created by CHI-WEI LO on 2022/1/14.
//

import SwiftUI

/// ð View + ViewPreference
@available(iOS 13.0, macOS 12.0, *)
extension View {
    
    /// â­ usage: `view.actOnSelfSize { size in ... }`
    public func actOnSelfSize(
        action: @escaping (CGSize) -> Void
    ) -> some View
    {
        // ä¸è¬ç view ä¸¦ä¸ç¥éèªå·±ç size è³è¨ï¼ä½ä½¿ç¨ï¼
        // `.background(GeometryReader{ geo in Color.clear })`
        // å°±å¯ä»¥å¨ä¸å½±é¿èªå·±çä½å±èå¤è§ä¸ï¼éé `geo` (GeometryProxy) ç©ä»¶
        // å¾ç¥èªå·±ç size (geo.size)ï¼ç¶å¾ç¨ .preference() åå ±ä¸å±¤ã
        self.background( GeometryReader { geo in
            Color.clear
                // â­ ä¸å±¤åå ±èªå·±ç size
                .preference(key: ViewPreference.Size.self, value: geo.size)
        })
        // â­ ä¸å±¤å¾ç¥ sizeï¼ä¸¦ç¨ `action` èçã
        .onPreferenceChange(ViewPreference.Size.self, perform: action)
    }
    
    // â­ local abbreviations
    typealias FBA = ViewPreference.FirstBoundsAnchor
    typealias LBA = ViewPreference.LastBoundsAnchor
    
    // ---------------------------------
    // ä¸å±¤åå ±è³æçãæ¹æ³å½åååãï¼
    // 1. å¦æåªæ¶éå¶ä¸­ä¸åï¼ç¨ï¼report...()
    // 2. å¦ææ¶éå¾å¤åï¼å°±ç¨ï¼collect...()
    // ----------------------------------
    
    /// â­ report bounds anchor (with anchor type)
    ///    (used when multiple child views report their bounds)
    @ViewBuilder public func report(
        bounds anchorType: ViewPreference.BoundsAnchorType
    ) -> some View {
        switch anchorType {
        case .first:
            // â­ åå ± anchor preference
            anchorPreference(key: FBA.self, value: .bounds) { $0 }
        //                        â°â 1 âââ¯         â°ââ2âââ¯  â°â3âââ¯
        // 1. è¦åå ±ç anchor preference (K = FirstBoundsAnchor)
        // 2. è¦åå ±ç anchor ç¨®é¡ (.bounds)
        // 3. å° Anchor<A> è½çºè¦åå ±çè³æï¼ @escaping (Anchor<A>) -> K.Value
        //    å¦æ Anchor<A> æ¬èº«å°±æ¯è¦åå ±çè³æ (K.Value)ï¼ç´æ¥ä½¿ç¨ `$0` å°±å¯ä»¥ã
        case .last:
            anchorPreference(key: LBA.self, value: .bounds) { $0 }
        }
    }
    
    /// â­ report bounds anchor
    ///    (used when only one child view reports its bounds)
    public func reportBounds() -> some View {
        // â­ åå ± anchor preference
        anchorPreference(key: FBA.self, value: .bounds) { $0 }
        //                    â°â 1 âââ¯         â°ââ2âââ¯  â°â3âââ¯
        // 1. è¦åå ±ç anchor preference (K = FirstBoundsAnchor)
        // 2. è¦åå ±ç anchor ç¨®é¡ (.bounds)
        // 3. å° Anchor<A> è½çºè¦åå ±çè³æï¼ @escaping (Anchor<A>) -> K.Value
        //    å¦æ Anchor<A> æ¬èº«å°±æ¯è¦åå ±çè³æ (K.Value)ï¼ç´æ¥ä½¿ç¨ `$0` å°±å¯ä»¥ã
    }
    
    /// â­ background by reported bounds (with anchor type)
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
    
    /// â­ background by reported bounds
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
    
    /// â­ act on bounds reported
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
