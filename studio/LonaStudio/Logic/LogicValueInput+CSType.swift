//
//  LogicValueInput+Variant.swift
//  LonaStudio
//
//  Created by Devin Abbott on 4/13/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import Foundation
import Logic

extension LogicValueInput {
    static func rootNode(forValue csValue: CSValue) -> LGCSyntaxNode {
        switch csValue.type {
//        case CSColorType:
//            return rootNode(forColorString: csValue.data.string)
        case .bool:
            return rootNode(for: csValue.data.boolValue)
        case .string:
            return rootNode(for: csValue.data.stringValue)
        case .named:
            return rootNode(forValue: csValue.unwrappedNamedType())
        case .variant:
            return .expression(
                .identifierExpression(
                    id: UUID(),
                    identifier: LGCIdentifier(id: UUID(), string: csValue.tag())
                )
            )
        default:
//            fatalError("Not supported")
            return .expression(.identifierExpression(id: UUID(), identifier: LGCIdentifier(id: UUID(), string: "")))
        }
    }

    static func makeValue(forType csType: CSType, node: LGCSyntaxNode) -> CSValue {
        switch csType {
//        case CSColorType:
//            return CSValue(type: csType, data: makeColorString(node: node).toData())
        case .bool:
            return CSValue(type: csType, data: makeBool(node: node).toData())
        case .string:
            return CSValue(type: csType, data: makeString(node: node).toData())
        case .named:
            return makeValue(forType: csType.unwrappedNamedType(), node: node)
        case .variant:
            switch node {
            case .expression(.identifierExpression(id: _, identifier: let identifier)):
                return CSValue(type: .unit, data: .Null).wrap(in: csType, tagged: identifier.string)
            default:
                return CSValue(type: .unit, data: .Null)
            }
        default:
            fatalError("Not supported")
        }
    }

    static func suggestions(forType csType: CSType, query: String) -> [LogicSuggestionItem] {
        switch csType {
        case .bool:
            return suggestionsForBool(query: query)
        case .string:
            return suggestionsForString(query: query)
        case .named:
            return suggestions(forType: csType.unwrappedNamedType(), query: query)
        case .variant(let cases):
            return cases.map { caseItem in
                LogicSuggestionItem(
                    title: caseItem.0,
                    category: "Cases".uppercased(),
                    node: .expression(
                        .identifierExpression(
                            id: UUID(),
                            identifier: LGCIdentifier(id: UUID(), string: caseItem.0)
                        )
                    )
                )
            }.titleContains(prefix: query)
        default:
            return []
        }
    }
}