// import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import '../i18n.dart';
import '../models/models.dart';
import '../models/base_models.dart';
import '../utils.dart';

class CoreWidgets {
  CoreWidgets();

  Widget errorNotice(String message) {
    return Center(
        child: Column(
      children: [
        const SizedBox(height: 30),
        Text(message),
        const SizedBox(height: 30),
      ],
    ));
  }

  Widget errorNoticeWithReload(
      String message, dynamic reloadBloc, dynamic reloadEvent) {
    return RefreshIndicator(
        child: ListView(
          children: [
            errorNotice(message),
          ],
        ),
        onRefresh: () {
          return Future.delayed(const Duration(milliseconds: 5), () {
            reloadBloc.add(reloadEvent);
          });
        });
  }

  Widget loadingNotice() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget buildMemberInfoCard(BuildContext context, member) => SizedBox(
        height: 200,
        width: 1000,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              ListTile(
                title: Text('${member.name}',
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(
                    '${member.address}\n${member.countryCode}-${member.postal}\n${member.city}'),
                leading: Icon(
                  Icons.home,
                  color: Colors.blue[500],
                ),
              ),
              ListTile(
                title: Text('${member.tel}',
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                leading: Icon(
                  Icons.contact_phone,
                  color: Colors.blue[500],
                ),
                onTap: () {
                  if (member.tel != '' && member.tel != null) {
                    coreUtils.launchURL("tel://${member.tel}");
                  }
                },
              ),
            ],
          ),
        ),
      );

  Widget buildOrderInfoCard(BuildContext context, order, {String? maintenanceContract}) {
    return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 80,
              child: ListTile(
                title: Text('${order.orderName} (${order.customerId})',
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(
                    '${order.orderAddress}\n${order.orderCountryCode}-${order.orderPostal}\n${order.orderCity}'),
                leading: Icon(
                  Icons.home,
                  color: Colors.blue[500],
                ),
              ),
            ),
            if (order.orderTel != null && order.orderTel != '')
              SizedBox(
                  height: 30,
                  child: ListTile(
                    title: Text('${order.orderTel}',
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    leading: Icon(
                      Icons.contact_phone,
                      color: Colors.blue[500],
                    ),
                    onTap: () {
                      if (order.orderTel != '' && order.orderTel != null) {
                        coreUtils.launchURL("tel://${order.orderTel}");
                      }
                    },
                  )),
            if (order.orderMobile != null && order.orderMobile != '')
              SizedBox(
                height: 30,
                child: ListTile(
                  title: Text('${order.orderMobile}',
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  leading: Icon(
                    Icons.send_to_mobile,
                    color: Colors.blue[500],
                  ),
                  onTap: () {
                    if (order.orderMobile != '' && order.orderMobile != null) {
                      coreUtils.launchURL("tel://${order.orderMobile}");
                    }
                  },
                ),
              ),
            if (order.orderEmail != null && order.orderEmail != '')
              ListTile(
                title: Text('${order.orderEmail}',
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                leading: Icon(
                  Icons.email,
                  color: Colors.blue[500],
                ),
                onTap: () {
                  if (order.orderEmail != '' && order.orderEmail != null) {
                    coreUtils.launchURL("mailto://${order.orderEmail}");
                  }
                },
              ),
            const SizedBox(height: 10),
            getMy24Divider(context),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...buildItemListKeyValueList(
                    "${My24i18n.tr('orders.info_order_id')} / ${My24i18n.tr('orders.info_order_reference')}",
                    "${order.orderId} / ${order.orderReference ?? '-'}"),
                ...buildItemListKeyValueList(
                    "${My24i18n.tr('orders.info_order_type')} / ${My24i18n.tr('orders.info_order_date')}",
                    "${order.orderType} / ${order.orderDate}"),
                ...buildItemListKeyValueList(
                    "${My24i18n.tr('customers.info_contact')}",
                    "${order.orderContact ?? '-'}"),
                if (order.customerRemarks != null && order.customerRemarks != '')
                  ...buildItemListKeyValueList(
                      "${My24i18n.tr('orders.info_order_customer_remarks')}",
                      "${order.customerRemarks}"),
                if (maintenanceContract != null)
                  ...buildItemListKeyValueList(
                      "${My24i18n.tr('assigned_orders.detail.info_maintenance_contract')}",
                      maintenanceContract),
                ...buildItemListKeyValueList(
                    "${My24i18n.tr('orders.info_last_status')}",
                    "${order.lastStatusFull}"),
              ],
            ),
          ],
        ));
  }

  Widget buildEmptyListFeedback({String? noResultsString}) {
    noResultsString ??= My24i18n.tr('generic.empty_table');

    return Column(
      children: [
        const SizedBox(height: 1),
        Text(noResultsString!, style: const TextStyle(fontStyle: FontStyle.italic))
      ],
    );
  }

  ElevatedButton createElevatedButtonColored(String text, Function callback,
      {foregroundColor = Colors.white, backgroundColor = Colors.blue}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: foregroundColor,
        backgroundColor: backgroundColor,
      ),
      onPressed: callback as void Function()?,
      child: Text(text),
    );
  }

  Widget createDefaultElevatedButton(BuildContext context, String text, Function callback) {
    return DefaultTextStyle.merge(child: ElevatedButton(
      style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Theme.of(context).primaryColor,
      ),
      onPressed: callback as void Function(),
      child: Text(text),
    ));
  }

  Widget createPhoneSection(BuildContext context, String number) {
    if (number == '') {
      return const SizedBox(height: 1);
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          padding: const EdgeInsets.all(1)),
      child: Text(number),
      onPressed: () => coreUtils.launchURL("tel://$number"),
    );
  }

  Widget createHeader(String text) {
    return Column(
        children: [
          const SizedBox(
            height: 10.0,
          ),
          Text(text,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 20, color: Colors.grey)),
          const SizedBox(
            height: 10.0,
          ),
        ],
      );
  }

  Widget createSubHeader(String text) {
    return Column(
        children: [
          const SizedBox(
            height: 10.0,
          ),
          Text(text,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
          const SizedBox(
            height: 10.0,
          ),
        ],
      );
  }

  Future<dynamic> displayDialog(context, title, text) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(title: Text(title), content: Text(text));
        });
  }

  showDeleteDialogWrapper(String title, String content, Function deleteFunction, BuildContext context) {
    // show the dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
                child: Text(My24i18n.tr('generic.button_cancel')),
                onPressed: () => Navigator.of(context).pop(false)),
            TextButton(
                child: Text(My24i18n.tr('generic.button_delete')),
                onPressed: () => Navigator.of(context).pop(true)),
          ],
        );
      },
    ).then((dialogResult) {
      if (dialogResult == null) return;

      if (dialogResult) {
        deleteFunction();
      }
    });
  }

  showActionDialogWrapper(String title, String content, String actionText,
      Function actionFunction, BuildContext context) {
    // show the dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
                child: Text(My24i18n.tr('generic.button_cancel')),
                onPressed: () => Navigator.of(context).pop(false)),
            TextButton(
                child: Text(actionText),
                onPressed: () => Navigator.of(context).pop(true)),
          ],
        );
      },
    ).then((dialogResult) {
      if (dialogResult == null) return;

      if (dialogResult) {
        actionFunction();
      }
    });
  }

  createSnackBar(BuildContext context, String content) {
    final snackBar = SnackBar(
      content: Text(content),
      duration: const Duration(seconds: 1),
    );

    // Find the ScaffoldMessenger in the widget tree
    // and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget createTable(List<TableRow> rows) {
    return Table(
        border: const TableBorder(
            horizontalInside: BorderSide(
                width: 1, color: Colors.grey, style: BorderStyle.solid)),
        children: rows);
  }

  Widget createTableWidths(
      List<TableRow> rows, Map<int, TableColumnWidth> columnWidths) {
    return Table(
        columnWidths: columnWidths,
        border: const TableBorder(
            horizontalInside: BorderSide(
                width: 1, color: Colors.grey, style: BorderStyle.solid)),
        children: rows);
  }

  Widget createTableHeaderCell(String content, [double padding = 8.0]) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Text(content, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget createTableColumnCell(String? content, [double padding = 4.0]) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Text(content ?? ''),
    );
  }

  Widget getOrderHeaderKeyWidget(String text, double fontsize) {
    return Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child:
            Text(text, style: TextStyle(fontSize: fontsize, color: Colors.grey)));
  }

  Widget getOrderHeaderValueWidget(String text, double fontsize) {
    return Padding(
        padding: const EdgeInsets.only(left: 8.0, bottom: 4, top: 2),
        child: Text(text,
            style: TextStyle(
                fontSize: fontsize,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: Colors.black)));
  }

  Widget createOrderHistoryListSubtitle2(order, Widget workorderWidget, Widget viewOrderWidget) {
    double fontsizeKey = 12.0;
    double fontsizeValue = 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        getOrderSubHeaderKeyWidget(
            My24i18n.tr('orders.info_order_id'), fontsizeKey),
        getOrderSubHeaderValueWidget('${order.orderId}', fontsizeValue),
        const SizedBox(height: 3),
        getOrderSubHeaderKeyWidget(
            My24i18n.tr('orders.info_order_type'), fontsizeKey),
        getOrderSubHeaderValueWidget('${order.orderType}', fontsizeValue),
        const SizedBox(height: 3),
        getOrderSubHeaderKeyWidget(
            My24i18n.tr('orders.info_last_status'), fontsizeKey),
        getOrderSubHeaderValueWidget('${order.lastStatusFull}', fontsizeValue),
        const SizedBox(height: 3),
        workorderWidget,
        viewOrderWidget
      ],
    );
  }

  Widget getOrderSubHeaderKeyWidget(String text, double fontsize) {
    return Padding(
        padding: const EdgeInsets.only(top: 1.0),
        child: Text(text, style: TextStyle(fontSize: fontsize)));
  }

  Widget getOrderSubHeaderValueWidget(String text, double fontsize) {
    return Padding(
        padding: const EdgeInsets.only(left: 8.0, bottom: 4, top: 2),
        child: Text(text,
            style: TextStyle(
              fontSize: fontsize,
              // fontWeight: FontWeight.bold,
              // fontStyle: FontStyle.italic
            )));
  }

  Widget createOrderHistoryListHeader2(String date) {
    double fontsizeKey = 14.0;
    double fontsizeValue = 20.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        getOrderHeaderKeyWidget(My24i18n.tr('orders.info_order_date'), fontsizeKey),
        getOrderHeaderValueWidget(date, fontsizeValue),
      ],
    );
  }

  Widget buildItemsSection(BuildContext context, String header,
      List<dynamic>? items, Function itemBuilder, Function getActions,
      {String? noResultsString,
      bool withDivider = true,
      bool withLastDivider = true
    }) {
    if (items == null || items.isEmpty) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (header != "") createHeader(header),
            buildEmptyListFeedback(noResultsString: noResultsString),
            getMy24Divider(context, last: true)
          ]);
    }

    List<Widget> resultItems = [];
    for (int i = 0; i < items.length; ++i) {
      var item = items[i];

      var newList = List<Widget>.from(resultItems)..addAll(itemBuilder(item));
      newList = List<Widget>.from(newList)..addAll(getActions(item));
      if (items.length == 1 && withDivider && withLastDivider) {
        newList.add(getMy24Divider(context, last: true));
      } else {
        if (i < items.length - 1 && withDivider) {
          newList.add(getMy24Divider(context, last: false));
        } else {
          if (withDivider && withLastDivider) {
            newList.add(getMy24Divider(context, last: true));
          }
        }
      }
      resultItems = newList;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [if (header != "") createHeader(header), ...resultItems],
    );
  }

  Widget buildItemListTile(String title, dynamic subtitle) {
    String text = subtitle != null ? "$subtitle" : "";

    return ListTile(
        title: createTableHeaderCell(text),
        subtitle: createTableColumnCell(title));
  }

  Widget buildItemListCustomWidget(String title, Widget content) {
    return Row(children: [createTableHeaderCell(title), content]);
  }

  Widget createCancelButton(Function onClick) {
    return createElevatedButtonColored(
        My24i18n.tr('generic.action_cancel'),
        onClick,
        backgroundColor: Colors.grey, foregroundColor: Colors.white
    );
  }

  Widget createViewButton(Function onClick) {
    return createElevatedButtonColored(
        My24i18n.tr('generic.action_view'),
        onClick,
        backgroundColor: Colors.green, foregroundColor: Colors.white
    );
  }

  Widget createButton(Function onClick) {
    return createElevatedButtonColored(
        My24i18n.tr('generic.action_new'),
        onClick,
        backgroundColor: Colors.green, foregroundColor: Colors.white
    );
  }

  Widget createDeleteButton(Function onClick) {
    return createElevatedButtonColored(
        My24i18n.tr('generic.action_delete'),
        onClick,
        foregroundColor: Colors.red, backgroundColor: Colors.white
    );
  }

  Widget createEditButton(Function onClick) {
    return createElevatedButtonColored(
        My24i18n.tr('generic.action_edit'),
        () => onClick()
    );
  }

  Widget createNewButton(Function onClick) {
    return createElevatedButtonColored(
        My24i18n.tr('generic.action_new'),
        () => onClick()
    );
  }

  Widget createSubmitButton(BuildContext context, Function onClick) {
    return createDefaultElevatedButton(
      context,
        My24i18n.tr('generic.button_submit'),
      () => onClick()
    );
  }

  Widget createImagePart(String url, String text) {
    return Center(
        child: Column(children: [
          Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(url, cacheWidth: 100),
                const SizedBox(width: 10),
                Text(text)
          ])
    ]));
  }

  Widget getTextDisabled(bool disabled, String text) {
    if (!disabled) {
      return Text(text);
    }

    return Text(text, style: const TextStyle(color: Colors.grey));
  }

  Widget getSearchContainer(BuildContext context, TextEditingController searchController, Function searchFunc) {
    const double height = 40.0;
    return Container(
      height: height,
      width: 200,
      margin: const EdgeInsets.all(1.0),
      padding: const EdgeInsets.all(1.0),
      decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent)),
      child: Row(
        children: [
          SizedBox(
              height: height - 10,
              width: 120,
              child: Padding(
                  padding: const EdgeInsets.only(bottom: 4, left: 10),
                  child: TextField(
                    controller: searchController,
                  ))),
          const Spacer(),
          SizedBox(
            height: height - 10,
            width: 70,
            child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: TextButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.grey,
                    ),
                    child: Text(My24i18n.tr('generic.action_search'),
                        style: const TextStyle(color: Colors.white, fontSize: 10)
                    ),
                    onPressed: () => {searchFunc(context)})),
          ),
        ],
      ),
    );
  }

  Widget wrapPaginationSearchRow(Widget child) {
    return Container(
        color: Colors.grey[200],
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: child,
        ));
  }

  Widget showPaginationSearchSection(
      BuildContext context,
      PaginationInfo? paginationInfo,
      TextEditingController searchController,
      Function nextPageFunc,
      Function previousPageFunc,
      Function searchFunc
      ) {
    if (paginationInfo == null ||
        paginationInfo.count! <= paginationInfo.pageSize!) {
      return wrapPaginationSearchRow(Row(
        children: [
          const Spacer(),
          getSearchContainer(context, searchController, searchFunc),
          const Spacer(),
        ],
      ));
    }

    final int numPages =
        (paginationInfo.count! / paginationInfo.pageSize!).round();
    return wrapPaginationSearchRow(Row(
      children: [
        TextButton(
            child: getTextDisabled(paginationInfo.currentPage! <= 1,
                My24i18n.tr('generic.button_back')),
            onPressed: () => {
                  if (paginationInfo.currentPage! > 1) {previousPageFunc(context)}
                }),
        const Spacer(),
        getSearchContainer(context, searchController, searchFunc),
        const Spacer(),
        TextButton(
            child: getTextDisabled(paginationInfo.currentPage! >= numPages,
                My24i18n.tr('generic.button_next')),
            onPressed: () => {
                  if (paginationInfo.currentPage! < numPages)
                    {nextPageFunc(context)}
                })
      ],
    ));
  }

  Widget showPaginationSearchNewSection(
      BuildContext context,
      PaginationInfo? paginationInfo,
      TextEditingController searchController,
      Function nextPageFunc,
      Function previousPageFunc,
      Function searchFunc,
      Function newFunc
      ) {
    if (paginationInfo == null ||
        paginationInfo.count! <= paginationInfo.pageSize!) {
      return wrapPaginationSearchRow(Row(
        children: [
          const Spacer(),
          createNewButton(() => {newFunc(context)}),
          const SizedBox(width: 10),
          getSearchContainer(context, searchController, searchFunc),
          const Spacer(),
        ],
      ));
    }

    final int numPages =
        (paginationInfo.count! / paginationInfo.pageSize!).round();
    final Color backColor =
        paginationInfo.currentPage! > 1 ? Colors.blue : Colors.grey;
    final Color forwardColor =
        paginationInfo.currentPage! < numPages ? Colors.blue : Colors.grey;

    return wrapPaginationSearchRow(Row(
      children: [
        IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: backColor,
              size: 20.0,
              semanticLabel: 'Back',
            ),
            onPressed: () => {
                  if (paginationInfo.currentPage! > 1) {previousPageFunc(context)}
                }),
        const Spacer(),
        createNewButton(() => {newFunc(context)}),
        const SizedBox(width: 5),
        getSearchContainer(context, searchController, searchFunc),
        const Spacer(),
        IconButton(
            icon: Icon(
              Icons.arrow_forward,
              color: forwardColor,
              size: 20.0,
              semanticLabel: 'Forward',
            ),
            onPressed: () => {
                  if (paginationInfo.currentPage! < numPages)
                    {nextPageFunc(context)}
                }),
      ],
    ));
  }

  // new items overview
  Widget getGenericKeyWidget(String text, {bool withPadding = true}) {
    double fontsize = 12.0;

    if (!withPadding) {
      return Text(text, style: TextStyle(fontSize: fontsize));
    }

    return Padding(
        padding: const EdgeInsets.only(top: 1.0),
        child: Text(text, style: TextStyle(fontSize: fontsize)));
  }

  Widget getGenericValueWidget(String text, {bool withPadding = true}) {
    double fontsize = 16.0;

    if (!withPadding) {
      return Text(text,
          style: TextStyle(
            fontSize: fontsize,
            fontWeight: FontWeight.bold,
            // fontStyle: FontStyle.italic
          ));
    }

    return Padding(
        padding: const EdgeInsets.only(left: 8.0, bottom: 4, top: 2),
        child: Text(text,
            style: TextStyle(
              fontSize: fontsize,
              fontWeight: FontWeight.bold,
              // fontStyle: FontStyle.italic
            )));
  }

  List<Widget> buildItemListKeyValueList(String key, dynamic value,
      {bool withPadding = true}) {
    String textValue = value != null ? "$value" : "";
    if (textValue == "") {
      textValue = "-";
    }

    return [
      getGenericKeyWidget(key, withPadding: withPadding),
      getGenericValueWidget(textValue, withPadding: withPadding),
      const SizedBox(height: 3)
    ];
  }

  Widget getMy24Divider(BuildContext context, {bool last = true}) {
    if (last) {
      return Divider(
        color: Theme.of(context).primaryColor,
        thickness: 1.0,
      );
    }
    return const Divider(
      color: Colors.grey,
      thickness: 1.0,
    );
  }

  Widget createSubmitSection(Row buttons) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          // color: Colors.blueGrey,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.blueGrey,
              border: Border.all(
                color: Colors.blueGrey[500]!,
              ),
              borderRadius: const BorderRadius.all(
                Radius.circular(5),
              )),
          child: buttons,
        )
      ],
    );
  }

  // slivers
  SliverPersistentHeader makeDefaultPaginationHeader(BuildContext context, String title) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: SliverAppBarDelegate(
        minHeight: 26.0,
        maxHeight: 26.0,
        child: Container(
            color: Theme.of(context).primaryColor,
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0, top: 7.0, bottom: 4.0),
              child: Text(
                title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            )),
      ),
    );
  }

  // NOT USED, here as an example
  SliverPersistentHeader makeHeader(BuildContext context, String headerText) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: SliverAppBarDelegate(
        minHeight: 40.0,
        maxHeight: 40.0,
        child: Container(
            color: Theme.of(context).primaryColor,
            child: Center(child: Text(headerText))),
      ),
    );
  }

  SliverPersistentHeader makeEmptyHeader() {
    return SliverPersistentHeader(
      delegate: SliverAppBarDelegate(
        minHeight: 0,
        maxHeight: 0,
        child: const SizedBox(),
      ),
    );
  }

  Widget createViewWorkOrderButton(String? workorderPdfUrl, BuildContext context) {
    if (workorderPdfUrl != null && workorderPdfUrl != '') {
      return createDefaultElevatedButton(
          context,
          My24i18n.tr('generic.button_open_workorder'),
          () async {
            Map<String, dynamic> openResult = await coreUtils.openDocument(workorderPdfUrl);
            if (!openResult['result'] && context.mounted) {
                createSnackBar(
                    context,
                    My24i18n.tr('generic.error_arg', namedArgs: {'error': openResult['message']})
                );
              }
          }
        );
    }

    return createDefaultElevatedButton(context, My24i18n.tr('generic.button_no_workorder'), () => {});
  }

  GestureDetector wrapGestureDetector(BuildContext context, Widget child) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: child);
  }
}

// mixin to handle TextEditingControllers in the form widgets
mixin TextEditingControllerMixin {
  List<TextEditingController> controllers = [];
  List<FocusNode> focusNodes = [];

  FocusNode createFocusNode({Function? listener}) {
    FocusNode node = FocusNode();

    if (listener != null) {
      node.addListener(() {
        listener();
      });
    }

    focusNodes.add(node);
    return node;
  }

  void addTextEditingController(
      TextEditingController controller, BaseFormData formData, String field) {
    controller.addListener(() {
      formData.setProp(field, controller.text);
    });

    String? value = formData.getProp(field);

    if (value != null) {
      controller.text = value;
    }

    controllers.add(controller);
  }

  void disposeTextEditingControllers() {
    for (int i = 0; i < controllers.length; i++) {
      controllers[i].dispose();
    }
  }

  void disposeFocusNodes() {
    for (int i = 0; i < focusNodes.length; i++) {
      focusNodes[i].dispose();
    }
  }

  void disposeAll() {
    disposeTextEditingControllers();
    disposeFocusNodes();
  }
}

class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });
  final double minHeight;
  final double maxHeight;
  final Widget child;
  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => max(maxHeight, minHeight);
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

