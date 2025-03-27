//
//  PercentFormatter.swift
//  upbit
//
//  Created by 홍정연 on 3/27/25.
//

import DGCharts
import Foundation

// MARK: DGCharts의 파이차트 Entry label을 value가 아닌 백분율로 포멧팅
class PercentFormatter: ValueFormatter {
    weak var chart: PieChartView?
    
    init(chart: PieChartView) {
        self.chart = chart
    }
    
    func stringForValue(_ value: Double,
                        entry: ChartDataEntry,
                        dataSetIndex: Int,
                        viewPortHandler: ViewPortHandler?) -> String {
        
        return String(format: "%.1f%%", value)
    }
}

