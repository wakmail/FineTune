import AppKit
import Testing
@testable import FineTune

@Suite("Process tap controller lifetime")
struct ProcessTapControllerDeinitTests {
    private struct SendablePointer: @unchecked Sendable {
        let rawValue: UnsafeMutableRawPointer
    }

    @Test("Final release is safe on the audio callback thread")
    @MainActor
    func finalReleaseOutsideMainActor() async {
        let app = AudioApp(
            id: 301,
            processObjectIDs: [401],
            name: "Test App",
            icon: NSImage(),
            bundleID: "com.example.test"
        )
        let pointer = SendablePointer(
            rawValue: Unmanaged.passRetained(
                ProcessTapController(
                    app: app,
                    targetDeviceUID: "test.device"
                )
            ).toOpaque()
        )

        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                Unmanaged<ProcessTapController>
                    .fromOpaque(pointer.rawValue)
                    .release()
                continuation.resume()
            }
        }
    }
}
