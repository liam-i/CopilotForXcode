import AppKit
import SwiftUI

private let r: Double = 8

@MainActor
final class ChatWindowViewModel: ObservableObject {
    @Published var chat: ChatProvider?
    @Published var colorScheme: ColorScheme
    @Published var isPanelDisplayed = false
    @AppStorage(\.chatPanelInASeparateWindow) var chatPanelInASeparateWindow
    
    public init(chat: ChatProvider? = nil, colorScheme: ColorScheme = .dark) {
        self.chat = chat
        self.colorScheme = colorScheme
    }
}

struct ChatWindowView: View {
    @ObservedObject var viewModel: ChatWindowViewModel

    var body: some View {
        Group {
            if let chat = viewModel.chat {
                ChatPanel(chat: chat)
            }
        }
        .opacity(viewModel.isPanelDisplayed ? 1 : 0)
        .frame(minWidth: Style.panelWidth, minHeight: Style.panelHeight)
        .preferredColorScheme(viewModel.colorScheme)
    }
}
