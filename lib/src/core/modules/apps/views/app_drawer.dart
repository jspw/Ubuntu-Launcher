import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:launcher/src/config/constants/size.dart';
import 'package:launcher/src/config/themes/cubit/opacity_cubit.dart';
import 'package:launcher/src/helpers/widgets/error_message.dart';
import 'package:logger/logger.dart';
import 'package:launcher/src/config/constants/enums.dart';
import 'package:launcher/src/blocs/apps_cubit.dart';

class AppDrawer extends StatelessWidget {
  static const route = '/app-drawer';
  
  const AppDrawer({super.key});
  
  @override
  Widget build(BuildContext context) {
    final appsCubit = BlocProvider.of<AppsCubit>(context);
    final opacityCubit = BlocProvider.of<OpacityCubit>(context);
    
    final List<String> sortTypes = [
      SortTypes.Alphabetically.toString().split('.').last,
      SortTypes.InstallationTime.toString().split('.').last,
      SortTypes.UpdateTime.toString().split('.').last,
    ];

    final ratio = 1.1 * 411.42857142857144 / deviceWidth;

    return PopScope(
      canPop: true,
      child: Focus(
        onFocusChange: (isFocusChanged) {
          if (isFocusChanged) {
            opacityCubit.setOpacitySemi();
            appsCubit.loadApps();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(100.0),
            child: SafeArea(
              child: Column(
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
                            Navigator.pop(context);
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
                          icon: const Icon(
                            Icons.sort,
                            color: Colors.white,
                          ),
                          iconSize: 40,
                          elevation: 16,

                          focusColor: Colors.green,
                          style: const TextStyle(color: Colors.black),
                          underline: Container(
                            color: Colors.transparent,
                            child: const Text(""),
                          ),
                          onChanged: (sortType) {
                            if (sortType != null) {
                              appsCubit.updateSortType(sortType);
                            }
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
                                    style: const TextStyle(color: Colors.black),
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
                          builder: (context, appState) {
                            if (appState is AppsLoaded) {
                              return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.white30,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: TextField(
                                    style: TextStyle(
                                        letterSpacing: 1.2,
                                        color: Colors.white,
                                        fontSize: normalTextSize),
                                    onSubmitted: (appName) {
                                      for (int i = 0;
                                          i < appState.apps.length;
                                          i++) {
                                        if (appState.apps[i].name
                                                .toString() ==
                                            appName) {
                                          InstalledApps.startApp(
                                              appState.apps[i].packageName);
                                          break;
                                        }
                                      }
                                    },
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.all(10),
                                      border: InputBorder.none,
                                      suffixIcon: const Icon(
                                        Icons.search_sharp,
                                        color: Colors.grey,
                                      ),
                                      fillColor: Colors.white,
                                      focusColor: Colors.white,
                                      hintStyle: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          textBaseline: TextBaseline.alphabetic,
                                          color: Colors.grey,
                                          fontSize: smallTextSize),
                                      hintText:
                                          '   Type to search applications',
                                    ),
                                  ));
                            } else {
                              return Container();
                            }
                          },
                        )),
                  ),
                ],
              ),
            ),
          ),
          body: RefreshIndicator(
            color: Colors.white,
            onRefresh: () => appsCubit.loadApps(),
            child: Container(
              padding: const EdgeInsets.only(left: 50),
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
                    return MasonryGridView.count(
                      crossAxisCount: ((4 * deviceWidth) / 432).round(),
                      itemCount: state.apps.length,
                      itemBuilder: (BuildContext context, int i) {
                        AppInfo app = state.apps[i];
                        return GestureDetector(
                            onTap: () {
                              try {
                                InstalledApps.startApp(app.packageName);
                              } catch (error) {
                                Logger().w(error);
                                ErrorMessage(
                                        context: context,
                                        error: error.toString())
                                    .display();
                              }
                              Navigator.pop(context);
                            },
                            onLongPress: () async {
                              try {
                                Navigator.pop(context);
                                InstalledApps.openSettings(app.packageName);
                              } catch (error) {
                                Logger().w(error);
                                ErrorMessage(context: context, error: error.toString())
                                    .display();
                              }
                            },
                            child: GridTile(
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    app.icon != null
                                        ? CircleAvatar(
                                            backgroundImage: MemoryImage(
                                              app.icon!,
                                            ),
                                            backgroundColor: Colors.white,
                                          )
                                        : const CircleAvatar(
                                            backgroundImage: AssetImage(
                                                "assets/images/no_image.png"),
                                            backgroundColor: Colors.white,
                                          ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Expanded(
                                      child: Text(
                                        app.name,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: smallTextSize),
                                        overflow: ratio < 1.2
                                            ? TextOverflow.clip
                                            : TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ));
                      },
                    );
                  } else {
                    return Center(
                      child: Column(
                        children: [
                          const RefreshProgressIndicator(),
                          const Text(
                            "Something Went Wrong",
                            style:
                                TextStyle(color: Colors.white, fontSize: 20.0),
                          )
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
