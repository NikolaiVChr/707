var colorGreen = [0.3,1,0.3];
var colorLightGreen = [0.16,0.8,0.13];
var colorBG = [0.4,0.48,0.4];
var colorGrey = [0.5,0.5,0.5];
var colorRed = [1,0,0];
var colorBlue = [0,0,1];
var colorLightBlue = [0.3,0.3,1];
var colorWhite = [1,1,1];
var colorYellow = [1,1,0];

var cursor_pos = [0,0];
var cursor_time = 0;
var cursor_screen = -1;
var cursor_type = 0;

var setCursor = func (x, y, screen, type) {
    cursor_pos = [x*diam - diam*0.5,-y*diam+diam*0.5];
    cursor_time = systime();
    cursor_screen = screen;
    cursor_type = type;
    #printf("slew %d,%d on screen %d", cursor_pos[0],cursor_pos[1],screen+1);
};

RadarScreenLeft = {
    new: func (_ident, root, center, diameter) {
        var rdr1 = {parents: [RadarScreenLeft]};
        var radius = diameter/2;
        rdr1.radius = radius;
        var font = int(0.08*diameter);
        
        rdr1.stroke = 2;
        rdr1.rootCenter = root.createChild("group")
                .setTranslation(center[0],center[1])
                .set("font","B612/B612Mono-Bold.ttf");

        rdr1.caretLine = rdr1.rootCenter.createChild("path")
           .vert(-radius)
           .setStrokeLineWidth(rdr1.stroke*1.8)
           .set("z-index",11)
           .setColor(colorLightGreen);


        rdr1.maxB = 150;
        rdr1.maxT =  15;
        rdr1.blep = setsize([],rdr1.maxB);
        rdr1.blepTriangle = setsize([],rdr1.maxT);
        rdr1.blepTriangleVel = setsize([],rdr1.maxT);
        rdr1.blepTriangleVelLine = setsize([],rdr1.maxT);
        rdr1.blepTriangleText = setsize([],rdr1.maxT);
        rdr1.blepTrianglePaths = setsize([],rdr1.maxT);
        rdr1.lnk = setsize([],rdr1.maxT);
        rdr1.lnkT = setsize([],rdr1.maxT+1);
        rdr1.lnkTA = setsize([],rdr1.maxT+1);
        rdr1.iff  = setsize([],rdr1.maxT);# friendly IFF response
        rdr1.iffU = setsize([],rdr1.maxT);# unknown IFF response
        for (var i = 0;i<rdr1.maxB;i+=1) {
                rdr1.blep[i] = rdr1.rootCenter.createChild("path")
                        .moveTo(0,-3)
                        .vert(7)
                        .setStrokeLineWidth(7)
                        .setStrokeLineCap("butt")
                        .set("z-index",10)
                        .hide();
        }
        for (var i = 0;i<rdr1.maxT;i+=1) {
                rdr1.blepTriangle[i] = rdr1.rootCenter.createChild("group")
                                .set("z-index",11);
                rdr1.blepTriangleVel[i] = rdr1.blepTriangle[i].createChild("group");
                rdr1.blepTriangleText[i] = rdr1.blepTriangle[i].createChild("text")
                                .setAlignment("center-top")
                                .setFontSize(20, 1.0)
                                .setTranslation(0,20)
                                .setColor(1, 1, 1);
                rdr1.blepTriangleVelLine[i] = rdr1.blepTriangleVel[i].createChild("path")
                                .lineTo(0,-10)
                                .setTranslation(0,-16)
                                .setStrokeLineWidth(2)
                                .setColor(colorRed);
                rdr1.blepTrianglePaths[i] = rdr1.blepTriangle[i].createChild("path")
                                .moveTo(-14,8)
                                .horiz(28)
                                .lineTo(0,-16)
                                .lineTo(-14,8)
                                .setColor(colorRed)
                                .set("z-index",10)
                                .setStrokeLineWidth(2);
                rdr1.iff[i] = rdr1.rootCenter.createChild("path")
                                .moveTo(-8,0)
                                .arcSmallCW(8,8, 0,  8*2, 0)
                                .arcSmallCW(8,8, 0, -8*2, 0)
                                .setColor(colorBlue)
                                .hide()
                                .set("z-index",12)
                                .setStrokeLineWidth(3);
                rdr1.iffU[i] = rdr1.rootCenter.createChild("path")
                                .moveTo(-8,-8)
                                .vert(16)
                                .horiz(16)
                                .vert(-16)
                                .horiz(-16)
                                .setColor(colorRed)
                                .hide()
                                .set("z-index",12)
                                .setStrokeLineWidth(3);
                rdr1.lnk[i] = rdr1.rootCenter.createChild("path")
                                .moveTo(-10,-10)
                                .vert(20)
                                .horiz(20)
                                .vert(-20)
                                .horiz(-20)
                                .moveTo(0,-10)
                                .vert(-10)
                                .setColor(colorLightBlue)
                                .hide()
                                .set("z-index",11)
                                .setStrokeLineWidth(3);

            rdr1.lnkT[i] = rdr1.rootCenter.createChild("text")
                .setAlignment("center-bottom")
                .setColor(colorLightBlue)
                .set("z-index",1)
                .setFontSize(20, 1.0);
            rdr1.lnkTA[i] = rdr1.rootCenter.createChild("text")
                                .setAlignment("center-top")
                                .setFontSize(20, 1.0);
        }
        rdr1.selection = rdr1.rootCenter.createChild("group")
                .set("z-index",12);
        rdr1.selectionPath = rdr1.selection.createChild("path")
                .moveTo(-16, 0)
                .arcSmallCW(16, 16, 0, 16*2, 0)
                .arcSmallCW(16, 16, 0, -16*2, 0)
                .setColor(colorWhite)
                .setStrokeLineWidth(2);
        rdr1.selection2 = rdr1.rootCenter.createChild("group")
                .set("z-index",12);
        rdr1.selection2Path = rdr1.selection2.createChild("path")
                .moveTo(-16, 0)
                .arcSmallCW(16, 16, 0, 16*2, 0)
                .arcSmallCW(16, 16, 0, -16*2, 0)
                .setColor(colorYellow)
                .setStrokeLineWidth(2);

        rdr1.lockInfo = rdr1.rootCenter.createChild("text")
                .setTranslation(-diam*0.25*1.5, diam*0.25)
                .setAlignment("left-center")
                .setColor(colorGreen)
                .set("z-index",1)
                .setFontSize(15, 1.0);
        rdr1.lockInfo2 = rdr1.rootCenter.createChild("text")
                .setTranslation(-diam*0.25*1.5, -diam*0.25)
                .setAlignment("left-center")
                .setColor(colorYellow)
                .set("z-index",1)
                .setFontSize(15, 1.0);
        rdr1.interceptText = rdr1.rootCenter.createChild("text")
                .setTranslation(-diam*0.25*1.5, diam*0.30)
                .setAlignment("left-center")
                .setColor(colorLightBlue)
                .set("z-index",1)
                .setFontSize(15, 1.0);
        rdr1.rangeInfo = rdr1.rootCenter.createChild("text")
                .setTranslation(-diam*0.25*1.5, diam*0.35)
                .setAlignment("left-center")
                .setColor(colorGrey)
                .set("z-index",1)
                .setFontSize(15, 1.0);

        rdr1.interceptCross = rdr1.rootCenter.createChild("path")
                            .moveTo(10,0)
                            .lineTo(-10,0)
                            .moveTo(0,-10)
                            .vert(20)
                            .setColor(colorYellow)
                            .set("z-index",14)
                            .setStrokeLineWidth(2);
        var tick_long = radius*0.25;
        var tick_short = tick_long*0.5;
        rdr1.compas1 = rdr1.rootCenter.createChild("path")# minor ticks
           .moveTo(radius*math.cos(30*D2R),radius*math.sin(-30*D2R))
           .lineTo((radius-tick_short)*math.cos(30*D2R),(radius-tick_short)*math.sin(-30*D2R))
           .moveTo(radius*math.cos(15*D2R),radius*math.sin(-15*D2R))
           .lineTo((radius-tick_short)*math.cos(15*D2R),(radius-tick_short)*math.sin(-15*D2R))
           .moveTo(radius*math.cos(45*D2R),radius*math.sin(-45*D2R))
           .lineTo((radius-tick_short)*math.cos(45*D2R),(radius-tick_short)*math.sin(-45*D2R))
           .moveTo(radius*math.cos(60*D2R),radius*math.sin(-60*D2R))
           .lineTo((radius-tick_short)*math.cos(60*D2R),(radius-tick_short)*math.sin(-60*D2R))
           .moveTo(radius*math.cos(75*D2R),radius*math.sin(-75*D2R))
           .lineTo((radius-tick_short)*math.cos(75*D2R),(radius-tick_short)*math.sin(-75*D2R))
           
           .moveTo(radius*math.cos(30*D2R),radius*math.sin(30*D2R))
           .lineTo((radius-tick_short)*math.cos(30*D2R),(radius-tick_short)*math.sin(30*D2R))
           .moveTo(radius*math.cos(15*D2R),radius*math.sin(15*D2R))
           .lineTo((radius-tick_short)*math.cos(15*D2R),(radius-tick_short)*math.sin(15*D2R))
           .moveTo(radius*math.cos(45*D2R),radius*math.sin(45*D2R))
           .lineTo((radius-tick_short)*math.cos(45*D2R),(radius-tick_short)*math.sin(45*D2R))
           .moveTo(radius*math.cos(60*D2R),radius*math.sin(60*D2R))
           .lineTo((radius-tick_short)*math.cos(60*D2R),(radius-tick_short)*math.sin(60*D2R))
           .moveTo(radius*math.cos(75*D2R),radius*math.sin(75*D2R))
           .lineTo((radius-tick_short)*math.cos(75*D2R),(radius-tick_short)*math.sin(75*D2R))

           .moveTo(-radius*math.cos(30*D2R),radius*math.sin(-30*D2R))
           .lineTo(-(radius-tick_short)*math.cos(30*D2R),(radius-tick_short)*math.sin(-30*D2R))
           .moveTo(-radius*math.cos(15*D2R),radius*math.sin(-15*D2R))
           .lineTo(-(radius-tick_short)*math.cos(15*D2R),(radius-tick_short)*math.sin(-15*D2R))
           .moveTo(-radius*math.cos(45*D2R),radius*math.sin(-45*D2R))
           .lineTo(-(radius-tick_short)*math.cos(45*D2R),(radius-tick_short)*math.sin(-45*D2R))
           .moveTo(-radius*math.cos(60*D2R),radius*math.sin(-60*D2R))
           .lineTo(-(radius-tick_short)*math.cos(60*D2R),(radius-tick_short)*math.sin(-60*D2R))
           .moveTo(-radius*math.cos(75*D2R),radius*math.sin(-75*D2R))
           .lineTo(-(radius-tick_short)*math.cos(75*D2R),(radius-tick_short)*math.sin(-75*D2R))
           
           .moveTo(-radius*math.cos(30*D2R),radius*math.sin(30*D2R))
           .lineTo(-(radius-tick_short)*math.cos(30*D2R),(radius-tick_short)*math.sin(30*D2R))
           .moveTo(-radius*math.cos(15*D2R),radius*math.sin(15*D2R))
           .lineTo(-(radius-tick_short)*math.cos(15*D2R),(radius-tick_short)*math.sin(15*D2R))
           .moveTo(-radius*math.cos(45*D2R),radius*math.sin(45*D2R))
           .lineTo(-(radius-tick_short)*math.cos(45*D2R),(radius-tick_short)*math.sin(45*D2R))
           .moveTo(-radius*math.cos(60*D2R),radius*math.sin(60*D2R))
           .lineTo(-(radius-tick_short)*math.cos(60*D2R),(radius-tick_short)*math.sin(60*D2R))
           .moveTo(-radius*math.cos(75*D2R),radius*math.sin(75*D2R))
           .lineTo(-(radius-tick_short)*math.cos(75*D2R),(radius-tick_short)*math.sin(75*D2R))
           .setStrokeLineWidth(rdr1.stroke*1.8)
           .set("z-index",1)
           .setColor(colorWhite);
        rdr1.compas2 = rdr1.rootCenter.createChild("path")# minor ticks
           .moveTo(radius,0)
           .lineTo((radius-tick_long),0)
           
           .moveTo(0,radius)
           .lineTo(0,(radius-tick_long))

           .moveTo(-radius,0)
           .lineTo(-(radius-tick_long),0)
           
           .moveTo(0,-radius)
           .lineTo(0,-(radius-tick_long))

           .moveTo(0,-radius)
           .lineTo(-tick_short,-(radius-tick_short))
           .moveTo(0,-radius)
           .lineTo(tick_short,-(radius-tick_short))

           .setStrokeLineWidth(rdr1.stroke*1.2)
           .set("z-index",1)
           .setColor(colorWhite);

        return rdr1;
    },
    paintRdr: func (contact) {
          if (contact["iff"] != nil) {
              if (contact.iff > 0 and me.elapsed-contact.iff < 3.5) {
                  me.myiff = 1;
              } elsif (contact.iff < 0 and me.elapsed+contact.iff < 3.5) {
                  me.myiff = -1;
              } else {
                  me.myiff = 0;
              }
          } else {
              me.myiff = 0;
          }
          me.bleps = contact.getBleps();
          foreach(me.bleppy ; me.bleps) {
              if (me.i < me.maxB and me.elapsed - me.bleppy.getBlepTime() < radar_system.apy1Radar.currentMode.timeToFadeBleps and me.bleppy.getDirection() != nil) {
                  me.distPixels = me.bleppy.getRangeNow()*(me.radius/(radar_system.apy1Radar.getRange()*NM2M));
                  
                  me.echoPos = me.calcPos(geo.normdeg180(me.bleppy.getAZDeviation()), me.distPixels);
#                  me.echoPos = me.calcEXPPos(me.echoPos);
                  if (me.echoPos == nil) {
                      continue;
                  }
                  me.color = math.pow(1-(me.elapsed - me.bleppy.getBlepTime())/radar_system.apy1Radar.currentMode.timeToFadeBleps, 2.2);
                  me.blep[me.i].setTranslation(me.echoPos);
                  me.blep[me.i].setColor(colorLightGreen[0]*me.color+colorBackground[0]*(1-me.color), colorLightGreen[1]*me.color+colorBackground[1]*(1-me.color), colorLightGreen[2]*me.color+colorBackground[2]*(1-me.color));
                  me.blep[me.i].show();
                  me.blep[me.i].update();
                  if (contact.equalsFast(radar_system.apy1Radar.getPriorityTarget()) and me.bleppy == me.bleps[size(me.bleps)-1]) {
                      me.selectShowTemp = math.mod(me.elapsed,0.50)<0.25;#todo
                      me.selectShow = me.selectShowTemp and contact.getType() == radar_system.AIR;
                      me.selection.setTranslation(me.echoPos);
                      me.selection.setColor(colorGreen);
                      me.printInfo(contact);
                      me.showLockInfo = 1;
                  } elsif (contact.equalsFast(radar_system.apy1Radar.currentMode.priorityTarget2) and me.bleppy == me.bleps[size(me.bleps)-1]) {
                      me.selectShowTemp = math.mod(me.elapsed,0.50)<0.25;#todo
                      me.selectShow2 = me.selectShowTemp and contact.getType() == radar_system.AIR;
                      me.selection2.setTranslation(me.echoPos);
                      me.selection2.setColor(colorYellow);
                      me.printInfo2(contact);
                      me.showLockInfo2 = 1;
                  }
                  if (me.elapsed - me.bleppy.getBlepTime() < radar_system.apy1Radar.currentMode.timeToFadeBleps) {
                      me.calcClick(contact, me.echoPos);
                  }
                  me.i += 1;
              }
          }
          me.sizeBleps = size(me.bleps);
          if (contact["blue"] != 1 and me.ii < me.maxT and ((me.sizeBleps and contact.hadTrackInfo()) or contact["blue"] == 2) and me.myiff == 0) {
              # Paint bleps with tracks
              if (contact["blue"] != 2) me.bleppy = me.bleps[me.sizeBleps-1];
              if (contact["blue"] == 2 or (me.bleppy.hasTrackInfo() and me.elapsed - me.bleppy.getBlepTime() < radar_system.apy1Radar.timeToKeepBleps)) {
                  me.color = contact["blue"] == 2?colorRed:colorWhite;
                  if (contact["blue"] == 2) {
                      me.c_heading    = contact.getHeading();
                      me.c_devheading = contact.getDeviationHeading();
                      me.c_speed      = contact.getSpeed();
                      me.c_alt        = contact.getAltitude();
                      me.distPixels   = contact.getRange()*(me.radius/(radar_system.apy1Radar.getRange()*NM2M));
                  } else {
                      me.c_heading    = me.bleppy.getHeading();
                      me.c_devheading = me.bleppy.getAZDeviation();
                      me.c_speed      = me.bleppy.getSpeed();
                      me.c_alt        = me.bleppy.getAltitude();
                      me.distPixels   = me.bleppy.getRangeNow()*(me.radius/(radar_system.apy1Radar.getRange()*NM2M));
                  }
                  me.rot = 22.5*math.round((me.c_heading-radar_system.self.getHeading())/22.5);
                  me.blepTrianglePaths[me.ii].setRotation(me.rot*D2R);
                  me.blepTrianglePaths[me.ii].setColor(me.color);
                  me.echoPos = me.calcPos(geo.normdeg180(me.c_devheading), me.distPixels);
  #                me.echoPos = me.calcEXPPos(me.echoPos);
                  if (me.echoPos == nil) {
                      return;
                  }
                  if (contact["blue"] == 2 and me.iii < me.maxT) {
                      me.lnkT[me.iii].setColor(me.color);
                      me.lnkT[me.iii].setTranslation(me.echoPos[0],me.echoPos[1]-25);
                      me.lnkT[me.iii].setText(""~contact.blueIndex);
                      me.lnkT[me.iii].show();
                      me.iii += 1;
                  }
                  me.blepTriangle[me.ii].setTranslation(me.echoPos);
                  if (me.c_speed != nil and me.c_speed > 0) {
                      me.blepTriangleVelLine[me.ii].setScale(1,me.c_speed*0.0045);
                      me.blepTriangleVelLine[me.ii].setColor(me.color);
                      me.blepTriangleVel[me.ii].setRotation(me.rot*D2R);
                      me.blepTriangleVel[me.ii].update();
                      me.blepTriangleVel[me.ii].show();
                  } else {
                      me.blepTriangleVel[me.ii].hide();
                  }
                  if (me.c_alt != nil) {
                      me.blepTriangleText[me.ii].setText(""~math.round(me.c_alt*0.001));
                      me.blepTriangleText[me.ii].setColor(me.color);
                  } else {
                      me.blepTriangleText[me.ii].setText("");
                  }
                  me.blinkShow = 1;#radar_system.apy1Radar.currentMode.longName != radar_system.twsMode.longName or (me.elapsed - contact.getLastBlepTime() < radar_system.F16TWSMode.timeToBlinkTracks) or (math.mod(me.elapsed,0.50)<0.25);
                  if (contact.equalsFast(radar_system.apy1Radar.getPriorityTarget())) {
                      me.selectShow = me.blinkShow and contact.getType() == radar_system.AIR;
                      me.blepTriangle[me.ii].setVisible(me.selectShow);
                      me.selection.setTranslation(me.echoPos);
                      me.selection.setColor(colorGreen);
                      me.printInfo(contact);
                      me.showLockInfo = 1;
                  } elsif (contact.equalsFast(radar_system.apy1Radar.currentMode.priorityTarget2)) {
                      me.selectShow2 = me.blinkShow and contact.getType() == radar_system.AIR;
                      me.blepTriangle[me.ii].setVisible(me.selectShow2);
                      me.selection2.setTranslation(me.echoPos);
                      me.selection2.setColor(colorYellow);
                      me.printInfo2(contact);
                      me.showLockInfo2 = 1;
                  }
                  me.blepTriangle[me.ii].setVisible(me.blinkShow and contact.getType() == radar_system.AIR);
                  me.blepTriangle[me.ii].update();
                  me.calcClick(contact, me.echoPos);

                  me.ii += 1;
              }
          } elsif (me.myiff != 0 and contact["blue"] != 1 and contact.isVisible() and me.iiii < me.maxT and me.sizeBleps) {
              # Paint IFF symbols
              me.bleppy = me.bleps[me.sizeBleps-1];
              if (me.elapsed - me.bleppy.getBlepTime() < radar_system.apy1Radar.timeToKeepBleps) {
                  me.echoPos = me.calcPos(geo.normdeg180(me.bleppy.getAZDeviation()), me.distPixels);
#                  me.echoPos = me.calcEXPPos(me.echoPos);
                  if (me.echoPos == nil) {
                      return;
                  }
                  me.path = me.myiff == -1?me.iffU[me.iiii]:me.iff[me.iiii];
                  me.pathHide = me.myiff == 1?me.iffU[me.iiii]:me.iff[me.iiii];
                  me.pathHide.hide();
                  me.path.setTranslation(me.echoPos[0],me.echoPos[1]-18);
                  me.path.show();
                  me.iiii += 1;
              }
          }
      },
    paintDL: func (contact) {
        if (contact.blue != 1) return;
        if (contact["iff"] != nil) {
            if (contact.iff > 0 and me.elapsed-contact.iff < 3.5) {
                me.myiff = 1;
            } elsif (contact.iff < 0 and me.elapsed+contact.iff < 3.5) {
                me.myiff = -1;
            } else {
                me.myiff = 0;
            }
        } else {
            me.myiff = 0;
        }

        me.blueBearing = geo.normdeg180(contact.getDeviationHeading());
        if (me.myiff == 0 and contact.isVisible() and contact.getRange()*M2NM < 125 and me.iii < me.maxT and math.abs(me.blueBearing) < 60) {
            me.distPixels = contact.get_range()*(me.radius/(radar_system.apy1Radar.getRange()));
            me.echoPos = me.calcPos(geo.normdeg180(me.blueBearing), me.distPixels);
            if (me.echoPos == nil) {
                return;
            }
            me.lnkT[me.iii].setColor(colorLightBlue);
            me.lnkT[me.iii].setTranslation(me.echoPos[0],me.echoPos[1]-25);
            me.lnkT[me.iii].setText(""~contact.blueIndex);
            me.lnkT[me.iii].show();
            me.lnkTA[me.iii].setColor(colorLightBlue);
            me.lnkTA[me.iii].setTranslation(me.echoPos[0],me.echoPos[1]+20);
            me.lnkTA[me.iii].setText(""~math.round(contact.getAltitude()*0.001));
            me.lnkTA[me.iii].show();
            me.lnk[me.iii].setColor(colorLightBlue);
            me.lnk[me.iii].setTranslation(me.echoPos);
            me.lnk[me.iii].setRotation(D2R*22.5*math.round( geo.normdeg(contact.get_heading()-radar_system.self.getHeading())/22.5 ));#Show rotation in increments of 22.5 deg
            me.lnk[me.iii].show();
            me.lnk[me.iii].update();
            if (contact.equalsFast(radar_system.apy1Radar.getPriorityTarget())) {
                me.selectShow = contact.getType() == radar_system.AIR;
                me.selection.setTranslation(me.echoPos);
                me.selection.setColor(colorLightBlue);
                me.printInfo(contact);
            } elsif (contact.equalsFast(radar_system.apy1Radar.currentMode.priorityTarget2)) {
                me.selectShow2 = contact.getType() == radar_system.AIR;
                me.selection.setTranslation(me.echoPos);
                me.selection.setColor(colorLightBlue);
                me.printInfo2(contact);
            }
            me.calcClick(contact, me.echoPos);
            me.iii += 1;
        } elsif (me.myiff != 0 and contact.isVisible() and me.iiii < me.maxT) {
            me.distPixels = contact.get_range()*(me.radius/(radar_system.apy1Radar.getRange()));
            me.echoPos = me.calcPos(geo.normdeg180(me.blueBearing), me.distPixels);
            if (me.echoPos == nil) {
                return;
            }
            me.path = me.myiff == -1?me.iffU[me.iiii]:me.iff[me.iiii];
            me.pathHide = me.myiff == 1?me.iffU[me.iiii]:me.iff[me.iiii];
            me.pathHide.hide();
            me.path.setTranslation(me.echoPos[0],me.echoPos[1]-18);
            me.path.show();

            me.iiii += 1;
        }
    },
    calcPos: func (dev, distPixels) {
        me.echoPosition = [distPixels*math.sin(D2R*dev), -distPixels*math.cos(D2R*dev)];
        return me.echoPosition;
    },
    calcClick: func (contact, echoPos) {
        if (cursor_screen != 0) {
            return;
        }
        if (cursor_type == 0) {
          if (math.abs(cursor_pos[0] - echoPos[0]) < 10 and math.abs(cursor_pos[1] - echoPos[1]) < 11) {
              me.desig_new = contact;
          }
        } elsif (cursor_type == 1) {
          if (math.abs(cursor_pos[0] - echoPos[0]) < 10 and math.abs(cursor_pos[1] - echoPos[1]) < 11) {
              me.desig_new2 = contact;
          }
        }
    },
    printInfo: func (contact) {
        if (contact.getLastHeading() != nil) {
            me.azimuth = math.round(geo.normdeg180(contact.get_bearing()-contact.getLastHeading())*0.1)*10;
            if (me.azimuth == 180 or me.azimuth == 0) {
                me.azSide = " ";
            } else {
                me.azSide = me.azimuth > 0 ?"L":"R";
            }
            me.azimuth = sprintf("AZ%3d%s", math.abs(me.azimuth), me.azSide);
            me.magn = geo.normdeg(contact.getLastHeading()+radar_system.self.getHeadingMag()-radar_system.self.getHeading());
            me.heady = sprintf("HEA%3d", int(me.magn/10)*10);
        } else {
            me.azimuth = "    ";
            me.heady = "   ";
        }
        if (contact.getLastClosureRate() != 0) {
            me.clos = sprintf("CLO%+5dK",math.round(contact.getLastClosureRate()*0.1)*10);
        } else {
            me.clos = "      ";
        }

        me.lockInfoText = sprintf("%s %s  %s  SPD%4d %s", contact.getModel(), me.azimuth, me.heady, contact.get_Speed(), me.clos);

        me.lockInfo.setText(me.lockInfoText);
        me.showLockInfo = 1;
    },
    printInfo2: func (contact) {
        if (contact.getLastHeading() != nil) {
            me.azimuth = math.round(geo.normdeg180(contact.get_bearing()-contact.getLastHeading())*0.1)*10;
            if (me.azimuth == 180 or me.azimuth == 0) {
                me.azSide = " ";
            } else {
                me.azSide = me.azimuth > 0 ?"L":"R";
            }
            me.azimuth = sprintf("AZ%3d%s", math.abs(me.azimuth), me.azSide);
            me.magn = geo.normdeg(contact.getLastHeading()+radar_system.self.getHeadingMag()-radar_system.self.getHeading());
            me.heady = sprintf("HEA%3d", int(me.magn/10)*10);
        } else {
            me.azimuth = "    ";
            me.heady = "   ";
        }
        if (contact.getLastClosureRate() != 0) {
            me.clos = sprintf("CLO%+5dK",math.round(contact.getLastClosureRate()*0.1)*10);
        } else {
            me.clos = "      ";
        }

        me.lockInfoText = sprintf("%s %s  %s  SPD%4d %s", contact.getModel(), me.azimuth, me.heady, contact.get_Speed(), me.clos);

        me.lockInfo2.setText(me.lockInfoText);
        me.showLockInfo2 = 1;
    },
    update: func {
        radar_system.apy1Radar.currentMode.setRange(getprop("instrumentation/mptcas/display-factor-awacs")*400);
        me.caretPosition = radar_system.apy1Radar.getCaretLinePosition();
        me.caretLine.setRotation(me.caretPosition[0]*D2R);#print(me.caretPosition[0]);
        me.compas1.setRotation(-radar_system.self.getHeading()*D2R);
        me.compas2.setRotation(-radar_system.self.getHeading()*D2R);
        me.elapsed = radar_system.elapsedProp.getValue();

        me.rangeInfo.setText(sprintf("  DISC: %3d NM  AZ %3d  EL %4.1f", radar_system.apy1Radar.getRange(),me.caretPosition[0],me.caretPosition[1]));

        me.desig_new = nil;
        me.desig_new2 = nil;
        me.ijk = 0;
        me.intercept = nil;
        me.showDLT = 0;
        me.prio = radar_system.apy1Radar.getPriorityTarget();
        me.tracks = [];
        me.selectShow = 0;
        me.selectShow2 = 0;
        me.showLockInfo = 0;
        me.showLockInfo2 = 0;
        me.i = 0;
        me.ii = 0;
        me.iii = 0;
        me.iiii = 0;
        me.randoo = rand();
        if (radar_system.datalink_power.getBoolValue()) {
            foreach(contact; vector_aicontacts_links) {
                if (contact["blue"] != 1) continue;
                me.paintDL(contact);
                contact.randoo = me.randoo;
            }
        }
        if (radar_system.apy1Radar.enabled) {
            foreach(var contact; radar_system.apy1Radar.getActiveBleps()) {
                if (contact["randoo"] == me.randoo) continue;

                me.paintRdr(contact);
                contact.randoo = me.randoo;
            }
        }
        if (radar_system.datalink_power.getBoolValue()) {
            foreach(contact; vector_aicontacts_links) {
                me.paintRdr(contact);
                contact.randoo = me.randoo;
            }
        }
        me.selection.setVisible(me.selectShow);
        me.selection2.setVisible(me.selectShow2);
        me.selection.update();
        me.selection2.update();
        me.lockInfo.setVisible(me.showLockInfo);
        me.lockInfo2.setVisible(me.showLockInfo2);
        for (;me.i < me.maxB;me.i+=1) {
            me.blep[me.i].hide();
        }
        for (;me.ii < me.maxT;me.ii+=1) {
            me.blepTriangle[me.ii].hide();
        }
        for (;me.iii < me.maxT;me.iii+=1) {
            me.lnk[me.iii].hide();
            me.lnkT[me.iii].hide();
            me.lnkTA[me.iii].hide();
        }
        for (;me.iiii < me.maxT;me.iiii+=1) {
            me.iff[me.iiii].hide();
            me.iffU[me.iiii].hide();
        }

        #
        # Intercept steering point for designated target
        #
        if (radar_system.apy1Radar.getPriorityTarget() != nil and radar_system.apy1Radar.currentMode.priorityTarget2 != nil) {
            me.from = radar_system.apy1Radar.getPriorityTarget();
            me.to   = radar_system.apy1Radar.currentMode.priorityTarget2;
            me.lastHead = me.to.getLastHeading();
            me.toSpeed = me.to.getLastSpeed();
            me.fromSpeed = me.from.getLastSpeed();
            if (me.fromSpeed != nil and me.toSpeed != nil and me.fromSpeed != 0 and me.toSpeed != 0 and me.lastHead != nil and me.from.getType() == radar_system.AIR and me.to.getType() == radar_system.AIR) {
                # we cheat a bit here with getting current properties:
                # bearingToRunner_deg, dist_m, runnerHeading_deg, runnerSpeed_mps, chaserSpeed_mps, chaserCoord, chaserHeading
                me.fromCoord = me.from.getLastCoord();
                me.toCoord = me.to.getLastCoord();
                me.bearingToRunner_deg = me.fromCoord.course_to(me.toCoord);
                me.dist_m              = me.fromCoord.distance_to(me.toCoord);

                me.intercept = get_intercept(
                  me.bearingToRunner_deg,
                  me.dist_m,
                  me.lastHead,
                  me.toSpeed*KT2MPS,
                  me.fromSpeed*KT2MPS,
                  me.fromCoord,
                  me.from.getLastHeading());
            }
        }
        if (me.intercept != nil) {
            me.interceptCoord = me.intercept[2];
            #me.interceptDist = me.intercept[3];
            me.fromCoord = radar_system.self.getCoord();
            me.dist_m    = me.fromCoord.distance_to(me.interceptCoord);
            me.course = me.fromCoord.course_to(me.interceptCoord);
            me.distPixels = me.dist_m*M2NM*(me.radius/radar_system.apy1Radar.getRange());
            me.echoPos = me.calcPos(geo.normdeg180(me.course - radar_system.self.getHeading()), me.distPixels);
            me.interceptCross.setTranslation(me.echoPos);
            me.interceptCross.setVisible(1);
            var mag_offset = getprop("/orientation/heading-magnetic-deg") - getprop("/orientation/heading-deg");
            me.txt = sprintf("Intercept: hdg %d magn. %.1f minutes", geo.normdeg(me.intercept[1]+mag_offset), me.intercept[0]/60);
            me.interceptText.setText(me.txt);
        } else {
            me.interceptText.setText("");
            me.interceptCross.setVisible(0);
        }

        if (cursor_screen == 0 and me.desig_new == nil and cursor_type == 0) {
            radar_system.apy1Radar.undesignate();
        } elsif (me.desig_new != nil) {
            radar_system.apy1Radar.designate(me.desig_new);
        }
        if (cursor_screen == 0 and me.desig_new2 == nil and cursor_type == 1) {
            radar_system.apy1Radar.currentMode.undesignate2();
        } elsif (me.desig_new2 != nil) {
            radar_system.apy1Radar.currentMode.designate2(me.desig_new2);
        }
        if (cursor_screen == 0) cursor_screen = -1;
        return;

    },
};



var diam = 512;
var cv = canvas.new({
                     "name": "E-3 RDR LEFT",
                     "size": [diam,diam], 
                     "view": [diam,diam],
                     "mipmapping": 1
                    });  

cv.addPlacement({"node": "canvas1", "texture":"radarblade.png"});

cv.setColorBackground(0.01, 0.105, 0);
var colorBackground = [0.01, 0.105, 0];

var root = cv.createGroup();
var rdr1 = RadarScreenLeft.new("RadarScreenLeft", root, [diam/2,diam/2],diam);




var vector_aicontacts_links = [];
var DLRecipient = emesary.Recipient.new("DLRecipient");
var startDLListener = func {
    DLRecipient.radar = radar_system.dlnkRadar;
    DLRecipient.Receive = func(notification) {
        if (notification.NotificationType == "DatalinkNotification") {
            #printf("DL recv: %s", notification.NotificationType);
            if (me.radar.enabled == 1) {
                vector_aicontacts_links = notification.vector;
            }
            return emesary.Transmitter.ReceiptStatus_OK;
        }
        return emesary.Transmitter.ReceiptStatus_NotProcessed;
    };
    emesary.GlobalTransmitter.Register(DLRecipient);
}

var get_intercept = func(bearingToRunner, dist_m, runnerHeading, runnerSpeed, chaserSpeed, chaserCoord, chaserHeading) {
    # from Leto
    # needs: bearingToRunner_deg, dist_m, runnerHeading_deg, runnerSpeed_mps, chaserSpeed_mps, chaserCoord, chaserHeading
    #        dist_m > 0 and chaserSpeed > 0

    if (dist_m < 500) {
        return nil;
    }

    var trigAngle = 90-bearingToRunner;
    var RunnerPosition = [dist_m*math.cos(trigAngle*D2R), dist_m*math.sin(trigAngle*D2R),0];
    var ChaserPosition = [0,0,0];

    var VectorFromRunner = vector.Math.minus(ChaserPosition, RunnerPosition);
    var runner_heading = 90-runnerHeading;
    var RunnerVelocity = [runnerSpeed*math.cos(runner_heading*D2R), runnerSpeed*math.sin(runner_heading*D2R),0];

    var a = chaserSpeed * chaserSpeed - runnerSpeed * runnerSpeed;
    var b = 2 * vector.Math.dotProduct(VectorFromRunner, RunnerVelocity);
    var c = -dist_m * dist_m;
    var dd = b*b-4*a*c;
    if (dd<0 or a == 0) {
      # intercept not possible
      return nil;
    }
#print(dd,"  sqrt:",math.sqrt(dd)," c:",c," b:",b," a:",a);
    var t1 = (-b+math.sqrt(dd))/(2*a);
    var t2 = (-b-math.sqrt(dd))/(2*a);

    if (t1 < 0 and t2 < 0) {
      # intercept not possible
      return nil;
    }

    var timeToIntercept = 0;
    if (t1 > 0 and t2 > 0) {
          timeToIntercept = math.min(t1, t2);
    } else {
          timeToIntercept = math.max(t1, t2);
    }

    # some feeble attempt to handle time being not a number:
    timeToIntercept = math.max(0.5, timeToIntercept);
    if (timeToIntercept < 1) {
          return nil;
    }
    


    var InterceptPosition = vector.Math.plus(RunnerPosition, vector.Math.product(timeToIntercept, RunnerVelocity));

    var ChaserVelocity = vector.Math.product(1/timeToIntercept, vector.Math.minus(InterceptPosition, ChaserPosition));
call(func{
    var interceptAngle = vector.Math.angleBetweenVectors([0,1,0], ChaserVelocity);
}, nil, nil, var err =[]);
    if (size(err)) {
      # If timeToIntercept is very big this will go into effect.
          return nil;
    }
    var interceptHeading = geo.normdeg(ChaserVelocity[0]<0?-interceptAngle:interceptAngle);

    var interceptDist = chaserSpeed*timeToIntercept;

    var interceptCoord = geo.Coord.new(chaserCoord);
    interceptCoord = interceptCoord.apply_course_distance(interceptHeading, interceptDist);
    var interceptRelativeBearing = geo.normdeg180(interceptHeading-chaserHeading);

    return [timeToIntercept, interceptHeading, interceptCoord, interceptDist, interceptRelativeBearing];
}

var timer = maketimer(0.05, func rdr1.update(););
timer.start();