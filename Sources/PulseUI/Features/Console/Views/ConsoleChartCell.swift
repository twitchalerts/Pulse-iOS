//
//  ConsoleChartInfoView.swift
//  PulseUI
//
//  Created by Lev Sokolov on 2023-01-24.
//  Copyright © 2023 kean. All rights reserved.
//

import SwiftUI
import Pulse
import CoreData
import Combine

struct ConsoleChartCell: View {
    let viewModel: ConsoleChartCellViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("CHART")
                    .lineLimit(1)
                    .font(ConsoleConstants.fontTitle)
                    .foregroundColor(.secondary)
                Spacer()
                Text(viewModel.time)
                    .lineLimit(1)
                    .font(ConsoleConstants.fontTitle)
                    .foregroundColor(.secondary)
                    .backport.monospacedDigit()
            }
            Text(viewModel.preprocessedText)
                .font(ConsoleConstants.fontBody)
                .foregroundColor(.white)
                .lineLimit(ConsoleSettings.shared.lineLimit)
        }
#if os(macOS)
        .padding(.vertical, 3)
#endif
    }
}

#if DEBUG
@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct ConsoleChartView_Previews: PreviewProvider {
    static var previews: some View {
        ConsoleChartCell(viewModel: .init(chartInfo: (try! LoggerStore.mock.lastChatInfo()!)))
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif
