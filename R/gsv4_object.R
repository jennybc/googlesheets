#' Google Sheets Object Makers
#' 
#' A set of functions to make API objects from R data types
#' 
#' gsv4_AddBandingRequest
#' 
#' Adds a new banded range to the spreadsheet.
#' 
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#AddBandingRequest}{Google's Documentation for AddBandingRequest}
#' @param bandedRange \code{\link{gsv4_BandedRange}} object. A banded (alternating colors) range in a sheet.
#' @return AddBandingRequest
#' @export
gsv4_AddBandingRequest <- function(bandedRange=NULL){

  params_data <- list()

  if(!is.null(bandedRange)){
  stopifnot(is.na(bandedRange) || class(bandedRange) == 'BandedRange')
    params_data[['bandedRange']] <- bandedRange
  }

  obj <- structure(params_data, class = "AddBandingRequest")
  return(obj)
}
#' 
#' gsv4_AddChartRequest
#' 
#' Adds a chart to a sheet in the spreadsheet.
#' 
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#AddChartRequest}{Google's Documentation for AddChartRequest}
#' @param chart \code{\link{gsv4_EmbeddedChart}} object. A chart embedded in a sheet.
#' @return AddChartRequest
#' @export
gsv4_AddChartRequest <- function(chart=NULL){

  params_data <- list()

  if(!is.null(chart)){
  stopifnot(is.na(chart) || class(chart) == 'EmbeddedChart')
    params_data[['chart']] <- chart
  }

  obj <- structure(params_data, class = "AddChartRequest")
  return(obj)
}
#' 
#' gsv4_AddConditionalFormatRuleRequest
#' 
#' Adds a new conditional format rule at the given index.
#' All subsequent rules' indexes are incremented.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#AddConditionalFormatRuleRequest}{Google's Documentation for AddConditionalFormatRuleRequest}
#' @param index integer. The zero-based index where the rule should be inserted.
#' @param rule \code{\link{gsv4_ConditionalFormatRule}} object. A rule describing a conditional format.
#' @return AddConditionalFormatRuleRequest
#' @export
gsv4_AddConditionalFormatRuleRequest <- function(index=NULL, rule=NULL){

  params_data <- list()

  if(!is.null(index)){
  stopifnot(is.na(index) || all.equal(index, as.integer(index)))
    params_data[['index']] <- unbox(index)
  }
  if(!is.null(rule)){
  stopifnot(is.na(rule) || class(rule) == 'ConditionalFormatRule')
    params_data[['rule']] <- rule
  }

  obj <- structure(params_data, class = "AddConditionalFormatRuleRequest")
  return(obj)
}
#' 
#' gsv4_AddFilterViewRequest
#' 
#' Adds a filter view.
#' 
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#AddFilterViewRequest}{Google's Documentation for AddFilterViewRequest}
#' @param filter \code{\link{gsv4_FilterView}} object. A filter view.
#' @return AddFilterViewRequest
#' @export
gsv4_AddFilterViewRequest <- function(filter=NULL){

  params_data <- list()

  if(!is.null(filter)){
  stopifnot(is.na(filter) || class(filter) == 'FilterView')
    params_data[['filter']] <- filter
  }

  obj <- structure(params_data, class = "AddFilterViewRequest")
  return(obj)
}
#' 
#' gsv4_AddNamedRangeRequest
#' 
#' Adds a named range to the spreadsheet.
#' 
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#AddNamedRangeRequest}{Google's Documentation for AddNamedRangeRequest}
#' @param namedRange \code{\link{gsv4_NamedRange}} object. A named range.
#' @return AddNamedRangeRequest
#' @export
gsv4_AddNamedRangeRequest <- function(namedRange=NULL){

  params_data <- list()

  if(!is.null(namedRange)){
  stopifnot(is.na(namedRange) || class(namedRange) == 'NamedRange')
    params_data[['namedRange']] <- namedRange
  }

  obj <- structure(params_data, class = "AddNamedRangeRequest")
  return(obj)
}
#' 
#' gsv4_AddProtectedRangeRequest
#' 
#' Adds a new protected range.
#' 
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#AddProtectedRangeRequest}{Google's Documentation for AddProtectedRangeRequest}
#' @param protectedRange \code{\link{gsv4_ProtectedRange}} object. A protected range.
#' @return AddProtectedRangeRequest
#' @export
gsv4_AddProtectedRangeRequest <- function(protectedRange=NULL){

  params_data <- list()

  if(!is.null(protectedRange)){
  stopifnot(is.na(protectedRange) || class(protectedRange) == 'ProtectedRange')
    params_data[['protectedRange']] <- protectedRange
  }

  obj <- structure(params_data, class = "AddProtectedRangeRequest")
  return(obj)
}
#' 
#' gsv4_AddSheetRequest
#' 
#' Adds a new sheet.
#' When a sheet is added at a given index,
#' all subsequent sheets' indexes are incremented.
#' To add an object sheet, use AddChartRequest instead and specify
#' EmbeddedObjectPosition.sheetId or
#' EmbeddedObjectPosition.newSheet.
#' 
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#AddSheetRequest}{Google's Documentation for AddSheetRequest}
#' @param properties \code{\link{gsv4_SheetProperties}} object. Properties of a sheet.
#' @return AddSheetRequest
#' @export
gsv4_AddSheetRequest <- function(properties=NULL){

  params_data <- list()

  if(!is.null(properties)){
  stopifnot(is.na(properties) || class(properties) == 'SheetProperties')
    params_data[['properties']] <- properties
  }

  obj <- structure(params_data, class = "AddSheetRequest")
  return(obj)
}
#' 
#' gsv4_AppendCellsRequest
#' 
#' Adds new cells after the last row with data in a sheet,
#' inserting new rows into the sheet if necessary.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#AppendCellsRequest}{Google's Documentation for AppendCellsRequest}
#' @param sheetId integer. The sheet ID to append the data to.
#' @param rows list of \code{\link{gsv4_RowData}} objects. The data to append.
#' @param fields string. The fields of CellData that should be updated.
#' At least one field must be specified.
#' The root is the CellData; 'row.values.' should not be specified.
#' A single `"*"` can be used as short-hand for listing every field.
#' @return AppendCellsRequest
#' @export
gsv4_AppendCellsRequest <- function(sheetId=NULL, rows=NULL, fields=NULL){

  params_data <- list()

  if(!is.null(sheetId)){
  stopifnot(is.na(sheetId) || all.equal(sheetId, as.integer(sheetId)))
    params_data[['sheetId']] <- unbox(sheetId)
  }
  if(!is.null(rows)){
  stopifnot(is.na(rows) || class(rows) == 'list' || class(rows) == 'data.frame')
    params_data[['rows']] <- rows
  }
  if(!is.null(fields)){
  stopifnot(is.na(fields) || is.character(fields))
    params_data[['fields']] <- unbox(fields)
  }

  obj <- structure(params_data, class = "AppendCellsRequest")
  return(obj)
}
#' 
#' gsv4_AppendDimensionRequest
#' 
#' Appends rows or columns to the end of a sheet.
#' 
#' dimension takes one of the following values:
#' \itemize{
#'  \item{DIMENSION_UNSPECIFIED - The default value, do not use.}
#'  \item{ROWS - Operates on the rows of a sheet.}
#'  \item{COLUMNS - Operates on the columns of a sheet.}
#' }
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#AppendDimensionRequest}{Google's Documentation for AppendDimensionRequest}
#' @param sheetId integer. The sheet to append rows or columns to.
#' @param dimension string. Whether rows or columns should be appended. dimension must take one of the following values: DIMENSION_UNSPECIFIED, ROWS, COLUMNS
#' See the details section for the definition of each of these values.
#' @param length integer. The number of rows or columns to append.
#' @return AppendDimensionRequest
#' @export
gsv4_AppendDimensionRequest <- function(sheetId=NULL, dimension=NULL, length=NULL){

  params_data <- list()

  if(!is.null(sheetId)){
  stopifnot(is.na(sheetId) || all.equal(sheetId, as.integer(sheetId)))
    params_data[['sheetId']] <- unbox(sheetId)
  }
  if(!is.null(dimension)){
  stopifnot(is.na(dimension) || is.character(dimension))
    params_data[['dimension']] <- unbox(dimension)
  }
  if(!is.null(length)){
  stopifnot(is.na(length) || all.equal(length, as.integer(length)))
    params_data[['length']] <- unbox(length)
  }

  obj <- structure(params_data, class = "AppendDimensionRequest")
  return(obj)
}
#' 
#' gsv4_AutoFillRequest
#' 
#' Fills in more data based on existing data.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#AutoFillRequest}{Google's Documentation for AutoFillRequest}
#' @param range \code{\link{gsv4_GridRange}} object. A range on a sheet.
#' All indexes are zero-based.
#' Indexes are half open, e.g the start index is inclusive
#' and the end index is exclusive -- [start_index, end_index).
#' Missing indexes indicate the range is unbounded on that side.
#' 
#' For example, if `"Sheet1"` is sheet ID 0, then:
#' 
#'   `Sheet1!A1:A1 == sheet_id: 0,
#'                   start_row_index: 0, end_row_index: 1,
#'                   start_column_index: 0, end_column_index: 1`
#' 
#'   `Sheet1!A3:B4 == sheet_id: 0,
#'                   start_row_index: 2, end_row_index: 4,
#'                   start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1!A:B == sheet_id: 0,
#'                 start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1!A5:B == sheet_id: 0,
#'                  start_row_index: 4,
#'                  start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1 == sheet_id:0`
#' 
#' The start index must always be less than or equal to the end index.
#' If the start index equals the end index, then the range is empty.
#' Empty ranges are typically not meaningful and are usually rendered in the
#' UI as `#REF!`.
#' @param sourceAndDestination \code{\link{gsv4_SourceAndDestination}} object. A combination of a source range and how to extend that source.
#' @param useAlternateSeries logical. TRUE if we should generate data with the "alternate" series.
#' This differs based on the type and amount of source data.
#' @return AutoFillRequest
#' @export
gsv4_AutoFillRequest <- function(range=NULL, sourceAndDestination=NULL, useAlternateSeries=NULL){

  params_data <- list()

  if(!is.null(range)){
  stopifnot(is.na(range) || class(range) == 'GridRange')
    params_data[['range']] <- range
  }
  if(!is.null(sourceAndDestination)){
  stopifnot(is.na(sourceAndDestination) || class(sourceAndDestination) == 'SourceAndDestination')
    params_data[['sourceAndDestination']] <- sourceAndDestination
  }
  if(!is.null(useAlternateSeries)){
  stopifnot(is.na(useAlternateSeries) || is.logical(useAlternateSeries))
    params_data[['useAlternateSeries']] <- unbox(useAlternateSeries)
  }

  obj <- structure(params_data, class = "AutoFillRequest")
  return(obj)
}
#' 
#' gsv4_AutoResizeDimensionsRequest
#' 
#' Automatically resizes one or more dimensions based on the contents
#' of the cells in that dimension.
#' 
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#AutoResizeDimensionsRequest}{Google's Documentation for AutoResizeDimensionsRequest}
#' @param dimensions \code{\link{gsv4_DimensionRange}} object. A range along a single dimension on a sheet.
#' All indexes are zero-based.
#' Indexes are half open: the start index is inclusive
#' and the end index is exclusive.
#' Missing indexes indicate the range is unbounded on that side.
#' @return AutoResizeDimensionsRequest
#' @export
gsv4_AutoResizeDimensionsRequest <- function(dimensions=NULL){

  params_data <- list()

  if(!is.null(dimensions)){
  stopifnot(is.na(dimensions) || class(dimensions) == 'DimensionRange')
    params_data[['dimensions']] <- dimensions
  }

  obj <- structure(params_data, class = "AutoResizeDimensionsRequest")
  return(obj)
}
#' 
#' gsv4_BandedRange
#' 
#' A banded (alternating colors) range in a sheet.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#BandedRange}{Google's Documentation for BandedRange}
#' @param range \code{\link{gsv4_GridRange}} object. A range on a sheet.
#' All indexes are zero-based.
#' Indexes are half open, e.g the start index is inclusive
#' and the end index is exclusive -- [start_index, end_index).
#' Missing indexes indicate the range is unbounded on that side.
#' 
#' For example, if `"Sheet1"` is sheet ID 0, then:
#' 
#'   `Sheet1!A1:A1 == sheet_id: 0,
#'                   start_row_index: 0, end_row_index: 1,
#'                   start_column_index: 0, end_column_index: 1`
#' 
#'   `Sheet1!A3:B4 == sheet_id: 0,
#'                   start_row_index: 2, end_row_index: 4,
#'                   start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1!A:B == sheet_id: 0,
#'                 start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1!A5:B == sheet_id: 0,
#'                  start_row_index: 4,
#'                  start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1 == sheet_id:0`
#' 
#' The start index must always be less than or equal to the end index.
#' If the start index equals the end index, then the range is empty.
#' Empty ranges are typically not meaningful and are usually rendered in the
#' UI as `#REF!`.
#' @param bandedRangeId integer. The id of the banded range.
#' @param columnProperties \code{\link{gsv4_BandingProperties}} object. Properties referring a single dimension (either row or column). If both
#' BandedRange.row_properties and BandedRange.column_properties are
#' set, the fill colors are applied to cells according to the following rules:
#' 
#' * header_color and footer_color take priority over band colors.
#' * first_band_color takes priority over second_band_color.
#' * row_properties takes priority over column_properties.
#' 
#' For example, the first row color takes priority over the first column
#' color, but the first column color takes priority over the second row color.
#' Similarly, the row header takes priority over the column header in the
#' top left cell, but the column header takes priority over the first row
#' color if the row header is not set.
#' @param rowProperties \code{\link{gsv4_BandingProperties}} object. Properties referring a single dimension (either row or column). If both
#' BandedRange.row_properties and BandedRange.column_properties are
#' set, the fill colors are applied to cells according to the following rules:
#' 
#' * header_color and footer_color take priority over band colors.
#' * first_band_color takes priority over second_band_color.
#' * row_properties takes priority over column_properties.
#' 
#' For example, the first row color takes priority over the first column
#' color, but the first column color takes priority over the second row color.
#' Similarly, the row header takes priority over the column header in the
#' top left cell, but the column header takes priority over the first row
#' color if the row header is not set.
#' @return BandedRange
#' @export
gsv4_BandedRange <- function(range=NULL, bandedRangeId=NULL, columnProperties=NULL, rowProperties=NULL){

  params_data <- list()

  if(!is.null(range)){
  stopifnot(is.na(range) || class(range) == 'GridRange')
    params_data[['range']] <- range
  }
  if(!is.null(bandedRangeId)){
  stopifnot(is.na(bandedRangeId) || all.equal(bandedRangeId, as.integer(bandedRangeId)))
    params_data[['bandedRangeId']] <- unbox(bandedRangeId)
  }
  if(!is.null(columnProperties)){
  stopifnot(is.na(columnProperties) || class(columnProperties) == 'BandingProperties')
    params_data[['columnProperties']] <- columnProperties
  }
  if(!is.null(rowProperties)){
  stopifnot(is.na(rowProperties) || class(rowProperties) == 'BandingProperties')
    params_data[['rowProperties']] <- rowProperties
  }

  obj <- structure(params_data, class = "BandedRange")
  return(obj)
}
#' 
#' gsv4_BandingProperties
#' 
#' Properties referring a single dimension (either row or column). If both
#' BandedRange.row_properties and BandedRange.column_properties are
#' set, the fill colors are applied to cells according to the following rules:
#' 
#' * header_color and footer_color take priority over band colors.
#' * first_band_color takes priority over second_band_color.
#' * row_properties takes priority over column_properties.
#' 
#' For example, the first row color takes priority over the first column
#' color, but the first column color takes priority over the second row color.
#' Similarly, the row header takes priority over the column header in the
#' top left cell, but the column header takes priority over the first row
#' color if the row header is not set.
#' 
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#BandingProperties}{Google's Documentation for BandingProperties}
#' @param firstBandColor \code{\link{gsv4_Color}} object. Represents a color in the RGBA color space. This representation is designed
#' for simplicity of conversion to/from color representations in various
#' languages over compactness; for example, the fields of this representation
#' can be trivially provided to the constructor of "java.awt.Color" in Java; it
#' can also be trivially provided to UIColor's "+colorWithRed:green:blue:alpha"
#' method in iOS; and, with just a little work, it can be easily formatted into
#' a CSS "rgba()" string in JavaScript, as well. Here are some examples:
#' 
#' Example (Java):
#' 
#'      import com.google.type.Color;
#' 
#'      // ...
#'      public static java.awt.Color fromProto(Color protocolor) {
#'        float alpha = protocolor.hasAlpha()
#'            ? protocolor.getAlpha().getValue()
#'            : 1.0;
#' 
#'        return new java.awt.Color(
#'            protocolor.getRed(),
#'            protocolor.getGreen(),
#'            protocolor.getBlue(),
#'            alpha);
#'      }
#' 
#'      public static Color toProto(java.awt.Color color) {
#'        float red = (float) color.getRed();
#'        float green = (float) color.getGreen();
#'        float blue = (float) color.getBlue();
#'        float denominator = 255.0;
#'        Color.Builder resultBuilder =
#'            Color
#'                .newBuilder()
#'                .setRed(red / denominator)
#'                .setGreen(green / denominator)
#'                .setBlue(blue / denominator);
#'        int alpha = color.getAlpha();
#'        if (alpha != 255) {
#'          result.setAlpha(
#'              FloatValue
#'                  .newBuilder()
#'                  .setValue(((float) alpha) / denominator)
#'                  .build());
#'        }
#'        return resultBuilder.build();
#'      }
#'      // ...
#' 
#' Example (iOS / Obj-C):
#' 
#'      // ...
#'      static UIColor* fromProto(Color* protocolor) {
#'         float red = [protocolor red];
#'         float green = [protocolor green];
#'         float blue = [protocolor blue];
#'         FloatValue* alpha_wrapper = [protocolor alpha];
#'         float alpha = 1.0;
#'         if (alpha_wrapper != nil) {
#'           alpha = [alpha_wrapper value];
#'         }
#'         return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
#'      }
#' 
#'      static Color* toProto(UIColor* color) {
#'          CGFloat red, green, blue, alpha;
#'          if (![color getRed:&red green:&green blue:&blue alpha:&alpha]) {
#'            return nil;
#'          }
#'          Color* result = [Color alloc] init];
#'          [result setRed:red];
#'          [result setGreen:green];
#'          [result setBlue:blue];
#'          if (alpha <= 0.9999) {
#'            [result setAlpha:floatWrapperWithValue(alpha)];
#'          }
#'          [result autorelease];
#'          return result;
#'     }
#'     // ...
#' 
#'  Example (JavaScript):
#' 
#'     // ...
#' 
#'     var protoToCssColor = function(rgb_color) {
#'        var redFrac = rgb_color.red || 0.0;
#'        var greenFrac = rgb_color.green || 0.0;
#'        var blueFrac = rgb_color.blue || 0.0;
#'        var red = Math.floor(redFrac * 255);
#'        var green = Math.floor(greenFrac * 255);
#'        var blue = Math.floor(blueFrac * 255);
#' 
#'        if (!('alpha' in rgb_color)) {
#'           return rgbToCssColor_(red, green, blue);
#'        }
#' 
#'        var alphaFrac = rgb_color.alpha.value || 0.0;
#'        var rgbParams = [red, green, blue].join(',');
#'        return ['rgba(', rgbParams, ',', alphaFrac, ')'].join('');
#'     };
#' 
#'     var rgbToCssColor_ = function(red, green, blue) {
#'       var rgbNumber = new Number((red << 16) | (green << 8) | blue);
#'       var hexString = rgbNumber.toString(16);
#'       var missingZeros = 6 - hexString.length;
#'       var resultBuilder = ['#'];
#'       for (var i = 0; i < missingZeros; i++) {
#'          resultBuilder.push('0');
#'       }
#'       resultBuilder.push(hexString);
#'       return resultBuilder.join('');
#'     };
#' 
#'     // ...
#' @param footerColor \code{\link{gsv4_Color}} object. Represents a color in the RGBA color space. This representation is designed
#' for simplicity of conversion to/from color representations in various
#' languages over compactness; for example, the fields of this representation
#' can be trivially provided to the constructor of "java.awt.Color" in Java; it
#' can also be trivially provided to UIColor's "+colorWithRed:green:blue:alpha"
#' method in iOS; and, with just a little work, it can be easily formatted into
#' a CSS "rgba()" string in JavaScript, as well. Here are some examples:
#' 
#' Example (Java):
#' 
#'      import com.google.type.Color;
#' 
#'      // ...
#'      public static java.awt.Color fromProto(Color protocolor) {
#'        float alpha = protocolor.hasAlpha()
#'            ? protocolor.getAlpha().getValue()
#'            : 1.0;
#' 
#'        return new java.awt.Color(
#'            protocolor.getRed(),
#'            protocolor.getGreen(),
#'            protocolor.getBlue(),
#'            alpha);
#'      }
#' 
#'      public static Color toProto(java.awt.Color color) {
#'        float red = (float) color.getRed();
#'        float green = (float) color.getGreen();
#'        float blue = (float) color.getBlue();
#'        float denominator = 255.0;
#'        Color.Builder resultBuilder =
#'            Color
#'                .newBuilder()
#'                .setRed(red / denominator)
#'                .setGreen(green / denominator)
#'                .setBlue(blue / denominator);
#'        int alpha = color.getAlpha();
#'        if (alpha != 255) {
#'          result.setAlpha(
#'              FloatValue
#'                  .newBuilder()
#'                  .setValue(((float) alpha) / denominator)
#'                  .build());
#'        }
#'        return resultBuilder.build();
#'      }
#'      // ...
#' 
#' Example (iOS / Obj-C):
#' 
#'      // ...
#'      static UIColor* fromProto(Color* protocolor) {
#'         float red = [protocolor red];
#'         float green = [protocolor green];
#'         float blue = [protocolor blue];
#'         FloatValue* alpha_wrapper = [protocolor alpha];
#'         float alpha = 1.0;
#'         if (alpha_wrapper != nil) {
#'           alpha = [alpha_wrapper value];
#'         }
#'         return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
#'      }
#' 
#'      static Color* toProto(UIColor* color) {
#'          CGFloat red, green, blue, alpha;
#'          if (![color getRed:&red green:&green blue:&blue alpha:&alpha]) {
#'            return nil;
#'          }
#'          Color* result = [Color alloc] init];
#'          [result setRed:red];
#'          [result setGreen:green];
#'          [result setBlue:blue];
#'          if (alpha <= 0.9999) {
#'            [result setAlpha:floatWrapperWithValue(alpha)];
#'          }
#'          [result autorelease];
#'          return result;
#'     }
#'     // ...
#' 
#'  Example (JavaScript):
#' 
#'     // ...
#' 
#'     var protoToCssColor = function(rgb_color) {
#'        var redFrac = rgb_color.red || 0.0;
#'        var greenFrac = rgb_color.green || 0.0;
#'        var blueFrac = rgb_color.blue || 0.0;
#'        var red = Math.floor(redFrac * 255);
#'        var green = Math.floor(greenFrac * 255);
#'        var blue = Math.floor(blueFrac * 255);
#' 
#'        if (!('alpha' in rgb_color)) {
#'           return rgbToCssColor_(red, green, blue);
#'        }
#' 
#'        var alphaFrac = rgb_color.alpha.value || 0.0;
#'        var rgbParams = [red, green, blue].join(',');
#'        return ['rgba(', rgbParams, ',', alphaFrac, ')'].join('');
#'     };
#' 
#'     var rgbToCssColor_ = function(red, green, blue) {
#'       var rgbNumber = new Number((red << 16) | (green << 8) | blue);
#'       var hexString = rgbNumber.toString(16);
#'       var missingZeros = 6 - hexString.length;
#'       var resultBuilder = ['#'];
#'       for (var i = 0; i < missingZeros; i++) {
#'          resultBuilder.push('0');
#'       }
#'       resultBuilder.push(hexString);
#'       return resultBuilder.join('');
#'     };
#' 
#'     // ...
#' @param headerColor \code{\link{gsv4_Color}} object. Represents a color in the RGBA color space. This representation is designed
#' for simplicity of conversion to/from color representations in various
#' languages over compactness; for example, the fields of this representation
#' can be trivially provided to the constructor of "java.awt.Color" in Java; it
#' can also be trivially provided to UIColor's "+colorWithRed:green:blue:alpha"
#' method in iOS; and, with just a little work, it can be easily formatted into
#' a CSS "rgba()" string in JavaScript, as well. Here are some examples:
#' 
#' Example (Java):
#' 
#'      import com.google.type.Color;
#' 
#'      // ...
#'      public static java.awt.Color fromProto(Color protocolor) {
#'        float alpha = protocolor.hasAlpha()
#'            ? protocolor.getAlpha().getValue()
#'            : 1.0;
#' 
#'        return new java.awt.Color(
#'            protocolor.getRed(),
#'            protocolor.getGreen(),
#'            protocolor.getBlue(),
#'            alpha);
#'      }
#' 
#'      public static Color toProto(java.awt.Color color) {
#'        float red = (float) color.getRed();
#'        float green = (float) color.getGreen();
#'        float blue = (float) color.getBlue();
#'        float denominator = 255.0;
#'        Color.Builder resultBuilder =
#'            Color
#'                .newBuilder()
#'                .setRed(red / denominator)
#'                .setGreen(green / denominator)
#'                .setBlue(blue / denominator);
#'        int alpha = color.getAlpha();
#'        if (alpha != 255) {
#'          result.setAlpha(
#'              FloatValue
#'                  .newBuilder()
#'                  .setValue(((float) alpha) / denominator)
#'                  .build());
#'        }
#'        return resultBuilder.build();
#'      }
#'      // ...
#' 
#' Example (iOS / Obj-C):
#' 
#'      // ...
#'      static UIColor* fromProto(Color* protocolor) {
#'         float red = [protocolor red];
#'         float green = [protocolor green];
#'         float blue = [protocolor blue];
#'         FloatValue* alpha_wrapper = [protocolor alpha];
#'         float alpha = 1.0;
#'         if (alpha_wrapper != nil) {
#'           alpha = [alpha_wrapper value];
#'         }
#'         return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
#'      }
#' 
#'      static Color* toProto(UIColor* color) {
#'          CGFloat red, green, blue, alpha;
#'          if (![color getRed:&red green:&green blue:&blue alpha:&alpha]) {
#'            return nil;
#'          }
#'          Color* result = [Color alloc] init];
#'          [result setRed:red];
#'          [result setGreen:green];
#'          [result setBlue:blue];
#'          if (alpha <= 0.9999) {
#'            [result setAlpha:floatWrapperWithValue(alpha)];
#'          }
#'          [result autorelease];
#'          return result;
#'     }
#'     // ...
#' 
#'  Example (JavaScript):
#' 
#'     // ...
#' 
#'     var protoToCssColor = function(rgb_color) {
#'        var redFrac = rgb_color.red || 0.0;
#'        var greenFrac = rgb_color.green || 0.0;
#'        var blueFrac = rgb_color.blue || 0.0;
#'        var red = Math.floor(redFrac * 255);
#'        var green = Math.floor(greenFrac * 255);
#'        var blue = Math.floor(blueFrac * 255);
#' 
#'        if (!('alpha' in rgb_color)) {
#'           return rgbToCssColor_(red, green, blue);
#'        }
#' 
#'        var alphaFrac = rgb_color.alpha.value || 0.0;
#'        var rgbParams = [red, green, blue].join(',');
#'        return ['rgba(', rgbParams, ',', alphaFrac, ')'].join('');
#'     };
#' 
#'     var rgbToCssColor_ = function(red, green, blue) {
#'       var rgbNumber = new Number((red << 16) | (green << 8) | blue);
#'       var hexString = rgbNumber.toString(16);
#'       var missingZeros = 6 - hexString.length;
#'       var resultBuilder = ['#'];
#'       for (var i = 0; i < missingZeros; i++) {
#'          resultBuilder.push('0');
#'       }
#'       resultBuilder.push(hexString);
#'       return resultBuilder.join('');
#'     };
#' 
#'     // ...
#' @param secondBandColor \code{\link{gsv4_Color}} object. Represents a color in the RGBA color space. This representation is designed
#' for simplicity of conversion to/from color representations in various
#' languages over compactness; for example, the fields of this representation
#' can be trivially provided to the constructor of "java.awt.Color" in Java; it
#' can also be trivially provided to UIColor's "+colorWithRed:green:blue:alpha"
#' method in iOS; and, with just a little work, it can be easily formatted into
#' a CSS "rgba()" string in JavaScript, as well. Here are some examples:
#' 
#' Example (Java):
#' 
#'      import com.google.type.Color;
#' 
#'      // ...
#'      public static java.awt.Color fromProto(Color protocolor) {
#'        float alpha = protocolor.hasAlpha()
#'            ? protocolor.getAlpha().getValue()
#'            : 1.0;
#' 
#'        return new java.awt.Color(
#'            protocolor.getRed(),
#'            protocolor.getGreen(),
#'            protocolor.getBlue(),
#'            alpha);
#'      }
#' 
#'      public static Color toProto(java.awt.Color color) {
#'        float red = (float) color.getRed();
#'        float green = (float) color.getGreen();
#'        float blue = (float) color.getBlue();
#'        float denominator = 255.0;
#'        Color.Builder resultBuilder =
#'            Color
#'                .newBuilder()
#'                .setRed(red / denominator)
#'                .setGreen(green / denominator)
#'                .setBlue(blue / denominator);
#'        int alpha = color.getAlpha();
#'        if (alpha != 255) {
#'          result.setAlpha(
#'              FloatValue
#'                  .newBuilder()
#'                  .setValue(((float) alpha) / denominator)
#'                  .build());
#'        }
#'        return resultBuilder.build();
#'      }
#'      // ...
#' 
#' Example (iOS / Obj-C):
#' 
#'      // ...
#'      static UIColor* fromProto(Color* protocolor) {
#'         float red = [protocolor red];
#'         float green = [protocolor green];
#'         float blue = [protocolor blue];
#'         FloatValue* alpha_wrapper = [protocolor alpha];
#'         float alpha = 1.0;
#'         if (alpha_wrapper != nil) {
#'           alpha = [alpha_wrapper value];
#'         }
#'         return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
#'      }
#' 
#'      static Color* toProto(UIColor* color) {
#'          CGFloat red, green, blue, alpha;
#'          if (![color getRed:&red green:&green blue:&blue alpha:&alpha]) {
#'            return nil;
#'          }
#'          Color* result = [Color alloc] init];
#'          [result setRed:red];
#'          [result setGreen:green];
#'          [result setBlue:blue];
#'          if (alpha <= 0.9999) {
#'            [result setAlpha:floatWrapperWithValue(alpha)];
#'          }
#'          [result autorelease];
#'          return result;
#'     }
#'     // ...
#' 
#'  Example (JavaScript):
#' 
#'     // ...
#' 
#'     var protoToCssColor = function(rgb_color) {
#'        var redFrac = rgb_color.red || 0.0;
#'        var greenFrac = rgb_color.green || 0.0;
#'        var blueFrac = rgb_color.blue || 0.0;
#'        var red = Math.floor(redFrac * 255);
#'        var green = Math.floor(greenFrac * 255);
#'        var blue = Math.floor(blueFrac * 255);
#' 
#'        if (!('alpha' in rgb_color)) {
#'           return rgbToCssColor_(red, green, blue);
#'        }
#' 
#'        var alphaFrac = rgb_color.alpha.value || 0.0;
#'        var rgbParams = [red, green, blue].join(',');
#'        return ['rgba(', rgbParams, ',', alphaFrac, ')'].join('');
#'     };
#' 
#'     var rgbToCssColor_ = function(red, green, blue) {
#'       var rgbNumber = new Number((red << 16) | (green << 8) | blue);
#'       var hexString = rgbNumber.toString(16);
#'       var missingZeros = 6 - hexString.length;
#'       var resultBuilder = ['#'];
#'       for (var i = 0; i < missingZeros; i++) {
#'          resultBuilder.push('0');
#'       }
#'       resultBuilder.push(hexString);
#'       return resultBuilder.join('');
#'     };
#' 
#'     // ...
#' @return BandingProperties
#' @export
gsv4_BandingProperties <- function(firstBandColor=NULL, footerColor=NULL, headerColor=NULL, secondBandColor=NULL){

  params_data <- list()

  if(!is.null(firstBandColor)){
  stopifnot(is.na(firstBandColor) || class(firstBandColor) == 'Color')
    params_data[['firstBandColor']] <- firstBandColor
  }
  if(!is.null(footerColor)){
  stopifnot(is.na(footerColor) || class(footerColor) == 'Color')
    params_data[['footerColor']] <- footerColor
  }
  if(!is.null(headerColor)){
  stopifnot(is.na(headerColor) || class(headerColor) == 'Color')
    params_data[['headerColor']] <- headerColor
  }
  if(!is.null(secondBandColor)){
  stopifnot(is.na(secondBandColor) || class(secondBandColor) == 'Color')
    params_data[['secondBandColor']] <- secondBandColor
  }

  obj <- structure(params_data, class = "BandingProperties")
  return(obj)
}
#' 
#' gsv4_BasicChartAxis
#' 
#' An axis of the chart.
#' A chart may not have more than one axis per
#' axis position.
#' 
#' position takes one of the following values:
#' \itemize{
#'  \item{BASIC_CHART_AXIS_POSITION_UNSPECIFIED - Default value, do not use.}
#'  \item{BOTTOM_AXIS - The axis rendered at the bottom of a chart.
#' For most charts, this is the standard major axis.
#' For bar charts, this is a minor axis.}
#'  \item{LEFT_AXIS - The axis rendered at the left of a chart.
#' For most charts, this is a minor axis.
#' For bar charts, this is the standard major axis.}
#'  \item{RIGHT_AXIS - The axis rendered at the right of a chart.
#' For most charts, this is a minor axis.
#' For bar charts, this is an unusual major axis.}
#' }
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#BasicChartAxis}{Google's Documentation for BasicChartAxis}
#' @param format \code{\link{gsv4_TextFormat}} object. The format of a run of text in a cell.
#' Absent values indicate that the field isn't specified.
#' @param position string. The position of this axis. position must take one of the following values: BASIC_CHART_AXIS_POSITION_UNSPECIFIED, BOTTOM_AXIS, LEFT_AXIS, RIGHT_AXIS
#' See the details section for the definition of each of these values.
#' @param title string. The title of this axis. If set, this overrides any title inferred
#' from headers of the data.
#' @return BasicChartAxis
#' @export
gsv4_BasicChartAxis <- function(format=NULL, position=NULL, title=NULL){

  params_data <- list()

  if(!is.null(format)){
  stopifnot(is.na(format) || class(format) == 'TextFormat')
    params_data[['format']] <- format
  }
  if(!is.null(position)){
  stopifnot(is.na(position) || is.character(position))
    params_data[['position']] <- unbox(position)
  }
  if(!is.null(title)){
  stopifnot(is.na(title) || is.character(title))
    params_data[['title']] <- unbox(title)
  }

  obj <- structure(params_data, class = "BasicChartAxis")
  return(obj)
}
#' 
#' gsv4_BasicChartDomain
#' 
#' The domain of a chart.
#' For example, if charting stock prices over time, this would be the date.
#' 
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#BasicChartDomain}{Google's Documentation for BasicChartDomain}
#' @param domain \code{\link{gsv4_ChartData}} object. The data included in a domain or series.
#' @return BasicChartDomain
#' @export
gsv4_BasicChartDomain <- function(domain=NULL){

  params_data <- list()

  if(!is.null(domain)){
  stopifnot(is.na(domain) || class(domain) == 'ChartData')
    params_data[['domain']] <- domain
  }

  obj <- structure(params_data, class = "BasicChartDomain")
  return(obj)
}
#' 
#' gsv4_BasicChartSeries
#' 
#' A single series of data in a chart.
#' For example, if charting stock prices over time, multiple series may exist,
#' one for the "Open Price", "High Price", "Low Price" and "Close Price".
#' 
#' targetAxis takes one of the following values:
#' \itemize{
#'  \item{BASIC_CHART_AXIS_POSITION_UNSPECIFIED - Default value, do not use.}
#'  \item{BOTTOM_AXIS - The axis rendered at the bottom of a chart.
#' For most charts, this is the standard major axis.
#' For bar charts, this is a minor axis.}
#'  \item{LEFT_AXIS - The axis rendered at the left of a chart.
#' For most charts, this is a minor axis.
#' For bar charts, this is the standard major axis.}
#'  \item{RIGHT_AXIS - The axis rendered at the right of a chart.
#' For most charts, this is a minor axis.
#' For bar charts, this is an unusual major axis.}
#' }
#' 
#' type takes one of the following values:
#' \itemize{
#'  \item{BASIC_CHART_TYPE_UNSPECIFIED - Default value, do not use.}
#'  \item{BAR - A <a href="/chart/interactive/docs/gallery/barchart">bar chart</a>.}
#'  \item{LINE - A <a href="/chart/interactive/docs/gallery/linechart">line chart</a>.}
#'  \item{AREA - An <a href="/chart/interactive/docs/gallery/areachart">area chart</a>.}
#'  \item{COLUMN - A <a href="/chart/interactive/docs/gallery/columnchart">column chart</a>.}
#'  \item{SCATTER - A <a href="/chart/interactive/docs/gallery/scatterchart">scatter chart</a>.}
#'  \item{COMBO - A <a href="/chart/interactive/docs/gallery/combochart">combo chart</a>.}
#' }
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#BasicChartSeries}{Google's Documentation for BasicChartSeries}
#' @param series \code{\link{gsv4_ChartData}} object. The data included in a domain or series.
#' @param targetAxis string. The minor axis that will specify the range of values for this series.
#' For example, if charting stocks over time, the "Volume" series
#' may want to be pinned to the right with the prices pinned to the left,
#' because the scale of trading volume is different than the scale of
#' prices.
#' It is an error to specify an axis that isn't a valid minor axis
#' for the chart's type. targetAxis must take one of the following values: BASIC_CHART_AXIS_POSITION_UNSPECIFIED, BOTTOM_AXIS, LEFT_AXIS, RIGHT_AXIS
#' See the details section for the definition of each of these values.
#' @param type string. The type of this series. Valid only if the
#' chartType is
#' COMBO.
#' Different types will change the way the series is visualized.
#' Only LINE, AREA,
#' and COLUMN are supported. type must take one of the following values: BASIC_CHART_TYPE_UNSPECIFIED, BAR, LINE, AREA, COLUMN, SCATTER, COMBO
#' See the details section for the definition of each of these values.
#' @return BasicChartSeries
#' @export
gsv4_BasicChartSeries <- function(series=NULL, targetAxis=NULL, type=NULL){

  params_data <- list()

  if(!is.null(series)){
  stopifnot(is.na(series) || class(series) == 'ChartData')
    params_data[['series']] <- series
  }
  if(!is.null(targetAxis)){
  stopifnot(is.na(targetAxis) || is.character(targetAxis))
    params_data[['targetAxis']] <- unbox(targetAxis)
  }
  if(!is.null(type)){
  stopifnot(is.na(type) || is.character(type))
    params_data[['type']] <- unbox(type)
  }

  obj <- structure(params_data, class = "BasicChartSeries")
  return(obj)
}
#' 
#' gsv4_BasicChartSpec
#' 
#' The specification for a basic chart.  See BasicChartType for the list
#' of charts this supports.
#' 
#' chartType takes one of the following values:
#' \itemize{
#'  \item{BASIC_CHART_TYPE_UNSPECIFIED - Default value, do not use.}
#'  \item{BAR - A <a href="/chart/interactive/docs/gallery/barchart">bar chart</a>.}
#'  \item{LINE - A <a href="/chart/interactive/docs/gallery/linechart">line chart</a>.}
#'  \item{AREA - An <a href="/chart/interactive/docs/gallery/areachart">area chart</a>.}
#'  \item{COLUMN - A <a href="/chart/interactive/docs/gallery/columnchart">column chart</a>.}
#'  \item{SCATTER - A <a href="/chart/interactive/docs/gallery/scatterchart">scatter chart</a>.}
#'  \item{COMBO - A <a href="/chart/interactive/docs/gallery/combochart">combo chart</a>.}
#' }
#' 
#' legendPosition takes one of the following values:
#' \itemize{
#'  \item{BASIC_CHART_LEGEND_POSITION_UNSPECIFIED - Default value, do not use.}
#'  \item{BOTTOM_LEGEND - The legend is rendered on the bottom of the chart.}
#'  \item{LEFT_LEGEND - The legend is rendered on the left of the chart.}
#'  \item{RIGHT_LEGEND - The legend is rendered on the right of the chart.}
#'  \item{TOP_LEGEND - The legend is rendered on the top of the chart.}
#'  \item{NO_LEGEND - No legend is rendered.}
#' }
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#BasicChartSpec}{Google's Documentation for BasicChartSpec}
#' @param axis list of \code{\link{gsv4_BasicChartAxis}} objects. The axis on the chart.
#' @param chartType string. The type of the chart. chartType must take one of the following values: BASIC_CHART_TYPE_UNSPECIFIED, BAR, LINE, AREA, COLUMN, SCATTER, COMBO
#' See the details section for the definition of each of these values.
#' @param domains list of \code{\link{gsv4_BasicChartDomain}} objects. The domain of data this is charting.
#' Only a single domain is supported.
#' @param headerCount integer. The number of rows or columns in the data that are "headers".
#' If not set, Google Sheets will guess how many rows are headers based
#' on the data.
#' 
#' (Note that BasicChartAxis.title may override the axis title
#'  inferred from the header values.)
#' @param legendPosition string. The position of the chart legend. legendPosition must take one of the following values: BASIC_CHART_LEGEND_POSITION_UNSPECIFIED, BOTTOM_LEGEND, LEFT_LEGEND, RIGHT_LEGEND, TOP_LEGEND, NO_LEGEND
#' See the details section for the definition of each of these values.
#' @param series list of \code{\link{gsv4_BasicChartSeries}} objects. The data this chart is visualizing.
#' @return BasicChartSpec
#' @export
gsv4_BasicChartSpec <- function(axis=NULL, chartType=NULL, domains=NULL, headerCount=NULL, legendPosition=NULL, series=NULL){

  params_data <- list()

  if(!is.null(axis)){
  stopifnot(is.na(axis) || class(axis) == 'list' || class(axis) == 'data.frame')
    params_data[['axis']] <- axis
  }
  if(!is.null(chartType)){
  stopifnot(is.na(chartType) || is.character(chartType))
    params_data[['chartType']] <- unbox(chartType)
  }
  if(!is.null(domains)){
  stopifnot(is.na(domains) || class(domains) == 'list' || class(domains) == 'data.frame')
    params_data[['domains']] <- domains
  }
  if(!is.null(headerCount)){
  stopifnot(is.na(headerCount) || all.equal(headerCount, as.integer(headerCount)))
    params_data[['headerCount']] <- unbox(headerCount)
  }
  if(!is.null(legendPosition)){
  stopifnot(is.na(legendPosition) || is.character(legendPosition))
    params_data[['legendPosition']] <- unbox(legendPosition)
  }
  if(!is.null(series)){
  stopifnot(is.na(series) || class(series) == 'list' || class(series) == 'data.frame')
    params_data[['series']] <- series
  }

  obj <- structure(params_data, class = "BasicChartSpec")
  return(obj)
}
#' 
#' gsv4_BasicFilter
#' 
#' The default filter associated with a sheet.
#' 
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#BasicFilter}{Google's Documentation for BasicFilter}
#' @param range \code{\link{gsv4_GridRange}} object. A range on a sheet.
#' All indexes are zero-based.
#' Indexes are half open, e.g the start index is inclusive
#' and the end index is exclusive -- [start_index, end_index).
#' Missing indexes indicate the range is unbounded on that side.
#' 
#' For example, if `"Sheet1"` is sheet ID 0, then:
#' 
#'   `Sheet1!A1:A1 == sheet_id: 0,
#'                   start_row_index: 0, end_row_index: 1,
#'                   start_column_index: 0, end_column_index: 1`
#' 
#'   `Sheet1!A3:B4 == sheet_id: 0,
#'                   start_row_index: 2, end_row_index: 4,
#'                   start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1!A:B == sheet_id: 0,
#'                 start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1!A5:B == sheet_id: 0,
#'                  start_row_index: 4,
#'                  start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1 == sheet_id:0`
#' 
#' The start index must always be less than or equal to the end index.
#' If the start index equals the end index, then the range is empty.
#' Empty ranges are typically not meaningful and are usually rendered in the
#' UI as `#REF!`.
#' @param criteria list or data.frame of \code{\link{gsv4_FilterCriteria}} objects. The criteria for showing/hiding values per column.
#' The map's key is the column index, and the value is the criteria for
#' that column.
#' @param sortSpecs list of \code{\link{gsv4_SortSpec}} objects. The sort order per column. Later specifications are used when values
#' are equal in the earlier specifications.
#' @return BasicFilter
#' @export
gsv4_BasicFilter <- function(range=NULL, criteria=NULL, sortSpecs=NULL){

  params_data <- list()

  if(!is.null(range)){
  stopifnot(is.na(range) || class(range) == 'GridRange')
    params_data[['range']] <- range
  }
  if(!is.null(criteria)){
  stopifnot(is.na(criteria) || class(criteria) == 'list' || class(criteria) == 'data.frame')
    params_data[['criteria']] <- criteria
  }
  if(!is.null(sortSpecs)){
  stopifnot(is.na(sortSpecs) || class(sortSpecs) == 'list' || class(sortSpecs) == 'data.frame')
    params_data[['sortSpecs']] <- sortSpecs
  }

  obj <- structure(params_data, class = "BasicFilter")
  return(obj)
}
#' 
#' gsv4_BatchClearValuesRequest
#' 
#' The request for clearing more than one range of values in a spreadsheet.
#' 
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#BatchClearValuesRequest}{Google's Documentation for BatchClearValuesRequest}
#' @param ranges list. The ranges to clear, in A1 notation.
#' @return BatchClearValuesRequest
#' @export
gsv4_BatchClearValuesRequest <- function(ranges=NULL){

  params_data <- list()

  if(!is.null(ranges)){
  stopifnot(is.na(ranges) || class(ranges) == 'list' || class(ranges) == 'data.frame')
    params_data[['ranges']] <- ranges
  }

  obj <- structure(params_data, class = "BatchClearValuesRequest")
  return(obj)
}
#' 
#' gsv4_BatchUpdateSpreadsheetRequest
#' 
#' The request for updating any aspect of a spreadsheet.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#BatchUpdateSpreadsheetRequest}{Google's Documentation for BatchUpdateSpreadsheetRequest}
#' @param includeSpreadsheetInResponse logical. Determines if the update response should include the spreadsheet
#' resource.
#' @param requests list of \code{\link{gsv4_Request}} objects. A list of updates to apply to the spreadsheet.
#' Requests will be applied in the order they are specified.
#' If any request is not valid, no requests will be applied.
#' @param responseIncludeGridData logical. TRUE if grid data should be returned. Meaningful only if
#' if include_spreadsheet_response is 'TRUE'.
#' This parameter is ignored if a field mask was set in the request.
#' @param responseRanges list. Limits the ranges included in the response spreadsheet.
#' Meaningful only if include_spreadsheet_response is 'TRUE'.
#' @return BatchUpdateSpreadsheetRequest
#' @export
gsv4_BatchUpdateSpreadsheetRequest <- function(includeSpreadsheetInResponse=NULL, requests=NULL, responseIncludeGridData=NULL, responseRanges=NULL){

  params_data <- list()

  if(!is.null(includeSpreadsheetInResponse)){
  stopifnot(is.na(includeSpreadsheetInResponse) || is.logical(includeSpreadsheetInResponse))
    params_data[['includeSpreadsheetInResponse']] <- unbox(includeSpreadsheetInResponse)
  }
  if(!is.null(requests)){
  stopifnot(is.na(requests) || class(requests) == 'list' || class(requests) == 'data.frame')
    params_data[['requests']] <- requests
  }
  if(!is.null(responseIncludeGridData)){
  stopifnot(is.na(responseIncludeGridData) || is.logical(responseIncludeGridData))
    params_data[['responseIncludeGridData']] <- unbox(responseIncludeGridData)
  }
  if(!is.null(responseRanges)){
  stopifnot(is.na(responseRanges) || class(responseRanges) == 'list' || class(responseRanges) == 'data.frame')
    params_data[['responseRanges']] <- responseRanges
  }

  obj <- structure(params_data, class = "BatchUpdateSpreadsheetRequest")
  return(obj)
}
#' 
#' gsv4_BatchUpdateValuesRequest
#' 
#' The request for updating more than one range of values in a spreadsheet.
#' 
#' responseDateTimeRenderOption takes one of the following values:
#' \itemize{
#'  \item{SERIAL_NUMBER - Instructs date, time, datetime, and duration fields to be output
#' as doubles in "serial number" format, as popularized by Lotus 1-2-3.
#' The whole number portion of the value (left of the decimal) counts
#' the days since December 30th 1899. The fractional portion (right of
#' the decimal) counts the time as a fraction of the day. For example,
#' January 1st 1900 at noon would be 2.5, 2 because it's 2 days after
#' December 30st 1899, and .5 because noon is half a day.  February 1st
#' 1900 at 3pm would be 33.625. This correctly treats the year 1900 as
#' not a leap year.}
#'  \item{FORMATTED_STRING - Instructs date, time, datetime, and duration fields to be output
#' as strings in their given number format (which is dependent
#' on the spreadsheet locale).}
#' }
#' 
#' responseValueRenderOption takes one of the following values:
#' \itemize{
#'  \item{FORMATTED_VALUE - Values will be calculated & formatted in the reply according to the
#' cell's formatting.  Formatting is based on the spreadsheet's locale,
#' not the requesting user's locale.
#' For example, if `A1` is `1.23` and `A2` is `=A1` and formatted as currency,
#' then `A2` would return `"$1.23"`.}
#'  \item{UNFORMATTED_VALUE - Values will be calculated, but not formatted in the reply.
#' For example, if `A1` is `1.23` and `A2` is `=A1` and formatted as currency,
#' then `A2` would return the number `1.23`.}
#'  \item{FORMULA - Values will not be calculated.  The reply will include the formulas.
#' For example, if `A1` is `1.23` and `A2` is `=A1` and formatted as currency,
#' then A2 would return `"=A1"`.}
#' }
#' 
#' valueInputOption takes one of the following values:
#' \itemize{
#'  \item{INPUT_VALUE_OPTION_UNSPECIFIED - Default input value. This value must not be used.}
#'  \item{RAW - The values the user has entered will not be parsed and will be stored
#' as-is.}
#'  \item{USER_ENTERED - The values will be parsed as if the user typed them into the UI.
#' Numbers will stay as numbers, but strings may be converted to numbers,
#' dates, etc. following the same rules that are applied when entering
#' text into a cell via the Google Sheets UI.}
#' }
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#BatchUpdateValuesRequest}{Google's Documentation for BatchUpdateValuesRequest}
#' @param data list of \code{\link{gsv4_ValueRange}} objects. The new values to apply to the spreadsheet.
#' @param includeValuesInResponse logical. Determines if the update response should include the values
#' of the cells that were updated. By default, responses
#' do not include the updated values. The `updatedData` field within
#' each of the BatchUpdateValuesResponse.responses will contain
#' the updated values. If the range to write was larger than than the range
#' actually written, the response will include all values in the requested
#' range (excluding trailing empty rows and columns).
#' @param responseDateTimeRenderOption string. Determines how dates, times, and durations in the response should be
#' rendered. This is ignored if response_value_render_option is
#' FORMATTED_VALUE.
#' The default dateTime render option is [DateTimeRenderOption.SERIAL_NUMBER]. responseDateTimeRenderOption must take one of the following values: SERIAL_NUMBER, FORMATTED_STRING
#' See the details section for the definition of each of these values.
#' @param responseValueRenderOption string. Determines how values in the response should be rendered.
#' The default render option is ValueRenderOption.FORMATTED_VALUE. responseValueRenderOption must take one of the following values: FORMATTED_VALUE, UNFORMATTED_VALUE, FORMULA
#' See the details section for the definition of each of these values.
#' @param valueInputOption string. How the input data should be interpreted. valueInputOption must take one of the following values: INPUT_VALUE_OPTION_UNSPECIFIED, RAW, USER_ENTERED
#' See the details section for the definition of each of these values.
#' @return BatchUpdateValuesRequest
#' @export
gsv4_BatchUpdateValuesRequest <- function(data=NULL, includeValuesInResponse=NULL, responseDateTimeRenderOption=NULL, responseValueRenderOption=NULL, valueInputOption=NULL){

  params_data <- list()

  if(!is.null(data)){
  stopifnot(is.na(data) || class(data) == 'list' || class(data) == 'data.frame')
    params_data[['data']] <- data
  }
  if(!is.null(includeValuesInResponse)){
  stopifnot(is.na(includeValuesInResponse) || is.logical(includeValuesInResponse))
    params_data[['includeValuesInResponse']] <- unbox(includeValuesInResponse)
  }
  if(!is.null(responseDateTimeRenderOption)){
  stopifnot(is.na(responseDateTimeRenderOption) || is.character(responseDateTimeRenderOption))
    params_data[['responseDateTimeRenderOption']] <- unbox(responseDateTimeRenderOption)
  }
  if(!is.null(responseValueRenderOption)){
  stopifnot(is.na(responseValueRenderOption) || is.character(responseValueRenderOption))
    params_data[['responseValueRenderOption']] <- unbox(responseValueRenderOption)
  }
  if(!is.null(valueInputOption)){
  stopifnot(is.na(valueInputOption) || is.character(valueInputOption))
    params_data[['valueInputOption']] <- unbox(valueInputOption)
  }

  obj <- structure(params_data, class = "BatchUpdateValuesRequest")
  return(obj)
}
#' 
#' gsv4_BooleanCondition
#' 
#' A condition that can evaluate to true or false.
#' BooleanConditions are used by conditional formatting,
#' data validation, and the criteria in filters.
#' 
#' type takes one of the following values:
#' \itemize{
#'  \item{CONDITION_TYPE_UNSPECIFIED - The default value, do not use.}
#'  \item{NUMBER_GREATER - The cell's value must be greater than the condition's value.
#' Supported by data validation, conditional formatting and filters.
#' Requires a single ConditionValue.}
#'  \item{NUMBER_GREATER_THAN_EQ - The cell's value must be greater than or equal to the condition's value.
#' Supported by data validation, conditional formatting and filters.
#' Requires a single ConditionValue.}
#'  \item{NUMBER_LESS - The cell's value must be less than the condition's value.
#' Supported by data validation, conditional formatting and filters.
#' Requires a single ConditionValue.}
#'  \item{NUMBER_LESS_THAN_EQ - The cell's value must be less than or equal to the condition's value.
#' Supported by data validation, conditional formatting and filters.
#' Requires a single ConditionValue.}
#'  \item{NUMBER_EQ - The cell's value must be equal to the condition's value.
#' Supported by data validation, conditional formatting and filters.
#' Requires a single ConditionValue.}
#'  \item{NUMBER_NOT_EQ - The cell's value must be not equal to the condition's value.
#' Supported by data validation, conditional formatting and filters.
#' Requires a single ConditionValue.}
#'  \item{NUMBER_BETWEEN - The cell's value must be between the two condition values.
#' Supported by data validation, conditional formatting and filters.
#' Requires exactly two ConditionValues.}
#'  \item{NUMBER_NOT_BETWEEN - The cell's value must not be between the two condition values.
#' Supported by data validation, conditional formatting and filters.
#' Requires exactly two ConditionValues.}
#'  \item{TEXT_CONTAINS - The cell's value must contain the condition's value.
#' Supported by data validation, conditional formatting and filters.
#' Requires a single ConditionValue.}
#'  \item{TEXT_NOT_CONTAINS - The cell's value must not contain the condition's value.
#' Supported by data validation, conditional formatting and filters.
#' Requires a single ConditionValue.}
#'  \item{TEXT_STARTS_WITH - The cell's value must start with the condition's value.
#' Supported by conditional formatting and filters.
#' Requires a single ConditionValue.}
#'  \item{TEXT_ENDS_WITH - The cell's value must end with the condition's value.
#' Supported by conditional formatting and filters.
#' Requires a single ConditionValue.}
#'  \item{TEXT_EQ - The cell's value must be exactly the condition's value.
#' Supported by data validation, conditional formatting and filters.
#' Requires a single ConditionValue.}
#'  \item{TEXT_IS_EMAIL - The cell's value must be a valid email address.
#' Supported by data validation.
#' Requires no ConditionValues.}
#'  \item{TEXT_IS_URL - The cell's value must be a valid URL.
#' Supported by data validation.
#' Requires no ConditionValues.}
#'  \item{DATE_EQ - The cell's value must be the same date as the condition's value.
#' Supported by data validation, conditional formatting and filters.
#' Requires a single ConditionValue.}
#'  \item{DATE_BEFORE - The cell's value must be before the date of the condition's value.
#' Supported by data validation, conditional formatting and filters.
#' Requires a single ConditionValue
#' that may be a relative date.}
#'  \item{DATE_AFTER - The cell's value must be after the date of the condition's value.
#' Supported by data validation, conditional formatting and filters.
#' Requires a single ConditionValue
#' that may be a relative date.}
#'  \item{DATE_ON_OR_BEFORE - The cell's value must be on or before the date of the condition's value.
#' Supported by data validation.
#' Requires a single ConditionValue
#' that may be a relative date.}
#'  \item{DATE_ON_OR_AFTER - The cell's value must be on or after the date of the condition's value.
#' Supported by data validation.
#' Requires a single ConditionValue
#' that may be a relative date.}
#'  \item{DATE_BETWEEN - The cell's value must be between the dates of the two condition values.
#' Supported by data validation.
#' Requires exactly two ConditionValues.}
#'  \item{DATE_NOT_BETWEEN - The cell's value must be outside the dates of the two condition values.
#' Supported by data validation.
#' Requires exactly two ConditionValues.}
#'  \item{DATE_IS_VALID - The cell's value must be a date.
#' Supported by data validation.
#' Requires no ConditionValues.}
#'  \item{ONE_OF_RANGE - The cell's value must be listed in the grid in condition value's range.
#' Supported by data validation.
#' Requires a single ConditionValue,
#' and the value must be a valid range in A1 notation.}
#'  \item{ONE_OF_LIST - The cell's value must in the list of condition values.
#' Supported by data validation.
#' Supports any number of condition values,
#' one per item in the list.
#' Formulas are not supported in the values.}
#'  \item{BLANK - The cell's value must be empty.
#' Supported by conditional formatting and filters.
#' Requires no ConditionValues.}
#'  \item{NOT_BLANK - The cell's value must not be empty.
#' Supported by conditional formatting and filters.
#' Requires no ConditionValues.}
#'  \item{CUSTOM_FORMULA - The condition's formula must evaluate to TRUE.
#' Supported by data validation, conditional formatting and filters.
#' Requires a single ConditionValue.}
#' }
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#BooleanCondition}{Google's Documentation for BooleanCondition}
#' @param type string. The type of condition. type must take one of the following values: CONDITION_TYPE_UNSPECIFIED, NUMBER_GREATER, NUMBER_GREATER_THAN_EQ, NUMBER_LESS, NUMBER_LESS_THAN_EQ, NUMBER_EQ, NUMBER_NOT_EQ, NUMBER_BETWEEN, NUMBER_NOT_BETWEEN, TEXT_CONTAINS, TEXT_NOT_CONTAINS, TEXT_STARTS_WITH, TEXT_ENDS_WITH, TEXT_EQ, TEXT_IS_EMAIL, TEXT_IS_URL, DATE_EQ, DATE_BEFORE, DATE_AFTER, DATE_ON_OR_BEFORE, DATE_ON_OR_AFTER, DATE_BETWEEN, DATE_NOT_BETWEEN, DATE_IS_VALID, ONE_OF_RANGE, ONE_OF_LIST, BLANK, NOT_BLANK, CUSTOM_FORMULA
#' See the details section for the definition of each of these values.
#' @param values list of \code{\link{gsv4_ConditionValue}} objects. The values of the condition. The number of supported values depends
#' on the condition type.  Some support zero values,
#' others one or two values,
#' and ConditionType.ONE_OF_LIST supports an arbitrary number of values.
#' @return BooleanCondition
#' @export
gsv4_BooleanCondition <- function(type=NULL, values=NULL){

  params_data <- list()

  if(!is.null(type)){
  stopifnot(is.na(type) || is.character(type))
    params_data[['type']] <- unbox(type)
  }
  if(!is.null(values)){
  stopifnot(is.na(values) || class(values) == 'matrix' || class(values) == 'data.frame')
    params_data[['values']] <- values
  }

  obj <- structure(params_data, class = "BooleanCondition")
  return(obj)
}
#' 
#' gsv4_BooleanRule
#' 
#' A rule that may or may not match, depending on the condition.
#' 
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#BooleanRule}{Google's Documentation for BooleanRule}
#' @param condition \code{\link{gsv4_BooleanCondition}} object. A condition that can evaluate to TRUE or FALSE.
#' BooleanConditions are used by conditional formatting,
#' data validation, and the criteria in filters.
#' @param format \code{\link{gsv4_CellFormat}} object. The format of a cell.
#' @return BooleanRule
#' @export
gsv4_BooleanRule <- function(condition=NULL, format=NULL){

  params_data <- list()

  if(!is.null(condition)){
  stopifnot(is.na(condition) || class(condition) == 'BooleanCondition')
    params_data[['condition']] <- condition
  }
  if(!is.null(format)){
  stopifnot(is.na(format) || class(format) == 'CellFormat')
    params_data[['format']] <- format
  }

  obj <- structure(params_data, class = "BooleanRule")
  return(obj)
}
#' 
#' gsv4_Border
#' 
#' A border along a cell.
#' 
#' style takes one of the following values:
#' \itemize{
#'  \item{STYLE_UNSPECIFIED - The style is not specified. Do not use this.}
#'  \item{DOTTED - The border is dotted.}
#'  \item{DASHED - The border is dashed.}
#'  \item{SOLID - The border is a thin solid line.}
#'  \item{SOLID_MEDIUM - The border is a medium solid line.}
#'  \item{SOLID_THICK - The border is a thick solid line.}
#'  \item{NONE - No border.
#' Used only when updating a border in order to erase it.}
#'  \item{DOUBLE - The border is two solid lines.}
#' }
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#Border}{Google's Documentation for Border}
#' @param color \code{\link{gsv4_Color}} object. Represents a color in the RGBA color space. This representation is designed
#' for simplicity of conversion to/from color representations in various
#' languages over compactness; for example, the fields of this representation
#' can be trivially provided to the constructor of "java.awt.Color" in Java; it
#' can also be trivially provided to UIColor's "+colorWithRed:green:blue:alpha"
#' method in iOS; and, with just a little work, it can be easily formatted into
#' a CSS "rgba()" string in JavaScript, as well. Here are some examples:
#' 
#' Example (Java):
#' 
#'      import com.google.type.Color;
#' 
#'      // ...
#'      public static java.awt.Color fromProto(Color protocolor) {
#'        float alpha = protocolor.hasAlpha()
#'            ? protocolor.getAlpha().getValue()
#'            : 1.0;
#' 
#'        return new java.awt.Color(
#'            protocolor.getRed(),
#'            protocolor.getGreen(),
#'            protocolor.getBlue(),
#'            alpha);
#'      }
#' 
#'      public static Color toProto(java.awt.Color color) {
#'        float red = (float) color.getRed();
#'        float green = (float) color.getGreen();
#'        float blue = (float) color.getBlue();
#'        float denominator = 255.0;
#'        Color.Builder resultBuilder =
#'            Color
#'                .newBuilder()
#'                .setRed(red / denominator)
#'                .setGreen(green / denominator)
#'                .setBlue(blue / denominator);
#'        int alpha = color.getAlpha();
#'        if (alpha != 255) {
#'          result.setAlpha(
#'              FloatValue
#'                  .newBuilder()
#'                  .setValue(((float) alpha) / denominator)
#'                  .build());
#'        }
#'        return resultBuilder.build();
#'      }
#'      // ...
#' 
#' Example (iOS / Obj-C):
#' 
#'      // ...
#'      static UIColor* fromProto(Color* protocolor) {
#'         float red = [protocolor red];
#'         float green = [protocolor green];
#'         float blue = [protocolor blue];
#'         FloatValue* alpha_wrapper = [protocolor alpha];
#'         float alpha = 1.0;
#'         if (alpha_wrapper != nil) {
#'           alpha = [alpha_wrapper value];
#'         }
#'         return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
#'      }
#' 
#'      static Color* toProto(UIColor* color) {
#'          CGFloat red, green, blue, alpha;
#'          if (![color getRed:&red green:&green blue:&blue alpha:&alpha]) {
#'            return nil;
#'          }
#'          Color* result = [Color alloc] init];
#'          [result setRed:red];
#'          [result setGreen:green];
#'          [result setBlue:blue];
#'          if (alpha <= 0.9999) {
#'            [result setAlpha:floatWrapperWithValue(alpha)];
#'          }
#'          [result autorelease];
#'          return result;
#'     }
#'     // ...
#' 
#'  Example (JavaScript):
#' 
#'     // ...
#' 
#'     var protoToCssColor = function(rgb_color) {
#'        var redFrac = rgb_color.red || 0.0;
#'        var greenFrac = rgb_color.green || 0.0;
#'        var blueFrac = rgb_color.blue || 0.0;
#'        var red = Math.floor(redFrac * 255);
#'        var green = Math.floor(greenFrac * 255);
#'        var blue = Math.floor(blueFrac * 255);
#' 
#'        if (!('alpha' in rgb_color)) {
#'           return rgbToCssColor_(red, green, blue);
#'        }
#' 
#'        var alphaFrac = rgb_color.alpha.value || 0.0;
#'        var rgbParams = [red, green, blue].join(',');
#'        return ['rgba(', rgbParams, ',', alphaFrac, ')'].join('');
#'     };
#' 
#'     var rgbToCssColor_ = function(red, green, blue) {
#'       var rgbNumber = new Number((red << 16) | (green << 8) | blue);
#'       var hexString = rgbNumber.toString(16);
#'       var missingZeros = 6 - hexString.length;
#'       var resultBuilder = ['#'];
#'       for (var i = 0; i < missingZeros; i++) {
#'          resultBuilder.push('0');
#'       }
#'       resultBuilder.push(hexString);
#'       return resultBuilder.join('');
#'     };
#' 
#'     // ...
#' @param style string. The style of the border. style must take one of the following values: STYLE_UNSPECIFIED, DOTTED, DASHED, SOLID, SOLID_MEDIUM, SOLID_THICK, NONE, DOUBLE
#' See the details section for the definition of each of these values.
#' @param width integer. The width of the border, in pixels.
#' Deprecated; the width is determined by the "style" field.
#' @return Border
#' @export
gsv4_Border <- function(color=NULL, style=NULL, width=NULL){

  params_data <- list()

  if(!is.null(color)){
  stopifnot(is.na(color) || class(color) == 'Color')
    params_data[['color']] <- color
  }
  if(!is.null(style)){
  stopifnot(is.na(style) || is.character(style))
    params_data[['style']] <- unbox(style)
  }
  if(!is.null(width)){
  stopifnot(is.na(width) || all.equal(width, as.integer(width)))
    params_data[['width']] <- unbox(width)
  }

  obj <- structure(params_data, class = "Border")
  return(obj)
}
#' 
#' gsv4_Borders
#' 
#' The borders of the cell.
#' 
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#Borders}{Google's Documentation for Borders}
#' @param bottom \code{\link{gsv4_Border}} object. A border along a cell.
#' @param left \code{\link{gsv4_Border}} object. A border along a cell.
#' @param right \code{\link{gsv4_Border}} object. A border along a cell.
#' @param top \code{\link{gsv4_Border}} object. A border along a cell.
#' @return Borders
#' @export
gsv4_Borders <- function(bottom=NULL, left=NULL, right=NULL, top=NULL){

  params_data <- list()

  if(!is.null(bottom)){
  stopifnot(is.na(bottom) || class(bottom) == 'Border')
    params_data[['bottom']] <- bottom
  }
  if(!is.null(left)){
  stopifnot(is.na(left) || class(left) == 'Border')
    params_data[['left']] <- left
  }
  if(!is.null(right)){
  stopifnot(is.na(right) || class(right) == 'Border')
    params_data[['right']] <- right
  }
  if(!is.null(top)){
  stopifnot(is.na(top) || class(top) == 'Border')
    params_data[['top']] <- top
  }

  obj <- structure(params_data, class = "Borders")
  return(obj)
}
#' 
#' gsv4_CellData
#' 
#' Data about a specific cell.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#CellData}{Google's Documentation for CellData}
#' @param dataValidation \code{\link{gsv4_DataValidationRule}} object. A data validation rule.
#' @param effectiveFormat \code{\link{gsv4_CellFormat}} object. The format of a cell.
#' @param effectiveValue \code{\link{gsv4_ExtendedValue}} object. The kinds of value that a cell in a spreadsheet can have.
#' @param formattedValue string. The formatted value of the cell.
#' This is the value as it's shown to the user.
#' This field is read-only.
#' @param hyperlink string. A hyperlink this cell points to, if any.
#' This field is read-only.  (To set it, use a `=HYPERLINK` formula.)
#' @param note string. Any note on the cell.
#' @param pivotTable \code{\link{gsv4_PivotTable}} object. A pivot table.
#' @param textFormatRuns list of \code{\link{gsv4_TextFormatRun}} objects. Runs of rich text applied to subsections of the cell.  Runs are only valid
#' on user entered strings, not formulas, bools, or numbers.
#' Runs start at specific indexes in the text and continue until the next
#' run. Properties of a run will continue unless explicitly changed
#' in a subsequent run (and properties of the first run will continue
#' the properties of the cell unless explicitly changed).
#' 
#' When writing, the new runs will overwrite any prior runs.  When writing a
#' new user_entered_value, previous runs will be erased.
#' @param userEnteredFormat \code{\link{gsv4_CellFormat}} object. The format of a cell.
#' @param userEnteredValue \code{\link{gsv4_ExtendedValue}} object. The kinds of value that a cell in a spreadsheet can have.
#' @return CellData
#' @export
gsv4_CellData <- function(dataValidation=NULL, effectiveFormat=NULL, effectiveValue=NULL, formattedValue=NULL, hyperlink=NULL, note=NULL, pivotTable=NULL, textFormatRuns=NULL, userEnteredFormat=NULL, userEnteredValue=NULL){

  params_data <- list()

  if(!is.null(dataValidation)){
  stopifnot(is.na(dataValidation) || class(dataValidation) == 'DataValidationRule')
    params_data[['dataValidation']] <- dataValidation
  }
  if(!is.null(effectiveFormat)){
  stopifnot(is.na(effectiveFormat) || class(effectiveFormat) == 'CellFormat')
    params_data[['effectiveFormat']] <- effectiveFormat
  }
  if(!is.null(effectiveValue)){
  stopifnot(is.na(effectiveValue) || class(effectiveValue) == 'ExtendedValue')
    params_data[['effectiveValue']] <- effectiveValue
  }
  if(!is.null(formattedValue)){
  stopifnot(is.na(formattedValue) || is.character(formattedValue))
    params_data[['formattedValue']] <- unbox(formattedValue)
  }
  if(!is.null(hyperlink)){
  stopifnot(is.na(hyperlink) || is.character(hyperlink))
    params_data[['hyperlink']] <- unbox(hyperlink)
  }
  if(!is.null(note)){
  stopifnot(is.na(note) || is.character(note))
    params_data[['note']] <- unbox(note)
  }
  if(!is.null(pivotTable)){
  stopifnot(is.na(pivotTable) || class(pivotTable) == 'PivotTable')
    params_data[['pivotTable']] <- pivotTable
  }
  if(!is.null(textFormatRuns)){
  stopifnot(is.na(textFormatRuns) || class(textFormatRuns) == 'list' || class(textFormatRuns) == 'data.frame')
    params_data[['textFormatRuns']] <- textFormatRuns
  }
  if(!is.null(userEnteredFormat)){
  stopifnot(is.na(userEnteredFormat) || class(userEnteredFormat) == 'CellFormat')
    params_data[['userEnteredFormat']] <- userEnteredFormat
  }
  if(!is.null(userEnteredValue)){
  stopifnot(is.na(userEnteredValue) || class(userEnteredValue) == 'ExtendedValue')
    params_data[['userEnteredValue']] <- userEnteredValue
  }

  obj <- structure(params_data, class = "CellData")
  return(obj)
}
#' 
#' gsv4_CellFormat
#' 
#' The format of a cell.
#' 
#' horizontalAlignment takes one of the following values:
#' \itemize{
#'  \item{HORIZONTAL_ALIGN_UNSPECIFIED - The horizontal alignment is not specified. Do not use this.}
#'  \item{LEFT - The text is explicitly aligned to the left of the cell.}
#'  \item{CENTER - The text is explicitly aligned to the center of the cell.}
#'  \item{RIGHT - The text is explicitly aligned to the right of the cell.}
#' }
#' 
#' hyperlinkDisplayType takes one of the following values:
#' \itemize{
#'  \item{HYPERLINK_DISPLAY_TYPE_UNSPECIFIED - The default value: the hyperlink is rendered. Do not use this.}
#'  \item{LINKED - A hyperlink should be explicitly rendered.}
#'  \item{PLAIN_TEXT - A hyperlink should not be rendered.}
#' }
#' 
#' textDirection takes one of the following values:
#' \itemize{
#'  \item{TEXT_DIRECTION_UNSPECIFIED - The text direction is not specified. Do not use this.}
#'  \item{LEFT_TO_RIGHT - The text direction of left-to-right was set by the user.}
#'  \item{RIGHT_TO_LEFT - The text direction of right-to-left was set by the user.}
#' }
#' 
#' verticalAlignment takes one of the following values:
#' \itemize{
#'  \item{VERTICAL_ALIGN_UNSPECIFIED - The vertical alignment is not specified.  Do not use this.}
#'  \item{TOP - The text is explicitly aligned to the top of the cell.}
#'  \item{MIDDLE - The text is explicitly aligned to the middle of the cell.}
#'  \item{BOTTOM - The text is explicitly aligned to the bottom of the cell.}
#' }
#' 
#' wrapStrategy takes one of the following values:
#' \itemize{
#'  \item{WRAP_STRATEGY_UNSPECIFIED - The default value, do not use.}
#'  \item{OVERFLOW_CELL - Lines that are longer than the cell width will be written in the next
#' cell over, so long as that cell is empty. If the next cell over is
#' non-empty, this behaves the same as CLIP. The text will never wrap
#' to the next line unless the user manually inserts a new line.
#' Example:
#' 
#'     | First sentence. |
#'     | Manual newline that is very long. <- Text continues into next cell
#'     | Next newline.   |}
#'  \item{LEGACY_WRAP - This wrap strategy represents the old Google Sheets wrap strategy where
#' words that are longer than a line are clipped rather than broken. This
#' strategy is not supported on all platforms and is being phased out.
#' Example:
#' 
#'     | Cell has a |
#'     | loooooooooo| <- Word is clipped.
#'     | word.      |}
#'  \item{CLIP - Lines that are longer than the cell width will be clipped.
#' The text will never wrap to the next line unless the user manually
#' inserts a new line.
#' Example:
#' 
#'     | First sentence. |
#'     | Manual newline t| <- Text is clipped
#'     | Next newline.   |}
#'  \item{WRAP - Words that are longer than a line are wrapped at the character level
#' rather than clipped.
#' Example:
#' 
#'     | Cell has a |
#'     | loooooooooo| <- Word is broken.
#'     | ong word.  |}
#' }
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#CellFormat}{Google's Documentation for CellFormat}
#' @param backgroundColor \code{\link{gsv4_Color}} object. Represents a color in the RGBA color space. This representation is designed
#' for simplicity of conversion to/from color representations in various
#' languages over compactness; for example, the fields of this representation
#' can be trivially provided to the constructor of "java.awt.Color" in Java; it
#' can also be trivially provided to UIColor's "+colorWithRed:green:blue:alpha"
#' method in iOS; and, with just a little work, it can be easily formatted into
#' a CSS "rgba()" string in JavaScript, as well. Here are some examples:
#' 
#' Example (Java):
#' 
#'      import com.google.type.Color;
#' 
#'      // ...
#'      public static java.awt.Color fromProto(Color protocolor) {
#'        float alpha = protocolor.hasAlpha()
#'            ? protocolor.getAlpha().getValue()
#'            : 1.0;
#' 
#'        return new java.awt.Color(
#'            protocolor.getRed(),
#'            protocolor.getGreen(),
#'            protocolor.getBlue(),
#'            alpha);
#'      }
#' 
#'      public static Color toProto(java.awt.Color color) {
#'        float red = (float) color.getRed();
#'        float green = (float) color.getGreen();
#'        float blue = (float) color.getBlue();
#'        float denominator = 255.0;
#'        Color.Builder resultBuilder =
#'            Color
#'                .newBuilder()
#'                .setRed(red / denominator)
#'                .setGreen(green / denominator)
#'                .setBlue(blue / denominator);
#'        int alpha = color.getAlpha();
#'        if (alpha != 255) {
#'          result.setAlpha(
#'              FloatValue
#'                  .newBuilder()
#'                  .setValue(((float) alpha) / denominator)
#'                  .build());
#'        }
#'        return resultBuilder.build();
#'      }
#'      // ...
#' 
#' Example (iOS / Obj-C):
#' 
#'      // ...
#'      static UIColor* fromProto(Color* protocolor) {
#'         float red = [protocolor red];
#'         float green = [protocolor green];
#'         float blue = [protocolor blue];
#'         FloatValue* alpha_wrapper = [protocolor alpha];
#'         float alpha = 1.0;
#'         if (alpha_wrapper != nil) {
#'           alpha = [alpha_wrapper value];
#'         }
#'         return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
#'      }
#' 
#'      static Color* toProto(UIColor* color) {
#'          CGFloat red, green, blue, alpha;
#'          if (![color getRed:&red green:&green blue:&blue alpha:&alpha]) {
#'            return nil;
#'          }
#'          Color* result = [Color alloc] init];
#'          [result setRed:red];
#'          [result setGreen:green];
#'          [result setBlue:blue];
#'          if (alpha <= 0.9999) {
#'            [result setAlpha:floatWrapperWithValue(alpha)];
#'          }
#'          [result autorelease];
#'          return result;
#'     }
#'     // ...
#' 
#'  Example (JavaScript):
#' 
#'     // ...
#' 
#'     var protoToCssColor = function(rgb_color) {
#'        var redFrac = rgb_color.red || 0.0;
#'        var greenFrac = rgb_color.green || 0.0;
#'        var blueFrac = rgb_color.blue || 0.0;
#'        var red = Math.floor(redFrac * 255);
#'        var green = Math.floor(greenFrac * 255);
#'        var blue = Math.floor(blueFrac * 255);
#' 
#'        if (!('alpha' in rgb_color)) {
#'           return rgbToCssColor_(red, green, blue);
#'        }
#' 
#'        var alphaFrac = rgb_color.alpha.value || 0.0;
#'        var rgbParams = [red, green, blue].join(',');
#'        return ['rgba(', rgbParams, ',', alphaFrac, ')'].join('');
#'     };
#' 
#'     var rgbToCssColor_ = function(red, green, blue) {
#'       var rgbNumber = new Number((red << 16) | (green << 8) | blue);
#'       var hexString = rgbNumber.toString(16);
#'       var missingZeros = 6 - hexString.length;
#'       var resultBuilder = ['#'];
#'       for (var i = 0; i < missingZeros; i++) {
#'          resultBuilder.push('0');
#'       }
#'       resultBuilder.push(hexString);
#'       return resultBuilder.join('');
#'     };
#' 
#'     // ...
#' @param borders \code{\link{gsv4_Borders}} object. The borders of the cell.
#' @param horizontalAlignment string. The horizontal alignment of the value in the cell. horizontalAlignment must take one of the following values: HORIZONTAL_ALIGN_UNSPECIFIED, LEFT, CENTER, RIGHT
#' See the details section for the definition of each of these values.
#' @param hyperlinkDisplayType string. How a hyperlink, if it exists, should be displayed in the cell. hyperlinkDisplayType must take one of the following values: HYPERLINK_DISPLAY_TYPE_UNSPECIFIED, LINKED, PLAIN_TEXT
#' See the details section for the definition of each of these values.
#' @param numberFormat \code{\link{gsv4_NumberFormat}} object. The number format of a cell.
#' @param padding \code{\link{gsv4_Padding}} object. The amount of padding around the cell, in pixels.
#' When updating padding, every field must be specified.
#' @param textDirection string. The direction of the text in the cell. textDirection must take one of the following values: TEXT_DIRECTION_UNSPECIFIED, LEFT_TO_RIGHT, RIGHT_TO_LEFT
#' See the details section for the definition of each of these values.
#' @param textFormat \code{\link{gsv4_TextFormat}} object. The format of a run of text in a cell.
#' Absent values indicate that the field isn't specified.
#' @param textRotation \code{\link{gsv4_TextRotation}} object. The rotation applied to text in a cell.
#' @param verticalAlignment string. The vertical alignment of the value in the cell. verticalAlignment must take one of the following values: VERTICAL_ALIGN_UNSPECIFIED, TOP, MIDDLE, BOTTOM
#' See the details section for the definition of each of these values.
#' @param wrapStrategy string. The wrap strategy for the value in the cell. wrapStrategy must take one of the following values: WRAP_STRATEGY_UNSPECIFIED, OVERFLOW_CELL, LEGACY_WRAP, CLIP, WRAP
#' See the details section for the definition of each of these values.
#' @return CellFormat
#' @export
gsv4_CellFormat <- function(backgroundColor=NULL, borders=NULL, horizontalAlignment=NULL, hyperlinkDisplayType=NULL, numberFormat=NULL, padding=NULL, textDirection=NULL, textFormat=NULL, textRotation=NULL, verticalAlignment=NULL, wrapStrategy=NULL){

  params_data <- list()

  if(!is.null(backgroundColor)){
  stopifnot(is.na(backgroundColor) || class(backgroundColor) == 'Color')
    params_data[['backgroundColor']] <- backgroundColor
  }
  if(!is.null(borders)){
  stopifnot(is.na(borders) || class(borders) == 'Borders')
    params_data[['borders']] <- borders
  }
  if(!is.null(horizontalAlignment)){
  stopifnot(is.na(horizontalAlignment) || is.character(horizontalAlignment))
    params_data[['horizontalAlignment']] <- unbox(horizontalAlignment)
  }
  if(!is.null(hyperlinkDisplayType)){
  stopifnot(is.na(hyperlinkDisplayType) || is.character(hyperlinkDisplayType))
    params_data[['hyperlinkDisplayType']] <- unbox(hyperlinkDisplayType)
  }
  if(!is.null(numberFormat)){
  stopifnot(is.na(numberFormat) || class(numberFormat) == 'NumberFormat')
    params_data[['numberFormat']] <- numberFormat
  }
  if(!is.null(padding)){
  stopifnot(is.na(padding) || class(padding) == 'Padding')
    params_data[['padding']] <- padding
  }
  if(!is.null(textDirection)){
  stopifnot(is.na(textDirection) || is.character(textDirection))
    params_data[['textDirection']] <- unbox(textDirection)
  }
  if(!is.null(textFormat)){
  stopifnot(is.na(textFormat) || class(textFormat) == 'TextFormat')
    params_data[['textFormat']] <- textFormat
  }
  if(!is.null(textRotation)){
  stopifnot(is.na(textRotation) || class(textRotation) == 'TextRotation')
    params_data[['textRotation']] <- textRotation
  }
  if(!is.null(verticalAlignment)){
  stopifnot(is.na(verticalAlignment) || is.character(verticalAlignment))
    params_data[['verticalAlignment']] <- unbox(verticalAlignment)
  }
  if(!is.null(wrapStrategy)){
  stopifnot(is.na(wrapStrategy) || is.character(wrapStrategy))
    params_data[['wrapStrategy']] <- unbox(wrapStrategy)
  }

  obj <- structure(params_data, class = "CellFormat")
  return(obj)
}
#' 
#' gsv4_ChartData
#' 
#' The data included in a domain or series.
#' 
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#ChartData}{Google's Documentation for ChartData}
#' @param sourceRange \code{\link{gsv4_ChartSourceRange}} object. Source ranges for a chart.
#' @return ChartData
#' @export
gsv4_ChartData <- function(sourceRange=NULL){

  params_data <- list()

  if(!is.null(sourceRange)){
  stopifnot(is.na(sourceRange) || class(sourceRange) == 'ChartSourceRange')
    params_data[['sourceRange']] <- sourceRange
  }

  obj <- structure(params_data, class = "ChartData")
  return(obj)
}
#' 
#' gsv4_ChartSourceRange
#' 
#' Source ranges for a chart.
#' 
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#ChartSourceRange}{Google's Documentation for ChartSourceRange}
#' @param sources list of \code{\link{gsv4_GridRange}} objects. The ranges of data for a series or domain.
#' Exactly one dimension must have a length of 1,
#' and all sources in the list must have the same dimension
#' with length 1.
#' The domain (if it exists) & all series must have the same number
#' of source ranges. If using more than one source range, then the source
#' range at a given offset must be contiguous across the domain and series.
#' 
#' For example, these are valid configurations:
#' 
#'     domain sources: A1:A5
#'     series1 sources: B1:B5
#'     series2 sources: D6:D10
#' 
#'     domain sources: A1:A5, C10:C12
#'     series1 sources: B1:B5, D10:D12
#'     series2 sources: C1:C5, E10:E12
#' @return ChartSourceRange
#' @export
gsv4_ChartSourceRange <- function(sources=NULL){

  params_data <- list()

  if(!is.null(sources)){
  stopifnot(is.na(sources) || class(sources) == 'list' || class(sources) == 'data.frame')
    params_data[['sources']] <- sources
  }

  obj <- structure(params_data, class = "ChartSourceRange")
  return(obj)
}
#' 
#' gsv4_ChartSpec
#' 
#' The specifications of a chart.
#' 
#' hiddenDimensionStrategy takes one of the following values:
#' \itemize{
#'  \item{CHART_HIDDEN_DIMENSION_STRATEGY_UNSPECIFIED - Default value, do not use.}
#'  \item{SKIP_HIDDEN_ROWS_AND_COLUMNS - Charts will skip hidden rows and columns.}
#'  \item{SKIP_HIDDEN_ROWS - Charts will skip hidden rows only.}
#'  \item{SKIP_HIDDEN_COLUMNS - Charts will skip hidden columns only.}
#'  \item{SHOW_ALL - Charts will not skip any hidden rows or columns.}
#' }
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#ChartSpec}{Google's Documentation for ChartSpec}
#' @param basicChart \code{\link{gsv4_BasicChartSpec}} object. The specification for a basic chart.  See BasicChartType for the list
#' of charts this supports.
#' @param hiddenDimensionStrategy string. Determines how the charts will use hidden rows or columns. hiddenDimensionStrategy must take one of the following values: CHART_HIDDEN_DIMENSION_STRATEGY_UNSPECIFIED, SKIP_HIDDEN_ROWS_AND_COLUMNS, SKIP_HIDDEN_ROWS, SKIP_HIDDEN_COLUMNS, SHOW_ALL
#' See the details section for the definition of each of these values.
#' @param pieChart \code{\link{gsv4_PieChartSpec}} object. A <a href="/chart/interactive/docs/gallery/piechart">pie chart</a>.
#' @param title string. The title of the chart.
#' @return ChartSpec
#' @export
gsv4_ChartSpec <- function(basicChart=NULL, hiddenDimensionStrategy=NULL, pieChart=NULL, title=NULL){

  params_data <- list()

  if(!is.null(basicChart)){
  stopifnot(is.na(basicChart) || class(basicChart) == 'BasicChartSpec')
    params_data[['basicChart']] <- basicChart
  }
  if(!is.null(hiddenDimensionStrategy)){
  stopifnot(is.na(hiddenDimensionStrategy) || is.character(hiddenDimensionStrategy))
    params_data[['hiddenDimensionStrategy']] <- unbox(hiddenDimensionStrategy)
  }
  if(!is.null(pieChart)){
  stopifnot(is.na(pieChart) || class(pieChart) == 'PieChartSpec')
    params_data[['pieChart']] <- pieChart
  }
  if(!is.null(title)){
  stopifnot(is.na(title) || is.character(title))
    params_data[['title']] <- unbox(title)
  }

  obj <- structure(params_data, class = "ChartSpec")
  return(obj)
}
#' 
#' gsv4_ClearBasicFilterRequest
#' 
#' Clears the basic filter, if any exists on the sheet.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#ClearBasicFilterRequest}{Google's Documentation for ClearBasicFilterRequest}
#' @param sheetId integer. The sheet ID on which the basic filter should be cleared.
#' @return ClearBasicFilterRequest
#' @export
gsv4_ClearBasicFilterRequest <- function(sheetId=NULL){

  params_data <- list()

  if(!is.null(sheetId)){
  stopifnot(is.na(sheetId) || all.equal(sheetId, as.integer(sheetId)))
    params_data[['sheetId']] <- unbox(sheetId)
  }

  obj <- structure(params_data, class = "ClearBasicFilterRequest")
  return(obj)
}
#' 
#' gsv4_ClearValuesRequest
#' 
#' The request for clearing a range of values in a spreadsheet.
#' 
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#ClearValuesRequest}{Google's Documentation for ClearValuesRequest}
#' @return ClearValuesRequest
#' @export
gsv4_ClearValuesRequest <- function(){

  params_data <- list()

  

  obj <- structure(params_data, class = "ClearValuesRequest")
  return(obj)
}
#' 
#' gsv4_Color
#' 
#' Represents a color in the RGBA color space. This representation is designed
#' for simplicity of conversion to/from color representations in various
#' languages over compactness; for example, the fields of this representation
#' can be trivially provided to the constructor of "java.awt.Color" in Java; it
#' can also be trivially provided to UIColor's "+colorWithRed:green:blue:alpha"
#' method in iOS; and, with just a little work, it can be easily formatted into
#' a CSS "rgba()" string in JavaScript, as well. Here are some examples:
#' 
#' Example (Java):
#' 
#'      import com.google.type.Color;
#' 
#'      // ...
#'      public static java.awt.Color fromProto(Color protocolor) {
#'        float alpha = protocolor.hasAlpha()
#'            ? protocolor.getAlpha().getValue()
#'            : 1.0;
#' 
#'        return new java.awt.Color(
#'            protocolor.getRed(),
#'            protocolor.getGreen(),
#'            protocolor.getBlue(),
#'            alpha);
#'      }
#' 
#'      public static Color toProto(java.awt.Color color) {
#'        float red = (float) color.getRed();
#'        float green = (float) color.getGreen();
#'        float blue = (float) color.getBlue();
#'        float denominator = 255.0;
#'        Color.Builder resultBuilder =
#'            Color
#'                .newBuilder()
#'                .setRed(red / denominator)
#'                .setGreen(green / denominator)
#'                .setBlue(blue / denominator);
#'        int alpha = color.getAlpha();
#'        if (alpha != 255) {
#'          result.setAlpha(
#'              FloatValue
#'                  .newBuilder()
#'                  .setValue(((float) alpha) / denominator)
#'                  .build());
#'        }
#'        return resultBuilder.build();
#'      }
#'      // ...
#' 
#' Example (iOS / Obj-C):
#' 
#'      // ...
#'      static UIColor* fromProto(Color* protocolor) {
#'         float red = [protocolor red];
#'         float green = [protocolor green];
#'         float blue = [protocolor blue];
#'         FloatValue* alpha_wrapper = [protocolor alpha];
#'         float alpha = 1.0;
#'         if (alpha_wrapper != nil) {
#'           alpha = [alpha_wrapper value];
#'         }
#'         return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
#'      }
#' 
#'      static Color* toProto(UIColor* color) {
#'          CGFloat red, green, blue, alpha;
#'          if (![color getRed:&red green:&green blue:&blue alpha:&alpha]) {
#'            return nil;
#'          }
#'          Color* result = [Color alloc] init];
#'          [result setRed:red];
#'          [result setGreen:green];
#'          [result setBlue:blue];
#'          if (alpha <= 0.9999) {
#'            [result setAlpha:floatWrapperWithValue(alpha)];
#'          }
#'          [result autorelease];
#'          return result;
#'     }
#'     // ...
#' 
#'  Example (JavaScript):
#' 
#'     // ...
#' 
#'     var protoToCssColor = function(rgb_color) {
#'        var redFrac = rgb_color.red || 0.0;
#'        var greenFrac = rgb_color.green || 0.0;
#'        var blueFrac = rgb_color.blue || 0.0;
#'        var red = Math.floor(redFrac * 255);
#'        var green = Math.floor(greenFrac * 255);
#'        var blue = Math.floor(blueFrac * 255);
#' 
#'        if (!('alpha' in rgb_color)) {
#'           return rgbToCssColor_(red, green, blue);
#'        }
#' 
#'        var alphaFrac = rgb_color.alpha.value || 0.0;
#'        var rgbParams = [red, green, blue].join(',');
#'        return ['rgba(', rgbParams, ',', alphaFrac, ')'].join('');
#'     };
#' 
#'     var rgbToCssColor_ = function(red, green, blue) {
#'       var rgbNumber = new Number((red << 16) | (green << 8) | blue);
#'       var hexString = rgbNumber.toString(16);
#'       var missingZeros = 6 - hexString.length;
#'       var resultBuilder = ['#'];
#'       for (var i = 0; i < missingZeros; i++) {
#'          resultBuilder.push('0');
#'       }
#'       resultBuilder.push(hexString);
#'       return resultBuilder.join('');
#'     };
#' 
#'     // ...
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#Color}{Google's Documentation for Color}
#' @param alpha numeric. The fraction of this color that should be applied to the pixel. That is,
#' the final pixel color is defined by the equation:
#' 
#'   pixel color = alpha * (this color) + (1.0 - alpha) * (background color)
#' 
#' This means that a value of 1.0 corresponds to a solid color, whereas
#' a value of 0.0 corresponds to a completely transparent color. This
#' uses a wrapper message rather than a simple float scalar so that it is
#' possible to distinguish between a default value and the value being unset.
#' If omitted, this color object is to be rendered as a solid color
#' (as if the alpha value had been explicitly given with a value of 1.0).
#' @param blue numeric. The amount of blue in the color as a value in the interval [0, 1].
#' @param green numeric. The amount of green in the color as a value in the interval [0, 1].
#' @param red numeric. The amount of red in the color as a value in the interval [0, 1].
#' @return Color
#' @export
gsv4_Color <- function(alpha=NULL, blue=NULL, green=NULL, red=NULL){

  params_data <- list()

  if(!is.null(alpha)){
  stopifnot(is.na(alpha) || is.numeric(alpha))
    params_data[['alpha']] <- unbox(alpha)
  }
  if(!is.null(blue)){
  stopifnot(is.na(blue) || is.numeric(blue))
    params_data[['blue']] <- unbox(blue)
  }
  if(!is.null(green)){
  stopifnot(is.na(green) || is.numeric(green))
    params_data[['green']] <- unbox(green)
  }
  if(!is.null(red)){
  stopifnot(is.na(red) || is.numeric(red))
    params_data[['red']] <- unbox(red)
  }

  obj <- structure(params_data, class = "Color")
  return(obj)
}
#' 
#' gsv4_ConditionalFormatRule
#' 
#' A rule describing a conditional format.
#' 
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#ConditionalFormatRule}{Google's Documentation for ConditionalFormatRule}
#' @param booleanRule \code{\link{gsv4_BooleanRule}} object. A rule that may or may not match, depending on the condition.
#' @param gradientRule \code{\link{gsv4_GradientRule}} object. A rule that applies a gradient color scale format, based on
#' the interpolation points listed. The format of a cell will vary
#' based on its contents as compared to the values of the interpolation
#' points.
#' @param ranges list of \code{\link{gsv4_GridRange}} objects. The ranges that will be formatted if the condition is TRUE.
#' All the ranges must be on the same grid.
#' @return ConditionalFormatRule
#' @export
gsv4_ConditionalFormatRule <- function(booleanRule=NULL, gradientRule=NULL, ranges=NULL){

  params_data <- list()

  if(!is.null(booleanRule)){
  stopifnot(is.na(booleanRule) || class(booleanRule) == 'BooleanRule')
    params_data[['booleanRule']] <- booleanRule
  }
  if(!is.null(gradientRule)){
  stopifnot(is.na(gradientRule) || class(gradientRule) == 'GradientRule')
    params_data[['gradientRule']] <- gradientRule
  }
  if(!is.null(ranges)){
  stopifnot(is.na(ranges) || class(ranges) == 'list' || class(ranges) == 'data.frame')
    params_data[['ranges']] <- ranges
  }

  obj <- structure(params_data, class = "ConditionalFormatRule")
  return(obj)
}
#' 
#' gsv4_ConditionValue
#' 
#' The value of the condition.
#' 
#' relativeDate takes one of the following values:
#' \itemize{
#'  \item{RELATIVE_DATE_UNSPECIFIED - Default value, do not use.}
#'  \item{PAST_YEAR - The value is one year before today.}
#'  \item{PAST_MONTH - The value is one month before today.}
#'  \item{PAST_WEEK - The value is one week before today.}
#'  \item{YESTERDAY - The value is yesterday.}
#'  \item{TODAY - The value is today.}
#'  \item{TOMORROW - The value is tomorrow.}
#' }
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#ConditionValue}{Google's Documentation for ConditionValue}
#' @param relativeDate string. A relative date (based on the current date).
#' Valid only if the type is
#' DATE_BEFORE,
#' DATE_AFTER,
#' DATE_ON_OR_BEFORE or
#' DATE_ON_OR_AFTER.
#' 
#' Relative dates are not supported in data validation.
#' They are supported only in conditional formatting and
#' conditional filters. relativeDate must take one of the following values: RELATIVE_DATE_UNSPECIFIED, PAST_YEAR, PAST_MONTH, PAST_WEEK, YESTERDAY, TODAY, TOMORROW
#' See the details section for the definition of each of these values.
#' @param userEnteredValue string. A value the condition is based on.
#' The value will be parsed as if the user typed into a cell.
#' Formulas are supported (and must begin with an `=`).
#' @return ConditionValue
#' @export
gsv4_ConditionValue <- function(relativeDate=NULL, userEnteredValue=NULL){

  params_data <- list()

  if(!is.null(relativeDate)){
  stopifnot(is.na(relativeDate) || is.character(relativeDate))
    params_data[['relativeDate']] <- unbox(relativeDate)
  }
  if(!is.null(userEnteredValue)){
  stopifnot(is.na(userEnteredValue) || is.character(userEnteredValue))
    params_data[['userEnteredValue']] <- unbox(userEnteredValue)
  }

  obj <- structure(params_data, class = "ConditionValue")
  return(obj)
}
#' 
#' gsv4_CopyPasteRequest
#' 
#' Copies data from the source to the destination.
#' 
#' pasteOrientation takes one of the following values:
#' \itemize{
#'  \item{NORMAL - Paste normally.}
#'  \item{TRANSPOSE - Paste transposed, where all rows become columns and vice versa.}
#' }
#' 
#' pasteType takes one of the following values:
#' \itemize{
#'  \item{PASTE_NORMAL - Paste values, formulas, formats, and merges.}
#'  \item{PASTE_VALUES - Paste the values ONLY without formats, formulas, or merges.}
#'  \item{PASTE_FORMAT - Paste the format and data validation only.}
#'  \item{PASTE_NO_BORDERS - Like PASTE_NORMAL but without borders.}
#'  \item{PASTE_FORMULA - Paste the formulas only.}
#'  \item{PASTE_DATA_VALIDATION - Paste the data validation only.}
#'  \item{PASTE_CONDITIONAL_FORMATTING - Paste the conditional formatting rules only.}
#' }
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#CopyPasteRequest}{Google's Documentation for CopyPasteRequest}
#' @param destination \code{\link{gsv4_GridRange}} object. A range on a sheet.
#' All indexes are zero-based.
#' Indexes are half open, e.g the start index is inclusive
#' and the end index is exclusive -- [start_index, end_index).
#' Missing indexes indicate the range is unbounded on that side.
#' 
#' For example, if `"Sheet1"` is sheet ID 0, then:
#' 
#'   `Sheet1!A1:A1 == sheet_id: 0,
#'                   start_row_index: 0, end_row_index: 1,
#'                   start_column_index: 0, end_column_index: 1`
#' 
#'   `Sheet1!A3:B4 == sheet_id: 0,
#'                   start_row_index: 2, end_row_index: 4,
#'                   start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1!A:B == sheet_id: 0,
#'                 start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1!A5:B == sheet_id: 0,
#'                  start_row_index: 4,
#'                  start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1 == sheet_id:0`
#' 
#' The start index must always be less than or equal to the end index.
#' If the start index equals the end index, then the range is empty.
#' Empty ranges are typically not meaningful and are usually rendered in the
#' UI as `#REF!`.
#' @param pasteOrientation string. How that data should be oriented when pasting. pasteOrientation must take one of the following values: NORMAL, TRANSPOSE
#' See the details section for the definition of each of these values.
#' @param pasteType string. What kind of data to paste. pasteType must take one of the following values: PASTE_NORMAL, PASTE_VALUES, PASTE_FORMAT, PASTE_NO_BORDERS, PASTE_FORMULA, PASTE_DATA_VALIDATION, PASTE_CONDITIONAL_FORMATTING
#' See the details section for the definition of each of these values.
#' @param source \code{\link{gsv4_GridRange}} object. A range on a sheet.
#' All indexes are zero-based.
#' Indexes are half open, e.g the start index is inclusive
#' and the end index is exclusive -- [start_index, end_index).
#' Missing indexes indicate the range is unbounded on that side.
#' 
#' For example, if `"Sheet1"` is sheet ID 0, then:
#' 
#'   `Sheet1!A1:A1 == sheet_id: 0,
#'                   start_row_index: 0, end_row_index: 1,
#'                   start_column_index: 0, end_column_index: 1`
#' 
#'   `Sheet1!A3:B4 == sheet_id: 0,
#'                   start_row_index: 2, end_row_index: 4,
#'                   start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1!A:B == sheet_id: 0,
#'                 start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1!A5:B == sheet_id: 0,
#'                  start_row_index: 4,
#'                  start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1 == sheet_id:0`
#' 
#' The start index must always be less than or equal to the end index.
#' If the start index equals the end index, then the range is empty.
#' Empty ranges are typically not meaningful and are usually rendered in the
#' UI as `#REF!`.
#' @return CopyPasteRequest
#' @export
gsv4_CopyPasteRequest <- function(destination=NULL, pasteOrientation=NULL, pasteType=NULL, source=NULL){

  params_data <- list()

  if(!is.null(destination)){
  stopifnot(is.na(destination) || class(destination) == 'GridRange')
    params_data[['destination']] <- destination
  }
  if(!is.null(pasteOrientation)){
  stopifnot(is.na(pasteOrientation) || is.character(pasteOrientation))
    params_data[['pasteOrientation']] <- unbox(pasteOrientation)
  }
  if(!is.null(pasteType)){
  stopifnot(is.na(pasteType) || is.character(pasteType))
    params_data[['pasteType']] <- unbox(pasteType)
  }
  if(!is.null(source)){
  stopifnot(is.na(source) || class(source) == 'GridRange')
    params_data[['source']] <- source
  }

  obj <- structure(params_data, class = "CopyPasteRequest")
  return(obj)
}
#' 
#' gsv4_CopySheetToAnotherSpreadsheetRequest
#' 
#' The request to copy a sheet across spreadsheets.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#CopySheetToAnotherSpreadsheetRequest}{Google's Documentation for CopySheetToAnotherSpreadsheetRequest}
#' @param destinationSpreadsheetId string. The ID of the spreadsheet to copy the sheet to.
#' @return CopySheetToAnotherSpreadsheetRequest
#' @export
gsv4_CopySheetToAnotherSpreadsheetRequest <- function(destinationSpreadsheetId=NULL){

  params_data <- list()

  if(!is.null(destinationSpreadsheetId)){
  stopifnot(is.na(destinationSpreadsheetId) || is.character(destinationSpreadsheetId))
    params_data[['destinationSpreadsheetId']] <- unbox(destinationSpreadsheetId)
  }

  obj <- structure(params_data, class = "CopySheetToAnotherSpreadsheetRequest")
  return(obj)
}
#' 
#' gsv4_CutPasteRequest
#' 
#' Moves data from the source to the destination.
#' 
#' pasteType takes one of the following values:
#' \itemize{
#'  \item{PASTE_NORMAL - Paste values, formulas, formats, and merges.}
#'  \item{PASTE_VALUES - Paste the values ONLY without formats, formulas, or merges.}
#'  \item{PASTE_FORMAT - Paste the format and data validation only.}
#'  \item{PASTE_NO_BORDERS - Like PASTE_NORMAL but without borders.}
#'  \item{PASTE_FORMULA - Paste the formulas only.}
#'  \item{PASTE_DATA_VALIDATION - Paste the data validation only.}
#'  \item{PASTE_CONDITIONAL_FORMATTING - Paste the conditional formatting rules only.}
#' }
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#CutPasteRequest}{Google's Documentation for CutPasteRequest}
#' @param destination \code{\link{gsv4_GridCoordinate}} object. A coordinate in a sheet.
#' All indexes are zero-based.
#' @param pasteType string. What kind of data to paste.  All the source data will be cut, regardless
#' of what is pasted. pasteType must take one of the following values: PASTE_NORMAL, PASTE_VALUES, PASTE_FORMAT, PASTE_NO_BORDERS, PASTE_FORMULA, PASTE_DATA_VALIDATION, PASTE_CONDITIONAL_FORMATTING
#' See the details section for the definition of each of these values.
#' @param source \code{\link{gsv4_GridRange}} object. A range on a sheet.
#' All indexes are zero-based.
#' Indexes are half open, e.g the start index is inclusive
#' and the end index is exclusive -- [start_index, end_index).
#' Missing indexes indicate the range is unbounded on that side.
#' 
#' For example, if `"Sheet1"` is sheet ID 0, then:
#' 
#'   `Sheet1!A1:A1 == sheet_id: 0,
#'                   start_row_index: 0, end_row_index: 1,
#'                   start_column_index: 0, end_column_index: 1`
#' 
#'   `Sheet1!A3:B4 == sheet_id: 0,
#'                   start_row_index: 2, end_row_index: 4,
#'                   start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1!A:B == sheet_id: 0,
#'                 start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1!A5:B == sheet_id: 0,
#'                  start_row_index: 4,
#'                  start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1 == sheet_id:0`
#' 
#' The start index must always be less than or equal to the end index.
#' If the start index equals the end index, then the range is empty.
#' Empty ranges are typically not meaningful and are usually rendered in the
#' UI as `#REF!`.
#' @return CutPasteRequest
#' @export
gsv4_CutPasteRequest <- function(destination=NULL, pasteType=NULL, source=NULL){

  params_data <- list()

  if(!is.null(destination)){
  stopifnot(is.na(destination) || class(destination) == 'GridCoordinate')
    params_data[['destination']] <- destination
  }
  if(!is.null(pasteType)){
  stopifnot(is.na(pasteType) || is.character(pasteType))
    params_data[['pasteType']] <- unbox(pasteType)
  }
  if(!is.null(source)){
  stopifnot(is.na(source) || class(source) == 'GridRange')
    params_data[['source']] <- source
  }

  obj <- structure(params_data, class = "CutPasteRequest")
  return(obj)
}
#' 
#' gsv4_DataValidationRule
#' 
#' A data validation rule.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#DataValidationRule}{Google's Documentation for DataValidationRule}
#' @param condition \code{\link{gsv4_BooleanCondition}} object. A condition that can evaluate to TRUE or FALSE.
#' BooleanConditions are used by conditional formatting,
#' data validation, and the criteria in filters.
#' @param inputMessage string. A message to show the user when adding data to the cell.
#' @param showCustomUi logical. TRUE if the UI should be customized based on the kind of condition.
#' If TRUE, "List" conditions will show a dropdown.
#' @param strict logical. TRUE if invalid data should be rejected.
#' @return DataValidationRule
#' @export
gsv4_DataValidationRule <- function(condition=NULL, inputMessage=NULL, showCustomUi=NULL, strict=NULL){

  params_data <- list()

  if(!is.null(condition)){
  stopifnot(is.na(condition) || class(condition) == 'BooleanCondition')
    params_data[['condition']] <- condition
  }
  if(!is.null(inputMessage)){
  stopifnot(is.na(inputMessage) || is.character(inputMessage))
    params_data[['inputMessage']] <- unbox(inputMessage)
  }
  if(!is.null(showCustomUi)){
  stopifnot(is.na(showCustomUi) || is.logical(showCustomUi))
    params_data[['showCustomUi']] <- unbox(showCustomUi)
  }
  if(!is.null(strict)){
  stopifnot(is.na(strict) || is.logical(strict))
    params_data[['strict']] <- unbox(strict)
  }

  obj <- structure(params_data, class = "DataValidationRule")
  return(obj)
}
#' 
#' gsv4_DeleteBandingRequest
#' 
#' Removes the banded range with the given ID from the spreadsheet.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#DeleteBandingRequest}{Google's Documentation for DeleteBandingRequest}
#' @param bandedRangeId integer. The ID of the banded range to delete.
#' @return DeleteBandingRequest
#' @export
gsv4_DeleteBandingRequest <- function(bandedRangeId=NULL){

  params_data <- list()

  if(!is.null(bandedRangeId)){
  stopifnot(is.na(bandedRangeId) || all.equal(bandedRangeId, as.integer(bandedRangeId)))
    params_data[['bandedRangeId']] <- unbox(bandedRangeId)
  }

  obj <- structure(params_data, class = "DeleteBandingRequest")
  return(obj)
}
#' 
#' gsv4_DeleteConditionalFormatRuleRequest
#' 
#' Deletes a conditional format rule at the given index.
#' All subsequent rules' indexes are decremented.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#DeleteConditionalFormatRuleRequest}{Google's Documentation for DeleteConditionalFormatRuleRequest}
#' @param sheetId integer. The sheet the rule is being deleted from.
#' @param index integer. The zero-based index of the rule to be deleted.
#' @return DeleteConditionalFormatRuleRequest
#' @export
gsv4_DeleteConditionalFormatRuleRequest <- function(sheetId=NULL, index=NULL){

  params_data <- list()

  if(!is.null(sheetId)){
  stopifnot(is.na(sheetId) || all.equal(sheetId, as.integer(sheetId)))
    params_data[['sheetId']] <- unbox(sheetId)
  }
  if(!is.null(index)){
  stopifnot(is.na(index) || all.equal(index, as.integer(index)))
    params_data[['index']] <- unbox(index)
  }

  obj <- structure(params_data, class = "DeleteConditionalFormatRuleRequest")
  return(obj)
}
#' 
#' gsv4_DeleteDimensionRequest
#' 
#' Deletes the dimensions from the sheet.
#' 
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#DeleteDimensionRequest}{Google's Documentation for DeleteDimensionRequest}
#' @param range \code{\link{gsv4_DimensionRange}} object. A range along a single dimension on a sheet.
#' All indexes are zero-based.
#' Indexes are half open: the start index is inclusive
#' and the end index is exclusive.
#' Missing indexes indicate the range is unbounded on that side.
#' @return DeleteDimensionRequest
#' @export
gsv4_DeleteDimensionRequest <- function(range=NULL){

  params_data <- list()

  if(!is.null(range)){
  stopifnot(is.na(range) || class(range) == 'DimensionRange')
    params_data[['range']] <- range
  }

  obj <- structure(params_data, class = "DeleteDimensionRequest")
  return(obj)
}
#' 
#' gsv4_DeleteEmbeddedObjectRequest
#' 
#' Deletes the embedded object with the given ID.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#DeleteEmbeddedObjectRequest}{Google's Documentation for DeleteEmbeddedObjectRequest}
#' @param objectId integer. The ID of the embedded object to delete.
#' @return DeleteEmbeddedObjectRequest
#' @export
gsv4_DeleteEmbeddedObjectRequest <- function(objectId=NULL){

  params_data <- list()

  if(!is.null(objectId)){
  stopifnot(is.na(objectId) || all.equal(objectId, as.integer(objectId)))
    params_data[['objectId']] <- unbox(objectId)
  }

  obj <- structure(params_data, class = "DeleteEmbeddedObjectRequest")
  return(obj)
}
#' 
#' gsv4_DeleteFilterViewRequest
#' 
#' Deletes a particular filter view.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#DeleteFilterViewRequest}{Google's Documentation for DeleteFilterViewRequest}
#' @param filterId integer. The ID of the filter to delete.
#' @return DeleteFilterViewRequest
#' @export
gsv4_DeleteFilterViewRequest <- function(filterId=NULL){

  params_data <- list()

  if(!is.null(filterId)){
  stopifnot(is.na(filterId) || all.equal(filterId, as.integer(filterId)))
    params_data[['filterId']] <- unbox(filterId)
  }

  obj <- structure(params_data, class = "DeleteFilterViewRequest")
  return(obj)
}
#' 
#' gsv4_DeleteNamedRangeRequest
#' 
#' Removes the named range with the given ID from the spreadsheet.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#DeleteNamedRangeRequest}{Google's Documentation for DeleteNamedRangeRequest}
#' @param namedRangeId string. The ID of the named range to delete.
#' @return DeleteNamedRangeRequest
#' @export
gsv4_DeleteNamedRangeRequest <- function(namedRangeId=NULL){

  params_data <- list()

  if(!is.null(namedRangeId)){
  stopifnot(is.na(namedRangeId) || is.character(namedRangeId))
    params_data[['namedRangeId']] <- unbox(namedRangeId)
  }

  obj <- structure(params_data, class = "DeleteNamedRangeRequest")
  return(obj)
}
#' 
#' gsv4_DeleteProtectedRangeRequest
#' 
#' Deletes the protected range with the given ID.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#DeleteProtectedRangeRequest}{Google's Documentation for DeleteProtectedRangeRequest}
#' @param protectedRangeId integer. The ID of the protected range to delete.
#' @return DeleteProtectedRangeRequest
#' @export
gsv4_DeleteProtectedRangeRequest <- function(protectedRangeId=NULL){

  params_data <- list()

  if(!is.null(protectedRangeId)){
  stopifnot(is.na(protectedRangeId) || all.equal(protectedRangeId, as.integer(protectedRangeId)))
    params_data[['protectedRangeId']] <- unbox(protectedRangeId)
  }

  obj <- structure(params_data, class = "DeleteProtectedRangeRequest")
  return(obj)
}
#' 
#' gsv4_DeleteRangeRequest
#' 
#' Deletes a range of cells, shifting other cells into the deleted area.
#' 
#' shiftDimension takes one of the following values:
#' \itemize{
#'  \item{DIMENSION_UNSPECIFIED - The default value, do not use.}
#'  \item{ROWS - Operates on the rows of a sheet.}
#'  \item{COLUMNS - Operates on the columns of a sheet.}
#' }
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#DeleteRangeRequest}{Google's Documentation for DeleteRangeRequest}
#' @param range \code{\link{gsv4_GridRange}} object. A range on a sheet.
#' All indexes are zero-based.
#' Indexes are half open, e.g the start index is inclusive
#' and the end index is exclusive -- [start_index, end_index).
#' Missing indexes indicate the range is unbounded on that side.
#' 
#' For example, if `"Sheet1"` is sheet ID 0, then:
#' 
#'   `Sheet1!A1:A1 == sheet_id: 0,
#'                   start_row_index: 0, end_row_index: 1,
#'                   start_column_index: 0, end_column_index: 1`
#' 
#'   `Sheet1!A3:B4 == sheet_id: 0,
#'                   start_row_index: 2, end_row_index: 4,
#'                   start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1!A:B == sheet_id: 0,
#'                 start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1!A5:B == sheet_id: 0,
#'                  start_row_index: 4,
#'                  start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1 == sheet_id:0`
#' 
#' The start index must always be less than or equal to the end index.
#' If the start index equals the end index, then the range is empty.
#' Empty ranges are typically not meaningful and are usually rendered in the
#' UI as `#REF!`.
#' @param shiftDimension string. The dimension from which deleted cells will be replaced with.
#' If ROWS, existing cells will be shifted upward to
#' replace the deleted cells. If COLUMNS, existing cells
#' will be shifted left to replace the deleted cells. shiftDimension must take one of the following values: DIMENSION_UNSPECIFIED, ROWS, COLUMNS
#' See the details section for the definition of each of these values.
#' @return DeleteRangeRequest
#' @export
gsv4_DeleteRangeRequest <- function(range=NULL, shiftDimension=NULL){

  params_data <- list()

  if(!is.null(range)){
  stopifnot(is.na(range) || class(range) == 'GridRange')
    params_data[['range']] <- range
  }
  if(!is.null(shiftDimension)){
  stopifnot(is.na(shiftDimension) || is.character(shiftDimension))
    params_data[['shiftDimension']] <- unbox(shiftDimension)
  }

  obj <- structure(params_data, class = "DeleteRangeRequest")
  return(obj)
}
#' 
#' gsv4_DeleteSheetRequest
#' 
#' Deletes the requested sheet.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#DeleteSheetRequest}{Google's Documentation for DeleteSheetRequest}
#' @param sheetId integer. The ID of the sheet to delete.
#' @return DeleteSheetRequest
#' @export
gsv4_DeleteSheetRequest <- function(sheetId=NULL){

  params_data <- list()

  if(!is.null(sheetId)){
  stopifnot(is.na(sheetId) || all.equal(sheetId, as.integer(sheetId)))
    params_data[['sheetId']] <- unbox(sheetId)
  }

  obj <- structure(params_data, class = "DeleteSheetRequest")
  return(obj)
}
#' 
#' gsv4_DimensionProperties
#' 
#' Properties about a dimension.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#DimensionProperties}{Google's Documentation for DimensionProperties}
#' @param hiddenByFilter logical. TRUE if this dimension is being filtered.
#' This field is read-only.
#' @param hiddenByUser logical. TRUE if this dimension is explicitly hidden.
#' @param pixelSize integer. The height (if a row) or width (if a column) of the dimension in pixels.
#' @return DimensionProperties
#' @export
gsv4_DimensionProperties <- function(hiddenByFilter=NULL, hiddenByUser=NULL, pixelSize=NULL){

  params_data <- list()

  if(!is.null(hiddenByFilter)){
  stopifnot(is.na(hiddenByFilter) || is.logical(hiddenByFilter))
    params_data[['hiddenByFilter']] <- unbox(hiddenByFilter)
  }
  if(!is.null(hiddenByUser)){
  stopifnot(is.na(hiddenByUser) || is.logical(hiddenByUser))
    params_data[['hiddenByUser']] <- unbox(hiddenByUser)
  }
  if(!is.null(pixelSize)){
  stopifnot(is.na(pixelSize) || all.equal(pixelSize, as.integer(pixelSize)))
    params_data[['pixelSize']] <- unbox(pixelSize)
  }

  obj <- structure(params_data, class = "DimensionProperties")
  return(obj)
}
#' 
#' gsv4_DimensionRange
#' 
#' A range along a single dimension on a sheet.
#' All indexes are zero-based.
#' Indexes are half open: the start index is inclusive
#' and the end index is exclusive.
#' Missing indexes indicate the range is unbounded on that side.
#' 
#' dimension takes one of the following values:
#' \itemize{
#'  \item{DIMENSION_UNSPECIFIED - The default value, do not use.}
#'  \item{ROWS - Operates on the rows of a sheet.}
#'  \item{COLUMNS - Operates on the columns of a sheet.}
#' }
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#DimensionRange}{Google's Documentation for DimensionRange}
#' @param sheetId integer. The sheet this span is on.
#' @param dimension string. The dimension of the span. dimension must take one of the following values: DIMENSION_UNSPECIFIED, ROWS, COLUMNS
#' See the details section for the definition of each of these values.
#' @param endIndex integer. The end (exclusive) of the span, or not set if unbounded.
#' @param startIndex integer. The start (inclusive) of the span, or not set if unbounded.
#' @return DimensionRange
#' @export
gsv4_DimensionRange <- function(sheetId=NULL, dimension=NULL, endIndex=NULL, startIndex=NULL){

  params_data <- list()

  if(!is.null(sheetId)){
  stopifnot(is.na(sheetId) || all.equal(sheetId, as.integer(sheetId)))
    params_data[['sheetId']] <- unbox(sheetId)
  }
  if(!is.null(dimension)){
  stopifnot(is.na(dimension) || is.character(dimension))
    params_data[['dimension']] <- unbox(dimension)
  }
  if(!is.null(endIndex)){
  stopifnot(is.na(endIndex) || all.equal(endIndex, as.integer(endIndex)))
    params_data[['endIndex']] <- unbox(endIndex)
  }
  if(!is.null(startIndex)){
  stopifnot(is.na(startIndex) || all.equal(startIndex, as.integer(startIndex)))
    params_data[['startIndex']] <- unbox(startIndex)
  }

  obj <- structure(params_data, class = "DimensionRange")
  return(obj)
}
#' 
#' gsv4_DuplicateFilterViewRequest
#' 
#' Duplicates a particular filter view.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#DuplicateFilterViewRequest}{Google's Documentation for DuplicateFilterViewRequest}
#' @param filterId integer. The ID of the filter being duplicated.
#' @return DuplicateFilterViewRequest
#' @export
gsv4_DuplicateFilterViewRequest <- function(filterId=NULL){

  params_data <- list()

  if(!is.null(filterId)){
  stopifnot(is.na(filterId) || all.equal(filterId, as.integer(filterId)))
    params_data[['filterId']] <- unbox(filterId)
  }

  obj <- structure(params_data, class = "DuplicateFilterViewRequest")
  return(obj)
}
#' 
#' gsv4_DuplicateSheetRequest
#' 
#' Duplicates the contents of a sheet.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#DuplicateSheetRequest}{Google's Documentation for DuplicateSheetRequest}
#' @param insertSheetIndex integer. The zero-based index where the new sheet should be inserted.
#' The index of all sheets after this are incremented.
#' @param newSheetId integer. If set, the ID of the new sheet. If not set, an ID is chosen.
#' If set, the ID must not conflict with any existing sheet ID.
#' If set, it must be non-negative.
#' @param newSheetName string. The name of the new sheet.  If empty, a new name is chosen for you.
#' @param sourceSheetId integer. The sheet to duplicate.
#' @return DuplicateSheetRequest
#' @export
gsv4_DuplicateSheetRequest <- function(insertSheetIndex=NULL, newSheetId=NULL, newSheetName=NULL, sourceSheetId=NULL){

  params_data <- list()

  if(!is.null(insertSheetIndex)){
  stopifnot(is.na(insertSheetIndex) || all.equal(insertSheetIndex, as.integer(insertSheetIndex)))
    params_data[['insertSheetIndex']] <- unbox(insertSheetIndex)
  }
  if(!is.null(newSheetId)){
  stopifnot(is.na(newSheetId) || all.equal(newSheetId, as.integer(newSheetId)))
    params_data[['newSheetId']] <- unbox(newSheetId)
  }
  if(!is.null(newSheetName)){
  stopifnot(is.na(newSheetName) || is.character(newSheetName))
    params_data[['newSheetName']] <- unbox(newSheetName)
  }
  if(!is.null(sourceSheetId)){
  stopifnot(is.na(sourceSheetId) || all.equal(sourceSheetId, as.integer(sourceSheetId)))
    params_data[['sourceSheetId']] <- unbox(sourceSheetId)
  }

  obj <- structure(params_data, class = "DuplicateSheetRequest")
  return(obj)
}
#' 
#' gsv4_Editors
#' 
#' The editors of a protected range.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#Editors}{Google's Documentation for Editors}
#' @param domainUsersCanEdit logical. TRUE if anyone in the document's domain has edit access to the protected
#' range.  Domain protection is only supported on documents within a domain.
#' @param groups list. The email addresses of groups with edit access to the protected range.
#' @param users list. The email addresses of users with edit access to the protected range.
#' @return Editors
#' @export
gsv4_Editors <- function(domainUsersCanEdit=NULL, groups=NULL, users=NULL){

  params_data <- list()

  if(!is.null(domainUsersCanEdit)){
  stopifnot(is.na(domainUsersCanEdit) || is.logical(domainUsersCanEdit))
    params_data[['domainUsersCanEdit']] <- unbox(domainUsersCanEdit)
  }
  if(!is.null(groups)){
  stopifnot(is.na(groups) || class(groups) == 'list' || class(groups) == 'data.frame')
    params_data[['groups']] <- groups
  }
  if(!is.null(users)){
  stopifnot(is.na(users) || class(users) == 'list' || class(users) == 'data.frame')
    params_data[['users']] <- users
  }

  obj <- structure(params_data, class = "Editors")
  return(obj)
}
#' 
#' gsv4_EmbeddedChart
#' 
#' A chart embedded in a sheet.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#EmbeddedChart}{Google's Documentation for EmbeddedChart}
#' @param chartId integer. The ID of the chart.
#' @param position \code{\link{gsv4_EmbeddedObjectPosition}} object. The position of an embedded object such as a chart.
#' @param spec \code{\link{gsv4_ChartSpec}} object. The specifications of a chart.
#' @return EmbeddedChart
#' @export
gsv4_EmbeddedChart <- function(chartId=NULL, position=NULL, spec=NULL){

  params_data <- list()

  if(!is.null(chartId)){
  stopifnot(is.na(chartId) || all.equal(chartId, as.integer(chartId)))
    params_data[['chartId']] <- unbox(chartId)
  }
  if(!is.null(position)){
  stopifnot(is.na(position) || class(position) == 'EmbeddedObjectPosition')
    params_data[['position']] <- position
  }
  if(!is.null(spec)){
  stopifnot(is.na(spec) || class(spec) == 'ChartSpec')
    params_data[['spec']] <- spec
  }

  obj <- structure(params_data, class = "EmbeddedChart")
  return(obj)
}
#' 
#' gsv4_EmbeddedObjectPosition
#' 
#' The position of an embedded object such as a chart.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#EmbeddedObjectPosition}{Google's Documentation for EmbeddedObjectPosition}
#' @param sheetId integer. The sheet this is on. Set only if the embedded object
#' is on its own sheet. Must be non-negative.
#' @param newSheet logical. If TRUE, the embedded object will be put on a new sheet whose ID
#' is chosen for you. Used only when writing.
#' @param overlayPosition \code{\link{gsv4_OverlayPosition}} object. The location an object is overlaid on top of a grid.
#' @return EmbeddedObjectPosition
#' @export
gsv4_EmbeddedObjectPosition <- function(sheetId=NULL, newSheet=NULL, overlayPosition=NULL){

  params_data <- list()

  if(!is.null(sheetId)){
  stopifnot(is.na(sheetId) || all.equal(sheetId, as.integer(sheetId)))
    params_data[['sheetId']] <- unbox(sheetId)
  }
  if(!is.null(newSheet)){
  stopifnot(is.na(newSheet) || is.logical(newSheet))
    params_data[['newSheet']] <- unbox(newSheet)
  }
  if(!is.null(overlayPosition)){
  stopifnot(is.na(overlayPosition) || class(overlayPosition) == 'OverlayPosition')
    params_data[['overlayPosition']] <- overlayPosition
  }

  obj <- structure(params_data, class = "EmbeddedObjectPosition")
  return(obj)
}
#' 
#' gsv4_ErrorValue
#' 
#' An error in a cell.
#' 
#' type takes one of the following values:
#' \itemize{
#'  \item{ERROR_TYPE_UNSPECIFIED - The default error type, do not use this.}
#'  \item{ERROR - Corresponds to the `#ERROR!` error.}
#'  \item{NULL_VALUE - Corresponds to the `#NULL!` error.}
#'  \item{DIVIDE_BY_ZERO - Corresponds to the `#DIV/0` error.}
#'  \item{VALUE - Corresponds to the `#VALUE!` error.}
#'  \item{REF - Corresponds to the `#REF!` error.}
#'  \item{NAME - Corresponds to the `#NAME?` error.}
#'  \item{NUM - Corresponds to the `#NUM!` error.}
#'  \item{N_A - Corresponds to the `#N/A` error.}
#'  \item{LOADING - Corresponds to the `Loading...` state.}
#' }
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#ErrorValue}{Google's Documentation for ErrorValue}
#' @param message string. A message with more information about the error
#' (in the spreadsheet's locale).
#' @param type string. The type of error. type must take one of the following values: ERROR_TYPE_UNSPECIFIED, ERROR, NULL_VALUE, DIVIDE_BY_ZERO, VALUE, REF, NAME, NUM, N_A, LOADING
#' See the details section for the definition of each of these values.
#' @return ErrorValue
#' @export
gsv4_ErrorValue <- function(message=NULL, type=NULL){

  params_data <- list()

  if(!is.null(message)){
  stopifnot(is.na(message) || is.character(message))
    params_data[['message']] <- unbox(message)
  }
  if(!is.null(type)){
  stopifnot(is.na(type) || is.character(type))
    params_data[['type']] <- unbox(type)
  }

  obj <- structure(params_data, class = "ErrorValue")
  return(obj)
}
#' 
#' gsv4_ExtendedValue
#' 
#' The kinds of value that a cell in a spreadsheet can have.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#ExtendedValue}{Google's Documentation for ExtendedValue}
#' @param boolValue logical. Represents a boolean value.
#' @param errorValue \code{\link{gsv4_ErrorValue}} object. An error in a cell.
#' @param formulaValue string. Represents a formula.
#' @param numberValue numeric. Represents a double value.
#' Note: Dates, Times and DateTimes are represented as doubles in
#' "serial number" format.
#' @param stringValue string. Represents a string value.
#' Leading single quotes are not included. For example, if the user typed
#' `'123` into the UI, this would be represented as a `stringValue` of
#' `"123"`.
#' @return ExtendedValue
#' @export
gsv4_ExtendedValue <- function(boolValue=NULL, errorValue=NULL, formulaValue=NULL, numberValue=NULL, stringValue=NULL){

  params_data <- list()

  if(!is.null(boolValue)){
  stopifnot(is.na(boolValue) || is.logical(boolValue))
    params_data[['boolValue']] <- unbox(boolValue)
  }
  if(!is.null(errorValue)){
  stopifnot(is.na(errorValue) || class(errorValue) == 'ErrorValue')
    params_data[['errorValue']] <- errorValue
  }
  if(!is.null(formulaValue)){
  stopifnot(is.na(formulaValue) || is.character(formulaValue))
    params_data[['formulaValue']] <- unbox(formulaValue)
  }
  if(!is.null(numberValue)){
  stopifnot(is.na(numberValue) || is.numeric(numberValue))
    params_data[['numberValue']] <- unbox(numberValue)
  }
  if(!is.null(stringValue)){
  stopifnot(is.na(stringValue) || is.character(stringValue))
    params_data[['stringValue']] <- unbox(stringValue)
  }

  obj <- structure(params_data, class = "ExtendedValue")
  return(obj)
}
#' 
#' gsv4_FilterCriteria
#' 
#' Criteria for showing/hiding rows in a filter or filter view.
#' 
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#FilterCriteria}{Google's Documentation for FilterCriteria}
#' @param condition \code{\link{gsv4_BooleanCondition}} object. A condition that can evaluate to TRUE or FALSE.
#' BooleanConditions are used by conditional formatting,
#' data validation, and the criteria in filters.
#' @param hiddenValues list. Values that should be hidden.
#' @return FilterCriteria
#' @export
gsv4_FilterCriteria <- function(condition=NULL, hiddenValues=NULL){

  params_data <- list()

  if(!is.null(condition)){
  stopifnot(is.na(condition) || class(condition) == 'BooleanCondition')
    params_data[['condition']] <- condition
  }
  if(!is.null(hiddenValues)){
  stopifnot(is.na(hiddenValues) || class(hiddenValues) == 'list' || class(hiddenValues) == 'data.frame')
    params_data[['hiddenValues']] <- hiddenValues
  }

  obj <- structure(params_data, class = "FilterCriteria")
  return(obj)
}
#' 
#' gsv4_FilterView
#' 
#' A filter view.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#FilterView}{Google's Documentation for FilterView}
#' @param range \code{\link{gsv4_GridRange}} object. A range on a sheet.
#' All indexes are zero-based.
#' Indexes are half open, e.g the start index is inclusive
#' and the end index is exclusive -- [start_index, end_index).
#' Missing indexes indicate the range is unbounded on that side.
#' 
#' For example, if `"Sheet1"` is sheet ID 0, then:
#' 
#'   `Sheet1!A1:A1 == sheet_id: 0,
#'                   start_row_index: 0, end_row_index: 1,
#'                   start_column_index: 0, end_column_index: 1`
#' 
#'   `Sheet1!A3:B4 == sheet_id: 0,
#'                   start_row_index: 2, end_row_index: 4,
#'                   start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1!A:B == sheet_id: 0,
#'                 start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1!A5:B == sheet_id: 0,
#'                  start_row_index: 4,
#'                  start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1 == sheet_id:0`
#' 
#' The start index must always be less than or equal to the end index.
#' If the start index equals the end index, then the range is empty.
#' Empty ranges are typically not meaningful and are usually rendered in the
#' UI as `#REF!`.
#' @param criteria list or data.frame of \code{\link{gsv4_FilterCriteria}} objects. The criteria for showing/hiding values per column.
#' The map's key is the column index, and the value is the criteria for
#' that column.
#' @param filterViewId integer. The ID of the filter view.
#' @param namedRangeId string. The named range this filter view is backed by, if any.
#' 
#' When writing, only one of range or named_range_id
#' may be set.
#' @param sortSpecs list of \code{\link{gsv4_SortSpec}} objects. The sort order per column. Later specifications are used when values
#' are equal in the earlier specifications.
#' @param title string. The name of the filter view.
#' @return FilterView
#' @export
gsv4_FilterView <- function(range=NULL, criteria=NULL, filterViewId=NULL, namedRangeId=NULL, sortSpecs=NULL, title=NULL){

  params_data <- list()

  if(!is.null(range)){
  stopifnot(is.na(range) || class(range) == 'GridRange')
    params_data[['range']] <- range
  }
  if(!is.null(criteria)){
  stopifnot(is.na(criteria) || class(criteria) == 'list' || class(criteria) == 'data.frame')
    params_data[['criteria']] <- criteria
  }
  if(!is.null(filterViewId)){
  stopifnot(is.na(filterViewId) || all.equal(filterViewId, as.integer(filterViewId)))
    params_data[['filterViewId']] <- unbox(filterViewId)
  }
  if(!is.null(namedRangeId)){
  stopifnot(is.na(namedRangeId) || is.character(namedRangeId))
    params_data[['namedRangeId']] <- unbox(namedRangeId)
  }
  if(!is.null(sortSpecs)){
  stopifnot(is.na(sortSpecs) || class(sortSpecs) == 'list' || class(sortSpecs) == 'data.frame')
    params_data[['sortSpecs']] <- sortSpecs
  }
  if(!is.null(title)){
  stopifnot(is.na(title) || is.character(title))
    params_data[['title']] <- unbox(title)
  }

  obj <- structure(params_data, class = "FilterView")
  return(obj)
}
#' 
#' gsv4_FindReplaceRequest
#' 
#' Finds and replaces data in cells over a range, sheet, or all sheets.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#FindReplaceRequest}{Google's Documentation for FindReplaceRequest}
#' @param sheetId integer. The sheet to find/replace over.
#' @param range \code{\link{gsv4_GridRange}} object. A range on a sheet.
#' All indexes are zero-based.
#' Indexes are half open, e.g the start index is inclusive
#' and the end index is exclusive -- [start_index, end_index).
#' Missing indexes indicate the range is unbounded on that side.
#' 
#' For example, if `"Sheet1"` is sheet ID 0, then:
#' 
#'   `Sheet1!A1:A1 == sheet_id: 0,
#'                   start_row_index: 0, end_row_index: 1,
#'                   start_column_index: 0, end_column_index: 1`
#' 
#'   `Sheet1!A3:B4 == sheet_id: 0,
#'                   start_row_index: 2, end_row_index: 4,
#'                   start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1!A:B == sheet_id: 0,
#'                 start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1!A5:B == sheet_id: 0,
#'                  start_row_index: 4,
#'                  start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1 == sheet_id:0`
#' 
#' The start index must always be less than or equal to the end index.
#' If the start index equals the end index, then the range is empty.
#' Empty ranges are typically not meaningful and are usually rendered in the
#' UI as `#REF!`.
#' @param allSheets logical. TRUE to find/replace over all sheets.
#' @param find string. The value to search.
#' @param includeFormulas logical. TRUE if the search should include cells with formulas.
#' FALSE to skip cells with formulas.
#' @param matchCase logical. TRUE if the search is case sensitive.
#' @param matchEntireCell logical. TRUE if the find value should match the entire cell.
#' @param replacement string. The value to use as the replacement.
#' @param searchByRegex logical. TRUE if the find value is a regex.
#' The regular expression and replacement should follow Java regex rules
#' at https://docs.oracle.com/javase/8/docs/api/java/util/regex/Pattern.html.
#' The replacement string is allowed to refer to capturing groups.
#' For example, if one cell has the contents `"Google Sheets"` and another
#' has `"Google Docs"`, then searching for `"o.* (.*)"` with a replacement of
#' `"$1 Rocks"` would change the contents of the cells to
#' `"GSheets Rocks"` and `"GDocs Rocks"` respectively.
#' @return FindReplaceRequest
#' @export
gsv4_FindReplaceRequest <- function(sheetId=NULL, range=NULL, allSheets=NULL, find=NULL, includeFormulas=NULL, matchCase=NULL, matchEntireCell=NULL, replacement=NULL, searchByRegex=NULL){

  params_data <- list()

  if(!is.null(sheetId)){
  stopifnot(is.na(sheetId) || all.equal(sheetId, as.integer(sheetId)))
    params_data[['sheetId']] <- unbox(sheetId)
  }
  if(!is.null(range)){
  stopifnot(is.na(range) || class(range) == 'GridRange')
    params_data[['range']] <- range
  }
  if(!is.null(allSheets)){
  stopifnot(is.na(allSheets) || is.logical(allSheets))
    params_data[['allSheets']] <- unbox(allSheets)
  }
  if(!is.null(find)){
  stopifnot(is.na(find) || is.character(find))
    params_data[['find']] <- unbox(find)
  }
  if(!is.null(includeFormulas)){
  stopifnot(is.na(includeFormulas) || is.logical(includeFormulas))
    params_data[['includeFormulas']] <- unbox(includeFormulas)
  }
  if(!is.null(matchCase)){
  stopifnot(is.na(matchCase) || is.logical(matchCase))
    params_data[['matchCase']] <- unbox(matchCase)
  }
  if(!is.null(matchEntireCell)){
  stopifnot(is.na(matchEntireCell) || is.logical(matchEntireCell))
    params_data[['matchEntireCell']] <- unbox(matchEntireCell)
  }
  if(!is.null(replacement)){
  stopifnot(is.na(replacement) || is.character(replacement))
    params_data[['replacement']] <- unbox(replacement)
  }
  if(!is.null(searchByRegex)){
  stopifnot(is.na(searchByRegex) || is.logical(searchByRegex))
    params_data[['searchByRegex']] <- unbox(searchByRegex)
  }

  obj <- structure(params_data, class = "FindReplaceRequest")
  return(obj)
}
#' 
#' gsv4_GradientRule
#' 
#' A rule that applies a gradient color scale format, based on
#' the interpolation points listed. The format of a cell will vary
#' based on its contents as compared to the values of the interpolation
#' points.
#' 
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#GradientRule}{Google's Documentation for GradientRule}
#' @param maxpoint \code{\link{gsv4_InterpolationPoint}} object. A single interpolation point on a gradient conditional format.
#' These pin the gradient color scale according to the color,
#' type and value chosen.
#' @param midpoint \code{\link{gsv4_InterpolationPoint}} object. A single interpolation point on a gradient conditional format.
#' These pin the gradient color scale according to the color,
#' type and value chosen.
#' @param minpoint \code{\link{gsv4_InterpolationPoint}} object. A single interpolation point on a gradient conditional format.
#' These pin the gradient color scale according to the color,
#' type and value chosen.
#' @return GradientRule
#' @export
gsv4_GradientRule <- function(maxpoint=NULL, midpoint=NULL, minpoint=NULL){

  params_data <- list()

  if(!is.null(maxpoint)){
  stopifnot(is.na(maxpoint) || class(maxpoint) == 'InterpolationPoint')
    params_data[['maxpoint']] <- maxpoint
  }
  if(!is.null(midpoint)){
  stopifnot(is.na(midpoint) || class(midpoint) == 'InterpolationPoint')
    params_data[['midpoint']] <- midpoint
  }
  if(!is.null(minpoint)){
  stopifnot(is.na(minpoint) || class(minpoint) == 'InterpolationPoint')
    params_data[['minpoint']] <- minpoint
  }

  obj <- structure(params_data, class = "GradientRule")
  return(obj)
}
#' 
#' gsv4_GridCoordinate
#' 
#' A coordinate in a sheet.
#' All indexes are zero-based.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#GridCoordinate}{Google's Documentation for GridCoordinate}
#' @param sheetId integer. The sheet this coordinate is on.
#' @param columnIndex integer. The column index of the coordinate.
#' @param rowIndex integer. The row index of the coordinate.
#' @return GridCoordinate
#' @export
gsv4_GridCoordinate <- function(sheetId=NULL, columnIndex=NULL, rowIndex=NULL){

  params_data <- list()

  if(!is.null(sheetId)){
  stopifnot(is.na(sheetId) || all.equal(sheetId, as.integer(sheetId)))
    params_data[['sheetId']] <- unbox(sheetId)
  }
  if(!is.null(columnIndex)){
  stopifnot(is.na(columnIndex) || all.equal(columnIndex, as.integer(columnIndex)))
    params_data[['columnIndex']] <- unbox(columnIndex)
  }
  if(!is.null(rowIndex)){
  stopifnot(is.na(rowIndex) || all.equal(rowIndex, as.integer(rowIndex)))
    params_data[['rowIndex']] <- unbox(rowIndex)
  }

  obj <- structure(params_data, class = "GridCoordinate")
  return(obj)
}
#' 
#' gsv4_GridData
#' 
#' Data in the grid, as well as metadata about the dimensions.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#GridData}{Google's Documentation for GridData}
#' @param columnMetadata list of \code{\link{gsv4_DimensionProperties}} objects. Metadata about the requested columns in the grid, starting with the column
#' in start_column.
#' @param rowData list of \code{\link{gsv4_RowData}} objects. The data in the grid, one entry per row,
#' starting with the row in startRow.
#' The values in RowData will correspond to columns starting
#' at start_column.
#' @param rowMetadata list of \code{\link{gsv4_DimensionProperties}} objects. Metadata about the requested rows in the grid, starting with the row
#' in start_row.
#' @param startColumn integer. The first column this GridData refers to, zero-based.
#' @param startRow integer. The first row this GridData refers to, zero-based.
#' @return GridData
#' @export
gsv4_GridData <- function(columnMetadata=NULL, rowData=NULL, rowMetadata=NULL, startColumn=NULL, startRow=NULL){

  params_data <- list()

  if(!is.null(columnMetadata)){
  stopifnot(is.na(columnMetadata) || class(columnMetadata) == 'list' || class(columnMetadata) == 'data.frame')
    params_data[['columnMetadata']] <- columnMetadata
  }
  if(!is.null(rowData)){
  stopifnot(is.na(rowData) || class(rowData) == 'list' || class(rowData) == 'data.frame')
    params_data[['rowData']] <- rowData
  }
  if(!is.null(rowMetadata)){
  stopifnot(is.na(rowMetadata) || class(rowMetadata) == 'list' || class(rowMetadata) == 'data.frame')
    params_data[['rowMetadata']] <- rowMetadata
  }
  if(!is.null(startColumn)){
  stopifnot(is.na(startColumn) || all.equal(startColumn, as.integer(startColumn)))
    params_data[['startColumn']] <- unbox(startColumn)
  }
  if(!is.null(startRow)){
  stopifnot(is.na(startRow) || all.equal(startRow, as.integer(startRow)))
    params_data[['startRow']] <- unbox(startRow)
  }

  obj <- structure(params_data, class = "GridData")
  return(obj)
}
#' 
#' gsv4_GridProperties
#' 
#' Properties of a grid.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#GridProperties}{Google's Documentation for GridProperties}
#' @param columnCount integer. The number of columns in the grid.
#' @param frozenColumnCount integer. The number of columns that are frozen in the grid.
#' @param frozenRowCount integer. The number of rows that are frozen in the grid.
#' @param hideGridlines logical. TRUE if the grid isn't showing gridlines in the UI.
#' @param rowCount integer. The number of rows in the grid.
#' @return GridProperties
#' @export
gsv4_GridProperties <- function(columnCount=NULL, frozenColumnCount=NULL, frozenRowCount=NULL, hideGridlines=NULL, rowCount=NULL){

  params_data <- list()

  if(!is.null(columnCount)){
  stopifnot(is.na(columnCount) || all.equal(columnCount, as.integer(columnCount)))
    params_data[['columnCount']] <- unbox(columnCount)
  }
  if(!is.null(frozenColumnCount)){
  stopifnot(is.na(frozenColumnCount) || all.equal(frozenColumnCount, as.integer(frozenColumnCount)))
    params_data[['frozenColumnCount']] <- unbox(frozenColumnCount)
  }
  if(!is.null(frozenRowCount)){
  stopifnot(is.na(frozenRowCount) || all.equal(frozenRowCount, as.integer(frozenRowCount)))
    params_data[['frozenRowCount']] <- unbox(frozenRowCount)
  }
  if(!is.null(hideGridlines)){
  stopifnot(is.na(hideGridlines) || is.logical(hideGridlines))
    params_data[['hideGridlines']] <- unbox(hideGridlines)
  }
  if(!is.null(rowCount)){
  stopifnot(is.na(rowCount) || all.equal(rowCount, as.integer(rowCount)))
    params_data[['rowCount']] <- unbox(rowCount)
  }

  obj <- structure(params_data, class = "GridProperties")
  return(obj)
}
#' 
#' gsv4_GridRange
#' 
#' A range on a sheet.
#' All indexes are zero-based.
#' Indexes are half open, e.g the start index is inclusive
#' and the end index is exclusive -- [start_index, end_index).
#' Missing indexes indicate the range is unbounded on that side.
#' 
#' For example, if `"Sheet1"` is sheet ID 0, then:
#' 
#'   `Sheet1!A1:A1 == sheet_id: 0,
#'                   start_row_index: 0, end_row_index: 1,
#'                   start_column_index: 0, end_column_index: 1`
#' 
#'   `Sheet1!A3:B4 == sheet_id: 0,
#'                   start_row_index: 2, end_row_index: 4,
#'                   start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1!A:B == sheet_id: 0,
#'                 start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1!A5:B == sheet_id: 0,
#'                  start_row_index: 4,
#'                  start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1 == sheet_id:0`
#' 
#' The start index must always be less than or equal to the end index.
#' If the start index equals the end index, then the range is empty.
#' Empty ranges are typically not meaningful and are usually rendered in the
#' UI as `#REF!`.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#GridRange}{Google's Documentation for GridRange}
#' @param sheetId integer. The sheet this range is on.
#' @param endColumnIndex integer. The end column (exclusive) of the range, or not set if unbounded.
#' @param endRowIndex integer. The end row (exclusive) of the range, or not set if unbounded.
#' @param startColumnIndex integer. The start column (inclusive) of the range, or not set if unbounded.
#' @param startRowIndex integer. The start row (inclusive) of the range, or not set if unbounded.
#' @return GridRange
#' @export
gsv4_GridRange <- function(sheetId=NULL, endColumnIndex=NULL, endRowIndex=NULL, startColumnIndex=NULL, startRowIndex=NULL){

  params_data <- list()

  if(!is.null(sheetId)){
  stopifnot(is.na(sheetId) || all.equal(sheetId, as.integer(sheetId)))
    params_data[['sheetId']] <- unbox(sheetId)
  }
  if(!is.null(endColumnIndex)){
  stopifnot(is.na(endColumnIndex) || all.equal(endColumnIndex, as.integer(endColumnIndex)))
    params_data[['endColumnIndex']] <- unbox(endColumnIndex)
  }
  if(!is.null(endRowIndex)){
  stopifnot(is.na(endRowIndex) || all.equal(endRowIndex, as.integer(endRowIndex)))
    params_data[['endRowIndex']] <- unbox(endRowIndex)
  }
  if(!is.null(startColumnIndex)){
  stopifnot(is.na(startColumnIndex) || all.equal(startColumnIndex, as.integer(startColumnIndex)))
    params_data[['startColumnIndex']] <- unbox(startColumnIndex)
  }
  if(!is.null(startRowIndex)){
  stopifnot(is.na(startRowIndex) || all.equal(startRowIndex, as.integer(startRowIndex)))
    params_data[['startRowIndex']] <- unbox(startRowIndex)
  }

  obj <- structure(params_data, class = "GridRange")
  return(obj)
}
#' 
#' gsv4_InsertDimensionRequest
#' 
#' Inserts rows or columns in a sheet at a particular index.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#InsertDimensionRequest}{Google's Documentation for InsertDimensionRequest}
#' @param range \code{\link{gsv4_DimensionRange}} object. A range along a single dimension on a sheet.
#' All indexes are zero-based.
#' Indexes are half open: the start index is inclusive
#' and the end index is exclusive.
#' Missing indexes indicate the range is unbounded on that side.
#' @param inheritFromBefore logical. Whether dimension properties should be extended from the dimensions
#' before or after the newly inserted dimensions.
#' TRUE to inherit from the dimensions before (in which case the start
#' index must be greater than 0), and FALSE to inherit from the dimensions
#' after.
#' 
#' For example, if row index 0 has red background and row index 1
#' has a green background, then inserting 2 rows at index 1 can inherit
#' either the green or red background.  If `inheritFromBefore` is TRUE,
#' the two new rows will be red (because the row before the insertion point
#' was red), whereas if `inheritFromBefore` is FALSE, the two new rows will
#' be green (because the row after the insertion point was green).
#' @return InsertDimensionRequest
#' @export
gsv4_InsertDimensionRequest <- function(range=NULL, inheritFromBefore=NULL){

  params_data <- list()

  if(!is.null(range)){
  stopifnot(is.na(range) || class(range) == 'DimensionRange')
    params_data[['range']] <- range
  }
  if(!is.null(inheritFromBefore)){
  stopifnot(is.na(inheritFromBefore) || is.logical(inheritFromBefore))
    params_data[['inheritFromBefore']] <- unbox(inheritFromBefore)
  }

  obj <- structure(params_data, class = "InsertDimensionRequest")
  return(obj)
}
#' 
#' gsv4_InsertRangeRequest
#' 
#' Inserts cells into a range, shifting the existing cells over or down.
#' 
#' shiftDimension takes one of the following values:
#' \itemize{
#'  \item{DIMENSION_UNSPECIFIED - The default value, do not use.}
#'  \item{ROWS - Operates on the rows of a sheet.}
#'  \item{COLUMNS - Operates on the columns of a sheet.}
#' }
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#InsertRangeRequest}{Google's Documentation for InsertRangeRequest}
#' @param range \code{\link{gsv4_GridRange}} object. A range on a sheet.
#' All indexes are zero-based.
#' Indexes are half open, e.g the start index is inclusive
#' and the end index is exclusive -- [start_index, end_index).
#' Missing indexes indicate the range is unbounded on that side.
#' 
#' For example, if `"Sheet1"` is sheet ID 0, then:
#' 
#'   `Sheet1!A1:A1 == sheet_id: 0,
#'                   start_row_index: 0, end_row_index: 1,
#'                   start_column_index: 0, end_column_index: 1`
#' 
#'   `Sheet1!A3:B4 == sheet_id: 0,
#'                   start_row_index: 2, end_row_index: 4,
#'                   start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1!A:B == sheet_id: 0,
#'                 start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1!A5:B == sheet_id: 0,
#'                  start_row_index: 4,
#'                  start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1 == sheet_id:0`
#' 
#' The start index must always be less than or equal to the end index.
#' If the start index equals the end index, then the range is empty.
#' Empty ranges are typically not meaningful and are usually rendered in the
#' UI as `#REF!`.
#' @param shiftDimension string. The dimension which will be shifted when inserting cells.
#' If ROWS, existing cells will be shifted down.
#' If COLUMNS, existing cells will be shifted right. shiftDimension must take one of the following values: DIMENSION_UNSPECIFIED, ROWS, COLUMNS
#' See the details section for the definition of each of these values.
#' @return InsertRangeRequest
#' @export
gsv4_InsertRangeRequest <- function(range=NULL, shiftDimension=NULL){

  params_data <- list()

  if(!is.null(range)){
  stopifnot(is.na(range) || class(range) == 'GridRange')
    params_data[['range']] <- range
  }
  if(!is.null(shiftDimension)){
  stopifnot(is.na(shiftDimension) || is.character(shiftDimension))
    params_data[['shiftDimension']] <- unbox(shiftDimension)
  }

  obj <- structure(params_data, class = "InsertRangeRequest")
  return(obj)
}
#' 
#' gsv4_InterpolationPoint
#' 
#' A single interpolation point on a gradient conditional format.
#' These pin the gradient color scale according to the color,
#' type and value chosen.
#' 
#' type takes one of the following values:
#' \itemize{
#'  \item{INTERPOLATION_POINT_TYPE_UNSPECIFIED - The default value, do not use.}
#'  \item{MIN - The interpolation point will use the minimum value in the
#' cells over the range of the conditional format.}
#'  \item{MAX - The interpolation point will use the maximum value in the
#' cells over the range of the conditional format.}
#'  \item{NUMBER - The interpolation point will use exactly the value in
#' InterpolationPoint.value.}
#'  \item{PERCENT - The interpolation point will be the given percentage over
#' all the cells in the range of the conditional format.
#' This is equivalent to NUMBER if the value was:
#' `=(MAX(FLATTEN(range)) * (value / 100))
#'   + (MIN(FLATTEN(range)) * (1 - (value / 100)))`
#' (where errors in the range are ignored when flattening).}
#'  \item{PERCENTILE - The interpolation point will be the given percentile
#' over all the cells in the range of the conditional format.
#' This is equivalent to NUMBER if the value was:
#' `=PERCENTILE(FLATTEN(range), value / 100)`
#' (where errors in the range are ignored when flattening).}
#' }
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#InterpolationPoint}{Google's Documentation for InterpolationPoint}
#' @param color \code{\link{gsv4_Color}} object. Represents a color in the RGBA color space. This representation is designed
#' for simplicity of conversion to/from color representations in various
#' languages over compactness; for example, the fields of this representation
#' can be trivially provided to the constructor of "java.awt.Color" in Java; it
#' can also be trivially provided to UIColor's "+colorWithRed:green:blue:alpha"
#' method in iOS; and, with just a little work, it can be easily formatted into
#' a CSS "rgba()" string in JavaScript, as well. Here are some examples:
#' 
#' Example (Java):
#' 
#'      import com.google.type.Color;
#' 
#'      // ...
#'      public static java.awt.Color fromProto(Color protocolor) {
#'        float alpha = protocolor.hasAlpha()
#'            ? protocolor.getAlpha().getValue()
#'            : 1.0;
#' 
#'        return new java.awt.Color(
#'            protocolor.getRed(),
#'            protocolor.getGreen(),
#'            protocolor.getBlue(),
#'            alpha);
#'      }
#' 
#'      public static Color toProto(java.awt.Color color) {
#'        float red = (float) color.getRed();
#'        float green = (float) color.getGreen();
#'        float blue = (float) color.getBlue();
#'        float denominator = 255.0;
#'        Color.Builder resultBuilder =
#'            Color
#'                .newBuilder()
#'                .setRed(red / denominator)
#'                .setGreen(green / denominator)
#'                .setBlue(blue / denominator);
#'        int alpha = color.getAlpha();
#'        if (alpha != 255) {
#'          result.setAlpha(
#'              FloatValue
#'                  .newBuilder()
#'                  .setValue(((float) alpha) / denominator)
#'                  .build());
#'        }
#'        return resultBuilder.build();
#'      }
#'      // ...
#' 
#' Example (iOS / Obj-C):
#' 
#'      // ...
#'      static UIColor* fromProto(Color* protocolor) {
#'         float red = [protocolor red];
#'         float green = [protocolor green];
#'         float blue = [protocolor blue];
#'         FloatValue* alpha_wrapper = [protocolor alpha];
#'         float alpha = 1.0;
#'         if (alpha_wrapper != nil) {
#'           alpha = [alpha_wrapper value];
#'         }
#'         return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
#'      }
#' 
#'      static Color* toProto(UIColor* color) {
#'          CGFloat red, green, blue, alpha;
#'          if (![color getRed:&red green:&green blue:&blue alpha:&alpha]) {
#'            return nil;
#'          }
#'          Color* result = [Color alloc] init];
#'          [result setRed:red];
#'          [result setGreen:green];
#'          [result setBlue:blue];
#'          if (alpha <= 0.9999) {
#'            [result setAlpha:floatWrapperWithValue(alpha)];
#'          }
#'          [result autorelease];
#'          return result;
#'     }
#'     // ...
#' 
#'  Example (JavaScript):
#' 
#'     // ...
#' 
#'     var protoToCssColor = function(rgb_color) {
#'        var redFrac = rgb_color.red || 0.0;
#'        var greenFrac = rgb_color.green || 0.0;
#'        var blueFrac = rgb_color.blue || 0.0;
#'        var red = Math.floor(redFrac * 255);
#'        var green = Math.floor(greenFrac * 255);
#'        var blue = Math.floor(blueFrac * 255);
#' 
#'        if (!('alpha' in rgb_color)) {
#'           return rgbToCssColor_(red, green, blue);
#'        }
#' 
#'        var alphaFrac = rgb_color.alpha.value || 0.0;
#'        var rgbParams = [red, green, blue].join(',');
#'        return ['rgba(', rgbParams, ',', alphaFrac, ')'].join('');
#'     };
#' 
#'     var rgbToCssColor_ = function(red, green, blue) {
#'       var rgbNumber = new Number((red << 16) | (green << 8) | blue);
#'       var hexString = rgbNumber.toString(16);
#'       var missingZeros = 6 - hexString.length;
#'       var resultBuilder = ['#'];
#'       for (var i = 0; i < missingZeros; i++) {
#'          resultBuilder.push('0');
#'       }
#'       resultBuilder.push(hexString);
#'       return resultBuilder.join('');
#'     };
#' 
#'     // ...
#' @param type string. How the value should be interpreted. type must take one of the following values: INTERPOLATION_POINT_TYPE_UNSPECIFIED, MIN, MAX, NUMBER, PERCENT, PERCENTILE
#' See the details section for the definition of each of these values.
#' @param value string. The value this interpolation point uses.  May be a formula.
#' Unused if type is MIN or
#' MAX.
#' @return InterpolationPoint
#' @export
gsv4_InterpolationPoint <- function(color=NULL, type=NULL, value=NULL){

  params_data <- list()

  if(!is.null(color)){
  stopifnot(is.na(color) || class(color) == 'Color')
    params_data[['color']] <- color
  }
  if(!is.null(type)){
  stopifnot(is.na(type) || is.character(type))
    params_data[['type']] <- unbox(type)
  }
  if(!is.null(value)){
  stopifnot(is.na(value) || is.character(value))
    params_data[['value']] <- unbox(value)
  }

  obj <- structure(params_data, class = "InterpolationPoint")
  return(obj)
}
#' 
#' gsv4_IterativeCalculationSettings
#' 
#' Settings to control how circular dependencies are resolved with iterative
#' calculation.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#IterativeCalculationSettings}{Google's Documentation for IterativeCalculationSettings}
#' @param convergenceThreshold numeric. When iterative calculation is enabled and successive results differ by
#' less than this threshold value, the calculation rounds stop.
#' @param maxIterations integer. When iterative calculation is enabled, the maximum number of calculation
#' rounds to perform.
#' @return IterativeCalculationSettings
#' @export
gsv4_IterativeCalculationSettings <- function(convergenceThreshold=NULL, maxIterations=NULL){

  params_data <- list()

  if(!is.null(convergenceThreshold)){
  stopifnot(is.na(convergenceThreshold) || is.numeric(convergenceThreshold))
    params_data[['convergenceThreshold']] <- unbox(convergenceThreshold)
  }
  if(!is.null(maxIterations)){
  stopifnot(is.na(maxIterations) || all.equal(maxIterations, as.integer(maxIterations)))
    params_data[['maxIterations']] <- unbox(maxIterations)
  }

  obj <- structure(params_data, class = "IterativeCalculationSettings")
  return(obj)
}
#' 
#' gsv4_MergeCellsRequest
#' 
#' Merges all cells in the range.
#' 
#' mergeType takes one of the following values:
#' \itemize{
#'  \item{MERGE_ALL - Create a single merge from the range}
#'  \item{MERGE_COLUMNS - Create a merge for each column in the range}
#'  \item{MERGE_ROWS - Create a merge for each row in the range}
#' }
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#MergeCellsRequest}{Google's Documentation for MergeCellsRequest}
#' @param range \code{\link{gsv4_GridRange}} object. A range on a sheet.
#' All indexes are zero-based.
#' Indexes are half open, e.g the start index is inclusive
#' and the end index is exclusive -- [start_index, end_index).
#' Missing indexes indicate the range is unbounded on that side.
#' 
#' For example, if `"Sheet1"` is sheet ID 0, then:
#' 
#'   `Sheet1!A1:A1 == sheet_id: 0,
#'                   start_row_index: 0, end_row_index: 1,
#'                   start_column_index: 0, end_column_index: 1`
#' 
#'   `Sheet1!A3:B4 == sheet_id: 0,
#'                   start_row_index: 2, end_row_index: 4,
#'                   start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1!A:B == sheet_id: 0,
#'                 start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1!A5:B == sheet_id: 0,
#'                  start_row_index: 4,
#'                  start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1 == sheet_id:0`
#' 
#' The start index must always be less than or equal to the end index.
#' If the start index equals the end index, then the range is empty.
#' Empty ranges are typically not meaningful and are usually rendered in the
#' UI as `#REF!`.
#' @param mergeType string. How the cells should be merged. mergeType must take one of the following values: MERGE_ALL, MERGE_COLUMNS, MERGE_ROWS
#' See the details section for the definition of each of these values.
#' @return MergeCellsRequest
#' @export
gsv4_MergeCellsRequest <- function(range=NULL, mergeType=NULL){

  params_data <- list()

  if(!is.null(range)){
  stopifnot(is.na(range) || class(range) == 'GridRange')
    params_data[['range']] <- range
  }
  if(!is.null(mergeType)){
  stopifnot(is.na(mergeType) || is.character(mergeType))
    params_data[['mergeType']] <- unbox(mergeType)
  }

  obj <- structure(params_data, class = "MergeCellsRequest")
  return(obj)
}
#' 
#' gsv4_MoveDimensionRequest
#' 
#' Moves one or more rows or columns.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#MoveDimensionRequest}{Google's Documentation for MoveDimensionRequest}
#' @param destinationIndex integer. The zero-based start index of where to move the source data to,
#' based on the coordinates *before* the source data is removed
#' from the grid.  Existing data will be shifted down or right
#' (depending on the dimension) to make room for the moved dimensions.
#' The source dimensions are removed from the grid, so the
#' the data may end up in a different index than specified.
#' 
#' For example, given `A1..A5` of `0, 1, 2, 3, 4` and wanting to move
#' `"1"` and `"2"` to between `"3"` and `"4"`, the source would be
#' `ROWS [1..3)`,and the destination index would be `"4"`
#' (the zero-based index of row 5).
#' The end result would be `A1..A5` of `0, 3, 1, 2, 4`.
#' @param source \code{\link{gsv4_DimensionRange}} object. A range along a single dimension on a sheet.
#' All indexes are zero-based.
#' Indexes are half open: the start index is inclusive
#' and the end index is exclusive.
#' Missing indexes indicate the range is unbounded on that side.
#' @return MoveDimensionRequest
#' @export
gsv4_MoveDimensionRequest <- function(destinationIndex=NULL, source=NULL){

  params_data <- list()

  if(!is.null(destinationIndex)){
  stopifnot(is.na(destinationIndex) || all.equal(destinationIndex, as.integer(destinationIndex)))
    params_data[['destinationIndex']] <- unbox(destinationIndex)
  }
  if(!is.null(source)){
  stopifnot(is.na(source) || class(source) == 'DimensionRange')
    params_data[['source']] <- source
  }

  obj <- structure(params_data, class = "MoveDimensionRequest")
  return(obj)
}
#' 
#' gsv4_NamedRange
#' 
#' A named range.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#NamedRange}{Google's Documentation for NamedRange}
#' @param range \code{\link{gsv4_GridRange}} object. A range on a sheet.
#' All indexes are zero-based.
#' Indexes are half open, e.g the start index is inclusive
#' and the end index is exclusive -- [start_index, end_index).
#' Missing indexes indicate the range is unbounded on that side.
#' 
#' For example, if `"Sheet1"` is sheet ID 0, then:
#' 
#'   `Sheet1!A1:A1 == sheet_id: 0,
#'                   start_row_index: 0, end_row_index: 1,
#'                   start_column_index: 0, end_column_index: 1`
#' 
#'   `Sheet1!A3:B4 == sheet_id: 0,
#'                   start_row_index: 2, end_row_index: 4,
#'                   start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1!A:B == sheet_id: 0,
#'                 start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1!A5:B == sheet_id: 0,
#'                  start_row_index: 4,
#'                  start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1 == sheet_id:0`
#' 
#' The start index must always be less than or equal to the end index.
#' If the start index equals the end index, then the range is empty.
#' Empty ranges are typically not meaningful and are usually rendered in the
#' UI as `#REF!`.
#' @param name string. The name of the named range.
#' @param namedRangeId string. The ID of the named range.
#' @return NamedRange
#' @export
gsv4_NamedRange <- function(range=NULL, name=NULL, namedRangeId=NULL){

  params_data <- list()

  if(!is.null(range)){
  stopifnot(is.na(range) || class(range) == 'GridRange')
    params_data[['range']] <- range
  }
  if(!is.null(name)){
  stopifnot(is.na(name) || is.character(name))
    params_data[['name']] <- unbox(name)
  }
  if(!is.null(namedRangeId)){
  stopifnot(is.na(namedRangeId) || is.character(namedRangeId))
    params_data[['namedRangeId']] <- unbox(namedRangeId)
  }

  obj <- structure(params_data, class = "NamedRange")
  return(obj)
}
#' 
#' gsv4_NumberFormat
#' 
#' The number format of a cell.
#' 
#' type takes one of the following values:
#' \itemize{
#'  \item{NUMBER_FORMAT_TYPE_UNSPECIFIED - The number format is not specified
#' and is based on the contents of the cell.
#' Do not explicitly use this.}
#'  \item{TEXT - Text formatting, e.g `1000.12`}
#'  \item{NUMBER - Number formatting, e.g, `1,000.12`}
#'  \item{PERCENT - Percent formatting, e.g `10.12\%`}
#'  \item{CURRENCY - Currency formatting, e.g `$1,000.12`}
#'  \item{DATE - Date formatting, e.g `9/26/2008`}
#'  \item{TIME - Time formatting, e.g `3:59:00 PM`}
#'  \item{DATE_TIME - Date+Time formatting, e.g `9/26/08 15:59:00`}
#'  \item{SCIENTIFIC - Scientific number formatting, e.g `1.01E+03`}
#' }
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#NumberFormat}{Google's Documentation for NumberFormat}
#' @param pattern string. Pattern string used for formatting.  If not set, a default pattern based on
#' the user's locale will be used if necessary for the given type.
#' See the \href{https://developers.google.com/sheets/api/guides/formats}{Date and Number Formats guide} for more
#' information about the supported patterns.
#' @param type string. The type of the number format.
#' When writing, this field must be set. type must take one of the following values: NUMBER_FORMAT_TYPE_UNSPECIFIED, TEXT, NUMBER, PERCENT, CURRENCY, DATE, TIME, DATE_TIME, SCIENTIFIC
#' See the details section for the definition of each of these values.
#' @return NumberFormat
#' @export
gsv4_NumberFormat <- function(pattern=NULL, type=NULL){

  params_data <- list()

  if(!is.null(pattern)){
  stopifnot(is.na(pattern) || is.character(pattern))
    params_data[['pattern']] <- unbox(pattern)
  }
  if(!is.null(type)){
  stopifnot(is.na(type) || is.character(type))
    params_data[['type']] <- unbox(type)
  }

  obj <- structure(params_data, class = "NumberFormat")
  return(obj)
}
#' 
#' gsv4_OverlayPosition
#' 
#' The location an object is overlaid on top of a grid.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#OverlayPosition}{Google's Documentation for OverlayPosition}
#' @param anchorCell \code{\link{gsv4_GridCoordinate}} object. A coordinate in a sheet.
#' All indexes are zero-based.
#' @param heightPixels integer. The height of the object, in pixels. Defaults to 371.
#' @param offsetXPixels integer. The horizontal offset, in pixels, that the object is offset
#' from the anchor cell.
#' @param offsetYPixels integer. The vertical offset, in pixels, that the object is offset
#' from the anchor cell.
#' @param widthPixels integer. The width of the object, in pixels. Defaults to 600.
#' @return OverlayPosition
#' @export
gsv4_OverlayPosition <- function(anchorCell=NULL, heightPixels=NULL, offsetXPixels=NULL, offsetYPixels=NULL, widthPixels=NULL){

  params_data <- list()

  if(!is.null(anchorCell)){
  stopifnot(is.na(anchorCell) || class(anchorCell) == 'GridCoordinate')
    params_data[['anchorCell']] <- anchorCell
  }
  if(!is.null(heightPixels)){
  stopifnot(is.na(heightPixels) || all.equal(heightPixels, as.integer(heightPixels)))
    params_data[['heightPixels']] <- unbox(heightPixels)
  }
  if(!is.null(offsetXPixels)){
  stopifnot(is.na(offsetXPixels) || all.equal(offsetXPixels, as.integer(offsetXPixels)))
    params_data[['offsetXPixels']] <- unbox(offsetXPixels)
  }
  if(!is.null(offsetYPixels)){
  stopifnot(is.na(offsetYPixels) || all.equal(offsetYPixels, as.integer(offsetYPixels)))
    params_data[['offsetYPixels']] <- unbox(offsetYPixels)
  }
  if(!is.null(widthPixels)){
  stopifnot(is.na(widthPixels) || all.equal(widthPixels, as.integer(widthPixels)))
    params_data[['widthPixels']] <- unbox(widthPixels)
  }

  obj <- structure(params_data, class = "OverlayPosition")
  return(obj)
}
#' 
#' gsv4_Padding
#' 
#' The amount of padding around the cell, in pixels.
#' When updating padding, every field must be specified.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#Padding}{Google's Documentation for Padding}
#' @param bottom integer. The bottom padding of the cell.
#' @param left integer. The left padding of the cell.
#' @param right integer. The right padding of the cell.
#' @param top integer. The top padding of the cell.
#' @return Padding
#' @export
gsv4_Padding <- function(bottom=NULL, left=NULL, right=NULL, top=NULL){

  params_data <- list()

  if(!is.null(bottom)){
  stopifnot(is.na(bottom) || all.equal(bottom, as.integer(bottom)))
    params_data[['bottom']] <- unbox(bottom)
  }
  if(!is.null(left)){
  stopifnot(is.na(left) || all.equal(left, as.integer(left)))
    params_data[['left']] <- unbox(left)
  }
  if(!is.null(right)){
  stopifnot(is.na(right) || all.equal(right, as.integer(right)))
    params_data[['right']] <- unbox(right)
  }
  if(!is.null(top)){
  stopifnot(is.na(top) || all.equal(top, as.integer(top)))
    params_data[['top']] <- unbox(top)
  }

  obj <- structure(params_data, class = "Padding")
  return(obj)
}
#' 
#' gsv4_PasteDataRequest
#' 
#' Inserts data into the spreadsheet starting at the specified coordinate.
#' 
#' type takes one of the following values:
#' \itemize{
#'  \item{PASTE_NORMAL - Paste values, formulas, formats, and merges.}
#'  \item{PASTE_VALUES - Paste the values ONLY without formats, formulas, or merges.}
#'  \item{PASTE_FORMAT - Paste the format and data validation only.}
#'  \item{PASTE_NO_BORDERS - Like PASTE_NORMAL but without borders.}
#'  \item{PASTE_FORMULA - Paste the formulas only.}
#'  \item{PASTE_DATA_VALIDATION - Paste the data validation only.}
#'  \item{PASTE_CONDITIONAL_FORMATTING - Paste the conditional formatting rules only.}
#' }
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#PasteDataRequest}{Google's Documentation for PasteDataRequest}
#' @param coordinate \code{\link{gsv4_GridCoordinate}} object. A coordinate in a sheet.
#' All indexes are zero-based.
#' @param data string. The data to insert.
#' @param delimiter string. The delimiter in the data.
#' @param html logical. TRUE if the data is HTML.
#' @param type string. How the data should be pasted. type must take one of the following values: PASTE_NORMAL, PASTE_VALUES, PASTE_FORMAT, PASTE_NO_BORDERS, PASTE_FORMULA, PASTE_DATA_VALIDATION, PASTE_CONDITIONAL_FORMATTING
#' See the details section for the definition of each of these values.
#' @return PasteDataRequest
#' @export
gsv4_PasteDataRequest <- function(coordinate=NULL, data=NULL, delimiter=NULL, html=NULL, type=NULL){

  params_data <- list()

  if(!is.null(coordinate)){
  stopifnot(is.na(coordinate) || class(coordinate) == 'GridCoordinate')
    params_data[['coordinate']] <- coordinate
  }
  if(!is.null(data)){
  stopifnot(is.na(data) || is.character(data))
    params_data[['data']] <- unbox(data)
  }
  if(!is.null(delimiter)){
  stopifnot(is.na(delimiter) || is.character(delimiter))
    params_data[['delimiter']] <- unbox(delimiter)
  }
  if(!is.null(html)){
  stopifnot(is.na(html) || is.logical(html))
    params_data[['html']] <- unbox(html)
  }
  if(!is.null(type)){
  stopifnot(is.na(type) || is.character(type))
    params_data[['type']] <- unbox(type)
  }

  obj <- structure(params_data, class = "PasteDataRequest")
  return(obj)
}
#' 
#' gsv4_PieChartSpec
#' 
#' A <a href="/chart/interactive/docs/gallery/piechart">pie chart</a>.
#' 
#' legendPosition takes one of the following values:
#' \itemize{
#'  \item{PIE_CHART_LEGEND_POSITION_UNSPECIFIED - Default value, do not use.}
#'  \item{BOTTOM_LEGEND - The legend is rendered on the bottom of the chart.}
#'  \item{LEFT_LEGEND - The legend is rendered on the left of the chart.}
#'  \item{RIGHT_LEGEND - The legend is rendered on the right of the chart.}
#'  \item{TOP_LEGEND - The legend is rendered on the top of the chart.}
#'  \item{NO_LEGEND - No legend is rendered.}
#'  \item{LABELED_LEGEND - Each pie slice has a label attached to it.}
#' }
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#PieChartSpec}{Google's Documentation for PieChartSpec}
#' @param domain \code{\link{gsv4_ChartData}} object. The data included in a domain or series.
#' @param legendPosition string. Where the legend of the pie chart should be drawn. legendPosition must take one of the following values: PIE_CHART_LEGEND_POSITION_UNSPECIFIED, BOTTOM_LEGEND, LEFT_LEGEND, RIGHT_LEGEND, TOP_LEGEND, NO_LEGEND, LABELED_LEGEND
#' See the details section for the definition of each of these values.
#' @param pieHole numeric. The size of the hole in the pie chart.
#' @param series \code{\link{gsv4_ChartData}} object. The data included in a domain or series.
#' @param threeDimensional logical. TRUE if the pie is three dimensional.
#' @return PieChartSpec
#' @export
gsv4_PieChartSpec <- function(domain=NULL, legendPosition=NULL, pieHole=NULL, series=NULL, threeDimensional=NULL){

  params_data <- list()

  if(!is.null(domain)){
  stopifnot(is.na(domain) || class(domain) == 'ChartData')
    params_data[['domain']] <- domain
  }
  if(!is.null(legendPosition)){
  stopifnot(is.na(legendPosition) || is.character(legendPosition))
    params_data[['legendPosition']] <- unbox(legendPosition)
  }
  if(!is.null(pieHole)){
  stopifnot(is.na(pieHole) || is.numeric(pieHole))
    params_data[['pieHole']] <- unbox(pieHole)
  }
  if(!is.null(series)){
  stopifnot(is.na(series) || class(series) == 'ChartData')
    params_data[['series']] <- series
  }
  if(!is.null(threeDimensional)){
  stopifnot(is.na(threeDimensional) || is.logical(threeDimensional))
    params_data[['threeDimensional']] <- unbox(threeDimensional)
  }

  obj <- structure(params_data, class = "PieChartSpec")
  return(obj)
}
#' 
#' gsv4_PivotFilterCriteria
#' 
#' Criteria for showing/hiding rows in a pivot table.
#' 
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#PivotFilterCriteria}{Google's Documentation for PivotFilterCriteria}
#' @param visibleValues list. Values that should be included.  Values not listed here are excluded.
#' @return PivotFilterCriteria
#' @export
gsv4_PivotFilterCriteria <- function(visibleValues=NULL){

  params_data <- list()

  if(!is.null(visibleValues)){
  stopifnot(is.na(visibleValues) || class(visibleValues) == 'list' || class(visibleValues) == 'data.frame')
    params_data[['visibleValues']] <- visibleValues
  }

  obj <- structure(params_data, class = "PivotFilterCriteria")
  return(obj)
}
#' 
#' gsv4_PivotGroup
#' 
#' A single grouping (either row or column) in a pivot table.
#' 
#' sortOrder takes one of the following values:
#' \itemize{
#'  \item{SORT_ORDER_UNSPECIFIED - Default value, do not use this.}
#'  \item{ASCENDING - Sort ascending.}
#'  \item{DESCENDING - Sort descending.}
#' }
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#PivotGroup}{Google's Documentation for PivotGroup}
#' @param showTotals logical. TRUE if the pivot table should include the totals for this grouping.
#' @param sortOrder string. The order the values in this group should be sorted. sortOrder must take one of the following values: SORT_ORDER_UNSPECIFIED, ASCENDING, DESCENDING
#' See the details section for the definition of each of these values.
#' @param sourceColumnOffset integer. The column offset of the source range that this grouping is based on.
#' 
#' For example, if the source was `C10:E15`, a `sourceColumnOffset` of `0`
#' means this group refers to column `C`, whereas the offset `1` would refer
#' to column `D`.
#' @param valueBucket \code{\link{gsv4_PivotGroupSortValueBucket}} object. Information about which values in a pivot group should be used for sorting.
#' @param valueMetadata list of \code{\link{gsv4_PivotGroupValueMetadata}} objects. Metadata about values in the grouping.
#' @return PivotGroup
#' @export
gsv4_PivotGroup <- function(showTotals=NULL, sortOrder=NULL, sourceColumnOffset=NULL, valueBucket=NULL, valueMetadata=NULL){

  params_data <- list()

  if(!is.null(showTotals)){
  stopifnot(is.na(showTotals) || is.logical(showTotals))
    params_data[['showTotals']] <- unbox(showTotals)
  }
  if(!is.null(sortOrder)){
  stopifnot(is.na(sortOrder) || is.character(sortOrder))
    params_data[['sortOrder']] <- unbox(sortOrder)
  }
  if(!is.null(sourceColumnOffset)){
  stopifnot(is.na(sourceColumnOffset) || all.equal(sourceColumnOffset, as.integer(sourceColumnOffset)))
    params_data[['sourceColumnOffset']] <- unbox(sourceColumnOffset)
  }
  if(!is.null(valueBucket)){
  stopifnot(is.na(valueBucket) || class(valueBucket) == 'PivotGroupSortValueBucket')
    params_data[['valueBucket']] <- valueBucket
  }
  if(!is.null(valueMetadata)){
  stopifnot(is.na(valueMetadata) || class(valueMetadata) == 'list' || class(valueMetadata) == 'data.frame')
    params_data[['valueMetadata']] <- valueMetadata
  }

  obj <- structure(params_data, class = "PivotGroup")
  return(obj)
}
#' 
#' gsv4_PivotGroupSortValueBucket
#' 
#' Information about which values in a pivot group should be used for sorting.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#PivotGroupSortValueBucket}{Google's Documentation for PivotGroupSortValueBucket}
#' @param buckets list of \code{\link{gsv4_ExtendedValue}} objects. Determines the bucket from which values are chosen to sort.
#' 
#' For example, in a pivot table with one row group & two column groups,
#' the row group can list up to two values. The first value corresponds
#' to a value within the first column group, and the second value
#' corresponds to a value in the second column group.  If no values
#' are listed, this would indicate that the row should be sorted according
#' to the "Grand Total" over the column groups. If a single value is listed,
#' this would correspond to using the "Total" of that bucket.
#' @param valuesIndex integer. The offset in the PivotTable.values list which the values in this
#' grouping should be sorted by.
#' @return PivotGroupSortValueBucket
#' @export
gsv4_PivotGroupSortValueBucket <- function(buckets=NULL, valuesIndex=NULL){

  params_data <- list()

  if(!is.null(buckets)){
  stopifnot(is.na(buckets) || class(buckets) == 'list' || class(buckets) == 'data.frame')
    params_data[['buckets']] <- buckets
  }
  if(!is.null(valuesIndex)){
  stopifnot(is.na(valuesIndex) || all.equal(valuesIndex, as.integer(valuesIndex)))
    params_data[['valuesIndex']] <- unbox(valuesIndex)
  }

  obj <- structure(params_data, class = "PivotGroupSortValueBucket")
  return(obj)
}
#' 
#' gsv4_PivotGroupValueMetadata
#' 
#' Metadata about a value in a pivot grouping.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#PivotGroupValueMetadata}{Google's Documentation for PivotGroupValueMetadata}
#' @param collapsed logical. TRUE if the data corresponding to the value is collapsed.
#' @param value \code{\link{gsv4_ExtendedValue}} object. The kinds of value that a cell in a spreadsheet can have.
#' @return PivotGroupValueMetadata
#' @export
gsv4_PivotGroupValueMetadata <- function(collapsed=NULL, value=NULL){

  params_data <- list()

  if(!is.null(collapsed)){
  stopifnot(is.na(collapsed) || is.logical(collapsed))
    params_data[['collapsed']] <- unbox(collapsed)
  }
  if(!is.null(value)){
  stopifnot(is.na(value) || class(value) == 'ExtendedValue')
    params_data[['value']] <- value
  }

  obj <- structure(params_data, class = "PivotGroupValueMetadata")
  return(obj)
}
#' 
#' gsv4_PivotTable
#' 
#' A pivot table.
#' 
#' valueLayout takes one of the following values:
#' \itemize{
#'  \item{HORIZONTAL - Values are laid out horizontally (as columns).}
#'  \item{VERTICAL - Values are laid out vertically (as rows).}
#' }
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#PivotTable}{Google's Documentation for PivotTable}
#' @param rows list of \code{\link{gsv4_PivotGroup}} objects. Each row grouping in the pivot table.
#' @param columns list of \code{\link{gsv4_PivotGroup}} objects. Each column grouping in the pivot table.
#' @param criteria list or data.frame of \code{\link{gsv4_PivotFilterCriteria}} objects. An optional mapping of filters per source column offset.
#' 
#' The filters will be applied before aggregating data into the pivot table.
#' The map's key is the column offset of the source range that you want to
#' filter, and the value is the criteria for that column.
#' 
#' For example, if the source was `C10:E15`, a key of `0` will have the filter
#' for column `C`, whereas the key `1` is for column `D`.
#' @param source \code{\link{gsv4_GridRange}} object. A range on a sheet.
#' All indexes are zero-based.
#' Indexes are half open, e.g the start index is inclusive
#' and the end index is exclusive -- [start_index, end_index).
#' Missing indexes indicate the range is unbounded on that side.
#' 
#' For example, if `"Sheet1"` is sheet ID 0, then:
#' 
#'   `Sheet1!A1:A1 == sheet_id: 0,
#'                   start_row_index: 0, end_row_index: 1,
#'                   start_column_index: 0, end_column_index: 1`
#' 
#'   `Sheet1!A3:B4 == sheet_id: 0,
#'                   start_row_index: 2, end_row_index: 4,
#'                   start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1!A:B == sheet_id: 0,
#'                 start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1!A5:B == sheet_id: 0,
#'                  start_row_index: 4,
#'                  start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1 == sheet_id:0`
#' 
#' The start index must always be less than or equal to the end index.
#' If the start index equals the end index, then the range is empty.
#' Empty ranges are typically not meaningful and are usually rendered in the
#' UI as `#REF!`.
#' @param valueLayout string. Whether values should be listed horizontally (as columns)
#' or vertically (as rows). valueLayout must take one of the following values: HORIZONTAL, VERTICAL
#' See the details section for the definition of each of these values.
#' @param values list of \code{\link{gsv4_PivotValue}} objects. A list of values to include in the pivot table.
#' @return PivotTable
#' @export
gsv4_PivotTable <- function(rows=NULL, columns=NULL, criteria=NULL, source=NULL, valueLayout=NULL, values=NULL){

  params_data <- list()

  if(!is.null(rows)){
  stopifnot(is.na(rows) || class(rows) == 'list' || class(rows) == 'data.frame')
    params_data[['rows']] <- rows
  }
  if(!is.null(columns)){
  stopifnot(is.na(columns) || class(columns) == 'list' || class(columns) == 'data.frame')
    params_data[['columns']] <- columns
  }
  if(!is.null(criteria)){
  stopifnot(is.na(criteria) || class(criteria) == 'list' || class(criteria) == 'data.frame')
    params_data[['criteria']] <- criteria
  }
  if(!is.null(source)){
  stopifnot(is.na(source) || class(source) == 'GridRange')
    params_data[['source']] <- source
  }
  if(!is.null(valueLayout)){
  stopifnot(is.na(valueLayout) || is.character(valueLayout))
    params_data[['valueLayout']] <- unbox(valueLayout)
  }
  if(!is.null(values)){
  stopifnot(is.na(values) || class(values) == 'matrix' || class(values) == 'data.frame')
    params_data[['values']] <- values
  }

  obj <- structure(params_data, class = "PivotTable")
  return(obj)
}
#' 
#' gsv4_PivotValue
#' 
#' The definition of how a value in a pivot table should be calculated.
#' 
#' summarizeFunction takes one of the following values:
#' \itemize{
#'  \item{PIVOT_STANDARD_VALUE_FUNCTION_UNSPECIFIED - The default, do not use.}
#'  \item{SUM - Corresponds to the `SUM` function.}
#'  \item{COUNTA - Corresponds to the `COUNTA` function.}
#'  \item{COUNT - Corresponds to the `COUNT` function.}
#'  \item{COUNTUNIQUE - Corresponds to the `COUNTUNIQUE` function.}
#'  \item{AVERAGE - Corresponds to the `AVERAGE` function.}
#'  \item{MAX - Corresponds to the `MAX` function.}
#'  \item{MIN - Corresponds to the `MIN` function.}
#'  \item{MEDIAN - Corresponds to the `MEDIAN` function.}
#'  \item{PRODUCT - Corresponds to the `PRODUCT` function.}
#'  \item{STDEV - Corresponds to the `STDEV` function.}
#'  \item{STDEVP - Corresponds to the `STDEVP` function.}
#'  \item{VAR - Corresponds to the `VAR` function.}
#'  \item{VARP - Corresponds to the `VARP` function.}
#'  \item{CUSTOM - Indicates the formula should be used as-is.
#' Only valid if PivotValue.formula was set.}
#' }
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#PivotValue}{Google's Documentation for PivotValue}
#' @param formula string. A custom formula to calculate the value.  The formula must start
#' with an `=` character.
#' @param name string. A name to use for the value. This is only used if formula was set.
#' Otherwise, the column name is used.
#' @param sourceColumnOffset integer. The column offset of the source range that this value reads from.
#' 
#' For example, if the source was `C10:E15`, a `sourceColumnOffset` of `0`
#' means this value refers to column `C`, whereas the offset `1` would
#' refer to column `D`.
#' @param summarizeFunction string. A function to summarize the value.
#' If formula is set, the only supported values are
#' SUM and
#' CUSTOM.
#' If sourceColumnOffset is set, then `CUSTOM`
#' is not supported. summarizeFunction must take one of the following values: PIVOT_STANDARD_VALUE_FUNCTION_UNSPECIFIED, SUM, COUNTA, COUNT, COUNTUNIQUE, AVERAGE, MAX, MIN, MEDIAN, PRODUCT, STDEV, STDEVP, VAR, VARP, CUSTOM
#' See the details section for the definition of each of these values.
#' @return PivotValue
#' @export
gsv4_PivotValue <- function(formula=NULL, name=NULL, sourceColumnOffset=NULL, summarizeFunction=NULL){

  params_data <- list()

  if(!is.null(formula)){
  stopifnot(is.na(formula) || is.character(formula))
    params_data[['formula']] <- unbox(formula)
  }
  if(!is.null(name)){
  stopifnot(is.na(name) || is.character(name))
    params_data[['name']] <- unbox(name)
  }
  if(!is.null(sourceColumnOffset)){
  stopifnot(is.na(sourceColumnOffset) || all.equal(sourceColumnOffset, as.integer(sourceColumnOffset)))
    params_data[['sourceColumnOffset']] <- unbox(sourceColumnOffset)
  }
  if(!is.null(summarizeFunction)){
  stopifnot(is.na(summarizeFunction) || is.character(summarizeFunction))
    params_data[['summarizeFunction']] <- unbox(summarizeFunction)
  }

  obj <- structure(params_data, class = "PivotValue")
  return(obj)
}
#' 
#' gsv4_ProtectedRange
#' 
#' A protected range.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#ProtectedRange}{Google's Documentation for ProtectedRange}
#' @param range \code{\link{gsv4_GridRange}} object. A range on a sheet.
#' All indexes are zero-based.
#' Indexes are half open, e.g the start index is inclusive
#' and the end index is exclusive -- [start_index, end_index).
#' Missing indexes indicate the range is unbounded on that side.
#' 
#' For example, if `"Sheet1"` is sheet ID 0, then:
#' 
#'   `Sheet1!A1:A1 == sheet_id: 0,
#'                   start_row_index: 0, end_row_index: 1,
#'                   start_column_index: 0, end_column_index: 1`
#' 
#'   `Sheet1!A3:B4 == sheet_id: 0,
#'                   start_row_index: 2, end_row_index: 4,
#'                   start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1!A:B == sheet_id: 0,
#'                 start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1!A5:B == sheet_id: 0,
#'                  start_row_index: 4,
#'                  start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1 == sheet_id:0`
#' 
#' The start index must always be less than or equal to the end index.
#' If the start index equals the end index, then the range is empty.
#' Empty ranges are typically not meaningful and are usually rendered in the
#' UI as `#REF!`.
#' @param description string. The description of this protected range.
#' @param editors \code{\link{gsv4_Editors}} object. The editors of a protected range.
#' @param namedRangeId string. The named range this protected range is backed by, if any.
#' 
#' When writing, only one of range or named_range_id
#' may be set.
#' @param protectedRangeId integer. The ID of the protected range.
#' This field is read-only.
#' @param requestingUserCanEdit logical. TRUE if the user who requested this protected range can edit the
#' protected area.
#' This field is read-only.
#' @param unprotectedRanges list of \code{\link{gsv4_GridRange}} objects. The list of unprotected ranges within a protected sheet.
#' Unprotected ranges are only supported on protected sheets.
#' @param warningOnly logical. TRUE if this protected range will show a warning when editing.
#' Warning-based protection means that every user can edit data in the
#' protected range, except editing will prompt a warning asking the user
#' to confirm the edit.
#' 
#' When writing: if this field is TRUE, then editors is ignored.
#' Additionally, if this field is changed from TRUE to FALSE and the
#' `editors` field is not set (nor included in the field mask), then
#' the editors will be set to all the editors in the document.
#' @return ProtectedRange
#' @export
gsv4_ProtectedRange <- function(range=NULL, description=NULL, editors=NULL, namedRangeId=NULL, protectedRangeId=NULL, requestingUserCanEdit=NULL, unprotectedRanges=NULL, warningOnly=NULL){

  params_data <- list()

  if(!is.null(range)){
  stopifnot(is.na(range) || class(range) == 'GridRange')
    params_data[['range']] <- range
  }
  if(!is.null(description)){
  stopifnot(is.na(description) || is.character(description))
    params_data[['description']] <- unbox(description)
  }
  if(!is.null(editors)){
  stopifnot(is.na(editors) || class(editors) == 'Editors')
    params_data[['editors']] <- editors
  }
  if(!is.null(namedRangeId)){
  stopifnot(is.na(namedRangeId) || is.character(namedRangeId))
    params_data[['namedRangeId']] <- unbox(namedRangeId)
  }
  if(!is.null(protectedRangeId)){
  stopifnot(is.na(protectedRangeId) || all.equal(protectedRangeId, as.integer(protectedRangeId)))
    params_data[['protectedRangeId']] <- unbox(protectedRangeId)
  }
  if(!is.null(requestingUserCanEdit)){
  stopifnot(is.na(requestingUserCanEdit) || is.logical(requestingUserCanEdit))
    params_data[['requestingUserCanEdit']] <- unbox(requestingUserCanEdit)
  }
  if(!is.null(unprotectedRanges)){
  stopifnot(is.na(unprotectedRanges) || class(unprotectedRanges) == 'list' || class(unprotectedRanges) == 'data.frame')
    params_data[['unprotectedRanges']] <- unprotectedRanges
  }
  if(!is.null(warningOnly)){
  stopifnot(is.na(warningOnly) || is.logical(warningOnly))
    params_data[['warningOnly']] <- unbox(warningOnly)
  }

  obj <- structure(params_data, class = "ProtectedRange")
  return(obj)
}
#' 
#' gsv4_RepeatCellRequest
#' 
#' Updates all cells in the range to the values in the given Cell object.
#' Only the fields listed in the fields field are updated; others are
#' unchanged.
#' 
#' If writing a cell with a formula, the formula's ranges will automatically
#' increment for each field in the range.
#' For example, if writing a cell with formula `=A1` into range B2:C4,
#' B2 would be `=A1`, B3 would be `=A2`, B4 would be `=A3`,
#' C2 would be `=B1`, C3 would be `=B2`, C4 would be `=B3`.
#' 
#' To keep the formula's ranges static, use the `$` indicator.
#' For example, use the formula `=$A$1` to prevent both the row and the
#' column from incrementing.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#RepeatCellRequest}{Google's Documentation for RepeatCellRequest}
#' @param range \code{\link{gsv4_GridRange}} object. A range on a sheet.
#' All indexes are zero-based.
#' Indexes are half open, e.g the start index is inclusive
#' and the end index is exclusive -- [start_index, end_index).
#' Missing indexes indicate the range is unbounded on that side.
#' 
#' For example, if `"Sheet1"` is sheet ID 0, then:
#' 
#'   `Sheet1!A1:A1 == sheet_id: 0,
#'                   start_row_index: 0, end_row_index: 1,
#'                   start_column_index: 0, end_column_index: 1`
#' 
#'   `Sheet1!A3:B4 == sheet_id: 0,
#'                   start_row_index: 2, end_row_index: 4,
#'                   start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1!A:B == sheet_id: 0,
#'                 start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1!A5:B == sheet_id: 0,
#'                  start_row_index: 4,
#'                  start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1 == sheet_id:0`
#' 
#' The start index must always be less than or equal to the end index.
#' If the start index equals the end index, then the range is empty.
#' Empty ranges are typically not meaningful and are usually rendered in the
#' UI as `#REF!`.
#' @param fields string. The fields that should be updated.  At least one field must be specified.
#' The root `cell` is implied and should not be specified.
#' A single `"*"` can be used as short-hand for listing every field.
#' @param cell \code{\link{gsv4_CellData}} object. Data about a specific cell.
#' @return RepeatCellRequest
#' @export
gsv4_RepeatCellRequest <- function(range=NULL, fields=NULL, cell=NULL){

  params_data <- list()

  if(!is.null(range)){
  stopifnot(is.na(range) || class(range) == 'GridRange')
    params_data[['range']] <- range
  }
  if(!is.null(fields)){
  stopifnot(is.na(fields) || is.character(fields))
    params_data[['fields']] <- unbox(fields)
  }
  if(!is.null(cell)){
  stopifnot(is.na(cell) || class(cell) == 'CellData')
    params_data[['cell']] <- cell
  }

  obj <- structure(params_data, class = "RepeatCellRequest")
  return(obj)
}
#' 
#' gsv4_Request
#' 
#' A single kind of update to apply to a spreadsheet.
#' 
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#Request}{Google's Documentation for Request}
#' @param addBanding \code{\link{gsv4_AddBandingRequest}} object. Adds a new banded range to the spreadsheet.
#' @param addChart \code{\link{gsv4_AddChartRequest}} object. Adds a chart to a sheet in the spreadsheet.
#' @param addConditionalFormatRule \code{\link{gsv4_AddConditionalFormatRuleRequest}} object. Adds a new conditional format rule at the given index.
#' All subsequent rules' indexes are incremented.
#' @param addFilterView \code{\link{gsv4_AddFilterViewRequest}} object. Adds a filter view.
#' @param addNamedRange \code{\link{gsv4_AddNamedRangeRequest}} object. Adds a named range to the spreadsheet.
#' @param addProtectedRange \code{\link{gsv4_AddProtectedRangeRequest}} object. Adds a new protected range.
#' @param addSheet \code{\link{gsv4_AddSheetRequest}} object. Adds a new sheet.
#' When a sheet is added at a given index,
#' all subsequent sheets' indexes are incremented.
#' To add an object sheet, use AddChartRequest instead and specify
#' EmbeddedObjectPosition.sheetId or
#' EmbeddedObjectPosition.newSheet.
#' @param appendCells \code{\link{gsv4_AppendCellsRequest}} object. Adds new cells after the last row with data in a sheet,
#' inserting new rows into the sheet if necessary.
#' @param appendDimension \code{\link{gsv4_AppendDimensionRequest}} object. Appends rows or columns to the end of a sheet.
#' @param autoFill \code{\link{gsv4_AutoFillRequest}} object. Fills in more data based on existing data.
#' @param autoResizeDimensions \code{\link{gsv4_AutoResizeDimensionsRequest}} object. Automatically resizes one or more dimensions based on the contents
#' of the cells in that dimension.
#' @param clearBasicFilter \code{\link{gsv4_ClearBasicFilterRequest}} object. Clears the basic filter, if any exists on the sheet.
#' @param copyPaste \code{\link{gsv4_CopyPasteRequest}} object. Copies data from the source to the destination.
#' @param cutPaste \code{\link{gsv4_CutPasteRequest}} object. Moves data from the source to the destination.
#' @param deleteBanding \code{\link{gsv4_DeleteBandingRequest}} object. Removes the banded range with the given ID from the spreadsheet.
#' @param deleteConditionalFormatRule \code{\link{gsv4_DeleteConditionalFormatRuleRequest}} object. Deletes a conditional format rule at the given index.
#' All subsequent rules' indexes are decremented.
#' @param deleteDimension \code{\link{gsv4_DeleteDimensionRequest}} object. Deletes the dimensions from the sheet.
#' @param deleteEmbeddedObject \code{\link{gsv4_DeleteEmbeddedObjectRequest}} object. Deletes the embedded object with the given ID.
#' @param deleteFilterView \code{\link{gsv4_DeleteFilterViewRequest}} object. Deletes a particular filter view.
#' @param deleteNamedRange \code{\link{gsv4_DeleteNamedRangeRequest}} object. Removes the named range with the given ID from the spreadsheet.
#' @param deleteProtectedRange \code{\link{gsv4_DeleteProtectedRangeRequest}} object. Deletes the protected range with the given ID.
#' @param deleteRange \code{\link{gsv4_DeleteRangeRequest}} object. Deletes a range of cells, shifting other cells into the deleted area.
#' @param deleteSheet \code{\link{gsv4_DeleteSheetRequest}} object. Deletes the requested sheet.
#' @param duplicateFilterView \code{\link{gsv4_DuplicateFilterViewRequest}} object. Duplicates a particular filter view.
#' @param duplicateSheet \code{\link{gsv4_DuplicateSheetRequest}} object. Duplicates the contents of a sheet.
#' @param findReplace \code{\link{gsv4_FindReplaceRequest}} object. Finds and replaces data in cells over a range, sheet, or all sheets.
#' @param insertDimension \code{\link{gsv4_InsertDimensionRequest}} object. Inserts rows or columns in a sheet at a particular index.
#' @param insertRange \code{\link{gsv4_InsertRangeRequest}} object. Inserts cells into a range, shifting the existing cells over or down.
#' @param mergeCells \code{\link{gsv4_MergeCellsRequest}} object. Merges all cells in the range.
#' @param moveDimension \code{\link{gsv4_MoveDimensionRequest}} object. Moves one or more rows or columns.
#' @param pasteData \code{\link{gsv4_PasteDataRequest}} object. Inserts data into the spreadsheet starting at the specified coordinate.
#' @param repeatCell \code{\link{gsv4_RepeatCellRequest}} object. Updates all cells in the range to the values in the given Cell object.
#' Only the fields listed in the fields field are updated; others are
#' unchanged.
#' 
#' If writing a cell with a formula, the formula's ranges will automatically
#' increment for each field in the range.
#' For example, if writing a cell with formula `=A1` into range B2:C4,
#' B2 would be `=A1`, B3 would be `=A2`, B4 would be `=A3`,
#' C2 would be `=B1`, C3 would be `=B2`, C4 would be `=B3`.
#' 
#' To keep the formula's ranges static, use the `$` indicator.
#' For example, use the formula `=$A$1` to prevent both the row and the
#' column from incrementing.
#' @param setBasicFilter \code{\link{gsv4_SetBasicFilterRequest}} object. Sets the basic filter associated with a sheet.
#' @param setDataValidation \code{\link{gsv4_SetDataValidationRequest}} object. Sets a data validation rule to every cell in the range.
#' To clear validation in a range, call this with no rule specified.
#' @param sortRange \code{\link{gsv4_SortRangeRequest}} object. Sorts data in rows based on a sort order per column.
#' @param textToColumns \code{\link{gsv4_TextToColumnsRequest}} object. Splits a column of text into multiple columns,
#' based on a delimiter in each cell.
#' @param unmergeCells \code{\link{gsv4_UnmergeCellsRequest}} object. Unmerges cells in the given range.
#' @param updateBanding \code{\link{gsv4_UpdateBandingRequest}} object. Updates properties of the supplied banded range.
#' @param updateBorders \code{\link{gsv4_UpdateBordersRequest}} object. Updates the borders of a range.
#' If a field is not set in the request, that means the border remains as-is.
#' For example, with two subsequent UpdateBordersRequest:
#' 
#'  1. range: A1:A5 `{ top: RED, bottom: WHITE }`
#'  2. range: A1:A5 `{ left: BLUE }`
#' 
#' That would result in A1:A5 having a borders of
#' `{ top: RED, bottom: WHITE, left: BLUE }`.
#' If you want to clear a border, explicitly set the style to
#' NONE.
#' @param updateCells \code{\link{gsv4_UpdateCellsRequest}} object. Updates all cells in a range with new data.
#' @param updateChartSpec \code{\link{gsv4_UpdateChartSpecRequest}} object. Updates a chart's specifications.
#' (This does not move or resize a chart. To move or resize a chart, use
#'  UpdateEmbeddedObjectPositionRequest.)
#' @param updateConditionalFormatRule \code{\link{gsv4_UpdateConditionalFormatRuleRequest}} object. Updates a conditional format rule at the given index,
#' or moves a conditional format rule to another index.
#' @param updateDimensionProperties \code{\link{gsv4_UpdateDimensionPropertiesRequest}} object. Updates properties of dimensions within the specified range.
#' @param updateEmbeddedObjectPosition \code{\link{gsv4_UpdateEmbeddedObjectPositionRequest}} object. Update an embedded object's position (such as a moving or resizing a
#' chart or image).
#' @param updateFilterView \code{\link{gsv4_UpdateFilterViewRequest}} object. Updates properties of the filter view.
#' @param updateNamedRange \code{\link{gsv4_UpdateNamedRangeRequest}} object. Updates properties of the named range with the specified
#' namedRangeId.
#' @param updateProtectedRange \code{\link{gsv4_UpdateProtectedRangeRequest}} object. Updates an existing protected range with the specified
#' protectedRangeId.
#' @param updateSheetProperties \code{\link{gsv4_UpdateSheetPropertiesRequest}} object. Updates properties of the sheet with the specified
#' sheetId.
#' @param updateSpreadsheetProperties \code{\link{gsv4_UpdateSpreadsheetPropertiesRequest}} object. Updates properties of a spreadsheet.
#' @return Request
#' @export
gsv4_Request <- function(addBanding=NULL, addChart=NULL, addConditionalFormatRule=NULL, addFilterView=NULL, addNamedRange=NULL, addProtectedRange=NULL, addSheet=NULL, appendCells=NULL, appendDimension=NULL, autoFill=NULL, autoResizeDimensions=NULL, clearBasicFilter=NULL, copyPaste=NULL, cutPaste=NULL, deleteBanding=NULL, deleteConditionalFormatRule=NULL, deleteDimension=NULL, deleteEmbeddedObject=NULL, deleteFilterView=NULL, deleteNamedRange=NULL, deleteProtectedRange=NULL, deleteRange=NULL, deleteSheet=NULL, duplicateFilterView=NULL, duplicateSheet=NULL, findReplace=NULL, insertDimension=NULL, insertRange=NULL, mergeCells=NULL, moveDimension=NULL, pasteData=NULL, repeatCell=NULL, setBasicFilter=NULL, setDataValidation=NULL, sortRange=NULL, textToColumns=NULL, unmergeCells=NULL, updateBanding=NULL, updateBorders=NULL, updateCells=NULL, updateChartSpec=NULL, updateConditionalFormatRule=NULL, updateDimensionProperties=NULL, updateEmbeddedObjectPosition=NULL, updateFilterView=NULL, updateNamedRange=NULL, updateProtectedRange=NULL, updateSheetProperties=NULL, updateSpreadsheetProperties=NULL){

  params_data <- list()

  if(!is.null(addBanding)){
  stopifnot(is.na(addBanding) || class(addBanding) == 'AddBandingRequest')
    params_data[['addBanding']] <- addBanding
  }
  if(!is.null(addChart)){
  stopifnot(is.na(addChart) || class(addChart) == 'AddChartRequest')
    params_data[['addChart']] <- addChart
  }
  if(!is.null(addConditionalFormatRule)){
  stopifnot(is.na(addConditionalFormatRule) || class(addConditionalFormatRule) == 'AddConditionalFormatRuleRequest')
    params_data[['addConditionalFormatRule']] <- addConditionalFormatRule
  }
  if(!is.null(addFilterView)){
  stopifnot(is.na(addFilterView) || class(addFilterView) == 'AddFilterViewRequest')
    params_data[['addFilterView']] <- addFilterView
  }
  if(!is.null(addNamedRange)){
  stopifnot(is.na(addNamedRange) || class(addNamedRange) == 'AddNamedRangeRequest')
    params_data[['addNamedRange']] <- addNamedRange
  }
  if(!is.null(addProtectedRange)){
  stopifnot(is.na(addProtectedRange) || class(addProtectedRange) == 'AddProtectedRangeRequest')
    params_data[['addProtectedRange']] <- addProtectedRange
  }
  if(!is.null(addSheet)){
  stopifnot(is.na(addSheet) || class(addSheet) == 'AddSheetRequest')
    params_data[['addSheet']] <- addSheet
  }
  if(!is.null(appendCells)){
  stopifnot(is.na(appendCells) || class(appendCells) == 'AppendCellsRequest')
    params_data[['appendCells']] <- appendCells
  }
  if(!is.null(appendDimension)){
  stopifnot(is.na(appendDimension) || class(appendDimension) == 'AppendDimensionRequest')
    params_data[['appendDimension']] <- appendDimension
  }
  if(!is.null(autoFill)){
  stopifnot(is.na(autoFill) || class(autoFill) == 'AutoFillRequest')
    params_data[['autoFill']] <- autoFill
  }
  if(!is.null(autoResizeDimensions)){
  stopifnot(is.na(autoResizeDimensions) || class(autoResizeDimensions) == 'AutoResizeDimensionsRequest')
    params_data[['autoResizeDimensions']] <- autoResizeDimensions
  }
  if(!is.null(clearBasicFilter)){
  stopifnot(is.na(clearBasicFilter) || class(clearBasicFilter) == 'ClearBasicFilterRequest')
    params_data[['clearBasicFilter']] <- clearBasicFilter
  }
  if(!is.null(copyPaste)){
  stopifnot(is.na(copyPaste) || class(copyPaste) == 'CopyPasteRequest')
    params_data[['copyPaste']] <- copyPaste
  }
  if(!is.null(cutPaste)){
  stopifnot(is.na(cutPaste) || class(cutPaste) == 'CutPasteRequest')
    params_data[['cutPaste']] <- cutPaste
  }
  if(!is.null(deleteBanding)){
  stopifnot(is.na(deleteBanding) || class(deleteBanding) == 'DeleteBandingRequest')
    params_data[['deleteBanding']] <- deleteBanding
  }
  if(!is.null(deleteConditionalFormatRule)){
  stopifnot(is.na(deleteConditionalFormatRule) || class(deleteConditionalFormatRule) == 'DeleteConditionalFormatRuleRequest')
    params_data[['deleteConditionalFormatRule']] <- deleteConditionalFormatRule
  }
  if(!is.null(deleteDimension)){
  stopifnot(is.na(deleteDimension) || class(deleteDimension) == 'DeleteDimensionRequest')
    params_data[['deleteDimension']] <- deleteDimension
  }
  if(!is.null(deleteEmbeddedObject)){
  stopifnot(is.na(deleteEmbeddedObject) || class(deleteEmbeddedObject) == 'DeleteEmbeddedObjectRequest')
    params_data[['deleteEmbeddedObject']] <- deleteEmbeddedObject
  }
  if(!is.null(deleteFilterView)){
  stopifnot(is.na(deleteFilterView) || class(deleteFilterView) == 'DeleteFilterViewRequest')
    params_data[['deleteFilterView']] <- deleteFilterView
  }
  if(!is.null(deleteNamedRange)){
  stopifnot(is.na(deleteNamedRange) || class(deleteNamedRange) == 'DeleteNamedRangeRequest')
    params_data[['deleteNamedRange']] <- deleteNamedRange
  }
  if(!is.null(deleteProtectedRange)){
  stopifnot(is.na(deleteProtectedRange) || class(deleteProtectedRange) == 'DeleteProtectedRangeRequest')
    params_data[['deleteProtectedRange']] <- deleteProtectedRange
  }
  if(!is.null(deleteRange)){
  stopifnot(is.na(deleteRange) || class(deleteRange) == 'DeleteRangeRequest')
    params_data[['deleteRange']] <- deleteRange
  }
  if(!is.null(deleteSheet)){
  stopifnot(is.na(deleteSheet) || class(deleteSheet) == 'DeleteSheetRequest')
    params_data[['deleteSheet']] <- deleteSheet
  }
  if(!is.null(duplicateFilterView)){
  stopifnot(is.na(duplicateFilterView) || class(duplicateFilterView) == 'DuplicateFilterViewRequest')
    params_data[['duplicateFilterView']] <- duplicateFilterView
  }
  if(!is.null(duplicateSheet)){
  stopifnot(is.na(duplicateSheet) || class(duplicateSheet) == 'DuplicateSheetRequest')
    params_data[['duplicateSheet']] <- duplicateSheet
  }
  if(!is.null(findReplace)){
  stopifnot(is.na(findReplace) || class(findReplace) == 'FindReplaceRequest')
    params_data[['findReplace']] <- findReplace
  }
  if(!is.null(insertDimension)){
  stopifnot(is.na(insertDimension) || class(insertDimension) == 'InsertDimensionRequest')
    params_data[['insertDimension']] <- insertDimension
  }
  if(!is.null(insertRange)){
  stopifnot(is.na(insertRange) || class(insertRange) == 'InsertRangeRequest')
    params_data[['insertRange']] <- insertRange
  }
  if(!is.null(mergeCells)){
  stopifnot(is.na(mergeCells) || class(mergeCells) == 'MergeCellsRequest')
    params_data[['mergeCells']] <- mergeCells
  }
  if(!is.null(moveDimension)){
  stopifnot(is.na(moveDimension) || class(moveDimension) == 'MoveDimensionRequest')
    params_data[['moveDimension']] <- moveDimension
  }
  if(!is.null(pasteData)){
  stopifnot(is.na(pasteData) || class(pasteData) == 'PasteDataRequest')
    params_data[['pasteData']] <- pasteData
  }
  if(!is.null(repeatCell)){
  stopifnot(is.na(repeatCell) || class(repeatCell) == 'RepeatCellRequest')
    params_data[['repeatCell']] <- repeatCell
  }
  if(!is.null(setBasicFilter)){
  stopifnot(is.na(setBasicFilter) || class(setBasicFilter) == 'SetBasicFilterRequest')
    params_data[['setBasicFilter']] <- setBasicFilter
  }
  if(!is.null(setDataValidation)){
  stopifnot(is.na(setDataValidation) || class(setDataValidation) == 'SetDataValidationRequest')
    params_data[['setDataValidation']] <- setDataValidation
  }
  if(!is.null(sortRange)){
  stopifnot(is.na(sortRange) || class(sortRange) == 'SortRangeRequest')
    params_data[['sortRange']] <- sortRange
  }
  if(!is.null(textToColumns)){
  stopifnot(is.na(textToColumns) || class(textToColumns) == 'TextToColumnsRequest')
    params_data[['textToColumns']] <- textToColumns
  }
  if(!is.null(unmergeCells)){
  stopifnot(is.na(unmergeCells) || class(unmergeCells) == 'UnmergeCellsRequest')
    params_data[['unmergeCells']] <- unmergeCells
  }
  if(!is.null(updateBanding)){
  stopifnot(is.na(updateBanding) || class(updateBanding) == 'UpdateBandingRequest')
    params_data[['updateBanding']] <- updateBanding
  }
  if(!is.null(updateBorders)){
  stopifnot(is.na(updateBorders) || class(updateBorders) == 'UpdateBordersRequest')
    params_data[['updateBorders']] <- updateBorders
  }
  if(!is.null(updateCells)){
  stopifnot(is.na(updateCells) || class(updateCells) == 'UpdateCellsRequest')
    params_data[['updateCells']] <- updateCells
  }
  if(!is.null(updateChartSpec)){
  stopifnot(is.na(updateChartSpec) || class(updateChartSpec) == 'UpdateChartSpecRequest')
    params_data[['updateChartSpec']] <- updateChartSpec
  }
  if(!is.null(updateConditionalFormatRule)){
  stopifnot(is.na(updateConditionalFormatRule) || class(updateConditionalFormatRule) == 'UpdateConditionalFormatRuleRequest')
    params_data[['updateConditionalFormatRule']] <- updateConditionalFormatRule
  }
  if(!is.null(updateDimensionProperties)){
  stopifnot(is.na(updateDimensionProperties) || class(updateDimensionProperties) == 'UpdateDimensionPropertiesRequest')
    params_data[['updateDimensionProperties']] <- updateDimensionProperties
  }
  if(!is.null(updateEmbeddedObjectPosition)){
  stopifnot(is.na(updateEmbeddedObjectPosition) || class(updateEmbeddedObjectPosition) == 'UpdateEmbeddedObjectPositionRequest')
    params_data[['updateEmbeddedObjectPosition']] <- updateEmbeddedObjectPosition
  }
  if(!is.null(updateFilterView)){
  stopifnot(is.na(updateFilterView) || class(updateFilterView) == 'UpdateFilterViewRequest')
    params_data[['updateFilterView']] <- updateFilterView
  }
  if(!is.null(updateNamedRange)){
  stopifnot(is.na(updateNamedRange) || class(updateNamedRange) == 'UpdateNamedRangeRequest')
    params_data[['updateNamedRange']] <- updateNamedRange
  }
  if(!is.null(updateProtectedRange)){
  stopifnot(is.na(updateProtectedRange) || class(updateProtectedRange) == 'UpdateProtectedRangeRequest')
    params_data[['updateProtectedRange']] <- updateProtectedRange
  }
  if(!is.null(updateSheetProperties)){
  stopifnot(is.na(updateSheetProperties) || class(updateSheetProperties) == 'UpdateSheetPropertiesRequest')
    params_data[['updateSheetProperties']] <- updateSheetProperties
  }
  if(!is.null(updateSpreadsheetProperties)){
  stopifnot(is.na(updateSpreadsheetProperties) || class(updateSpreadsheetProperties) == 'UpdateSpreadsheetPropertiesRequest')
    params_data[['updateSpreadsheetProperties']] <- updateSpreadsheetProperties
  }

  obj <- structure(params_data, class = "Request")
  return(obj)
}
#' 
#' gsv4_RowData
#' 
#' Data about each cell in a row.
#' 
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#RowData}{Google's Documentation for RowData}
#' @param values list of \code{\link{gsv4_CellData}} objects. The values in the row, one per column.
#' @return RowData
#' @export
gsv4_RowData <- function(values=NULL){

  params_data <- list()

  if(!is.null(values)){
  stopifnot(is.na(values) || class(values) == 'matrix' || class(values) == 'data.frame')
    params_data[['values']] <- values
  }

  obj <- structure(params_data, class = "RowData")
  return(obj)
}
#' 
#' gsv4_SetBasicFilterRequest
#' 
#' Sets the basic filter associated with a sheet.
#' 
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#SetBasicFilterRequest}{Google's Documentation for SetBasicFilterRequest}
#' @param filter \code{\link{gsv4_BasicFilter}} object. The default filter associated with a sheet.
#' @return SetBasicFilterRequest
#' @export
gsv4_SetBasicFilterRequest <- function(filter=NULL){

  params_data <- list()

  if(!is.null(filter)){
  stopifnot(is.na(filter) || class(filter) == 'BasicFilter')
    params_data[['filter']] <- filter
  }

  obj <- structure(params_data, class = "SetBasicFilterRequest")
  return(obj)
}
#' 
#' gsv4_SetDataValidationRequest
#' 
#' Sets a data validation rule to every cell in the range.
#' To clear validation in a range, call this with no rule specified.
#' 
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#SetDataValidationRequest}{Google's Documentation for SetDataValidationRequest}
#' @param range \code{\link{gsv4_GridRange}} object. A range on a sheet.
#' All indexes are zero-based.
#' Indexes are half open, e.g the start index is inclusive
#' and the end index is exclusive -- [start_index, end_index).
#' Missing indexes indicate the range is unbounded on that side.
#' 
#' For example, if `"Sheet1"` is sheet ID 0, then:
#' 
#'   `Sheet1!A1:A1 == sheet_id: 0,
#'                   start_row_index: 0, end_row_index: 1,
#'                   start_column_index: 0, end_column_index: 1`
#' 
#'   `Sheet1!A3:B4 == sheet_id: 0,
#'                   start_row_index: 2, end_row_index: 4,
#'                   start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1!A:B == sheet_id: 0,
#'                 start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1!A5:B == sheet_id: 0,
#'                  start_row_index: 4,
#'                  start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1 == sheet_id:0`
#' 
#' The start index must always be less than or equal to the end index.
#' If the start index equals the end index, then the range is empty.
#' Empty ranges are typically not meaningful and are usually rendered in the
#' UI as `#REF!`.
#' @param rule \code{\link{gsv4_DataValidationRule}} object. A data validation rule.
#' @return SetDataValidationRequest
#' @export
gsv4_SetDataValidationRequest <- function(range=NULL, rule=NULL){

  params_data <- list()

  if(!is.null(range)){
  stopifnot(is.na(range) || class(range) == 'GridRange')
    params_data[['range']] <- range
  }
  if(!is.null(rule)){
  stopifnot(is.na(rule) || class(rule) == 'DataValidationRule')
    params_data[['rule']] <- rule
  }

  obj <- structure(params_data, class = "SetDataValidationRequest")
  return(obj)
}
#' 
#' gsv4_Sheet
#' 
#' A sheet in a spreadsheet.
#' 
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#Sheet}{Google's Documentation for Sheet}
#' @param bandedRanges list of \code{\link{gsv4_BandedRange}} objects. The banded (i.e. alternating colors) ranges on this sheet.
#' @param basicFilter \code{\link{gsv4_BasicFilter}} object. The default filter associated with a sheet.
#' @param charts list of \code{\link{gsv4_EmbeddedChart}} objects. The specifications of every chart on this sheet.
#' @param conditionalFormats list of \code{\link{gsv4_ConditionalFormatRule}} objects. The conditional format rules in this sheet.
#' @param data list of \code{\link{gsv4_GridData}} objects. Data in the grid, if this is a grid sheet.
#' The number of GridData objects returned is dependent on the number of
#' ranges requested on this sheet. For example, if this is representing
#' `Sheet1`, and the spreadsheet was requested with ranges
#' `Sheet1!A1:C10` and `Sheet1!D15:E20`, then the first GridData will have a
#' startRow/startColumn of `0`,
#' while the second one will have `startRow 14` (zero-based row 15),
#' and `startColumn 3` (zero-based column D).
#' @param filterViews list of \code{\link{gsv4_FilterView}} objects. The filter views in this sheet.
#' @param merges list of \code{\link{gsv4_GridRange}} objects. The ranges that are merged together.
#' @param properties \code{\link{gsv4_SheetProperties}} object. Properties of a sheet.
#' @param protectedRanges list of \code{\link{gsv4_ProtectedRange}} objects. The protected ranges in this sheet.
#' @return Sheet
#' @export
gsv4_Sheet <- function(bandedRanges=NULL, basicFilter=NULL, charts=NULL, conditionalFormats=NULL, data=NULL, filterViews=NULL, merges=NULL, properties=NULL, protectedRanges=NULL){

  params_data <- list()

  if(!is.null(bandedRanges)){
  stopifnot(is.na(bandedRanges) || class(bandedRanges) == 'list' || class(bandedRanges) == 'data.frame')
    params_data[['bandedRanges']] <- bandedRanges
  }
  if(!is.null(basicFilter)){
  stopifnot(is.na(basicFilter) || class(basicFilter) == 'BasicFilter')
    params_data[['basicFilter']] <- basicFilter
  }
  if(!is.null(charts)){
  stopifnot(is.na(charts) || class(charts) == 'list' || class(charts) == 'data.frame')
    params_data[['charts']] <- charts
  }
  if(!is.null(conditionalFormats)){
  stopifnot(is.na(conditionalFormats) || class(conditionalFormats) == 'list' || class(conditionalFormats) == 'data.frame')
    params_data[['conditionalFormats']] <- conditionalFormats
  }
  if(!is.null(data)){
  stopifnot(is.na(data) || class(data) == 'list' || class(data) == 'data.frame')
    params_data[['data']] <- data
  }
  if(!is.null(filterViews)){
  stopifnot(is.na(filterViews) || class(filterViews) == 'list' || class(filterViews) == 'data.frame')
    params_data[['filterViews']] <- filterViews
  }
  if(!is.null(merges)){
  stopifnot(is.na(merges) || class(merges) == 'list' || class(merges) == 'data.frame')
    params_data[['merges']] <- merges
  }
  if(!is.null(properties)){
  stopifnot(is.na(properties) || class(properties) == 'SheetProperties')
    params_data[['properties']] <- properties
  }
  if(!is.null(protectedRanges)){
  stopifnot(is.na(protectedRanges) || class(protectedRanges) == 'list' || class(protectedRanges) == 'data.frame')
    params_data[['protectedRanges']] <- protectedRanges
  }

  obj <- structure(params_data, class = "Sheet")
  return(obj)
}
#' 
#' gsv4_SheetProperties
#' 
#' Properties of a sheet.
#' 
#' sheetType takes one of the following values:
#' \itemize{
#'  \item{SHEET_TYPE_UNSPECIFIED - Default value, do not use.}
#'  \item{GRID - The sheet is a grid.}
#'  \item{OBJECT - The sheet has no grid and instead has an object like a chart or image.}
#' }
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#SheetProperties}{Google's Documentation for SheetProperties}
#' @param sheetId integer. The ID of the sheet. Must be non-negative.
#' This field cannot be changed once set.
#' @param gridProperties \code{\link{gsv4_GridProperties}} object. Properties of a grid.
#' @param hidden logical. TRUE if the sheet is hidden in the UI, FALSE if it's visible.
#' @param index integer. The index of the sheet within the spreadsheet.
#' When adding or updating sheet properties, if this field
#' is excluded then the sheet will be added or moved to the end
#' of the sheet list. When updating sheet indices or inserting
#' sheets, movement is considered in "before the move" indexes.
#' For example, if there were 3 sheets (S1, S2, S3) in order to
#' move S1 ahead of S2 the index would have to be set to 2. A sheet
#' index update request will be ignored if the requested index is
#' identical to the sheets current index or if the requested new
#' index is equal to the current sheet index + 1.
#' @param rightToLeft logical. TRUE if the sheet is an RTL sheet instead of an LTR sheet.
#' @param sheetType string. The type of sheet. Defaults to GRID.
#' This field cannot be changed once set. sheetType must take one of the following values: SHEET_TYPE_UNSPECIFIED, GRID, OBJECT
#' See the details section for the definition of each of these values.
#' @param tabColor \code{\link{gsv4_Color}} object. Represents a color in the RGBA color space. This representation is designed
#' for simplicity of conversion to/from color representations in various
#' languages over compactness; for example, the fields of this representation
#' can be trivially provided to the constructor of "java.awt.Color" in Java; it
#' can also be trivially provided to UIColor's "+colorWithRed:green:blue:alpha"
#' method in iOS; and, with just a little work, it can be easily formatted into
#' a CSS "rgba()" string in JavaScript, as well. Here are some examples:
#' 
#' Example (Java):
#' 
#'      import com.google.type.Color;
#' 
#'      // ...
#'      public static java.awt.Color fromProto(Color protocolor) {
#'        float alpha = protocolor.hasAlpha()
#'            ? protocolor.getAlpha().getValue()
#'            : 1.0;
#' 
#'        return new java.awt.Color(
#'            protocolor.getRed(),
#'            protocolor.getGreen(),
#'            protocolor.getBlue(),
#'            alpha);
#'      }
#' 
#'      public static Color toProto(java.awt.Color color) {
#'        float red = (float) color.getRed();
#'        float green = (float) color.getGreen();
#'        float blue = (float) color.getBlue();
#'        float denominator = 255.0;
#'        Color.Builder resultBuilder =
#'            Color
#'                .newBuilder()
#'                .setRed(red / denominator)
#'                .setGreen(green / denominator)
#'                .setBlue(blue / denominator);
#'        int alpha = color.getAlpha();
#'        if (alpha != 255) {
#'          result.setAlpha(
#'              FloatValue
#'                  .newBuilder()
#'                  .setValue(((float) alpha) / denominator)
#'                  .build());
#'        }
#'        return resultBuilder.build();
#'      }
#'      // ...
#' 
#' Example (iOS / Obj-C):
#' 
#'      // ...
#'      static UIColor* fromProto(Color* protocolor) {
#'         float red = [protocolor red];
#'         float green = [protocolor green];
#'         float blue = [protocolor blue];
#'         FloatValue* alpha_wrapper = [protocolor alpha];
#'         float alpha = 1.0;
#'         if (alpha_wrapper != nil) {
#'           alpha = [alpha_wrapper value];
#'         }
#'         return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
#'      }
#' 
#'      static Color* toProto(UIColor* color) {
#'          CGFloat red, green, blue, alpha;
#'          if (![color getRed:&red green:&green blue:&blue alpha:&alpha]) {
#'            return nil;
#'          }
#'          Color* result = [Color alloc] init];
#'          [result setRed:red];
#'          [result setGreen:green];
#'          [result setBlue:blue];
#'          if (alpha <= 0.9999) {
#'            [result setAlpha:floatWrapperWithValue(alpha)];
#'          }
#'          [result autorelease];
#'          return result;
#'     }
#'     // ...
#' 
#'  Example (JavaScript):
#' 
#'     // ...
#' 
#'     var protoToCssColor = function(rgb_color) {
#'        var redFrac = rgb_color.red || 0.0;
#'        var greenFrac = rgb_color.green || 0.0;
#'        var blueFrac = rgb_color.blue || 0.0;
#'        var red = Math.floor(redFrac * 255);
#'        var green = Math.floor(greenFrac * 255);
#'        var blue = Math.floor(blueFrac * 255);
#' 
#'        if (!('alpha' in rgb_color)) {
#'           return rgbToCssColor_(red, green, blue);
#'        }
#' 
#'        var alphaFrac = rgb_color.alpha.value || 0.0;
#'        var rgbParams = [red, green, blue].join(',');
#'        return ['rgba(', rgbParams, ',', alphaFrac, ')'].join('');
#'     };
#' 
#'     var rgbToCssColor_ = function(red, green, blue) {
#'       var rgbNumber = new Number((red << 16) | (green << 8) | blue);
#'       var hexString = rgbNumber.toString(16);
#'       var missingZeros = 6 - hexString.length;
#'       var resultBuilder = ['#'];
#'       for (var i = 0; i < missingZeros; i++) {
#'          resultBuilder.push('0');
#'       }
#'       resultBuilder.push(hexString);
#'       return resultBuilder.join('');
#'     };
#' 
#'     // ...
#' @param title string. The name of the sheet.
#' @return SheetProperties
#' @export
gsv4_SheetProperties <- function(sheetId=NULL, gridProperties=NULL, hidden=NULL, index=NULL, rightToLeft=NULL, sheetType=NULL, tabColor=NULL, title=NULL){

  params_data <- list()

  if(!is.null(sheetId)){
  stopifnot(is.na(sheetId) || all.equal(sheetId, as.integer(sheetId)))
    params_data[['sheetId']] <- unbox(sheetId)
  }
  if(!is.null(gridProperties)){
  stopifnot(is.na(gridProperties) || class(gridProperties) == 'GridProperties')
    params_data[['gridProperties']] <- gridProperties
  }
  if(!is.null(hidden)){
  stopifnot(is.na(hidden) || is.logical(hidden))
    params_data[['hidden']] <- unbox(hidden)
  }
  if(!is.null(index)){
  stopifnot(is.na(index) || all.equal(index, as.integer(index)))
    params_data[['index']] <- unbox(index)
  }
  if(!is.null(rightToLeft)){
  stopifnot(is.na(rightToLeft) || is.logical(rightToLeft))
    params_data[['rightToLeft']] <- unbox(rightToLeft)
  }
  if(!is.null(sheetType)){
  stopifnot(is.na(sheetType) || is.character(sheetType))
    params_data[['sheetType']] <- unbox(sheetType)
  }
  if(!is.null(tabColor)){
  stopifnot(is.na(tabColor) || class(tabColor) == 'Color')
    params_data[['tabColor']] <- tabColor
  }
  if(!is.null(title)){
  stopifnot(is.na(title) || is.character(title))
    params_data[['title']] <- unbox(title)
  }

  obj <- structure(params_data, class = "SheetProperties")
  return(obj)
}
#' 
#' gsv4_SortRangeRequest
#' 
#' Sorts data in rows based on a sort order per column.
#' 
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#SortRangeRequest}{Google's Documentation for SortRangeRequest}
#' @param range \code{\link{gsv4_GridRange}} object. A range on a sheet.
#' All indexes are zero-based.
#' Indexes are half open, e.g the start index is inclusive
#' and the end index is exclusive -- [start_index, end_index).
#' Missing indexes indicate the range is unbounded on that side.
#' 
#' For example, if `"Sheet1"` is sheet ID 0, then:
#' 
#'   `Sheet1!A1:A1 == sheet_id: 0,
#'                   start_row_index: 0, end_row_index: 1,
#'                   start_column_index: 0, end_column_index: 1`
#' 
#'   `Sheet1!A3:B4 == sheet_id: 0,
#'                   start_row_index: 2, end_row_index: 4,
#'                   start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1!A:B == sheet_id: 0,
#'                 start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1!A5:B == sheet_id: 0,
#'                  start_row_index: 4,
#'                  start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1 == sheet_id:0`
#' 
#' The start index must always be less than or equal to the end index.
#' If the start index equals the end index, then the range is empty.
#' Empty ranges are typically not meaningful and are usually rendered in the
#' UI as `#REF!`.
#' @param sortSpecs list of \code{\link{gsv4_SortSpec}} objects. The sort order per column. Later specifications are used when values
#' are equal in the earlier specifications.
#' @return SortRangeRequest
#' @export
gsv4_SortRangeRequest <- function(range=NULL, sortSpecs=NULL){

  params_data <- list()

  if(!is.null(range)){
  stopifnot(is.na(range) || class(range) == 'GridRange')
    params_data[['range']] <- range
  }
  if(!is.null(sortSpecs)){
  stopifnot(is.na(sortSpecs) || class(sortSpecs) == 'list' || class(sortSpecs) == 'data.frame')
    params_data[['sortSpecs']] <- sortSpecs
  }

  obj <- structure(params_data, class = "SortRangeRequest")
  return(obj)
}
#' 
#' gsv4_SortSpec
#' 
#' A sort order associated with a specific column or row.
#' 
#' sortOrder takes one of the following values:
#' \itemize{
#'  \item{SORT_ORDER_UNSPECIFIED - Default value, do not use this.}
#'  \item{ASCENDING - Sort ascending.}
#'  \item{DESCENDING - Sort descending.}
#' }
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#SortSpec}{Google's Documentation for SortSpec}
#' @param dimensionIndex integer. The dimension the sort should be applied to.
#' @param sortOrder string. The order data should be sorted. sortOrder must take one of the following values: SORT_ORDER_UNSPECIFIED, ASCENDING, DESCENDING
#' See the details section for the definition of each of these values.
#' @return SortSpec
#' @export
gsv4_SortSpec <- function(dimensionIndex=NULL, sortOrder=NULL){

  params_data <- list()

  if(!is.null(dimensionIndex)){
  stopifnot(is.na(dimensionIndex) || all.equal(dimensionIndex, as.integer(dimensionIndex)))
    params_data[['dimensionIndex']] <- unbox(dimensionIndex)
  }
  if(!is.null(sortOrder)){
  stopifnot(is.na(sortOrder) || is.character(sortOrder))
    params_data[['sortOrder']] <- unbox(sortOrder)
  }

  obj <- structure(params_data, class = "SortSpec")
  return(obj)
}
#' 
#' gsv4_SourceAndDestination
#' 
#' A combination of a source range and how to extend that source.
#' 
#' dimension takes one of the following values:
#' \itemize{
#'  \item{DIMENSION_UNSPECIFIED - The default value, do not use.}
#'  \item{ROWS - Operates on the rows of a sheet.}
#'  \item{COLUMNS - Operates on the columns of a sheet.}
#' }
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#SourceAndDestination}{Google's Documentation for SourceAndDestination}
#' @param dimension string. The dimension that data should be filled into. dimension must take one of the following values: DIMENSION_UNSPECIFIED, ROWS, COLUMNS
#' See the details section for the definition of each of these values.
#' @param fillLength integer. The number of rows or columns that data should be filled into.
#' Positive numbers expand beyond the last row or last column
#' of the source.  Negative numbers expand before the first row
#' or first column of the source.
#' @param source \code{\link{gsv4_GridRange}} object. A range on a sheet.
#' All indexes are zero-based.
#' Indexes are half open, e.g the start index is inclusive
#' and the end index is exclusive -- [start_index, end_index).
#' Missing indexes indicate the range is unbounded on that side.
#' 
#' For example, if `"Sheet1"` is sheet ID 0, then:
#' 
#'   `Sheet1!A1:A1 == sheet_id: 0,
#'                   start_row_index: 0, end_row_index: 1,
#'                   start_column_index: 0, end_column_index: 1`
#' 
#'   `Sheet1!A3:B4 == sheet_id: 0,
#'                   start_row_index: 2, end_row_index: 4,
#'                   start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1!A:B == sheet_id: 0,
#'                 start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1!A5:B == sheet_id: 0,
#'                  start_row_index: 4,
#'                  start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1 == sheet_id:0`
#' 
#' The start index must always be less than or equal to the end index.
#' If the start index equals the end index, then the range is empty.
#' Empty ranges are typically not meaningful and are usually rendered in the
#' UI as `#REF!`.
#' @return SourceAndDestination
#' @export
gsv4_SourceAndDestination <- function(dimension=NULL, fillLength=NULL, source=NULL){

  params_data <- list()

  if(!is.null(dimension)){
  stopifnot(is.na(dimension) || is.character(dimension))
    params_data[['dimension']] <- unbox(dimension)
  }
  if(!is.null(fillLength)){
  stopifnot(is.na(fillLength) || all.equal(fillLength, as.integer(fillLength)))
    params_data[['fillLength']] <- unbox(fillLength)
  }
  if(!is.null(source)){
  stopifnot(is.na(source) || class(source) == 'GridRange')
    params_data[['source']] <- source
  }

  obj <- structure(params_data, class = "SourceAndDestination")
  return(obj)
}
#' 
#' gsv4_Spreadsheet
#' 
#' Resource that represents a spreadsheet.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#Spreadsheet}{Google's Documentation for Spreadsheet}
#' @param spreadsheetId string. The ID of the spreadsheet.
#' This field is read-only.
#' @param namedRanges list of \code{\link{gsv4_NamedRange}} objects. The named ranges defined in a spreadsheet.
#' @param properties \code{\link{gsv4_SpreadsheetProperties}} object. Properties of a spreadsheet.
#' @param sheets list of \code{\link{gsv4_Sheet}} objects. The sheets that are part of a spreadsheet.
#' @param spreadsheetUrl string. The url of the spreadsheet.
#' This field is read-only.
#' @return Spreadsheet
#' @export
gsv4_Spreadsheet <- function(spreadsheetId=NULL, namedRanges=NULL, properties=NULL, sheets=NULL, spreadsheetUrl=NULL){

  params_data <- list()

  if(!is.null(spreadsheetId)){
  stopifnot(is.na(spreadsheetId) || is.character(spreadsheetId))
    params_data[['spreadsheetId']] <- unbox(spreadsheetId)
  }
  if(!is.null(namedRanges)){
  stopifnot(is.na(namedRanges) || class(namedRanges) == 'list' || class(namedRanges) == 'data.frame')
    params_data[['namedRanges']] <- namedRanges
  }
  if(!is.null(properties)){
  stopifnot(is.na(properties) || class(properties) == 'SpreadsheetProperties')
    params_data[['properties']] <- properties
  }
  if(!is.null(sheets)){
  stopifnot(is.na(sheets) || class(sheets) == 'list' || class(sheets) == 'data.frame')
    params_data[['sheets']] <- sheets
  }
  if(!is.null(spreadsheetUrl)){
  stopifnot(is.na(spreadsheetUrl) || is.character(spreadsheetUrl))
    params_data[['spreadsheetUrl']] <- unbox(spreadsheetUrl)
  }

  obj <- structure(params_data, class = "Spreadsheet")
  return(obj)
}
#' 
#' gsv4_SpreadsheetProperties
#' 
#' Properties of a spreadsheet.
#' 
#' autoRecalc takes one of the following values:
#' \itemize{
#'  \item{RECALCULATION_INTERVAL_UNSPECIFIED - Default value. This value must not be used.}
#'  \item{ON_CHANGE - Volatile functions are updated on every change.}
#'  \item{MINUTE - Volatile functions are updated on every change and every minute.}
#'  \item{HOUR - Volatile functions are updated on every change and hourly.}
#' }
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#SpreadsheetProperties}{Google's Documentation for SpreadsheetProperties}
#' @param autoRecalc string. The amount of time to wait before volatile functions are recalculated. autoRecalc must take one of the following values: RECALCULATION_INTERVAL_UNSPECIFIED, ON_CHANGE, MINUTE, HOUR
#' See the details section for the definition of each of these values.
#' @param defaultFormat \code{\link{gsv4_CellFormat}} object. The format of a cell.
#' @param iterativeCalculationSettings \code{\link{gsv4_IterativeCalculationSettings}} object. Settings to control how circular dependencies are resolved with iterative
#' calculation.
#' @param locale string. The locale of the spreadsheet in one of the following formats:
#' 
#' * an ISO 639-1 language code such as `en`
#' 
#' * an ISO 639-2 language code such as `fil`, if no 639-1 code exists
#' 
#' * a combination of the ISO language code and country code, such as `en_US`
#' 
#' Note: when updating this field, not all locales/languages are supported.
#' @param timeZone string. The time zone of the spreadsheet, in CLDR format such as
#' `America/New_York`. If the time zone isn't recognized, this may
#' be a custom time zone such as `GMT-07:00`.
#' @param title string. The title of the spreadsheet.
#' @return SpreadsheetProperties
#' @export
gsv4_SpreadsheetProperties <- function(autoRecalc=NULL, defaultFormat=NULL, iterativeCalculationSettings=NULL, locale=NULL, timeZone=NULL, title=NULL){

  params_data <- list()

  if(!is.null(autoRecalc)){
  stopifnot(is.na(autoRecalc) || is.character(autoRecalc))
    params_data[['autoRecalc']] <- unbox(autoRecalc)
  }
  if(!is.null(defaultFormat)){
  stopifnot(is.na(defaultFormat) || class(defaultFormat) == 'CellFormat')
    params_data[['defaultFormat']] <- defaultFormat
  }
  if(!is.null(iterativeCalculationSettings)){
  stopifnot(is.na(iterativeCalculationSettings) || class(iterativeCalculationSettings) == 'IterativeCalculationSettings')
    params_data[['iterativeCalculationSettings']] <- iterativeCalculationSettings
  }
  if(!is.null(locale)){
  stopifnot(is.na(locale) || is.character(locale))
    params_data[['locale']] <- unbox(locale)
  }
  if(!is.null(timeZone)){
  stopifnot(is.na(timeZone) || is.character(timeZone))
    params_data[['timeZone']] <- unbox(timeZone)
  }
  if(!is.null(title)){
  stopifnot(is.na(title) || is.character(title))
    params_data[['title']] <- unbox(title)
  }

  obj <- structure(params_data, class = "SpreadsheetProperties")
  return(obj)
}
#' 
#' gsv4_TextFormat
#' 
#' The format of a run of text in a cell.
#' Absent values indicate that the field isn't specified.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#TextFormat}{Google's Documentation for TextFormat}
#' @param bold logical. TRUE if the text is bold.
#' @param fontFamily string. The font family.
#' @param fontSize integer. The size of the font.
#' @param foregroundColor \code{\link{gsv4_Color}} object. Represents a color in the RGBA color space. This representation is designed
#' for simplicity of conversion to/from color representations in various
#' languages over compactness; for example, the fields of this representation
#' can be trivially provided to the constructor of "java.awt.Color" in Java; it
#' can also be trivially provided to UIColor's "+colorWithRed:green:blue:alpha"
#' method in iOS; and, with just a little work, it can be easily formatted into
#' a CSS "rgba()" string in JavaScript, as well. Here are some examples:
#' 
#' Example (Java):
#' 
#'      import com.google.type.Color;
#' 
#'      // ...
#'      public static java.awt.Color fromProto(Color protocolor) {
#'        float alpha = protocolor.hasAlpha()
#'            ? protocolor.getAlpha().getValue()
#'            : 1.0;
#' 
#'        return new java.awt.Color(
#'            protocolor.getRed(),
#'            protocolor.getGreen(),
#'            protocolor.getBlue(),
#'            alpha);
#'      }
#' 
#'      public static Color toProto(java.awt.Color color) {
#'        float red = (float) color.getRed();
#'        float green = (float) color.getGreen();
#'        float blue = (float) color.getBlue();
#'        float denominator = 255.0;
#'        Color.Builder resultBuilder =
#'            Color
#'                .newBuilder()
#'                .setRed(red / denominator)
#'                .setGreen(green / denominator)
#'                .setBlue(blue / denominator);
#'        int alpha = color.getAlpha();
#'        if (alpha != 255) {
#'          result.setAlpha(
#'              FloatValue
#'                  .newBuilder()
#'                  .setValue(((float) alpha) / denominator)
#'                  .build());
#'        }
#'        return resultBuilder.build();
#'      }
#'      // ...
#' 
#' Example (iOS / Obj-C):
#' 
#'      // ...
#'      static UIColor* fromProto(Color* protocolor) {
#'         float red = [protocolor red];
#'         float green = [protocolor green];
#'         float blue = [protocolor blue];
#'         FloatValue* alpha_wrapper = [protocolor alpha];
#'         float alpha = 1.0;
#'         if (alpha_wrapper != nil) {
#'           alpha = [alpha_wrapper value];
#'         }
#'         return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
#'      }
#' 
#'      static Color* toProto(UIColor* color) {
#'          CGFloat red, green, blue, alpha;
#'          if (![color getRed:&red green:&green blue:&blue alpha:&alpha]) {
#'            return nil;
#'          }
#'          Color* result = [Color alloc] init];
#'          [result setRed:red];
#'          [result setGreen:green];
#'          [result setBlue:blue];
#'          if (alpha <= 0.9999) {
#'            [result setAlpha:floatWrapperWithValue(alpha)];
#'          }
#'          [result autorelease];
#'          return result;
#'     }
#'     // ...
#' 
#'  Example (JavaScript):
#' 
#'     // ...
#' 
#'     var protoToCssColor = function(rgb_color) {
#'        var redFrac = rgb_color.red || 0.0;
#'        var greenFrac = rgb_color.green || 0.0;
#'        var blueFrac = rgb_color.blue || 0.0;
#'        var red = Math.floor(redFrac * 255);
#'        var green = Math.floor(greenFrac * 255);
#'        var blue = Math.floor(blueFrac * 255);
#' 
#'        if (!('alpha' in rgb_color)) {
#'           return rgbToCssColor_(red, green, blue);
#'        }
#' 
#'        var alphaFrac = rgb_color.alpha.value || 0.0;
#'        var rgbParams = [red, green, blue].join(',');
#'        return ['rgba(', rgbParams, ',', alphaFrac, ')'].join('');
#'     };
#' 
#'     var rgbToCssColor_ = function(red, green, blue) {
#'       var rgbNumber = new Number((red << 16) | (green << 8) | blue);
#'       var hexString = rgbNumber.toString(16);
#'       var missingZeros = 6 - hexString.length;
#'       var resultBuilder = ['#'];
#'       for (var i = 0; i < missingZeros; i++) {
#'          resultBuilder.push('0');
#'       }
#'       resultBuilder.push(hexString);
#'       return resultBuilder.join('');
#'     };
#' 
#'     // ...
#' @param italic logical. TRUE if the text is italicized.
#' @param strikethrough logical. TRUE if the text has a strikethrough.
#' @param underline logical. TRUE if the text is underlined.
#' @return TextFormat
#' @export
gsv4_TextFormat <- function(bold=NULL, fontFamily=NULL, fontSize=NULL, foregroundColor=NULL, italic=NULL, strikethrough=NULL, underline=NULL){

  params_data <- list()

  if(!is.null(bold)){
  stopifnot(is.na(bold) || is.logical(bold))
    params_data[['bold']] <- unbox(bold)
  }
  if(!is.null(fontFamily)){
  stopifnot(is.na(fontFamily) || is.character(fontFamily))
    params_data[['fontFamily']] <- unbox(fontFamily)
  }
  if(!is.null(fontSize)){
  stopifnot(is.na(fontSize) || all.equal(fontSize, as.integer(fontSize)))
    params_data[['fontSize']] <- unbox(fontSize)
  }
  if(!is.null(foregroundColor)){
  stopifnot(is.na(foregroundColor) || class(foregroundColor) == 'Color')
    params_data[['foregroundColor']] <- foregroundColor
  }
  if(!is.null(italic)){
  stopifnot(is.na(italic) || is.logical(italic))
    params_data[['italic']] <- unbox(italic)
  }
  if(!is.null(strikethrough)){
  stopifnot(is.na(strikethrough) || is.logical(strikethrough))
    params_data[['strikethrough']] <- unbox(strikethrough)
  }
  if(!is.null(underline)){
  stopifnot(is.na(underline) || is.logical(underline))
    params_data[['underline']] <- unbox(underline)
  }

  obj <- structure(params_data, class = "TextFormat")
  return(obj)
}
#' 
#' gsv4_TextFormatRun
#' 
#' A run of a text format. The format of this run continues until the start
#' index of the next run.
#' When updating, all fields must be set.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#TextFormatRun}{Google's Documentation for TextFormatRun}
#' @param format \code{\link{gsv4_TextFormat}} object. The format of a run of text in a cell.
#' Absent values indicate that the field isn't specified.
#' @param startIndex integer. The character index where this run starts.
#' @return TextFormatRun
#' @export
gsv4_TextFormatRun <- function(format=NULL, startIndex=NULL){

  params_data <- list()

  if(!is.null(format)){
  stopifnot(is.na(format) || class(format) == 'TextFormat')
    params_data[['format']] <- format
  }
  if(!is.null(startIndex)){
  stopifnot(is.na(startIndex) || all.equal(startIndex, as.integer(startIndex)))
    params_data[['startIndex']] <- unbox(startIndex)
  }

  obj <- structure(params_data, class = "TextFormatRun")
  return(obj)
}
#' 
#' gsv4_TextRotation
#' 
#' The rotation applied to text in a cell.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#TextRotation}{Google's Documentation for TextRotation}
#' @param angle integer. The angle between the standard orientation and the desired orientation.
#' Measured in degrees. Valid values are between -90 and 90. Positive
#' angles are angled upwards, negative are angled downwards.
#' 
#' Note: For LTR text direction positive angles are in the counterclockwise
#' direction, whereas for RTL they are in the clockwise direction
#' @param vertical logical. If TRUE, text reads top to bottom, but the orientation of individual
#' characters is unchanged.
#' For example:
#' 
#'     | V |
#'     | e |
#'     | r |
#'     | t |
#'     | i |
#'     | c |
#'     | a |
#'     | l |
#' @return TextRotation
#' @export
gsv4_TextRotation <- function(angle=NULL, vertical=NULL){

  params_data <- list()

  if(!is.null(angle)){
  stopifnot(is.na(angle) || all.equal(angle, as.integer(angle)))
    params_data[['angle']] <- unbox(angle)
  }
  if(!is.null(vertical)){
  stopifnot(is.na(vertical) || is.logical(vertical))
    params_data[['vertical']] <- unbox(vertical)
  }

  obj <- structure(params_data, class = "TextRotation")
  return(obj)
}
#' 
#' gsv4_TextToColumnsRequest
#' 
#' Splits a column of text into multiple columns,
#' based on a delimiter in each cell.
#' 
#' delimiterType takes one of the following values:
#' \itemize{
#'  \item{DELIMITER_TYPE_UNSPECIFIED - Default value. This value must not be used.}
#'  \item{COMMA - ","}
#'  \item{SEMICOLON - ";"}
#'  \item{PERIOD - "."}
#'  \item{SPACE - " "}
#'  \item{CUSTOM - A custom value as defined in delimiter.}
#' }
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#TextToColumnsRequest}{Google's Documentation for TextToColumnsRequest}
#' @param delimiter string. The delimiter to use. Used only if delimiterType is
#' CUSTOM.
#' @param delimiterType string. The delimiter type to use. delimiterType must take one of the following values: DELIMITER_TYPE_UNSPECIFIED, COMMA, SEMICOLON, PERIOD, SPACE, CUSTOM
#' See the details section for the definition of each of these values.
#' @param source \code{\link{gsv4_GridRange}} object. A range on a sheet.
#' All indexes are zero-based.
#' Indexes are half open, e.g the start index is inclusive
#' and the end index is exclusive -- [start_index, end_index).
#' Missing indexes indicate the range is unbounded on that side.
#' 
#' For example, if `"Sheet1"` is sheet ID 0, then:
#' 
#'   `Sheet1!A1:A1 == sheet_id: 0,
#'                   start_row_index: 0, end_row_index: 1,
#'                   start_column_index: 0, end_column_index: 1`
#' 
#'   `Sheet1!A3:B4 == sheet_id: 0,
#'                   start_row_index: 2, end_row_index: 4,
#'                   start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1!A:B == sheet_id: 0,
#'                 start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1!A5:B == sheet_id: 0,
#'                  start_row_index: 4,
#'                  start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1 == sheet_id:0`
#' 
#' The start index must always be less than or equal to the end index.
#' If the start index equals the end index, then the range is empty.
#' Empty ranges are typically not meaningful and are usually rendered in the
#' UI as `#REF!`.
#' @return TextToColumnsRequest
#' @export
gsv4_TextToColumnsRequest <- function(delimiter=NULL, delimiterType=NULL, source=NULL){

  params_data <- list()

  if(!is.null(delimiter)){
  stopifnot(is.na(delimiter) || is.character(delimiter))
    params_data[['delimiter']] <- unbox(delimiter)
  }
  if(!is.null(delimiterType)){
  stopifnot(is.na(delimiterType) || is.character(delimiterType))
    params_data[['delimiterType']] <- unbox(delimiterType)
  }
  if(!is.null(source)){
  stopifnot(is.na(source) || class(source) == 'GridRange')
    params_data[['source']] <- source
  }

  obj <- structure(params_data, class = "TextToColumnsRequest")
  return(obj)
}
#' 
#' gsv4_UnmergeCellsRequest
#' 
#' Unmerges cells in the given range.
#' 
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#UnmergeCellsRequest}{Google's Documentation for UnmergeCellsRequest}
#' @param range \code{\link{gsv4_GridRange}} object. A range on a sheet.
#' All indexes are zero-based.
#' Indexes are half open, e.g the start index is inclusive
#' and the end index is exclusive -- [start_index, end_index).
#' Missing indexes indicate the range is unbounded on that side.
#' 
#' For example, if `"Sheet1"` is sheet ID 0, then:
#' 
#'   `Sheet1!A1:A1 == sheet_id: 0,
#'                   start_row_index: 0, end_row_index: 1,
#'                   start_column_index: 0, end_column_index: 1`
#' 
#'   `Sheet1!A3:B4 == sheet_id: 0,
#'                   start_row_index: 2, end_row_index: 4,
#'                   start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1!A:B == sheet_id: 0,
#'                 start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1!A5:B == sheet_id: 0,
#'                  start_row_index: 4,
#'                  start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1 == sheet_id:0`
#' 
#' The start index must always be less than or equal to the end index.
#' If the start index equals the end index, then the range is empty.
#' Empty ranges are typically not meaningful and are usually rendered in the
#' UI as `#REF!`.
#' @return UnmergeCellsRequest
#' @export
gsv4_UnmergeCellsRequest <- function(range=NULL){

  params_data <- list()

  if(!is.null(range)){
  stopifnot(is.na(range) || class(range) == 'GridRange')
    params_data[['range']] <- range
  }

  obj <- structure(params_data, class = "UnmergeCellsRequest")
  return(obj)
}
#' 
#' gsv4_UpdateBandingRequest
#' 
#' Updates properties of the supplied banded range.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#UpdateBandingRequest}{Google's Documentation for UpdateBandingRequest}
#' @param fields string. The fields that should be updated.  At least one field must be specified.
#' The root `bandedRange` is implied and should not be specified.
#' A single `"*"` can be used as short-hand for listing every field.
#' @param bandedRange \code{\link{gsv4_BandedRange}} object. A banded (alternating colors) range in a sheet.
#' @return UpdateBandingRequest
#' @export
gsv4_UpdateBandingRequest <- function(fields=NULL, bandedRange=NULL){

  params_data <- list()

  if(!is.null(fields)){
  stopifnot(is.na(fields) || is.character(fields))
    params_data[['fields']] <- unbox(fields)
  }
  if(!is.null(bandedRange)){
  stopifnot(is.na(bandedRange) || class(bandedRange) == 'BandedRange')
    params_data[['bandedRange']] <- bandedRange
  }

  obj <- structure(params_data, class = "UpdateBandingRequest")
  return(obj)
}
#' 
#' gsv4_UpdateBordersRequest
#' 
#' Updates the borders of a range.
#' If a field is not set in the request, that means the border remains as-is.
#' For example, with two subsequent UpdateBordersRequest:
#' 
#'  1. range: A1:A5 `{ top: RED, bottom: WHITE }`
#'  2. range: A1:A5 `{ left: BLUE }`
#' 
#' That would result in A1:A5 having a borders of
#' `{ top: RED, bottom: WHITE, left: BLUE }`.
#' If you want to clear a border, explicitly set the style to
#' NONE.
#' 
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#UpdateBordersRequest}{Google's Documentation for UpdateBordersRequest}
#' @param range \code{\link{gsv4_GridRange}} object. A range on a sheet.
#' All indexes are zero-based.
#' Indexes are half open, e.g the start index is inclusive
#' and the end index is exclusive -- [start_index, end_index).
#' Missing indexes indicate the range is unbounded on that side.
#' 
#' For example, if `"Sheet1"` is sheet ID 0, then:
#' 
#'   `Sheet1!A1:A1 == sheet_id: 0,
#'                   start_row_index: 0, end_row_index: 1,
#'                   start_column_index: 0, end_column_index: 1`
#' 
#'   `Sheet1!A3:B4 == sheet_id: 0,
#'                   start_row_index: 2, end_row_index: 4,
#'                   start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1!A:B == sheet_id: 0,
#'                 start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1!A5:B == sheet_id: 0,
#'                  start_row_index: 4,
#'                  start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1 == sheet_id:0`
#' 
#' The start index must always be less than or equal to the end index.
#' If the start index equals the end index, then the range is empty.
#' Empty ranges are typically not meaningful and are usually rendered in the
#' UI as `#REF!`.
#' @param bottom \code{\link{gsv4_Border}} object. A border along a cell.
#' @param innerHorizontal \code{\link{gsv4_Border}} object. A border along a cell.
#' @param innerVertical \code{\link{gsv4_Border}} object. A border along a cell.
#' @param left \code{\link{gsv4_Border}} object. A border along a cell.
#' @param right \code{\link{gsv4_Border}} object. A border along a cell.
#' @param top \code{\link{gsv4_Border}} object. A border along a cell.
#' @return UpdateBordersRequest
#' @export
gsv4_UpdateBordersRequest <- function(range=NULL, bottom=NULL, innerHorizontal=NULL, innerVertical=NULL, left=NULL, right=NULL, top=NULL){

  params_data <- list()

  if(!is.null(range)){
  stopifnot(is.na(range) || class(range) == 'GridRange')
    params_data[['range']] <- range
  }
  if(!is.null(bottom)){
  stopifnot(is.na(bottom) || class(bottom) == 'Border')
    params_data[['bottom']] <- bottom
  }
  if(!is.null(innerHorizontal)){
  stopifnot(is.na(innerHorizontal) || class(innerHorizontal) == 'Border')
    params_data[['innerHorizontal']] <- innerHorizontal
  }
  if(!is.null(innerVertical)){
  stopifnot(is.na(innerVertical) || class(innerVertical) == 'Border')
    params_data[['innerVertical']] <- innerVertical
  }
  if(!is.null(left)){
  stopifnot(is.na(left) || class(left) == 'Border')
    params_data[['left']] <- left
  }
  if(!is.null(right)){
  stopifnot(is.na(right) || class(right) == 'Border')
    params_data[['right']] <- right
  }
  if(!is.null(top)){
  stopifnot(is.na(top) || class(top) == 'Border')
    params_data[['top']] <- top
  }

  obj <- structure(params_data, class = "UpdateBordersRequest")
  return(obj)
}
#' 
#' gsv4_UpdateCellsRequest
#' 
#' Updates all cells in a range with new data.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#UpdateCellsRequest}{Google's Documentation for UpdateCellsRequest}
#' @param range \code{\link{gsv4_GridRange}} object. A range on a sheet.
#' All indexes are zero-based.
#' Indexes are half open, e.g the start index is inclusive
#' and the end index is exclusive -- [start_index, end_index).
#' Missing indexes indicate the range is unbounded on that side.
#' 
#' For example, if `"Sheet1"` is sheet ID 0, then:
#' 
#'   `Sheet1!A1:A1 == sheet_id: 0,
#'                   start_row_index: 0, end_row_index: 1,
#'                   start_column_index: 0, end_column_index: 1`
#' 
#'   `Sheet1!A3:B4 == sheet_id: 0,
#'                   start_row_index: 2, end_row_index: 4,
#'                   start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1!A:B == sheet_id: 0,
#'                 start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1!A5:B == sheet_id: 0,
#'                  start_row_index: 4,
#'                  start_column_index: 0, end_column_index: 2`
#' 
#'   `Sheet1 == sheet_id:0`
#' 
#' The start index must always be less than or equal to the end index.
#' If the start index equals the end index, then the range is empty.
#' Empty ranges are typically not meaningful and are usually rendered in the
#' UI as `#REF!`.
#' @param rows list of \code{\link{gsv4_RowData}} objects. The data to write.
#' @param fields string. The fields of CellData that should be updated.
#' At least one field must be specified.
#' The root is the CellData; 'row.values.' should not be specified.
#' A single `"*"` can be used as short-hand for listing every field.
#' @param start \code{\link{gsv4_GridCoordinate}} object. A coordinate in a sheet.
#' All indexes are zero-based.
#' @return UpdateCellsRequest
#' @export
gsv4_UpdateCellsRequest <- function(range=NULL, rows=NULL, fields=NULL, start=NULL){

  params_data <- list()

  if(!is.null(range)){
  stopifnot(is.na(range) || class(range) == 'GridRange')
    params_data[['range']] <- range
  }
  if(!is.null(rows)){
  stopifnot(is.na(rows) || class(rows) == 'list' || class(rows) == 'data.frame')
    params_data[['rows']] <- rows
  }
  if(!is.null(fields)){
  stopifnot(is.na(fields) || is.character(fields))
    params_data[['fields']] <- unbox(fields)
  }
  if(!is.null(start)){
  stopifnot(is.na(start) || class(start) == 'GridCoordinate')
    params_data[['start']] <- start
  }

  obj <- structure(params_data, class = "UpdateCellsRequest")
  return(obj)
}
#' 
#' gsv4_UpdateChartSpecRequest
#' 
#' Updates a chart's specifications.
#' (This does not move or resize a chart. To move or resize a chart, use
#'  UpdateEmbeddedObjectPositionRequest.)
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#UpdateChartSpecRequest}{Google's Documentation for UpdateChartSpecRequest}
#' @param chartId integer. The ID of the chart to update.
#' @param spec \code{\link{gsv4_ChartSpec}} object. The specifications of a chart.
#' @return UpdateChartSpecRequest
#' @export
gsv4_UpdateChartSpecRequest <- function(chartId=NULL, spec=NULL){

  params_data <- list()

  if(!is.null(chartId)){
  stopifnot(is.na(chartId) || all.equal(chartId, as.integer(chartId)))
    params_data[['chartId']] <- unbox(chartId)
  }
  if(!is.null(spec)){
  stopifnot(is.na(spec) || class(spec) == 'ChartSpec')
    params_data[['spec']] <- spec
  }

  obj <- structure(params_data, class = "UpdateChartSpecRequest")
  return(obj)
}
#' 
#' gsv4_UpdateConditionalFormatRuleRequest
#' 
#' Updates a conditional format rule at the given index,
#' or moves a conditional format rule to another index.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#UpdateConditionalFormatRuleRequest}{Google's Documentation for UpdateConditionalFormatRuleRequest}
#' @param sheetId integer. The sheet of the rule to move.  Required if new_index is set,
#' unused otherwise.
#' @param index integer. The zero-based index of the rule that should be replaced or moved.
#' @param newIndex integer. The zero-based new index the rule should end up at.
#' @param rule \code{\link{gsv4_ConditionalFormatRule}} object. A rule describing a conditional format.
#' @return UpdateConditionalFormatRuleRequest
#' @export
gsv4_UpdateConditionalFormatRuleRequest <- function(sheetId=NULL, index=NULL, newIndex=NULL, rule=NULL){

  params_data <- list()

  if(!is.null(sheetId)){
  stopifnot(is.na(sheetId) || all.equal(sheetId, as.integer(sheetId)))
    params_data[['sheetId']] <- unbox(sheetId)
  }
  if(!is.null(index)){
  stopifnot(is.na(index) || all.equal(index, as.integer(index)))
    params_data[['index']] <- unbox(index)
  }
  if(!is.null(newIndex)){
  stopifnot(is.na(newIndex) || all.equal(newIndex, as.integer(newIndex)))
    params_data[['newIndex']] <- unbox(newIndex)
  }
  if(!is.null(rule)){
  stopifnot(is.na(rule) || class(rule) == 'ConditionalFormatRule')
    params_data[['rule']] <- rule
  }

  obj <- structure(params_data, class = "UpdateConditionalFormatRuleRequest")
  return(obj)
}
#' 
#' gsv4_UpdateDimensionPropertiesRequest
#' 
#' Updates properties of dimensions within the specified range.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#UpdateDimensionPropertiesRequest}{Google's Documentation for UpdateDimensionPropertiesRequest}
#' @param range \code{\link{gsv4_DimensionRange}} object. A range along a single dimension on a sheet.
#' All indexes are zero-based.
#' Indexes are half open: the start index is inclusive
#' and the end index is exclusive.
#' Missing indexes indicate the range is unbounded on that side.
#' @param fields string. The fields that should be updated.  At least one field must be specified.
#' The root `properties` is implied and should not be specified.
#' A single `"*"` can be used as short-hand for listing every field.
#' @param properties \code{\link{gsv4_DimensionProperties}} object. Properties about a dimension.
#' @return UpdateDimensionPropertiesRequest
#' @export
gsv4_UpdateDimensionPropertiesRequest <- function(range=NULL, fields=NULL, properties=NULL){

  params_data <- list()

  if(!is.null(range)){
  stopifnot(is.na(range) || class(range) == 'DimensionRange')
    params_data[['range']] <- range
  }
  if(!is.null(fields)){
  stopifnot(is.na(fields) || is.character(fields))
    params_data[['fields']] <- unbox(fields)
  }
  if(!is.null(properties)){
  stopifnot(is.na(properties) || class(properties) == 'DimensionProperties')
    params_data[['properties']] <- properties
  }

  obj <- structure(params_data, class = "UpdateDimensionPropertiesRequest")
  return(obj)
}
#' 
#' gsv4_UpdateEmbeddedObjectPositionRequest
#' 
#' Update an embedded object's position (such as a moving or resizing a
#' chart or image).
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#UpdateEmbeddedObjectPositionRequest}{Google's Documentation for UpdateEmbeddedObjectPositionRequest}
#' @param fields string. The fields of OverlayPosition
#' that should be updated when setting a new position. Used only if
#' newPosition.overlayPosition
#' is set, in which case at least one field must
#' be specified.  The root `newPosition.overlayPosition` is implied and
#' should not be specified.
#' A single `"*"` can be used as short-hand for listing every field.
#' @param newPosition \code{\link{gsv4_EmbeddedObjectPosition}} object. The position of an embedded object such as a chart.
#' @param objectId integer. The ID of the object to moved.
#' @return UpdateEmbeddedObjectPositionRequest
#' @export
gsv4_UpdateEmbeddedObjectPositionRequest <- function(fields=NULL, newPosition=NULL, objectId=NULL){

  params_data <- list()

  if(!is.null(fields)){
  stopifnot(is.na(fields) || is.character(fields))
    params_data[['fields']] <- unbox(fields)
  }
  if(!is.null(newPosition)){
  stopifnot(is.na(newPosition) || class(newPosition) == 'EmbeddedObjectPosition')
    params_data[['newPosition']] <- newPosition
  }
  if(!is.null(objectId)){
  stopifnot(is.na(objectId) || all.equal(objectId, as.integer(objectId)))
    params_data[['objectId']] <- unbox(objectId)
  }

  obj <- structure(params_data, class = "UpdateEmbeddedObjectPositionRequest")
  return(obj)
}
#' 
#' gsv4_UpdateFilterViewRequest
#' 
#' Updates properties of the filter view.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#UpdateFilterViewRequest}{Google's Documentation for UpdateFilterViewRequest}
#' @param fields string. The fields that should be updated.  At least one field must be specified.
#' The root `filter` is implied and should not be specified.
#' A single `"*"` can be used as short-hand for listing every field.
#' @param filter \code{\link{gsv4_FilterView}} object. A filter view.
#' @return UpdateFilterViewRequest
#' @export
gsv4_UpdateFilterViewRequest <- function(fields=NULL, filter=NULL){

  params_data <- list()

  if(!is.null(fields)){
  stopifnot(is.na(fields) || is.character(fields))
    params_data[['fields']] <- unbox(fields)
  }
  if(!is.null(filter)){
  stopifnot(is.na(filter) || class(filter) == 'FilterView')
    params_data[['filter']] <- filter
  }

  obj <- structure(params_data, class = "UpdateFilterViewRequest")
  return(obj)
}
#' 
#' gsv4_UpdateNamedRangeRequest
#' 
#' Updates properties of the named range with the specified
#' namedRangeId.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#UpdateNamedRangeRequest}{Google's Documentation for UpdateNamedRangeRequest}
#' @param fields string. The fields that should be updated.  At least one field must be specified.
#' The root `namedRange` is implied and should not be specified.
#' A single `"*"` can be used as short-hand for listing every field.
#' @param namedRange \code{\link{gsv4_NamedRange}} object. A named range.
#' @return UpdateNamedRangeRequest
#' @export
gsv4_UpdateNamedRangeRequest <- function(fields=NULL, namedRange=NULL){

  params_data <- list()

  if(!is.null(fields)){
  stopifnot(is.na(fields) || is.character(fields))
    params_data[['fields']] <- unbox(fields)
  }
  if(!is.null(namedRange)){
  stopifnot(is.na(namedRange) || class(namedRange) == 'NamedRange')
    params_data[['namedRange']] <- namedRange
  }

  obj <- structure(params_data, class = "UpdateNamedRangeRequest")
  return(obj)
}
#' 
#' gsv4_UpdateProtectedRangeRequest
#' 
#' Updates an existing protected range with the specified
#' protectedRangeId.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#UpdateProtectedRangeRequest}{Google's Documentation for UpdateProtectedRangeRequest}
#' @param fields string. The fields that should be updated.  At least one field must be specified.
#' The root `protectedRange` is implied and should not be specified.
#' A single `"*"` can be used as short-hand for listing every field.
#' @param protectedRange \code{\link{gsv4_ProtectedRange}} object. A protected range.
#' @return UpdateProtectedRangeRequest
#' @export
gsv4_UpdateProtectedRangeRequest <- function(fields=NULL, protectedRange=NULL){

  params_data <- list()

  if(!is.null(fields)){
  stopifnot(is.na(fields) || is.character(fields))
    params_data[['fields']] <- unbox(fields)
  }
  if(!is.null(protectedRange)){
  stopifnot(is.na(protectedRange) || class(protectedRange) == 'ProtectedRange')
    params_data[['protectedRange']] <- protectedRange
  }

  obj <- structure(params_data, class = "UpdateProtectedRangeRequest")
  return(obj)
}
#' 
#' gsv4_UpdateSheetPropertiesRequest
#' 
#' Updates properties of the sheet with the specified
#' sheetId.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#UpdateSheetPropertiesRequest}{Google's Documentation for UpdateSheetPropertiesRequest}
#' @param fields string. The fields that should be updated.  At least one field must be specified.
#' The root `properties` is implied and should not be specified.
#' A single `"*"` can be used as short-hand for listing every field.
#' @param properties \code{\link{gsv4_SheetProperties}} object. Properties of a sheet.
#' @return UpdateSheetPropertiesRequest
#' @export
gsv4_UpdateSheetPropertiesRequest <- function(fields=NULL, properties=NULL){

  params_data <- list()

  if(!is.null(fields)){
  stopifnot(is.na(fields) || is.character(fields))
    params_data[['fields']] <- unbox(fields)
  }
  if(!is.null(properties)){
  stopifnot(is.na(properties) || class(properties) == 'SheetProperties')
    params_data[['properties']] <- properties
  }

  obj <- structure(params_data, class = "UpdateSheetPropertiesRequest")
  return(obj)
}
#' 
#' gsv4_UpdateSpreadsheetPropertiesRequest
#' 
#' Updates properties of a spreadsheet.
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets#UpdateSpreadsheetPropertiesRequest}{Google's Documentation for UpdateSpreadsheetPropertiesRequest}
#' @param fields string. The fields that should be updated.  At least one field must be specified.
#' The root 'properties' is implied and should not be specified.
#' A single `"*"` can be used as short-hand for listing every field.
#' @param properties \code{\link{gsv4_SpreadsheetProperties}} object. Properties of a spreadsheet.
#' @return UpdateSpreadsheetPropertiesRequest
#' @export
gsv4_UpdateSpreadsheetPropertiesRequest <- function(fields=NULL, properties=NULL){

  params_data <- list()

  if(!is.null(fields)){
  stopifnot(is.na(fields) || is.character(fields))
    params_data[['fields']] <- unbox(fields)
  }
  if(!is.null(properties)){
  stopifnot(is.na(properties) || class(properties) == 'SpreadsheetProperties')
    params_data[['properties']] <- properties
  }

  obj <- structure(params_data, class = "UpdateSpreadsheetPropertiesRequest")
  return(obj)
}
#' 
#' gsv4_ValueRange
#' 
#' Data within a range of the spreadsheet.
#' 
#' majorDimension takes one of the following values:
#' \itemize{
#'  \item{DIMENSION_UNSPECIFIED - The default value, do not use.}
#'  \item{ROWS - Operates on the rows of a sheet.}
#'  \item{COLUMNS - Operates on the columns of a sheet.}
#' }
#' 
#' @importFrom jsonlite unbox
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets.values#ValueRange}{Google's Documentation for ValueRange}
#' @param range string. The range the values cover, in A1 notation.
#' For output, this range indicates the entire requested range,
#' even though the values will exclude trailing rows and columns.
#' When appending values, this field represents the range to search for a
#' table, after which values will be appended.
#' @param majorDimension string. The major dimension of the values.
#' 
#' For output, if the spreadsheet data is: `A1=1,B1=2,A2=3,B2=4`,
#' then requesting `range=A1:B2,majorDimension=ROWS` will return
#' `[[1,2],[3,4]]`,
#' whereas requesting `range=A1:B2,majorDimension=COLUMNS` will return
#' `[[1,3],[2,4]]`.
#' 
#' For input, with `range=A1:B2,majorDimension=ROWS` then `[[1,2],[3,4]]`
#' will set `A1=1,B1=2,A2=3,B2=4`. With `range=A1:B2,majorDimension=COLUMNS`
#' then `[[1,2],[3,4]]` will set `A1=1,B1=3,A2=2,B2=4`.
#' 
#' When writing, if this field is not set, it defaults to ROWS. majorDimension must take one of the following values: DIMENSION_UNSPECIFIED, ROWS, COLUMNS
#' See the details section for the definition of each of these values.
#' @param values list. The data that was read or to be written.  This is an array of arrays,
#' the outer array representing all the data and each inner array
#' representing a major dimension. Each item in the inner array
#' corresponds with one cell.
#' 
#' For output, empty trailing rows and columns will not be included.
#' 
#' For input, supported value types are: bool, string, and double.
#' Null values will be skipped.
#' To set a cell to an empty value, set the string value to an empty string.
#' @return ValueRange
#' @export
gsv4_ValueRange <- function(range=NULL, majorDimension=NULL, values=NULL){

  params_data <- list()

  if(!is.null(range)){
  stopifnot(is.na(range) || is.character(range))
    params_data[['range']] <- unbox(range)
  }
  if(!is.null(majorDimension)){
  stopifnot(is.na(majorDimension) || is.character(majorDimension))
    params_data[['majorDimension']] <- unbox(majorDimension)
  }
  if(!is.null(values)){
  stopifnot(is.na(values) || class(values) == 'matrix' || class(values) == 'data.frame')
    params_data[['values']] <- values
  }

  obj <- structure(params_data, class = "ValueRange")
  return(obj)
}
#' 
#' gsv4_standard_parameters
#' 
#' Auxiliary function for modifying HTTP methods in the Sheets API v4.
#' 
#' @seealso \href{https://developers.google.com/sheets/api/query-parameters}{Google's Documentation of Standard Query Parameters}
#' @param fields string. Selector specifying which fields to include in a partial response.
#' @param .xgafv string. V1 error format. .xgafv must take one of the following values: 1, 2
#' See the details section for the definition of each of these values.
#' @param alt string. Data format for response. alt must take one of the following values: json, media, proto
#' See the details section for the definition of each of these values.
#' @param callback string. JSONP
#' @param pp logical. Pretty-print response.
#' @param prettyPrint logical. Returns response with indentations and line breaks.
#' @param quotaUser string. Available to use for quota purposes for server-side applications. Can be any arbitrary string assigned to a user, but should not exceed 40 characters.
#' @param upload_protocol string. Upload protocol for media (e.g. "raw", "multipart").
#' @param uploadType string. Legacy upload protocol for media (e.g. "media", "multipart").
#' @return A \code{list} with components named as the arguments
#' .xgafv takes one of the following values:
#' \itemize{
#'  \item{1 - v1 error format}
#'  \item{2 - v2 error format}
#' }
#' 
#' alt takes one of the following values:
#' \itemize{
#'  \item{json - Responses with Content-Type of application/json}
#'  \item{media - Media download with context-dependent Content-Type}
#'  \item{proto - Responses with Content-Type of application/x-protobuf}
#' }
#' 
#' @export
gsv4_standard_parameters <- function(fields=NULL, .xgafv=NULL, alt=NULL, callback=NULL, pp=NULL, prettyPrint=NULL, quotaUser=NULL, upload_protocol=NULL, uploadType=NULL){

  params_data <- list()

  if(!is.null(fields)){
  stopifnot(is.na(fields) || is.character(fields))
    params_data[['fields']] <- fields
  }
  if(!is.null(.xgafv)){
  stopifnot(is.na(.xgafv) || is.character(.xgafv))
    params_data[['$.xgafv']] <- .xgafv
  }
  if(!is.null(alt)){
  stopifnot(is.na(alt) || is.character(alt))
    params_data[['alt']] <- alt
  }
  if(!is.null(callback)){
  stopifnot(is.na(callback) || is.character(callback))
    params_data[['callback']] <- callback
  }
  if(!is.null(pp)){
  stopifnot(is.na(pp) || is.logical(pp))
    params_data[['pp']] <- pp
  }
  if(!is.null(prettyPrint)){
  stopifnot(is.na(prettyPrint) || is.logical(prettyPrint))
    params_data[['prettyPrint']] <- prettyPrint
  }
  if(!is.null(quotaUser)){
  stopifnot(is.na(quotaUser) || is.character(quotaUser))
    params_data[['quotaUser']] <- quotaUser
  }
  if(!is.null(upload_protocol)){
  stopifnot(is.na(upload_protocol) || is.character(upload_protocol))
    params_data[['upload_protocol']] <- upload_protocol
  }
  if(!is.null(uploadType)){
  stopifnot(is.na(uploadType) || is.character(uploadType))
    params_data[['uploadType']] <- uploadType
  }

  return(params_data)
}
#' 
