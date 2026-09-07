import Testing
@testable import FineTune

@MainActor
struct AudioRecordingPermissionRestartTests {
    @Test func newlyGrantedPermissionRequiresRestart() {
        let permission = AudioRecordingPermission()
        permission.updateStatus(.denied, requireRestartAfterNewAuthorization: false)
        var promptCount = 0
        permission.onRestartRequired = { promptCount += 1 }

        permission.updateStatus(.authorized, requireRestartAfterNewAuthorization: true)

        #expect(permission.restartRequired)
        #expect(promptCount == 1)
    }

    @Test func existingAuthorizationDoesNotRequireRestart() {
        let permission = AudioRecordingPermission()
        permission.updateStatus(.authorized, requireRestartAfterNewAuthorization: false)

        #expect(!permission.restartRequired)
    }

    @Test func repeatedAuthorizationPromptsOnlyOnce() {
        let permission = AudioRecordingPermission()
        permission.updateStatus(.denied, requireRestartAfterNewAuthorization: false)
        var promptCount = 0
        permission.onRestartRequired = { promptCount += 1 }

        permission.updateStatus(.authorized, requireRestartAfterNewAuthorization: true)
        permission.updateStatus(.authorized, requireRestartAfterNewAuthorization: true)

        #expect(promptCount == 1)
    }
}
