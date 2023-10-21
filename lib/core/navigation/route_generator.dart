import 'package:flutter/material.dart';
import 'package:gazer_client/core/protocol/resource/resource_list.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:gazer_client/forms/mores/about_form/about_form.dart';
import 'package:gazer_client/forms/nodes/main_form/main_form.dart';
import 'package:gazer_client/forms/maps/map_form/main/map_view.dart';
import 'package:gazer_client/forms/units/unit_add_form/unit_add_form.dart';
import 'package:gazer_client/forms/units/unit_edit/unit_edit_form.dart';
import 'package:gazer_client/forms/units/unit_form/unit_form.dart';
import 'package:gazer_client/forms/utilities/resources/resources_form/resources_form.dart';
import 'package:wakelock/wakelock.dart';

import '../../forms/chart_groups/chart_group_form/chart_group_form.dart';
import '../../forms/home/home.dart';
import '../../forms/mores/access_form/access_form.dart';
import '../../forms/mores/appearance_form/appearance_form.dart';
import '../../forms/mores/billing_form/billing_form.dart';
import '../../forms/mores/guest_access_form/guest_access_form.dart';
import '../../forms/nodes/node_edit_form/node_edit_form.dart';
import '../../forms/units/data_item_history_table_form/data_item_history_table_form.dart';
import '../../forms/units/data_item_properties/data_item_properties.dart';
import '../../forms/utilities/lookup_form/lookup_form.dart';
import '../../forms/utilities/resources/resource_info_form/resource_info_form.dart';
import '../../forms/utilities/resources/resource_item_add_form/resource_item_add_form.dart';
import '../../forms/maps/map_form/main/map_form.dart';
import '../../forms/maps/map_form/main/map_item.dart';
import '../../forms/maps/map_item_add_form/map_item_add_form.dart';
import '../../forms/maps/map_item_properties_form/map_item_properties_form.dart';
import '../../forms/utilities/resources/resource_change_form/resource_change_form.dart';
import '../../forms/mores/more_form/more_form.dart';
import '../../forms/nodes/node_add_form/node_add_form.dart';
import '../../forms/units/node_form/node_form.dart';

class RouteGenerator {
  static void processRouteArguments(RouteSettings settings) {
    if (settings.name == "/" ||
        settings.name == "/home" ||
        settings.name == "/node" ||
        settings.name == "/chart_groups" ||
        settings.name == "/chart_group" ||
        settings.name == "/maps" ||
        settings.name == "/more" ||
        settings.name == "/map" ||
        settings.name == "/users") {
      Repository().lastPath = settings.name!;
    }

    if (settings.arguments is HomeFormArgument) {
      Repository().lastSelectedConnection =
          (settings.arguments as HomeFormArgument).connection;
    }

    if (settings.arguments is NodeFormArgument) {
      Repository().lastSelectedConnection =
          (settings.arguments as NodeFormArgument).connection;
    }

    if (settings.arguments is UnitFormArgument) {
      Repository().lastSelectedConnection =
          (settings.arguments as UnitFormArgument).connection;
    }
  }

  static Widget transBuilder(context, animation, secondaryAnimation, child) {
    //return child;
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  static Duration transDuration() {
    return const Duration(milliseconds: 200);
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    processRouteArguments(settings);

    // keep the device screen awake
    switch (settings.name) {
      case '/maps':
      case '/map':
        Wakelock.enable();
        break;
      default:
        Wakelock.disable();
        break;
    }

    switch (settings.name) {
      case '/':
        Repository().navIndex = NavIndex.units;
        return PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return const MainForm();
          },
          transitionsBuilder: transBuilder,
          transitionDuration: transDuration(),
          reverseTransitionDuration: transDuration(),
        );
      case '/node':
        Repository().navIndex = NavIndex.units;
        return PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return NodeForm(
              arg: settings.arguments as NodeFormArgument,
            );
          },
          transitionsBuilder: transBuilder,
          transitionDuration: transDuration(),
          reverseTransitionDuration: transDuration(),
        );
      case '/chart_groups':
        Repository().navIndex = NavIndex.charts;
        return PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return ResourcesForm(
              settings.arguments as ResourcesFormArgument,
            );
          },
          transitionsBuilder: transBuilder,
          transitionDuration: transDuration(),
          reverseTransitionDuration: transDuration(),
        );
      case '/chart_group':
        Repository().navIndex = NavIndex.charts;
        return PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return ChartGroupForm(
              settings.arguments as ChartGroupFormArgument,
            );
          },
          transitionsBuilder: transBuilder,
          transitionDuration: transDuration(),
          reverseTransitionDuration: transDuration(),
        );
      case '/home':
        Repository().navIndex = NavIndex.home;
        return PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return HomeForm(
              settings.arguments as HomeFormArgument,
            );
          },
          transitionsBuilder: transBuilder,
          transitionDuration: transDuration(),
          reverseTransitionDuration: transDuration(),
        );
      case '/more':
        Repository().navIndex = NavIndex.more;
        return PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return MoreForm(
              settings.arguments as MoreFormArgument,
            );
          },
          transitionsBuilder: transBuilder,
          transitionDuration: transDuration(),
          reverseTransitionDuration: transDuration(),
        );
      case '/about':
        Repository().navIndex = NavIndex.more;
        return PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return AboutForm(
              settings.arguments as AboutFormArgument,
            );
          },
          transitionsBuilder: transBuilder,
          transitionDuration: transDuration(),
          reverseTransitionDuration: transDuration(),
        );
      case '/appearance':
        Repository().navIndex = NavIndex.more;
        return PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return AppearanceForm(
              settings.arguments as AppearanceFormArgument,
            );
          },
          transitionsBuilder: transBuilder,
          transitionDuration: transDuration(),
          reverseTransitionDuration: transDuration(),
        );
      case '/access':
        Repository().navIndex = NavIndex.more;
        return PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return AccessForm(
              settings.arguments as AccessFormArgument,
            );
          },
          transitionsBuilder: transBuilder,
          transitionDuration: transDuration(),
          reverseTransitionDuration: transDuration(),
        );
      case '/guest_access':
        Repository().navIndex = NavIndex.more;
        return PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return GuestAccessForm(
              settings.arguments as GuestAccessFormArgument,
            );
          },
          transitionsBuilder: transBuilder,
          transitionDuration: transDuration(),
          reverseTransitionDuration: transDuration(),
        );
      case '/billing':
        Repository().navIndex = NavIndex.more;
        return PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return BillingForm(
              settings.arguments as BillingFormArgument,
            );
          },
          transitionsBuilder: transBuilder,
          transitionDuration: transDuration(),
          reverseTransitionDuration: transDuration(),
        );
      case '/maps':
        Repository().navIndex = NavIndex.maps;
        return PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return ResourcesForm(
              settings.arguments as ResourcesFormArgument,
            );
          },
          transitionsBuilder: transBuilder,
          transitionDuration: transDuration(),
          reverseTransitionDuration: transDuration(),
        );
      case '/select_resource':
        return PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return ResourcesForm(
              settings.arguments as ResourcesFormArgument,
            );
          },
          transitionsBuilder: transBuilder,
          transitionDuration: transDuration(),
          reverseTransitionDuration: transDuration(),
        );
      case '/map':
        return PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return MapForm(
              settings.arguments as MapFormArgument,
            );
          },
          transitionsBuilder: transBuilder,
          transitionDuration: transDuration(),
          reverseTransitionDuration: transDuration(),
        );
      case '/resource_add':
        return PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return ResourceItemAddForm(
              settings.arguments as ResourceItemAddFormArgument,
            );
          },
          transitionsBuilder: transBuilder,
          transitionDuration: transDuration(),
          reverseTransitionDuration: transDuration(),
        );
      case '/resource_rename':
        return PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return ResourceChangeForm(
              settings.arguments as ResourceChangeFormArgument,
            );
          },
          transitionsBuilder: transBuilder,
          transitionDuration: transDuration(),
          reverseTransitionDuration: transDuration(),
        );
      case '/resource_info':
        return PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return ResourceInfoForm(
              settings.arguments as ResourceInfoFormArgument,
            );
          },
          transitionsBuilder: transBuilder,
          transitionDuration: transDuration(),
          reverseTransitionDuration: transDuration(),
        );
      case '/map_item_properties':
        return PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return MapItemPropertiesForm(
              settings.arguments as MapItemPropertiesFormArgument,
            );
          },
          transitionsBuilder: transBuilder,
          transitionDuration: transDuration(),
          reverseTransitionDuration: transDuration(),
        );
      case '/map_item_add':
        return PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return MapItemAddForm(
              settings.arguments as MapItemAddFormArgument,
            );
          },
          transitionsBuilder: transBuilder,
          transitionDuration: transDuration(),
          reverseTransitionDuration: transDuration(),
        );
      case '/lookup':
        return PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return LookupForm(
              settings.arguments as LookupFormArgument,
            );
          },
          transitionsBuilder: transBuilder,
          transitionDuration: transDuration(),
          reverseTransitionDuration: transDuration(),
        );
      case '/unit':
        return PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return UnitForm(
              arg: settings.arguments as UnitFormArgument,
            );
          },
          transitionsBuilder: transBuilder,
          transitionDuration: transDuration(),
          reverseTransitionDuration: transDuration(),
        );
      case '/unit_add':
        return PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return UnitAddForm(
              arg: settings.arguments as UnitAddFormArgument,
            );
          },
          transitionsBuilder: transBuilder,
          transitionDuration: transDuration(),
          reverseTransitionDuration: transDuration(),
        );
      case '/unit_edit':
        return PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return UnitEditForm(
              arg: settings.arguments as UnitEditFormArgument,
            );
          },
          transitionsBuilder: transBuilder,
          transitionDuration: transDuration(),
          reverseTransitionDuration: transDuration(),
        );
      case '/node_add':
        return PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return NodeAddForm(
              arg: settings.arguments as NodeAddFormArgument,
            );
          },
          transitionsBuilder: transBuilder,
          transitionDuration: transDuration(),
          reverseTransitionDuration: transDuration(),
        );
      case '/node_edit':
        return PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return NodeEditForm(
              arg: settings.arguments as NodeEditFormArgument,
            );
          },
          transitionsBuilder: transBuilder,
          transitionDuration: transDuration(),
          reverseTransitionDuration: transDuration(),
        );
      case '/data_item_properties':
        return PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return WidgetDataItemProperties(
              settings.arguments as DataItemPropertiesFormArgument,
            );
          },
          transitionsBuilder: transBuilder,
          transitionDuration: transDuration(),
          reverseTransitionDuration: transDuration(),
        );
      case '/data_item_history_table':
        return PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return DataItemHistoryTableForm(
              settings.arguments as DataItemHistoryTableFormArgument,
            );
          },
          transitionsBuilder: transBuilder,
          transitionDuration: transDuration(),
          reverseTransitionDuration: transDuration(),
        );
    }
    return MaterialPageRoute(builder: (_) => const Text("wrong path"));
  }
}

class MainFormArgument {}

class NodeFormArgument {
  Connection connection;
  NodeFormArgument(this.connection);
}

class ChartGroupsFormArgument {
  Connection connection;
  ChartGroupsFormArgument(this.connection);
}

class ChartGroupFormArgument {
  Connection connection;
  String id;
  bool edit;
  ChartGroupFormArgument(this.connection, this.id, this.edit);
}

class ChartGroupAddFormArgument {
  Connection connection;
  ChartGroupAddFormArgument(this.connection);
}

class ChartGroupRenameFormArgument {
  Connection connection;
  String id;
  ResListItemItemResponse resInfo;
  ChartGroupRenameFormArgument(this.connection, this.id, this.resInfo);
}

class MoreFormArgument {
  Connection connection;
  MoreFormArgument(this.connection);
}

class HomeFormArgument {
  Connection connection;
  HomeFormArgument(this.connection);
}

class AboutFormArgument {
  Connection connection;
  AboutFormArgument(this.connection);
}

class AppearanceFormArgument {
  Connection connection;
  AppearanceFormArgument(this.connection);
}

class AccessFormArgument {
  Connection connection;
  AccessFormArgument(this.connection);
}

class GuestAccessFormArgument {
  Connection connection;
  GuestAccessFormArgument(this.connection);
}

class BillingFormArgument {
  Connection connection;
  BillingFormArgument(this.connection);
}

class MapsFormArgument {
  Connection connection;
  bool filterByFolder;
  String folderId;
  String folderName;
  MapsFormArgument(
      this.connection, this.filterByFolder, this.folderId, this.folderName);
}

class ResourcesFormArgument {
  Connection connection;
  String type;
  String typeName;
  String typeNamePlural;
  IconData iconData;
  bool viewAsFolders;
  bool filterByFolder;
  String folderId;
  String folderName;
  Function(BuildContext context, ResListItemItemResponse res) onClick;
  Function(BuildContext context, String resId)? onCreated;
  ResourcesFormArgument(
      this.connection,
      this.type,
      this.typeName,
      this.typeNamePlural,
      this.iconData,
      this.viewAsFolders,
      this.filterByFolder,
      this.folderId,
      this.folderName,
      this.onClick,
      this.onCreated);
}

class MapFormArgument {
  Connection connection;
  String id;
  bool edit;
  MapFormArgument(this.connection, this.id, this.edit);
}

class ResourceItemAddFormArgument {
  Connection connection;
  String type;
  String folder;
  String typeName;
  String typeNamePlural;
  ResourceItemAddFormArgument(this.connection, this.type, this.folder,
      this.typeName, this.typeNamePlural);
}

class ResourceChangeFormArgument {
  Connection connection;
  String id;
  ResListItemItemResponse resInfo;
  String type;
  String typeName;
  String typeNamePlural;
  ResourceChangeFormArgument(this.connection, this.id, this.resInfo, this.type,
      this.typeName, this.typeNamePlural);
}

class ResourceInfoFormArgument {
  Connection connection;
  String id;
  ResListItemItemResponse resInfo;
  String type;
  String typeName;
  String typeNamePlural;
  ResourceInfoFormArgument(this.connection, this.id, this.resInfo, this.type,
      this.typeName, this.typeNamePlural);
}

class MapItemPropertiesFormArgument {
  Connection connection;
  IPropContainer item;
  MapItemPropertiesFormArgument(this.connection, this.item);
}

class MapItemAddFormArgument {
  Connection connection;
  MapView map;
  MapItemAddFormArgument(this.connection, this.map);
}

class MapItemDecorationAddFormArgument {
  Connection connection;
  MapItemDecorationAddFormArgument(this.connection);
}

class UsersFormArgument {
  Connection connection;
  UsersFormArgument(this.connection);
}

class UserAddFormArgument {
  Connection connection;
  UserAddFormArgument(this.connection);
}

class UserSetPasswordFormArgument {
  Connection connection;
  String userName;
  UserSetPasswordFormArgument(this.connection, this.userName);
}

class UserEditFormArgument {
  Connection connection;
  String userName;
  UserEditFormArgument(this.connection, this.userName);
}

class UserFormArgument {
  Connection connection;
  String userName;
  UserFormArgument(this.connection, this.userName);
}

class LookupFormArgument {
  Connection connection;
  String header;
  String lookupParameter;
  LookupFormArgument(this.connection, this.header, this.lookupParameter);
}

class RemoteAccessFormArgument {
  Connection connection;
  RemoteAccessFormArgument(this.connection);
}

class UnitFormArgument {
  Connection connection;
  String unitId;
  UnitFormArgument(this.connection, this.unitId);
}

class UnitAddFormArgument {
  Connection connection;
  UnitAddFormArgument(this.connection);
}

class NodeAddFormArgument {
  bool toCloud;
  NodeAddFormArgument(this.toCloud);
}

class NodeEditFormArgument {
  Connection connection;
  NodeEditFormArgument(this.connection);
}

class DataItemHistoryTableFormArgument {
  Connection connection;
  String itemName;
  DataItemHistoryTableFormArgument(this.connection, this.itemName);
}

class UnitEditFormArgument {
  Connection connection;
  String unitId;
  String unitType;
  UnitEditFormArgument(this.connection, this.unitId, this.unitType);
}

class DataItemPropertiesFormArgument {
  Connection connection;
  String itemName;
  int itemId;
  DataItemPropertiesFormArgument(this.connection, this.itemId, this.itemName);
}
