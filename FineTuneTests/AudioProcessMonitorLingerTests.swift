import AppKit
import AudioToolbox
import Testing
@testable import FineTune

@Suite("Audio process monitor linger")
@MainActor
struct AudioProcessMonitorLingerTests {
    @Test("New apps appear immediately")
    func additionsAreImmediate() {
        let monitor = AudioProcessMonitor(removalLingerDuration: .milliseconds(50))
        let app = makeApp(pid: 101, objectID: 201)

        monitor.applyDetectedApps([app])

        #expect(monitor.activeApps.map(\.id) == [101])
    }

    @Test("Stopped apps remain until the linger duration expires")
    func removalsAreDelayed() async {
        let monitor = AudioProcessMonitor(removalLingerDuration: .milliseconds(10))
        let app = makeApp(pid: 102, objectID: 202)
        monitor.applyDetectedApps([app])

        monitor.applyDetectedApps([])
        #expect(monitor.activeApps.map(\.id) == [102])

        await monitor.waitForPendingRemovals()
        #expect(monitor.activeApps.isEmpty)
    }

    @Test("Playback resuming cancels pending removal")
    func resumingCancelsRemoval() async {
        let monitor = AudioProcessMonitor(removalLingerDuration: .milliseconds(80))
        let app = makeApp(pid: 103, objectID: 203)
        monitor.applyDetectedApps([app])
        monitor.applyDetectedApps([])

        try? await Task.sleep(for: .milliseconds(30))
        monitor.applyDetectedApps([app])
        try? await Task.sleep(for: .milliseconds(100))

        #expect(monitor.activeApps.map(\.id) == [103])
    }

    @Test("A relaunched app replaces its lingering process")
    func relaunchReplacesLingeringProcess() {
        let monitor = AudioProcessMonitor(removalLingerDuration: .seconds(1))
        let oldApp = makeApp(pid: 104, objectID: 204)
        let newApp = makeApp(pid: 105, objectID: 205)
        monitor.applyDetectedApps([oldApp])
        monitor.applyDetectedApps([])

        monitor.applyDetectedApps([newApp])

        #expect(monitor.activeApps.map(\.id) == [105])
    }

    private func makeApp(pid: pid_t, objectID: AudioObjectID) -> AudioApp {
        AudioApp(
            id: pid,
            processObjectIDs: [objectID],
            name: "Test App",
            icon: NSImage(),
            bundleID: "com.example.test"
        )
    }
}
