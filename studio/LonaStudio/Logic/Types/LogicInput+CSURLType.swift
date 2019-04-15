//
//  LogicInput+CSUrl.swift
//  LonaStudio
//
//  Created by Devin Abbott on 4/14/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import Foundation
import Logic

extension LogicInput {
    static func expression(forURLString string: String?) -> LGCExpression {
        switch string {
        case .none:
            return .identifierExpression(
                id: UUID(),
                identifier: LGCIdentifier(id: UUID(), string: "none")
            )

        case .some(let value):
            return .identifierExpression(
                id: UUID(),
                identifier: LGCIdentifier(id: UUID(), string: value)
            )
        }
    }

    static func makeURLString(node: LGCSyntaxNode) -> String? {
        switch node {
        case .expression(.identifierExpression(id: _, identifier: let identifier)):
            return identifier.string
        default:
            return nil
        }
    }

    private static let sizeRE = try! NSRegularExpression(pattern: #"(\d+)\s*[ x]?\s*(\d+)?"#)

    static func suggestionsForURL(isOptional: Bool, node: LGCSyntaxNode, query: String) -> [LogicSuggestionItem] {
        let noneSuggestion = LogicSuggestionItem(
            title: "None",
            category: "No URL".uppercased(),
            node: .expression(
                .identifierExpression(
                    id: UUID(),
                    identifier: LGCIdentifier(id: UUID(), string: "none")
                )
            )
        )

        let lowercasedQuery = query.lowercased()

        let customSuggestion = LogicSuggestionItem(
            title: "URL: \(query)",
            category: "URLS",
            node: .expression(
                .identifierExpression(
                    id: UUID(),
                    identifier: LGCIdentifier(id: UUID(), string: query)
                )
            ),
            disabled: URL(string: query) == nil
        )

        var width: Int?
        var height: Int?

        if let sizeMatch = sizeRE.firstMatch(in: query, range: NSRange(query.startIndex..<query.endIndex, in: query)) {
            if sizeMatch.numberOfRanges > 1, let range = Range(sizeMatch.range(at: 1), in: query) {
                width = Int(query[range])
            }
            if sizeMatch.numberOfRanges > 2, let range = Range(sizeMatch.range(at: 2), in: query) {
                height = Int(query[range])
            }
        }

        let sizes = [width, height].compactMap { $0 }.map { $0.description }

        let dataSourceSuggestions = [
            LogicSuggestionItem(
                title: !sizes.isEmpty ? "placehold.it/\(sizes.joined(separator: "x"))" : "placehold.it",
                category: "Data Sources".uppercased(),
                node: .expression(
                    .identifierExpression(
                        id: UUID(),
                        identifier: LGCIdentifier(id: UUID(), string: "https://placehold.it/\(sizes.joined(separator: "x"))")
                    )
                ),
                disabled: sizes.isEmpty
            ),
            LogicSuggestionItem(
                title: !sizes.isEmpty ? "picsum.photos/\(sizes.joined(separator: "/"))" : "picsum.photos",
                category: "Data Sources".uppercased(),
                node: .expression(
                    .identifierExpression(
                        id: UUID(),
                        identifier: LGCIdentifier(id: UUID(), string: "https://picsum.photos/\(sizes.joined(separator: "/"))")
                    )
                ),
                disabled: sizes.isEmpty
            )
        ]

        return (isOptional && query.isEmpty || "none".contains(lowercasedQuery) ? [noneSuggestion] : []) + [customSuggestion] + dataSourceSuggestions
    }
}