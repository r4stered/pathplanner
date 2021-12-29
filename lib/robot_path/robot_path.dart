import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'waypoint.dart';

class RobotPath {
  List<Waypoint> waypoints;
  double? maxVelocity;
  double? maxAcceleration;
  late String name;

  RobotPath(this.waypoints,
      {this.name = 'New Path', this.maxVelocity, this.maxAcceleration});

  RobotPath.fromJson(Map<String, dynamic> json) : waypoints = [] {
    for (Map<String, dynamic> pointJson in json['waypoints']) {
      waypoints.add(Waypoint.fromJson(pointJson));
    }

    maxVelocity = json['maxVelocity'];
    maxAcceleration = json['maxAcceleration'];
  }

  String? getWaypointLabel(Waypoint? waypoint) {
    if (waypoint == null) return null;
    if (waypoint.isStartPoint()) return 'Start Point';
    if (waypoint.isEndPoint()) return 'End Point';

    return 'Waypoint ' + waypoints.indexOf(waypoint).toString();
  }

  void savePath(String saveDir) {
    File pathFile = File(saveDir + name + '.path');
    pathFile.writeAsString(jsonEncode(this));
  }

  void addWaypoint(Point anchorPos) {
    waypoints[waypoints.length - 1].addNextControl();
    waypoints.add(
      Waypoint(
        prevControl:
            (waypoints[waypoints.length - 1].nextControl! + anchorPos) * 0.5,
        anchorPoint: anchorPos,
      ),
    );
  }

  static List<Waypoint> cloneWaypointList(List<Waypoint> waypoints) {
    List<Waypoint> points = [];

    for (Waypoint w in waypoints) {
      points.add(w.clone());
    }

    return points;
  }

  Map<String, dynamic> toJson() {
    if (maxVelocity == null && maxAcceleration == null) {
      return {
        'waypoints': waypoints,
      };
    } else {
      return {
        'waypoints': waypoints,
        'maxVelocity': maxVelocity,
        'maxAcceleration': maxAcceleration,
      };
    }
  }
}
