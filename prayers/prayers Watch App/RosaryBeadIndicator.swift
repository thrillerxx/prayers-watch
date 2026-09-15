import SwiftUI

struct RosaryBeadIndicator: View {
    let position: RosaryBeadPosition
    var solidChrome: Bool = false
    var accentLight: Color
    var accentDark: Color
    var dimForeground: Color

    var body: some View {
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
        .frame(width: 40, height: 40)
        .background { indicatorGlassCircle }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(position.accessibilityLabel)
        .accessibilityIdentifier("RosaryBeadIndicator")
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

    private func beadDot(large: Bool, lit: Bool) -> some View {
        Circle()
            .fill(lit ? activeGold : dimForeground.opacity(large ? 0.35 : 0.28))
            .frame(width: large ? 5 : 3, height: large ? 5 : 3)
    }

    private var activeGold: Color {
        solidChrome ? accentDark : accentLight
    }
}
