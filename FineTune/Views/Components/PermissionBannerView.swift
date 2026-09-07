// FineTune/Views/Components/PermissionBannerView.swift
import SwiftUI

struct PermissionBannerView: View {
    let permission: AudioRecordingPermission

    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: DesignTokens.Spacing.sm) {
                Image(systemName: "speaker.slash")
                    .font(.title)
                    .foregroundStyle(DesignTokens.Colors.textTertiary)

                Text(title)
                    .font(.callout)
                    .foregroundStyle(DesignTokens.Colors.textSecondary)

                if let detail {
                    Text(detail)
                        .font(DesignTokens.Typography.caption)
                        .foregroundStyle(DesignTokens.Colors.textTertiary)
                        .multilineTextAlignment(.center)
                }

                actionButton
            }
            Spacer()
        }
        .padding(.vertical, DesignTokens.Spacing.xl)
    }

    @ViewBuilder
    private var actionButton: some View {
        if permission.restartRequired {
            Button("Restart FineTune") {
                permission.restartApplication()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        } else if permission.status == .denied {
            Button("Open System Settings") {
                openSystemAudioSettings()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        } else {
            Button("Grant Access") {
                permission.request()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
    }

    private var title: String {
        permission.restartRequired
            ? "Restart FineTune to apply audio access"
            : "Audio capture access required"
    }

    private var detail: String? {
        if permission.restartRequired {
            return "App volume changes take effect after FineTune restarts."
        }
        if permission.status == .denied {
            return "Enable in System Settings \u{2192} Privacy & Security \u{2192} Screen & System Audio Recording"
        }
        return nil
    }

    private func openSystemAudioSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_ScreenCapture") {
            NSWorkspace.shared.open(url)
        }
    }
}
