import Testing
import CoreGraphics
@testable import FineTune

struct SettingsWindowPositionerTests {
    @Test func centersWindowInsideVisibleFrame() {
        let visibleFrame = CGRect(x: 100, y: 50, width: 1600, height: 900)
        let origin = SettingsWindowPositioner.centeredOrigin(
            windowSize: CGSize(width: 720, height: 560),
            visibleFrame: visibleFrame
        )

        #expect(origin == CGPoint(x: 540, y: 220))
    }

    @Test func clampsOversizedWindowToVisibleOrigin() {
        let visibleFrame = CGRect(x: -1400, y: 25, width: 1200, height: 800)
        let origin = SettingsWindowPositioner.centeredOrigin(
            windowSize: CGSize(width: 1400, height: 900),
            visibleFrame: visibleFrame
        )

        #expect(origin == visibleFrame.origin)
    }
}
