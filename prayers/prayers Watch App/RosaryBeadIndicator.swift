import SwiftUI

struct RosaryBeadIndicator: View {
    let position: RosaryBeadPosition
    var solidChrome: Bool = false
    var accentLight: Color
    var accentDark: Color
    var dimForeground: Color

    #if DEBUG
    @AppStorage(RosaryBeadIndicatorStyle.storageKey) private var styleRaw: String = RosaryBeadIndicatorStyle.decadeStrip.rawValue
    #endif

    var body: some View {
        Group {
            switch resolvedStyle {
            case .decadeStrip:
                decadeStripStyle
            case .chainGlyph:
                chainGlyphStyle
            case .medallion:
                medallionStyle
            }
        }
        .frame(width: 40, height: 40)
        .background { indicatorGlassCircle }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(position.accessibilityLabel)
        .accessibilityIdentifier("RosaryBeadIndicator")
        #if DEBUG
        .onLongPressGesture(minimumDuration: 0.6) {
            RosaryBeadIndicatorStyle.cycleNext()
            styleRaw = RosaryBeadIndicatorStyle.current.rawValue
        }
        #endif
    }

    private var resolvedStyle: RosaryBeadIndicatorStyle {
        #if DEBUG
        RosaryBeadIndicatorStyle(rawValue: styleRaw) ?? .decadeStrip
        #else
        .decadeStrip
        #endif
    }

    private var indicatorGlassCircle: some View {
        Circle()
            .fill(solidChrome ? Color.primary.opacity(0.14) : Color.clear)
            .background(.ultraThinMaterial, in: Circle())
            .overlay {
                Circle()
                    .stroke(
                        solidChrome ? Color.primary.opacity(0.22) : accentLight.opacity(0.45),
                        lineWidth: 0.5
                    )
            }
    }

    // MARK: - Style A: decade strip

    private var decadeStripStyle: some View {
        Group {
            switch position.phase {
            case .opening(let bead):
                openingStrip(bead: bead)
            case .decade(let bead):
                decadeStrip(bead: bead)
            case .closing:
                closingStrip
            }
        }
    }

    private func openingStrip(bead: RosaryBeadPosition.OpeningBead) -> some View {
        HStack(spacing: 2) {
            beadDot(large: true, lit: bead == .largeOurFather)
            ForEach(0..<3, id: \.self) { i in
                let lit: Bool = {
                    switch bead {
                    case .intention, .smallFaith: return i == 0
                    case .smallHope: return i == 1
                    case .smallCharity: return i == 2
                    default: return false
                    }
                }()
                beadDot(large: false, lit: lit)
            }
        }
        .overlay(alignment: .leading) {
            if bead == .crucifix {
                Image(systemName: "cross.fill")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(activeGold)
            }
        }
    }

    private func decadeStrip(bead: RosaryBeadPosition.DecadeBead) -> some View {
        VStack(spacing: 1) {
            beadDot(large: true, lit: {
                if case .ourFather = bead { return true }
                return false
            }())
            HStack(spacing: 1) {
                ForEach(1...5, id: \.self) { n in
                    hailMaryDot(bead: bead, n: n)
                }
            }
            HStack(spacing: 1) {
                ForEach(6...10, id: \.self) { n in
                    hailMaryDot(bead: bead, n: n)
                }
            }
            if case .meditation(let d) = bead {
                Text("\(d)")
                    .font(.system(size: 7, weight: .bold))
                    .foregroundStyle(dimForeground.opacity(0.85))
            } else if case .gloryBe = bead {
                Text("G")
                    .font(.system(size: 7, weight: .bold))
                    .foregroundStyle(activeGold)
            } else if case .fatima = bead {
                Text("F")
                    .font(.system(size: 7, weight: .bold))
                    .foregroundStyle(activeGold)
            }
        }
    }

    private func hailMaryDot(bead: RosaryBeadPosition.DecadeBead, n: Int) -> some View {
        beadDot(large: false, lit: {
            if case .hailMary(_, let num) = bead { return num == n }
            return false
        }())
    }

    private var closingStrip: some View {
        Image(systemName: "flag.checkered")
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(dimForeground.opacity(0.75))
    }

    // MARK: - Style B: chain glyph

    private var chainGlyphStyle: some View {
        ZStack {
            chainPath
                .stroke(dimForeground.opacity(0.35), lineWidth: 1)
            chainHighlight
        }
        .padding(4)
    }

    private var chainPath: Path {
        var path = Path()
        let w: CGFloat = 32
        let h: CGFloat = 28
        path.move(to: CGPoint(x: w * 0.12, y: h * 0.92))
        path.addLine(to: CGPoint(x: w * 0.12, y: h * 0.55))
        for i in 0..<5 {
            let cx = w * (0.22 + CGFloat(i) * 0.14)
            path.addArc(
                center: CGPoint(x: cx, y: h * 0.42),
                radius: 4,
                startAngle: .degrees(200),
                endAngle: .degrees(-20),
                clockwise: true
            )
        }
        return path
    }

    @ViewBuilder
    private var chainHighlight: some View {
        let segment = chainSegmentIndex
        Circle()
            .fill(activeGold)
            .frame(width: 5, height: 5)
            .offset(chainHighlightOffset(segment: segment))
    }

    private var chainSegmentIndex: Int {
        switch position.phase {
        case .opening: return 0
        case .decade(let bead):
            switch bead {
            case .meditation(let d): return d
            case .ourFather(let d): return d
            case .hailMary(let d, _): return d
            case .gloryBe(let d): return d
            case .fatima(let d): return d
            }
        case .closing: return 6
        }
    }

    private func chainHighlightOffset(segment: Int) -> CGSize {
        if segment == 0 {
            return CGSize(width: -12, height: 10)
        }
        if segment >= 6 {
            return CGSize(width: 12, height: -8)
        }
        let x = -8 + CGFloat(segment) * 5.5
        return CGSize(width: x, height: -4)
    }

    // MARK: - Style C: medallion + numeric

    private var medallionStyle: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [accentLight, accentDark],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 28, height: 28)
            Text(position.compactLabel)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(Color.black.opacity(0.82))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }
    }

    private func beadDot(large: Bool, lit: Bool) -> some View {
        Circle()
            .fill(lit ? activeGold : dimForeground.opacity(large ? 0.35 : 0.28))
            .frame(width: large ? 5 : 3, height: large ? 5 : 3)
    }

    private var activeGold: Color {
        solidChrome ? accentDark : accentLight
    }
}
