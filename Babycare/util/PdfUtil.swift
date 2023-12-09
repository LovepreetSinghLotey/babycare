//
//  PdfUtil.swift
//  Babycare
//
//  Created by User on 15/05/23.
//

import Foundation
import UIKit

class PdfUtil{
    
    var parentVC: UIViewController!
    var view: UIView!
    
    init(parentVC: UIViewController){
        self.parentVC = parentVC
        self.view = parentVC.view
    }
    
    func sharePDFTable(fileName: String, headers: [String], rows: [[String]]) {
        // Create a PDF context
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792) // US Letter size
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        let data = renderer.pdfData { (context) in
            // Define the font and cell padding
            let font = UIFont.nunito(size: 12)
            let cellPadding: CGFloat = 5
            
            // Calculate the column widths based on the data and font
            let columnWidths = getColumnWidths(headers: headers, rows: rows, font: font, cellPadding: cellPadding)
            
            // Start a new page
            context.beginPage()
            
            // Draw the table headers
            drawTableHeaders(headers: headers, columnWidths: columnWidths, font: font, cellPadding: cellPadding, context: context)
            
            // Draw the table rows
            drawTableRows(rows: rows, columnWidths: columnWidths, font: font, cellPadding: cellPadding, context: context)
        }
        
        // Save the PDF to a temporary file
        let tempURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(fileName).pdf")
        try? data.write(to: tempURL!)
        
        // Share the PDF using the activity view controller
        let activityVC = UIActivityViewController(activityItems: [tempURL!], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        parentVC.present(activityVC, animated: true, completion: nil)
    }

    func getColumnWidths(headers: [String], rows: [[String]], font: UIFont, cellPadding: CGFloat) -> [CGFloat] {
        // Calculate the maximum width of each column
        var columnWidths = [CGFloat](repeating: 0, count: headers.count)
        for (i, header) in headers.enumerated() {
            let headerString = NSAttributedString(string: header, attributes: [.font: font])
            let headerWidth = headerString.size().width
            columnWidths[i] = max(columnWidths[i], headerWidth)
        }
        for row in rows {
            for (i, cell) in row.enumerated() {
                let cellString = NSAttributedString(string: cell, attributes: [.font: font])
                let cellWidth = cellString.size().width
                columnWidths[i] = max(columnWidths[i], cellWidth)
            }
        }
        
        // Add padding to the column widths
        columnWidths = columnWidths.map { $0 + cellPadding * 2 }
        
        return columnWidths
    }



    func drawTableHeaders(headers: [String], columnWidths: [CGFloat], font: UIFont, cellPadding: CGFloat, context: UIGraphicsPDFRendererContext) {
        // Set the fill and stroke color
        UIColor.black.setFill()
        UIColor.black.setStroke()
        
        // Set the font and text alignment
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ]
        
        // Draw the headers
        var x: CGFloat = 0
        let y: CGFloat = 0
        for (i, header) in headers.enumerated() {
            let rect = CGRect(x: x, y: y, width: columnWidths[i], height: font.lineHeight + cellPadding * 2)
            header.draw(in: rect, withAttributes: attributes)
            x += columnWidths[i]
        }
    }
    
    func drawTableRows(rows: [[String]], columnWidths: [CGFloat], font: UIFont, cellPadding: CGFloat, context: UIGraphicsPDFRendererContext) {
        // Set the fill and stroke color
        UIColor.black.setFill()
        UIColor.black.setStroke()
        
        // Set the font and text alignment
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attributes = [NSAttributedString.Key.font: font, NSAttributedString.Key.paragraphStyle: paragraphStyle]
        
        // Define the starting position of the rows
        var x: CGFloat = 0
        var y = font.lineHeight + cellPadding * 2
        
        // Draw each row
        for row in rows {
            x = 0
            
            // Draw each cell in the row
            for (i, cell) in row.enumerated() {
                let rect = CGRect(x: x, y: y, width: columnWidths[i], height: font.lineHeight + cellPadding * 2)
                cell.draw(in: rect, withAttributes: attributes)
                x += columnWidths[i]
            }
            
            // Move to the next row
            y += font.lineHeight + cellPadding * 2
        }
    }
}
