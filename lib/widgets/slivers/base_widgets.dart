import 'package:flutter/material.dart';

import '../../widgets/widgets.dart';
import '../../models/models.dart';
import 'app_bars.dart';

abstract class BaseSliverPlainStatelessWidget extends StatelessWidget {
  final String? mainMemberPicture;
  final Function mainTransFunc;

  // base class for forms, errors, empty
  const BaseSliverPlainStatelessWidget({
    Key? key,
    required this.mainMemberPicture,
    required this.mainTransFunc
  }) : super(key: key);

  Widget getContentWidget(BuildContext context);
  Widget getBottomSection(BuildContext context);

  String getAppBarTitle(BuildContext context) {
    return mainTransFunc('app_bar_title');
  }

  String getAppBarSubtitle(BuildContext context) {
    return "";
  }

  SliverAppBar getAppBar(BuildContext context) {
    GenericAppBarFactory factory = GenericAppBarFactory(
        context: context,
        title: getAppBarTitle(context),
        subtitle: getAppBarSubtitle(context),
        memberPicture: mainMemberPicture
    );
    return factory.createAppBar();
  }

  Widget getBuildContent(BuildContext context) {
    return Column(children: [
      Expanded(
          child: CustomScrollView(slivers: <Widget>[
        getAppBar(context),
        SliverList(
            delegate: SliverChildListDelegate([
          Align(
              alignment: Alignment.topRight,
              child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(children: [
                    getContentWidget(context),
                  ])))
        ]))
      ])),
      getBottomSection(context)
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return getBuildContent(context);
  }
}

abstract class BaseSliverListStatelessWidget extends StatelessWidget {
  final PaginationInfo? paginationInfo;
  final String? memberPicture;
  final Function transFunc;

  // base class for lists
  const BaseSliverListStatelessWidget({
    Key? key,
    required this.paginationInfo,
    required this.memberPicture,
    required this.transFunc
  }) : super(key: key);

  void doRefresh(BuildContext context);
  Widget getBottomSection(BuildContext context);
  SliverList getSliverList(BuildContext context);

  String getAppBarTitle(BuildContext context) {
    return transFunc('app_bar_title');
  }

  String getAppBarSubtitle(BuildContext context) {
    return "";
  }

  String getModelName() {
    return transFunc('model_name');
  }

  SliverList getPreSliverListContent(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        return const SizedBox(height: 1);
      },
      childCount: 1,
    ));
  }

  SliverAppBar getAppBar(BuildContext context) {
    GenericAppBarFactory factory = GenericAppBarFactory(
        context: context,
        title: getAppBarTitle(context),
        subtitle: getAppBarSubtitle(context),
        memberPicture: memberPicture);
    return factory.createAppBar();
  }

  bool _showPagination() {
    return paginationInfo!.previous != null && paginationInfo!.next != null;
  }

  SliverPersistentHeader makePaginationHeader(BuildContext context, Function transFunc) {
    return makeDefaultPaginationHeader(
        context, paginationInfo!, getModelName(), transFunc);
  }

  SliverPersistentHeader makeTabHeader(BuildContext context) {
    return makeEmptyHeader();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        // edgeOffset: 120,
        onRefresh: () async {
          doRefresh(context);
        },
        child: Column(children: [
          Expanded(
              child: CustomScrollView(
                  // physics: BouncingScrollPhysics(),
                  slivers: <Widget>[
                getAppBar(context),
                if (_showPagination()) makePaginationHeader(context, () {}),
                makeTabHeader(context),
                getPreSliverListContent(context),
                getSliverList(context)
              ])),
          getBottomSection(context)
        ]));
  }
}

abstract class BaseEmptyWidget extends BaseSliverPlainStatelessWidget {
  final String? memberPicture;
  final Function transFunc;

  const BaseEmptyWidget({
    Key? key,
    required this.memberPicture,
    required this.transFunc
  }) : super(
      key: key,
      mainMemberPicture: memberPicture,
      mainTransFunc: transFunc
  );

  String getEmptyMessage();
  void doRefresh(BuildContext context);

  @override
  String getAppBarTitle(BuildContext context) {
    return transFunc('app_bar_title_empty');
  }

  @override
  Widget getBuildContent(BuildContext context) {
    return RefreshIndicator(
        // edgeOffset: 120,
        onRefresh: () async {
          doRefresh(context);
        },
        child: Column(children: [
          Expanded(
              child: CustomScrollView(slivers: <Widget>[
            getAppBar(context),
            SliverList(
                delegate: SliverChildListDelegate([
              Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(children: [
                        getContentWidget(context),
                      ])))
            ]))
          ])),
          getBottomSection(context)
        ]));
  }

  @override
  Widget getContentWidget(BuildContext context) {
    return Center(
        child: Column(
      children: [const SizedBox(height: 30), Text(getEmptyMessage())],
    ));
  }
}

abstract class BaseErrorWidget extends BaseSliverPlainStatelessWidget {
  final String? memberPicture;
  final String? error;
  final Function transFunc;

  const BaseErrorWidget({
    Key? key,
    required this.error,
    required this.memberPicture,
    required this.transFunc
  }) : super(
      key: key,
      mainMemberPicture: memberPicture,
      mainTransFunc: transFunc
  );

  @override
  String getAppBarTitle(BuildContext context) {
    return transFunc('app_bar_title_error');
  }

  @override
  Widget getContentWidget(BuildContext context) {
    return errorNotice(error!);
  }
}
