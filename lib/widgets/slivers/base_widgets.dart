import 'package:flutter/material.dart';

import '../../widgets/widgets.dart';
import '../../models/models.dart';
import 'app_bars.dart';

abstract class BaseSliverPlainStatelessWidget extends StatelessWidget {
  final String? mainMemberPicture;
  final String mainAppBarTitle;
  final String mainAppBarSubTitle;

  // base class for forms, errors, empty
  const BaseSliverPlainStatelessWidget({
    Key? key,
    required this.mainMemberPicture,
    required this.mainAppBarTitle,
    required this.mainAppBarSubTitle,
  }) : super(key: key);

  Widget getContentWidget(BuildContext context);
  Widget getBottomSection(BuildContext context);

  SliverAppBar getAppBar(BuildContext context) {
    GenericAppBarFactory factory = GenericAppBarFactory(
        context: context,
        title: mainAppBarTitle,
        subtitle: mainAppBarSubTitle,
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
                ]
              )
            )
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
  final String appBarTitle;
  final String appBarSubTitle;
  final String modelName;
  final String paginationTitle;

  // base class for lists
  const BaseSliverListStatelessWidget({
    Key? key,
    required this.paginationInfo,
    required this.memberPicture,
    required this.appBarTitle,
    required this.appBarSubTitle,
    required this.modelName,
    required this.paginationTitle
  }) : super(key: key);

  void doRefresh(BuildContext context);
  Widget getBottomSection(BuildContext context);
  SliverList getSliverList(BuildContext context);

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
        title: appBarTitle,
        subtitle: appBarSubTitle,
        memberPicture: memberPicture);
    return factory.createAppBar();
  }

  bool _showPagination() {
    return paginationInfo!.previous != null && paginationInfo!.next != null;
  }

  SliverPersistentHeader makePaginationHeader(BuildContext context) {
    return makeDefaultPaginationHeader(context, paginationTitle);
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
                if (_showPagination()) makePaginationHeader(context),
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
  final String appBarTitle;
  final String appBarSubTitle;

  const BaseEmptyWidget({
    Key? key,
    required this.memberPicture,
    required this.appBarTitle,
    required this.appBarSubTitle,
  }) : super(
      key: key,
      mainMemberPicture: memberPicture,
      mainAppBarTitle: appBarTitle,
      mainAppBarSubTitle: appBarSubTitle
  );

  String getEmptyMessage();
  void doRefresh(BuildContext context);

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
                                ]
                              )
                          )
                      )]
                    )
                )
          ])),
          getBottomSection(context)
        ])
    );
  }

  @override
  Widget getContentWidget(BuildContext context) {
    return Center(
        child: Column(
          children: [const SizedBox(height: 30), Text(getEmptyMessage())],
        )
    );
  }
}

abstract class BaseErrorWidget extends BaseSliverPlainStatelessWidget {
  final String? memberPicture;
  final String? error;
  final String appBarTitle;
  final String appBarSubTitle;

  const BaseErrorWidget({
    Key? key,
    required this.error,
    required this.memberPicture,
    required this.appBarTitle,
    required this.appBarSubTitle,
  }) : super(
      key: key,
      mainMemberPicture: memberPicture,
      mainAppBarTitle: appBarTitle,
      mainAppBarSubTitle: appBarSubTitle
  );

  @override
  Widget getContentWidget(BuildContext context) {
    return errorNotice(error!);
  }
}
