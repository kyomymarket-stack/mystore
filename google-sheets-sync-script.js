/**
 * Google Apps Script for Syncing Data to Google Sheets
 * 
 * SETUP INSTRUCTIONS:
 * 1. Open your Google Sheet
 * 2. Go to Extensions → Apps Script
 * 3. Delete any existing code and paste this entire script
 * 4. Click "Deploy" → "New deployment"
 * 5. Choose type: "Web app"
 * 6. Execute as: "Me"
 * 7. Who has access: "Anyone"
 * 8. Click "Deploy" and copy the Web App URL
 * 9. Paste the Web App URL in your application's Google Sheets configuration
 */

function doPost(e) {
    try {
        // Parse the incoming JSON data
        const data = JSON.parse(e.postData.contents);
        const spreadsheetId = data.spreadsheetId;
        const sheetName = data.sheetName || 'Data';
        const rows = data.data;

        // Open the spreadsheet
        const spreadsheet = SpreadsheetApp.openById(spreadsheetId);

        // Get or create the sheet
        let sheet = spreadsheet.getSheetByName(sheetName);
        if (!sheet) {
            sheet = spreadsheet.insertSheet(sheetName);
        }

        // Clear existing content
        sheet.clear();

        // Write the data
        if (rows && rows.length > 0) {
            // Write all rows at once for better performance
            sheet.getRange(1, 1, rows.length, rows[0].length).setValues(rows);

            // Format the header row
            const headerRange = sheet.getRange(1, 1, 1, rows[0].length);
            headerRange.setFontWeight('bold');
            headerRange.setBackground('#4285f4');
            headerRange.setFontColor('#ffffff');

            // Auto-resize columns
            for (let i = 1; i <= rows[0].length; i++) {
                sheet.autoResizeColumn(i);
            }

            // Freeze header row
            sheet.setFrozenRows(1);
        }

        // Add timestamp
        const metadataSheet = spreadsheet.getSheetByName('_Metadata') || spreadsheet.insertSheet('_Metadata');
        metadataSheet.getRange('A1').setValue('Last Updated:');
        metadataSheet.getRange('B1').setValue(new Date());
        metadataSheet.getRange('A2').setValue('Total Rows:');
        metadataSheet.getRange('B2').setValue(rows.length - 1); // Subtract header row

        return ContentService
            .createTextOutput(JSON.stringify({
                success: true,
                message: 'Data synced successfully',
                rowsWritten: rows.length - 1
            }))
            .setMimeType(ContentService.MimeType.JSON);

    } catch (error) {
        return ContentService
            .createTextOutput(JSON.stringify({
                success: false,
                error: error.toString()
            }))
            .setMimeType(ContentService.MimeType.JSON);
    }
}

// Test function - you can run this to test the script
function testDoPost() {
    const testData = {
        postData: {
            contents: JSON.stringify({
                spreadsheetId: SpreadsheetApp.getActiveSpreadsheet().getId(),
                sheetName: 'Test',
                data: [
                    ['Header 1', 'Header 2', 'Header 3'],
                    ['Value 1', 'Value 2', 'Value 3'],
                    ['Value 4', 'Value 5', 'Value 6']
                ]
            })
        }
    };

    Logger.log(doPost(testData).getContent());
}
