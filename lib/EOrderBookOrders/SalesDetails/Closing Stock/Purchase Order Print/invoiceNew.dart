import 'dart:io';
import 'dart:typed_data';
import 'package:eorderbook/EOrderBookOrders/Inovice/Utility.dart';
import 'package:eorderbook/EOrderBookOrders/Inovice/Utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eorderbook/widgets/ConstantWidget.dart';
import 'package:eorderbook/EOrderBookOrders/Inovice/DynamicPdfSizeScreen.dart';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/Closing%20Stock/Model/OrderModelNew.dart';
import 'InvoiceDataNew.dart';


MyDataNew? _myData;

Future<void> _saveAsFile(BuildContext context, LayoutCallback build,
    PdfPageFormat pageFormat) async {
  final bytes = await build(pageFormat);

  final appDocDir = await getApplicationDocumentsDirectory();
  final appDocPath = appDocDir.path;
  final file = File(appDocPath + '/' + '${_myData!.time}.pdf');
  Utils.dTPrint('Save as file ${file.path} ...');
  await file.writeAsBytes(bytes);
  await OpenFile.open(file.path);
}

class MyPdfWidgetNew extends StatefulWidget {
  final MyDataNew myData;
  final bool pageBack;

  MyPdfWidgetNew({Key? key, required this.myData , required this.pageBack}) : super(key: key);

  @override
  _MyPdfWidgetNewState createState() => _MyPdfWidgetNewState();
}

class _MyPdfWidgetNewState extends State<MyPdfWidgetNew> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _myData = widget.myData;
    });
  }


  Future<void> checkData() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    setState(() {
      width = (_pref.getDouble(ConstantWidget.width) == 0
          ? width
          : _pref.getDouble(ConstantWidget.width))!;
      height = (_pref.getDouble(ConstantWidget.height) == 0
          ? height
          : _pref.getDouble(ConstantWidget.height))!;
    });
  }

  double width = 104.8, height = 235;
  bool willShow = false;

  @override
  Widget build(BuildContext context) {
    final actions = <PdfPreviewAction>[
      if (!kIsWeb)
        const PdfPreviewAction(
          icon: Icon(Icons.save),
          onPressed: _saveAsFile,
        )
    ];

    return WillPopScope(
      onWillPop: ()async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.myData.products.first.distributorName),
          leading: IconButton(onPressed: () {
            if(widget.pageBack) {
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
            }{
              Navigator.pop(context);
            }
          }, icon: Icon(Icons.arrow_back)),
          actions: [
            IconButton(
              icon: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Icon(Icons.settings),
              ),
              onPressed: () async {
                bool result =
                    await Navigator.of(context).push(MaterialPageRoute<dynamic>(
                  builder: (BuildContext context) {
                    return DynamicPageSize();
                  },
                ));
                if (result != null) {
                  SharedPreferences _pref = await SharedPreferences.getInstance();
                  setState(() {
                    width = (_pref.getDouble(ConstantWidget.width) == 0
                        ? width
                        : _pref.getDouble(ConstantWidget.width))!;
                    height = (_pref.getDouble(ConstantWidget.height) == 0
                        ? height
                        : _pref.getDouble(ConstantWidget.height))!;
                  });
                }
              },
            )
          ],
        ),
        body: PdfPreview(
          maxPageWidth: 700,
          initialPageFormat: PdfPageFormat(
            width * PdfPageFormat.mm,
            height * PdfPageFormat.mm,
            marginAll: 0 * PdfPageFormat.cm,
          ),
          build: (format) => generateInvoice(format, widget.myData),
          actions: actions,
          canChangePageFormat: false,
        ),
      ),
    );
  }


}

Future<Uint8List> generateInvoice(
    PdfPageFormat pageFormat, MyDataNew myData) async {
  final invoice = Invoice(
    invoiceNumber: "${myData.time}",
    products: myData.products,
    baseColor: PdfColors.grey300,
    accentColor: PdfColors.blueGrey900,
  );

  return await invoice.buildPdf(pageFormat, myData);
}

class Invoice {
  Invoice({
    required this.products,
    required this.invoiceNumber,
    required this.baseColor,
    required this.accentColor,
  });

  final List<OrderNew> products;
  final String invoiceNumber;
  final PdfColor baseColor;
  final PdfColor accentColor;

  static const _darkColor = PdfColors.black;
  static const _whiteColor = PdfColors.white;
  static const _blackColor = PdfColors.black;
  static var welcomeTC = PdfColor.fromHex("#106366");

  PdfColor get _baseTextColor => _darkColor;


  PdfColor get _blackTextColor => _blackColor;
  PdfColor get welcomeTextColor => welcomeTC;


  double  _grandTotal = OrderNew.calculateTotalOrderValue(_myData!.products);


  double get due {
    // return _grandTotal - int.parse(_myData!.paidAmount);
    return 0;
  }

  String? _logo;

  String? _bgShape;
  var IMAGE_KEY = 'IMAGE_KEY';

  Future<Uint8List> buildPdf(PdfPageFormat pageFormat, MyDataNew myData) async {
    // Create a PDF document.
    final doc = pw.Document();

    // List<Map<String, dynamic>> info=await myData.getAddressInfo;

    // _logo = await rootBundle.loadString('assets/medail.svg');
    // _bgShape = await rootBundle.loadString('assets/bg2.svg');
    var bytesN = await rootBundle.load('assets/fonts/hs_m.ttf');
    var bytesB = await rootBundle.load('assets/fonts/hs_b.ttf');
    var bytesI = await rootBundle.load('assets/fonts/hs_m.ttf');
    final imageString = await ImageSharedPrefs.loadImageFromPrefs(IMAGE_KEY);
    SharedPreferences _pref = await SharedPreferences.getInstance();
    var width = (_pref.getDouble(ConstantWidget.width) ?? 104.8);
    var height = (_pref.getDouble(ConstantWidget.height) ?? 235);
    doc.addPage(
      pw.MultiPage(
        pageTheme: _buildTheme(
            PdfPageFormat(
              width * PdfPageFormat.mm,
              height * PdfPageFormat.mm,
              marginTop: .5 * PdfPageFormat.cm,
              marginBottom: .5 * PdfPageFormat.cm,
              marginLeft: .8 * PdfPageFormat.cm,
              marginRight: .8 * PdfPageFormat.cm,
            ),
            pw.TtfFont(bytesN),
            pw.TtfFont(bytesB),
            pw.TtfFont(bytesI)),
        // header: _buildHeader,
        footer: (context) {
          return pw.Column(children: [
            pw.Container(
                child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 5, top: 5),
                    child: pw.Text(
                      '${context.pageNumber}/${context.pagesCount}',
                      //Page
                      style: const pw.TextStyle(
                        fontSize: 7,
                        color: PdfColors.black,
                      ),
                    )),
              ],
            ))
          ]);
        },
        build: (context) => [
          // pw.SizedBox(height: 20),
          _contentMainHeader(context, myData, imageString, doc,width,height),
          pw.SizedBox(height: 5),
          // _contentHeader(context),
          _contentTable(context, myData),
          pw.SizedBox(height: 10),
          _contentFooter(context, myData),
        ],
      ),
    );

    // Return the PDF file content
    return doc.save();
  }

  pw.PageTheme _buildTheme(
      PdfPageFormat pageFormat, pw.Font base, pw.Font bold, pw.Font italic) {
    return pw.PageTheme(
      pageFormat: pageFormat,
      theme: pw.ThemeData.withFont(
        base: base,
        bold: bold,
        italic: italic,
      ),
      buildBackground: (context) => pw.FullPage(
        ignoreMargins: true,
      ),
    );
  }

  pw.Widget _contentFooter(pw.Context context, MyDataNew myData) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 1,
          child: pw.DefaultTextStyle(
            style: const pw.TextStyle(
              fontSize: 8,
              color: _darkColor,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Sub Total:'),
                    // pw.Text(_formatCurrency(_total)),
                  ],
                ),
                pw.Divider(color: accentColor),
                pw.DefaultTextStyle(
                  style: const pw.TextStyle(
                    color: _blackColor,
                    fontSize: 8,
                    // fontWeight: pw.FontWeight.bold,
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Total:'),
                      pw.Text((_grandTotal).toString()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

      ],
    );
  }

  pw.Widget _termsAndConditions(pw.Context context, MyDataNew myData) {
    return myData.time == ""
        ? pw.SizedBox(height: 2)
        : pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.only(bottom: 4),
                      child: pw.Text(
                        'Terms & Conditions',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: _blackTextColor,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.Text(
                     ' myData.shop.tAndC',
                      textAlign: pw.TextAlign.justify,
                      style: const pw.TextStyle(
                        fontSize: 5,
                        lineSpacing: 2,
                        color: _darkColor,
                      ),
                    ),
                  ]
          );
  }

  pw.Widget _contentTable(pw.Context context, MyDataNew myData) {
    const tableHeaders = [
      '  Description  ',
      '  Bal  ',
      '  Rate  ',
      '  Qty  ',
      '  Amount  '
    ];

    // Filter products where order quantity is greater than 0
    // final filteredProducts = products.where((product) => product.rate > 0).toList();

    return pw.Table.fromTextArray(
      border: null,
      cellAlignment: pw.Alignment.centerLeft,
      headerDecoration: pw.BoxDecoration(
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
        color: baseColor,
      ),
      headerHeight: 20,
      cellHeight: 20,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
        4: pw.Alignment.center,
        5: pw.Alignment.center,
      },
      headerStyle: pw.TextStyle(
        color: _baseTextColor,
        fontSize: 8,
        fontWeight: pw.FontWeight.bold,
      ),
      cellStyle: const pw.TextStyle(
        color: _darkColor,
        fontSize: 8,
      ),
      rowDecoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: accentColor,
            width: .5,
          ),
        ),
      ),
      headers: List<String>.generate(
        tableHeaders.length,
            (col) => tableHeaders[col],
      ),
      // data: List<List<String>>.generate(
      //   filteredProducts.length,
      //       (row) => List<String>.generate(
      //     tableHeaders.length,
      //         (col) {
      //       return filteredProducts[row].getIndex(col);
      //     },
      //   ),
      // ),
      data: List<List<String>>.generate(
        products.length,
            (row) => List<String>.generate(
          tableHeaders.length,
              (col) => products[row].getIndex(col),
        ),
      ),
    );
  }
  pw.Widget _contentMainHeader(
      pw.Context context, MyDataNew myData, String? imageString, pw.Document doc,double width,double height) {
    return pw.Column(
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Expanded(
              flex: 12,
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Container(
                    margin: const pw.EdgeInsets.symmetric(horizontal: 12),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: _blackTextColor),
                      borderRadius:
                          const pw.BorderRadius.all(pw.Radius.circular(2)),
                      color: _whiteColor,
                    ),
                    padding: const pw.EdgeInsets.only(
                        left: 5, top: 5, bottom: 5, right: 5),
                    alignment: pw.Alignment.center,
                    child: pw.Column(children: [
                      pw.Text('Purchase Order', style: pw.TextStyle(
                        fontSize: 18
                      )),
                      pw.Text('Purchase Order : ${products.first.purchaseOrderNumber}',style: pw.TextStyle(
                        fontSize: 10
                      )),
                      pw.Text('Distributor : ${products.first.distributorName}',style: pw.TextStyle(
                          fontSize: 10
                      )),
                      pw.Text('Date   : ${_formatDate(DateTime.now())}',style: pw.TextStyle(
                          fontSize: 10
                      ))
                    ]),
                  ),
                ],
              ),
            ),
          ],
        ),

      ],
    );
  }

  static String _formatDate(DateTime date) {
    final format = DateFormat.yMMMd('en_US');
    return format.format(date);
  }
}

String _formatCurrency(double amount) {
  return '${amount.toStringAsFixed(0)}';
}
