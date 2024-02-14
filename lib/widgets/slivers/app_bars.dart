import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

import 'package:logging/logging.dart';

final log = Logger('core.slivers.app_bars');

EdgeInsets contentPadding = Platform.isIOS ?
  const EdgeInsets.only(left: 20, top: 54) :
  const EdgeInsets.only(top: 0);


class TestNavBar extends StatelessWidget {
  const TestNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      // stretch: true,
      floating: true,
      // stretchTriggerOffset: 80.0,
      // onStretchTrigger: () async {
      //   if (onStretch != null) {
      //     await onStretch(context);
      //   }
      // },
      backgroundColor: Theme.of(context).primaryColor,
      iconTheme: const IconThemeData(color: Colors.white),
      expandedHeight: 180.0,
      collapsedHeight: 70,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text('hoi'),
        centerTitle: false,
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.fadeTitle,
          StretchMode.blurBackground,
        ],
        background: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.center,
              colors: <Color>[Theme.of(context).primaryColor, Colors.transparent],
            ),
          ),
          // child: image,
        ),
      ),
    );
  }

}

// generic header factory base class
abstract class BaseSmallAppBarFactory {
  BuildContext context;
  String title;

  BaseSmallAppBarFactory({
    required this.context,
    required this.title,
  });

  Widget createTitle() {
    return Text(title);
  }

  SliverAppBar createAppBar() {
    return SliverAppBar(
      pinned: true,
      stretch: false,
      floating: false,
      backgroundColor: Theme.of(context).primaryColor,
      iconTheme: const IconThemeData(color: Colors.white),
      expandedHeight: 60.0,
      collapsedHeight: 60.0,
      title: createTitle(),
    );
  }
}

// generic header factory base class
abstract class BaseGenericAppBarFactory {
  BuildContext mainContext;
  String mainTitle;
  String mainSubtitle;
  String? mainMemberPicture;
  Function? mainOnStretch;

  BaseGenericAppBarFactory({
    required this.mainContext,
    required this.mainTitle,
    required this.mainSubtitle,
    required this.mainMemberPicture,
    this.mainOnStretch
  });

  Widget createTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(mainTitle, style: const TextStyle(color: Colors.white, )),
        Text(mainSubtitle, style: const TextStyle(color: Colors.white, fontSize: 12.0)),
      ],
    );
    // return ListTile(
    //     contentPadding: contentPadding,
    //     textColor: Colors.white,
    //     title: Text(title),
    //     subtitle: Text(subtitle)
    // );
  }

  SliverAppBar createAppBar() {
    Widget image;
    if (mainMemberPicture == null) {
      image = Image.asset("assets/icon/icon.png");
      log.info("memberPicture not set, using default one");
    } else {
      image = CachedNetworkImage(
        placeholder: (context, url) => const CircularProgressIndicator(),
        imageUrl: mainMemberPicture!,
        fit: BoxFit.cover,
      );
    }

    return SliverAppBar(
      pinned: true,
      // stretch: true,
      floating: true,
      // stretchTriggerOffset: 80.0,
      // onStretchTrigger: () async {
      //   if (onStretch != null) {
      //     await onStretch(context);
      //   }
      // },
      backgroundColor: Theme.of(mainContext).primaryColor,
      iconTheme: const IconThemeData(color: Colors.white),
      expandedHeight: 180.0,
      collapsedHeight: 70,
      flexibleSpace: FlexibleSpaceBar(
        title: createTitle(),
        centerTitle: false,
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.fadeTitle,
          StretchMode.blurBackground,
        ],
        background: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.center,
              colors: <Color>[Theme.of(mainContext).primaryColor, Colors.transparent],
            ),
          ),
          child: image,
        ),
      ),
    );
  }
}

class GenericAppBarFactory extends BaseGenericAppBarFactory {
  BuildContext context;
  String title;
  String subtitle;
  String? memberPicture;
  Function? onStretch;

  GenericAppBarFactory({
    required this.context,
    required this.title,
    required this.subtitle,
    required this.memberPicture,
    this.onStretch
  }) : super(
      mainContext: context,
      mainTitle: title,
      mainSubtitle: subtitle,
      mainOnStretch: onStretch,
      mainMemberPicture: memberPicture
  );
}

class SmallAppBarFactory extends BaseSmallAppBarFactory {
  SmallAppBarFactory({
    required BuildContext context,
    required String title
  }) : super(context: context, title: title);

}