import CodeiumService
import Foundation
import GitHubCopilotService
import Preferences
import SuggestionModel

public protocol SuggestionServiceType {
    func getSuggestions(
        fileURL: URL,
        content: String,
        cursorPosition: CursorPosition,
        tabSize: Int,
        indentSize: Int,
        usesTabsForIndentation: Bool,
        ignoreSpaceOnlySuggestions: Bool
    ) async throws -> [CodeSuggestion]

    func notifyAccepted(_ suggestion: CodeSuggestion) async
    func notifyRejected(_ suggestions: [CodeSuggestion]) async
    func notifyOpenTextDocument(fileURL: URL, content: String) async throws
    func notifyChangeTextDocument(fileURL: URL, content: String) async throws
    func notifyCloseTextDocument(fileURL: URL) async throws
    func notifySaveTextDocument(fileURL: URL) async throws
}

protocol SuggestionServiceProvider: SuggestionServiceType {}

public final class SuggestionService: SuggestionServiceType {
    let projectRootURL: URL
    let onServiceLaunched: (SuggestionServiceType) -> Void
    lazy var suggestionProvider: SuggestionServiceProvider = buildService()

    var codeiumService: CodeiumSuggestionServiceType?

    var serviceType: SuggestionFeatureProvider {
        UserDefaults.shared.value(for: \.suggestionFeatureProvider)
    }

    public init(projectRootURL: URL, onServiceLaunched: @escaping (SuggestionServiceType) -> Void) {
        self.projectRootURL = projectRootURL
        self.onServiceLaunched = onServiceLaunched
    }

    func buildService() -> SuggestionServiceProvider {
        switch serviceType {
        case .codeium:
            return CodeiumSuggestionProvider(
                projectRootURL: projectRootURL,
                onServiceLaunched: onServiceLaunched
            )
        case .gitHubCopilot:
            return GitHubCopilotSuggestionProvider(
                projectRootURL: projectRootURL,
                onServiceLaunched: onServiceLaunched
            )
        }
    }
}

public extension SuggestionService {
    func getSuggestions(
        fileURL: URL,
        content: String,
        cursorPosition: SuggestionModel.CursorPosition,
        tabSize: Int,
        indentSize: Int,
        usesTabsForIndentation: Bool,
        ignoreSpaceOnlySuggestions: Bool
    ) async throws -> [SuggestionModel.CodeSuggestion] {
        try await suggestionProvider.getSuggestions(
            fileURL: fileURL,
            content: content,
            cursorPosition: cursorPosition,
            tabSize: tabSize,
            indentSize: indentSize,
            usesTabsForIndentation: usesTabsForIndentation,
            ignoreSpaceOnlySuggestions: ignoreSpaceOnlySuggestions
        )
    }

    func notifyAccepted(_ suggestion: SuggestionModel.CodeSuggestion) async {
        await suggestionProvider.notifyAccepted(suggestion)
    }

    func notifyRejected(_ suggestions: [SuggestionModel.CodeSuggestion]) async {
        await suggestionProvider.notifyRejected(suggestions)
    }

    func notifyOpenTextDocument(fileURL: URL, content: String) async throws {
        try await suggestionProvider.notifyOpenTextDocument(fileURL: fileURL, content: content)
    }

    func notifyChangeTextDocument(fileURL: URL, content: String) async throws {
        try await suggestionProvider.notifyChangeTextDocument(fileURL: fileURL, content: content)
    }

    func notifyCloseTextDocument(fileURL: URL) async throws {
        try await suggestionProvider.notifyCloseTextDocument(fileURL: fileURL)
    }

    func notifySaveTextDocument(fileURL: URL) async throws {
        try await suggestionProvider.notifySaveTextDocument(fileURL: fileURL)
    }
}

