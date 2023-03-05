import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/AppGlobal.dart';
import 'package:emartconsumer/cab_service/cab_home_screen.dart';
import 'package:emartconsumer/cab_service/cab_order_screen.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/main.dart';
import 'package:emartconsumer/model/User.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:emartconsumer/services/localDatabase.dart';
import 'package:emartconsumer/ui/Language/language_choose_screen.dart';
import 'package:emartconsumer/ui/StoreSelection/StoreSelection.dart';
import 'package:emartconsumer/ui/auth/AuthScreen.dart';
import 'package:emartconsumer/ui/privacy_policy/privacy_policy.dart';
import 'package:emartconsumer/ui/profile/ProfileScreen.dart';
import 'package:emartconsumer/ui/termsAndCondition/terms_and_codition.dart';
import 'package:emartconsumer/ui/wallet/walletScreen.dart';
import 'package:emartconsumer/userPrefrence.dart';
import 'package:emartconsumer/utils/DarkThemeProvider.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

enum DrawerSelection { Dashboard, Home, Wallet, Profile, Orders, termsCondition, privacyPolicy, chooseLanguage, Logout }

class DashBoardCabService extends StatefulWidget {
  final User? user;
  final Widget currentWidget;
  final String vendorId;
  final String appBarTitle;
  final DrawerSelection drawerSelection;

  DashBoardCabService({Key? key, required this.user, currentWidget, vendorId, appBarTitle, this.drawerSelection = DrawerSelection.Home})
      : appBarTitle = appBarTitle ?? 'Home'.tr(),
        vendorId = vendorId ?? "",
        currentWidget = currentWidget ??
            CabHomeScreen(
              user: MyAppState.currentUser,
            ),
        super(key: key);

  @override
  _DashBoardCabService createState() {
    return _DashBoardCabService();
  }
}

class _DashBoardCabService extends State<DashBoardCabService> {
  var key = GlobalKey<ScaffoldState>();

  late CartDatabase cartDatabase;
  late User user;
  late String _appBarTitle;
  final fireStoreUtils = FireStoreUtils();

  late Widget _currentWidget;
  late DrawerSelection _drawerSelection;

  int cartCount = 0;
  bool? isWalletEnable;

  @override
  void initState() {
    FireStoreUtils.getWalletSettingData();
    fireStoreUtils.getplaceholderimage().then((value) {
      AppGlobal.placeHolderImage = value;
    });

    super.initState();
    //FireStoreUtils.walletSettingData().then((value) => isWalletEnable = value);
    if (widget.user != null) {
      user = widget.user!;
    } else {
      user = User();
    }
    _currentWidget = widget.currentWidget;
    _appBarTitle = widget.appBarTitle;
    _drawerSelection = widget.drawerSelection;
    //getKeyHash();
    /// On iOS, we request notification permissions, Does nothing and returns null on Android
    FireStoreUtils.firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    cartDatabase = Provider.of<CartDatabase>(context);
  }

  DateTime pre_backpress = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return WillPopScope(
      onWillPop: () async {
        if (_currentWidget is! CabHomeScreen) {
          setState(() {
            _drawerSelection = DrawerSelection.Home;
            _appBarTitle = 'Cab Ride'.tr();
            _currentWidget = CabHomeScreen(
              user: MyAppState.currentUser,
            );
          });
          return false;
        } else {
          pushAndRemoveUntil(context, const StoreSelection(), false);
          return true;
        }
      },
      child: ChangeNotifierProvider.value(
        value: user,
        child: Consumer<User>(
          builder: (context, user, _) {
            return SafeArea(
              child: Scaffold(
                extendBodyBehindAppBar: _drawerSelection == DrawerSelection.Wallet ? true : false,
                key: key,
                drawer: Drawer(
                  child: Container(
                      color: isDarkMode(context) ? Colors.black : null,
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView(
                              padding: EdgeInsets.zero,
                              children: [
                                Consumer<User>(builder: (context, user, _) {
                                  return DrawerHeader(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        displayCircleImage(user.profilePictureURL, 75, false),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 8.0),
                                                    child: Text(
                                                      user.fullName(),
                                                      style: const TextStyle(color: Colors.white),
                                                    ),
                                                  ),
                                                  Padding(
                                                      padding: const EdgeInsets.only(top: 8.0),
                                                      child: Text(
                                                        user.email,
                                                        style: const TextStyle(color: Colors.white),
                                                      )),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                !themeChange.darkTheme?const Icon(Icons.light_mode_sharp):const Icon(Icons.nightlight),
                                                Switch(
                                                  // thumb color (round icon)
                                                  splashRadius: 50.0,
                                                  activeThumbImage: const AssetImage('https://lists.gnu.org/archive/html/emacs-devel/2015-10/pngR9b4lzUy39.png'),
                                                  inactiveThumbImage: const AssetImage('http://wolfrosch.com/_img/works/goodies/icon/vim@2x'),

                                                  value: themeChange.darkTheme,
                                                  onChanged: (value) => setState(() => themeChange.darkTheme = value),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(COLOR_PRIMARY),
                                    ),
                                  );
                                }),
                                ListTileTheme(
                                  style: ListTileStyle.drawer,
                                  selectedColor: Color(COLOR_PRIMARY),
                                  child: ListTile(
                                    selected: _drawerSelection == DrawerSelection.Dashboard,
                                    title: const Text('Dashboard').tr(),
                                    onTap: () {
                                      Navigator.pop(context);
                                      pushAndRemoveUntil(context, const StoreSelection(), false);
                                    },
                                    leading: Image.asset(
                                      'assets/images/dashboard.png',
                                      color: _drawerSelection == DrawerSelection.Dashboard
                                          ? Color(COLOR_PRIMARY)
                                          : isDarkMode(context)
                                              ? Colors.grey.shade200
                                              : Colors.grey.shade600,
                                      width: 24,
                                      height: 24,
                                    ),
                                  ),
                                ),
                                ListTileTheme(
                                  style: ListTileStyle.drawer,
                                  selectedColor: Color(COLOR_PRIMARY),
                                  child: ListTile(
                                    selected: _drawerSelection == DrawerSelection.Home,
                                    title: const Text('Book Ride').tr(),
                                    onTap: () {
                                      Navigator.pop(context);
                                      setState(() {
                                        _drawerSelection = DrawerSelection.Home;
                                        _appBarTitle = 'Stores'.tr();
                                        _currentWidget = CabHomeScreen(
                                          user: MyAppState.currentUser,
                                        );
                                      });
                                    },
                                    leading: const Icon(CupertinoIcons.home),
                                  ),
                                ),
                                Visibility(
                                  visible: UserPreference.getWalletData() ?? false,
                                  child: ListTileTheme(
                                    style: ListTileStyle.drawer,
                                    selectedColor: Color(COLOR_PRIMARY),
                                    child: ListTile(
                                      selected: _drawerSelection == DrawerSelection.Wallet,
                                      leading: const Icon(Icons.account_balance_wallet_outlined),
                                      title: const Text("Wallet").tr(),
                                      onTap: () {
                                        Navigator.pop(context);
                                        if (MyAppState.currentUser == null) {
                                          push(context, const AuthScreen());
                                        } else {
                                          setState(() {
                                            _drawerSelection = DrawerSelection.Wallet;
                                            _appBarTitle = 'Wallet'.tr();
                                            _currentWidget = const WalletScreen();
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                ListTileTheme(
                                  style: ListTileStyle.drawer,
                                  selectedColor: Color(COLOR_PRIMARY),
                                  child: ListTile(
                                    selected: _drawerSelection == DrawerSelection.Profile,
                                    leading: const Icon(CupertinoIcons.person),
                                    title: const Text('Profile').tr(),
                                    onTap: () {
                                      Navigator.pop(context);
                                      if (MyAppState.currentUser == null) {
                                        push(context, const AuthScreen());
                                      } else {
                                        setState(() {
                                          _drawerSelection = DrawerSelection.Profile;
                                          _appBarTitle = 'My Profile'.tr();
                                          _currentWidget = const ProfileScreen();
                                        });
                                      }
                                    },
                                  ),
                                ),
                                ListTileTheme(
                                  style: ListTileStyle.drawer,
                                  selectedColor: Color(COLOR_PRIMARY),
                                  child: ListTile(
                                    selected: _drawerSelection == DrawerSelection.Orders,
                                    leading: Image.asset(
                                      'assets/images/truck.png',
                                      color: _drawerSelection == DrawerSelection.Orders
                                          ? Color(COLOR_PRIMARY)
                                          : isDarkMode(context)
                                              ? Colors.grey.shade200
                                              : Colors.grey.shade600,
                                      width: 24,
                                      height: 24,
                                    ),
                                    title: const Text('Rides').tr(),
                                    onTap: () {
                                      Navigator.pop(context);
                                      if (MyAppState.currentUser == null) {
                                        push(context, const AuthScreen());
                                      } else {
                                        setState(() {
                                          _drawerSelection = DrawerSelection.Orders;
                                          _appBarTitle = 'Rides'.tr();
                                          _currentWidget = const CabOrderScreen();
                                        });
                                      }
                                    },
                                  ),
                                ),
                                ListTileTheme(
                                  style: ListTileStyle.drawer,
                                  selectedColor: Color(COLOR_PRIMARY),
                                  child: ListTile(
                                    selected: _drawerSelection == DrawerSelection.termsCondition,
                                    leading: const Icon(Icons.policy),
                                    title: const Text('Terms and Condition'),
                                    onTap: () async {
                                      push(context, const TermsAndCondition());
                                    },
                                  ),
                                ),
                                ListTileTheme(
                                  style: ListTileStyle.drawer,
                                  selectedColor: Color(COLOR_PRIMARY),
                                  child: ListTile(
                                    selected: _drawerSelection == DrawerSelection.privacyPolicy,
                                    leading: const Icon(Icons.privacy_tip),
                                    title: const Text('Privacy policy').tr(),
                                    onTap: () async {
                                      push(context, const PrivacyPolicyScreen());
                                    },
                                  ),
                                ),
                                Visibility(
                                  visible: isLanguageShown,
                                  child: ListTileTheme(
                                    style: ListTileStyle.drawer,
                                    selectedColor: Color(COLOR_PRIMARY),
                                    child: ListTile(
                                      selected: _drawerSelection == DrawerSelection.chooseLanguage,
                                      leading: Icon(
                                        Icons.language,
                                        color: _drawerSelection == DrawerSelection.chooseLanguage
                                            ? Color(COLOR_PRIMARY)
                                            : isDarkMode(context)
                                                ? Colors.grey.shade200
                                                : Colors.grey.shade600,
                                      ),
                                      title: const Text('Language').tr(),
                                      onTap: () {
                                        Navigator.pop(context);
                                        setState(() {
                                          _drawerSelection = DrawerSelection.chooseLanguage;
                                          _appBarTitle = 'Language'.tr();
                                          _currentWidget = LanguageChooseScreen(
                                            isContainer: true,
                                          );
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                ListTileTheme(
                                  style: ListTileStyle.drawer,
                                  selectedColor: Color(COLOR_PRIMARY),
                                  child: ListTile(
                                    selected: _drawerSelection == DrawerSelection.Logout,
                                    leading: const Icon(Icons.logout),
                                    title: Text((MyAppState.currentUser == null) ? 'Log In'.tr() : 'Log Out'.tr()),
                                    onTap: () async {
                                      if (MyAppState.currentUser == null) {
                                        pushAndRemoveUntil(context, const AuthScreen(), false);
                                      } else {
                                        Navigator.pop(context);
                                        //user.active = false;
                                        user.lastOnlineTimestamp = Timestamp.now();
                                        user.fcmToken = "";
                                        await FireStoreUtils.updateCurrentUser(user);
                                        await auth.FirebaseAuth.instance.signOut();
                                        MyAppState.currentUser = null;
                                        COLOR_PRIMARY = 0xFF00B761;
                                        MyAppState.selectedPosition = Position.fromMap({'latitude': 0.0, 'longitude': 0.0});
                                        Provider.of<CartDatabase>(context, listen: false).deleteAllProducts();
                                        pushAndRemoveUntil(context, const AuthScreen(), false);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("V : $appVersion"),
                          )
                        ],
                      )),
                ),
                appBar: _drawerSelection == DrawerSelection.Home
                    ? null
                    : AppBar(
                        elevation: _drawerSelection == DrawerSelection.Wallet ? 0 : 0,
                        centerTitle: _drawerSelection == DrawerSelection.Wallet ? true : false,
                        backgroundColor: _drawerSelection == DrawerSelection.Wallet
                            ? Colors.transparent
                            : isDarkMode(context)
                                ? Colors.black
                                : Colors.white,
                        //isDarkMode(context) ? Color(DARK_COLOR) : null,
                        leading: Padding(
                          padding: const EdgeInsets.all(8),
                          child: ElevatedButton(
                            onPressed: () {
                              key.currentState!.openDrawer();
                            },
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              primary: Colors.white,
                              padding: const EdgeInsets.all(10),
                            ),
                            child: Image.asset(
                              "assets/icons/ic_side_menu.png",
                              color: Colors.black,
                            ),
                          ),
                        ),
                        // iconTheme: IconThemeData(color: Colors.blue),
                        title: Text(
                          _appBarTitle,
                          style: TextStyle(
                              fontFamily: "Poppinsm",
                              fontSize: 18,
                              color: _drawerSelection == DrawerSelection.Wallet
                                  ? Colors.white
                                  : isDarkMode(context)
                                      ? Colors.white
                                      : Colors.black,
                              //isDarkMode(context) ? Colors.white : Colors.black,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                body: _currentWidget,
              ),
            );
          },
        ),
      ),
    );
  }
}
