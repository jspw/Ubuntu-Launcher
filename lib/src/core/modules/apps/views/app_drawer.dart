import 'package:android_intent/android_intent.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:launcher/src/config/themes/cubit/opacity_cubit.dart';
import 'package:launcher/src/ui/uninstaller_dialouge.dart';
import 'package:platform/platform.dart';
import 'package:launcher/src/constants/enums.dart';
import 'package:launcher/src/core/modules/apps/blocs/cubit/apps_cubit.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';

class AppDrawer extends StatelessWidget {
  static const route = '/app-drawer';
  TextEditingController _searchController;
  GlobalKey<AutoCompleteTextFieldState<String>> _autoCompeleteTextFieldkey =
      new GlobalKey();
  List<String> appsName = [];
  List<String> sortTypes = [
    SortOptions.Alphabetically.toString().split('.').last,
    SortOptions.InstallationTime.toString().split('.').last,
    SortOptions.UpdateTime.toString().split('.').last,
  ];

  appInfo(apps) async {
    List<String> appsNameDemo = [];

    for (int i = 0; i < apps.length; i++) {
      appsNameDemo.add(apps[i].appName.toString());
    }

    appsName = appsNameDemo;
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;

    final appsCubit = BlocProvider.of<AppsCubit>(context);

    final opacityCubit = BlocProvider.of<OpacityCubit>(context);

    return WillPopScope(
      onWillPop: () async => false,
      child: Focus(
        onFocusChange: (isFocusChanged) {
          if (isFocusChanged) {
            opacityCubit.setOpacitySemi();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(100.0),
            child: SafeArea(
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // opacityCubit.opacityReset();
                            Navigator.pop(
                              context,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            child: Hero(
                              tag: 'drawer',
                              child: Image.asset(
                                "assets/images/drawer.png",
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        DropdownButton<String>(
                          // value: sortType,
                          icon: Icon(
                            Icons.sort,
                            color: Colors.white,
                          ),
                          iconSize: 40,
                          elevation: 16,

                          // focusColor: Colors.green,
                          style: TextStyle(color: Colors.black),
                          underline: Container(
                            color: Colors.transparent,
                            child: Text(""),
                          ),
                          onChanged: (sortType) {
                            print(sortType);
                            appsCubit.sortApps(sortType);
                          },
                          items: sortTypes
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Card(
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(5),
                                  child: Text(
                                    value,
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        )
                      ],
                    ),
                  ),
                  Flexible(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: BlocBuilder<AppsCubit, AppsState>(
                          builder: (context, state) {
                            if (state is AppsLoaded) {
                              final apps = state.apps;

                              return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.white30,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: SimpleAutoCompleteTextField(
                                    style: TextStyle(
                                        letterSpacing: 1.2,
                                        color: Colors.white,
                                        fontSize: 24.0),
                                    controller: _searchController,
                                    key: _autoCompeleteTextFieldkey,
                                    suggestions: appsName,
                                    textSubmitted: (appName) {
                                      for (int i = 0; i < apps.length; i++) {
                                        if (apps[i].appName.toString() ==
                                            appName) {
                                          DeviceApps.openApp(
                                              apps[i].packageName);
                                          break;
                                        }
                                      }
                                    },
                                    clearOnSubmit: true,
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.all(10),
                                      border: InputBorder.none,
                                      suffixIcon: Icon(
                                        Icons.search_sharp,
                                        color: Colors.grey,
                                      ),
                                      fillColor: Colors.white,
                                      focusColor: Colors.white,
                                      hintStyle: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          textBaseline: TextBaseline.alphabetic,
                                          color: Colors.grey,
                                          fontSize: 20.0),
                                      hintText:
                                          '   Type to search applications',
                                    ),
                                  ));
                            } else
                              return RefreshProgressIndicator();
                          },
                        )),
                  ),
                ],
              ),
            ),
          ),
          body: RefreshIndicator(
            color: Colors.white,
            onRefresh: () async => appsCubit.getApps,
            child: Container(
              padding: const EdgeInsets.only(left: 30),
              child: BlocBuilder<AppsCubit, AppsState>(
                builder: (context, state) {
                  if (state is AppsLoading) {
                    return Center(
                      child: Container(
                        height: 50,
                        width: 50,
                        color: Colors.transparent,
                        child: Image.asset(
                          "assets/images/loader2.gif",
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  } else if (state is AppsLoaded) {
                    final apps = state.apps;
                    appInfo(apps);
                    return StaggeredGridView.countBuilder(
                      crossAxisCount: ((4 * deviceWidth) / 432).round(),
                      itemCount: apps.length,
                      itemBuilder: (BuildContext context, int i) {
                        Application app = apps[i];
                        return GestureDetector(
                            onTap: () {
                              DeviceApps.openApp(app.packageName);
                              Navigator.pop(context);
                              // opacityCubit.opacityReset();
                            },
                            onLongPress: () async {
                              // showMyDialog(context);

                              if (LocalPlatform().isAndroid) {
                                final AndroidIntent intent = AndroidIntent(
                                  action: 'action_application_details_settings',
                                  data: 'package:' +
                                      app.packageName, // replace com.example.app with your applicationId
                                );
                                await intent.launch();
                              }
                            },
                            child: app is ApplicationWithIcon
                                ? GridTile(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          Container(
                                            child: CircleAvatar(
                                              backgroundImage: MemoryImage(
                                                app.icon,
                                              ),
                                              backgroundColor: Colors.white,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            app.appName,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : null);
                      },
                      staggeredTileBuilder: (int index) =>
                          new StaggeredTile.count(1, 1),
                    );
                  } else
                    return Center(
                      child: Column(
                        children: [
                          RefreshProgressIndicator(),
                          Text(
                            "Something Went Wrong",
                            style:
                                TextStyle(color: Colors.white, fontSize: 20.0),
                          )
                        ],
                      ),
                    );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
