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

var setCursor = func (x, y, screen) {
    cursor_pos = [x*diam - diam*0.5,-y*diam+diam*0.5];
    cursor_time = systime();
    cursor_screen = screen;
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
                .setColor(1,1,1)
                .setStrokeLineWidth(2);

        rdr1.lockInfo = rdr1.rootCenter.createChild("text")
                .setTranslation(-diam*0.25*1.5, diam*0.25)
                .setAlignment("left-center")
                .setColor(1,1,1)
                .set("z-index",1)
                .setFontSize(15, 1.0);
        rdr1.rangeInfo = rdr1.rootCenter.createChild("text")
                .setTranslation(-diam*0.25*1.5, diam*0.35)
                .setAlignment("left-center")
                .setColor(1,1,1)
                .set("z-index",1)
                .setFontSize(15, 1.0);

        rdr1.interceptCross = rdr1.rootCenter.createChild("path")
                            .moveTo(10,0)
                            .lineTo(-10,0)
                            .moveTo(0,-10)
                            .vert(20)
                            .setColor(1,1,1)
                            .set("z-index",14)
                            .setStrokeLineWidth(2);

        return rdr1;








        rdr1.inner_radius = radius*0.30;# field where inner IDs are placed
        rdr1.outer_radius = radius*0.65;# field where outer IDs are placed

        rdr1.sep1_radius = radius*0.300;
        rdr1.sep2_radius = radius*0.525;
        rdr1.sep3_radius = radius*0.775;

        rdr1.circle_radius_full = radius*0.974;
        rdr1.circle_radius_big = radius*0.5;
        rdr1.circle_radius_small = radius*0.125;
        var tick_long = radius*0.25;
        var tick_full = radius-rdr1.circle_radius_small;
        var tick_short = tick_long*0.5;
        var font = int(0.08*diameter);
        var colorG = [0.3,1,0.3];
        var colorLG = [0.16,0.8,0.13];
        var colorBG = [0.4,0.48,0.4];
        rdr1.stroke = 2;
        rdr1.fadeTime = 7;#seconds
        rdr1.rootCenter = root.createChild("group")
                .setTranslation(center[0],center[1])
                .set("font","B612/B612Mono-Bold.ttf");
        
#        root.createChild("path")
#           .moveTo(0, diameter/2)
#           .arcSmallCW(diameter/2, diameter/2, 0, diameter, 0)
#           .arcSmallCW(diameter/2, diameter/2, 0, -diameter, 0)
#           .setStrokeLineWidth(rdr1.stroke*1.8)
#           .setColor(1, 1, 1);
        root.createChild("path")# inner circle
           .moveTo(diameter/2-rdr1.circle_radius_small, diameter/2)
           .arcSmallCW(rdr1.circle_radius_small, rdr1.circle_radius_small, 0, rdr1.circle_radius_small*2, 0)
           .arcSmallCW(rdr1.circle_radius_small, rdr1.circle_radius_small, 0, -rdr1.circle_radius_small*2, 0)
           .setStrokeLineWidth(rdr1.stroke*1.8)
           .setColor(colorBG);
        root.createChild("path")# outer circle
           .moveTo(diameter/2-rdr1.circle_radius_big, diameter/2)
           .arcSmallCW(rdr1.circle_radius_big, rdr1.circle_radius_big, 0, rdr1.circle_radius_big*2, 0)
           .arcSmallCW(rdr1.circle_radius_big, rdr1.circle_radius_big, 0, -rdr1.circle_radius_big*2, 0)
           .setStrokeLineWidth(rdr1.stroke*1.8)
           .setColor(colorBG);
        root.createChild("path")# full circle
           .moveTo(diameter/2-rdr1.circle_radius_full, diameter/2)
           .arcSmallCW(rdr1.circle_radius_full, rdr1.circle_radius_full, 0, rdr1.circle_radius_full*2, 0)
           .arcSmallCW(rdr1.circle_radius_full, rdr1.circle_radius_full, 0, -rdr1.circle_radius_full*2, 0)
           .setStrokeLineWidth(rdr1.stroke*1.8)
           .setColor(colorBG);
        root.createChild("path")#middle cross
           .moveTo(diameter/2-rdr1.circle_radius_small, diameter/2)
           .horiz(rdr1.circle_radius_small/2)
           .moveTo(diameter/2+rdr1.circle_radius_small, diameter/2)
           .horiz(-rdr1.circle_radius_small/2)
           .moveTo(diameter/2, diameter/2-rdr1.circle_radius_small)
           .vert(rdr1.circle_radius_small*0.5)
           .moveTo(diameter/2, diameter/2+rdr1.circle_radius_small)
           .vert(-rdr1.circle_radius_small*0.5)
           .setStrokeLineWidth(rdr1.stroke*2.1)
           .setColor(colorLG);
        rdr1.noisebar = root.createChild("path")#middle cross moving tick
           .moveTo(diameter/2+rdr1.circle_radius_small*0.5, diameter/2)
           .vert(-rdr1.circle_radius_small*0.25)
           .setStrokeLineWidth(rdr1.stroke*2.1)
           .setColor(colorLG);
        root.createChild("path")# 4 main ticks
           .moveTo(0,diameter*0.5)
           .horiz(tick_full)
           .moveTo(diameter,diameter*0.5)
           .horiz(-tick_full)
           .moveTo(diameter*0.5,0)
           .vert(tick_full)
           .moveTo(diameter*0.5,diameter)
           .vert(-tick_full)
           .setStrokeLineWidth(rdr1.stroke*1.8)
           .setColor(colorBG);
        rdr1.rootCenter.createChild("path")# minor ticks
           .moveTo(radius*math.cos(30*D2R),radius*math.sin(-30*D2R))
           .lineTo((radius-tick_short)*math.cos(30*D2R),(radius-tick_short)*math.sin(-30*D2R))
           .moveTo(radius*math.cos(15*D2R),radius*math.sin(-15*D2R))
           .lineTo((radius-tick_short)*math.cos(15*D2R),(radius-tick_short)*math.sin(-15*D2R))
           .moveTo(radius*math.cos(45*D2R),radius*math.sin(-45*D2R))
           .lineTo((radius-tick_long)*math.cos(45*D2R),(radius-tick_long)*math.sin(-45*D2R))
           .moveTo(radius*math.cos(60*D2R),radius*math.sin(-60*D2R))
           .lineTo((radius-tick_short)*math.cos(60*D2R),(radius-tick_short)*math.sin(-60*D2R))
           .moveTo(radius*math.cos(75*D2R),radius*math.sin(-75*D2R))
           .lineTo((radius-tick_short)*math.cos(75*D2R),(radius-tick_short)*math.sin(-75*D2R))
           
           .moveTo(radius*math.cos(30*D2R),radius*math.sin(30*D2R))
           .lineTo((radius-tick_short)*math.cos(30*D2R),(radius-tick_short)*math.sin(30*D2R))
           .moveTo(radius*math.cos(15*D2R),radius*math.sin(15*D2R))
           .lineTo((radius-tick_short)*math.cos(15*D2R),(radius-tick_short)*math.sin(15*D2R))
           .moveTo(radius*math.cos(45*D2R),radius*math.sin(45*D2R))
           .lineTo((radius-tick_long)*math.cos(45*D2R),(radius-tick_long)*math.sin(45*D2R))
           .moveTo(radius*math.cos(60*D2R),radius*math.sin(60*D2R))
           .lineTo((radius-tick_short)*math.cos(60*D2R),(radius-tick_short)*math.sin(60*D2R))
           .moveTo(radius*math.cos(75*D2R),radius*math.sin(75*D2R))
           .lineTo((radius-tick_short)*math.cos(75*D2R),(radius-tick_short)*math.sin(75*D2R))

           .moveTo(-radius*math.cos(30*D2R),radius*math.sin(-30*D2R))
           .lineTo(-(radius-tick_short)*math.cos(30*D2R),(radius-tick_short)*math.sin(-30*D2R))
           .moveTo(-radius*math.cos(15*D2R),radius*math.sin(-15*D2R))
           .lineTo(-(radius-tick_short)*math.cos(15*D2R),(radius-tick_short)*math.sin(-15*D2R))
           .moveTo(-radius*math.cos(45*D2R),radius*math.sin(-45*D2R))
           .lineTo(-(radius-tick_long)*math.cos(45*D2R),(radius-tick_long)*math.sin(-45*D2R))
           .moveTo(-radius*math.cos(60*D2R),radius*math.sin(-60*D2R))
           .lineTo(-(radius-tick_short)*math.cos(60*D2R),(radius-tick_short)*math.sin(-60*D2R))
           .moveTo(-radius*math.cos(75*D2R),radius*math.sin(-75*D2R))
           .lineTo(-(radius-tick_short)*math.cos(75*D2R),(radius-tick_short)*math.sin(-75*D2R))
           
           .moveTo(-radius*math.cos(30*D2R),radius*math.sin(30*D2R))
           .lineTo(-(radius-tick_short)*math.cos(30*D2R),(radius-tick_short)*math.sin(30*D2R))
           .moveTo(-radius*math.cos(15*D2R),radius*math.sin(15*D2R))
           .lineTo(-(radius-tick_short)*math.cos(15*D2R),(radius-tick_short)*math.sin(15*D2R))
           .moveTo(-radius*math.cos(45*D2R),radius*math.sin(45*D2R))
           .lineTo(-(radius-tick_long)*math.cos(45*D2R),(radius-tick_long)*math.sin(45*D2R))
           .moveTo(-radius*math.cos(60*D2R),radius*math.sin(60*D2R))
           .lineTo(-(radius-tick_short)*math.cos(60*D2R),(radius-tick_short)*math.sin(60*D2R))
           .moveTo(-radius*math.cos(75*D2R),radius*math.sin(75*D2R))
           .lineTo(-(radius-tick_short)*math.cos(75*D2R),(radius-tick_short)*math.sin(75*D2R))
           .setStrokeLineWidth(rdr1.stroke*1.8)
           .setColor(colorBG);
        rdr1.texts = setsize([],rdr1.max_icons);# aircraft ID
        for (var i = 0;i<rdr1.max_icons;i+=1) {
            rdr1.texts[i] = rdr1.rootCenter.createChild("text")
                .setText("00")
                .setAlignment("center-center")
                .setColor(colorG)
                .setFontSize(font, 1)
                .hide();

        }
        rdr1.symbol_hat = setsize([],rdr1.max_icons);# airborne symbol over ID
        for (var i = 0;i<rdr1.max_icons;i+=1) {
            rdr1.symbol_hat[i] = rdr1.rootCenter.createChild("path")
                    .moveTo(0,-font)
                    .lineTo(font*0.7,-font*0.5)
                    .moveTo(0,-font)
                    .lineTo(-font*0.7,-font*0.5)
                    .setStrokeLineWidth(rdr1.stroke*1.2)
                    .setColor(colorG)
                    .hide();
        }

 #       me.symbol_16_SAM = setsize([],max_icons);
#       for (var i = 0;i<max_icons;i+=1) {
 #          me.symbol_16_SAM[i] = me.rootCenter.createChild("path")
#                   .moveTo(-11, 7)
#                   .lineTo(-9, -7)
#                   .moveTo(-9, -7)
#                   .lineTo(-9, -4)
#                   .moveTo(-9, -8)
#                   .lineTo(-11, -4)
#                   .setStrokeLineWidth(rdr1.stroke*1)
#                   .setColor(1,0,0)
#                   .hide();
#        }
        rdr1.symbol_launch = setsize([],rdr1.max_icons);
        for (var i = 0;i<rdr1.max_icons;i+=1) {
            rdr1.symbol_launch[i] = rdr1.rootCenter.createChild("path")
                    .moveTo(font*1.2, 0)
                    .arcSmallCW(font*1.2, font*1.2, 0, -font*2.4, 0)
                    .arcSmallCW(font*1.2, font*1.2, 0, font*2.4, 0)
                    .setStrokeLineWidth(rdr1.stroke*1.2)
                    .setColor(colorG)
                    .hide();
        }
        rdr1.symbol_new = setsize([],rdr1.max_icons);
        for (var i = 0;i<rdr1.max_icons;i+=1) {
            rdr1.symbol_new[i] = rdr1.rootCenter.createChild("path")
                    .moveTo(font*1.2, 0)
                    .arcSmallCCW(font*1.2, font*1.2, 0, -font*2.4, 0)
                    .setStrokeLineWidth(rdr1.stroke*1.2)
                    .setColor(colorG)
                    .hide();
        }
#        rdr1.symbol_16_lethal = setsize([],max_icons);
#        for (var i = 0;i<max_icons;i+=1) {
#           rdr1.symbol_16_lethal[i] = rdr1.rootCenter.createChild("path")
#                   .moveTo(10, 10)
#                   .lineTo(10, -10)
#                   .lineTo(-10,-10)
#                   .lineTo(-10,10)
#                   .lineTo(10, 10)
#                   .setStrokeLineWidth(rdr1.stroke*1)
#                   .setColor(1,0,0)
#                   .hide();
#        }
        rdr1.symbol_priority = rdr1.rootCenter.createChild("path")
                    .moveTo(0, font*1.2)
                    .lineTo(font*1.2, 0)
                    .lineTo(0,-font*1.2)
                    .lineTo(-font*1.2,0)
                    .lineTo(0, font*1.2)
                    .setStrokeLineWidth(rdr1.stroke*1.2)
                    .setColor(colorG)
                    .hide();
        rdr1.symbol_maw = rdr1.rootCenter.createChild("path")
                    .moveTo(0,-font*1.2)
                    .lineTo(font*0.2, -font*1.0)
                    .vert(font*2)
                    .horiz(-font*0.4)
                    .vert(-font*2)
                    .lineTo(0,-font*1.2)
                    .setStrokeLineWidth(rdr1.stroke*1.2)
                    .setColor(colorG)
                    .hide();
                    
        
#        rdr1.symbol_16_air = setsize([],max_icons);
#        for (var i = 0;i<max_icons;i+=1) {
#           rdr1.symbol_16_air[i] = rdr1.rootCenter.createChild("path")
#                   .moveTo(15, 0)
#                   .lineTo(0,-15)
#                   .lineTo(-15,0)
#                   .setStrokeLineWidth(rdr1.stroke*1)
#                   .setColor(1,0,0)
#                   .hide();
#        }

        rdr1.shownList = [];
        #
        # recipient that will be registered on the global transmitter and connect this
        # subsystem to allow subsystem notifications to be received
        rdr1.recipient = emesary.Recipient.new(_ident);
        rdr1.recipient.parent_obj = rdr1;

        rdr1.recipient.Receive = func(notification)
        {
            if (notification.NotificationType == "FullNotification")
            {
                me.parent_obj.update(radar_system.f16_rdr1.vector_aicontacts_threats, "normal");
                return emesary.Transmitter.ReceiptStatus_OK;
            }
            return emesary.Transmitter.ReceiptStatus_NotProcessed;
        };
        emesary.GlobalTransmitter.Register(rdr1.recipient);
        
        rdr1.noiseup = 10;
        return rwr;
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
              if (me.i < me.maxB and me.elapsed - me.bleppy.getBlepTime() < radar_system.apy1Radar.currentMode.timeToFadeBleps and me.bleppy.getDirection() != nil and (radar_system.apy1Radar.currentMode.longName != radar_system.vsMode.longName or (me.bleppy.getClosureRate() != nil and me.bleppy.getClosureRate()>0))) {
                  if (me.bleppy.getClosureRate() != nil and radar_system.apy1Radar.currentMode.longName == radar_system.vsMode.longName) {
                      me.distPixels = math.min(950, me.bleppy.getClosureRate())*(482/(1000));
                  } else {
                      me.distPixels = me.bleppy.getRangeNow()*(me.radius/(radar_system.apy1Radar.getRange()*NM2M));
                  }
                  me.echoPos = me.calcPos(geo.normdeg180(me.bleppy.getAZDeviation()), me.distPixels);
#                  me.echoPos = me.calcEXPPos(me.echoPos);
                  if (me.echoPos == nil) {
                      continue;
                  }
                  me.color = math.pow(1-(me.elapsed - me.bleppy.getBlepTime())/radar_system.apy1Radar.currentMode.timeToFadeBleps, 2.2);
                  me.blep[me.i].setTranslation(me.echoPos);
                  me.blep[me.i].setColor(colorWhite[0]*me.color+colorBackground[0]*(1-me.color), colorWhite[1]*me.color+colorBackground[1]*(1-me.color), colorWhite[2]*me.color+colorBackground[2]*(1-me.color));
                  me.blep[me.i].show();
                  me.blep[me.i].update();
                  if (contact.equalsFast(radar_system.apy1Radar.getPriorityTarget()) and me.bleppy == me.bleps[size(me.bleps)-1]) {
                      me.selectShowTemp = radar_system.apy1Radar.currentMode.longName != radar_system.twsMode.longName or (me.elapsed - contact.getLastBlepTime() < radar_system.F16TWSMode.timeToBlinkTracks) or (math.mod(me.elapsed,0.50)<0.25);
                      me.selectShow = me.selectShowTemp and contact.getType() == radar_system.AIR;
                      me.selection.setTranslation(me.echoPos);
                      me.selection.setColor(colorWhite);
                      me.printInfo(contact);
                      me.showLockInfo = 1;
                  }
                  if (me.elapsed - me.bleppy.getBlepTime() < radar_system.apy1Radar.currentMode.timeToFadeBleps) {
                      me.calcClick(contact, me.echoPos);
                  }
                  me.i += 1;
              }
          }
          me.sizeBleps = size(me.bleps);
          if (contact["blue"] != 1 and me.ii < me.maxT and ((me.sizeBleps and contact.hadTrackInfo()) or contact["blue"] == 2) and me.myiff == 0 and radar_system.apy1Radar.currentMode.longName != radar_system.vsMode.longName) {
              # Paint bleps with tracks
              if (contact["blue"] != 2) me.bleppy = me.bleps[me.sizeBleps-1];
              if (contact["blue"] == 2 or (me.bleppy.hasTrackInfo() and me.elapsed - me.bleppy.getBlepTime() < radar_system.apy1Radar.timeToKeepBleps)) {
                  me.color = contact["blue"] == 2?colorLightBlue:colorRed;
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
                  me.rot = 22.5*math.round((me.c_heading-radar_system.self.getHeading()-me.c_devheading)/22.5);
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
                  me.blinkShow = radar_system.apy1Radar.currentMode.longName != radar_system.twsMode.longName or (me.elapsed - contact.getLastBlepTime() < radar_system.F16TWSMode.timeToBlinkTracks) or (math.mod(me.elapsed,0.50)<0.25);
                  if (contact.equalsFast(radar_system.apy1Radar.getPriorityTarget())) {
                      me.selectShow = me.blinkShow and contact.getType() == radar_system.AIR;
                      me.blepTriangle[me.ii].setVisible(me.selectShow);
                      me.selection.setTranslation(me.echoPos);
                      me.selection.setColor(me.color);
                      me.printInfo(contact);
                      me.showLockInfo = 1;
                  }
                  me.blepTriangle[me.ii].setVisible(me.blinkShow and contact.getType() == radar_system.AIR);
                  me.blepTriangle[me.ii].update();
                  me.calcClick(contact, me.echoPos);

                  me.ii += 1;
              }
          } elsif (me.myiff != 0 and contact["blue"] != 1 and contact.isVisible() and me.iiii < me.maxT and me.sizeBleps and radar_system.apy1Radar.currentMode.longName != radar_system.vsMode.longName) {
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
    calcPos: func (dev, distPixels) {
        me.echoPosition = [distPixels*math.sin(D2R*dev), -distPixels*math.cos(D2R*dev)];
        return me.echoPosition;
    },
    calcClick: func (contact, echoPos) {
        if (cursor_screen != 0) {
            return;
        }
        if (math.abs(cursor_pos[0] - echoPos[0]) < 10 and math.abs(cursor_pos[1] - echoPos[1]) < 11) {
            me.desig_new = contact;
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
            me.clos = sprintf("CLO%+4dK",math.round(contact.getLastClosureRate()*0.1)*10);
        } else {
            me.clos = "      ";
        }

        me.lockInfoText = sprintf("%s     %s     SPD%4d   %s", me.azimuth, me.heady, contact.get_Speed(), me.clos);

        me.lockInfo.setText(me.lockInfoText);
        me.showLockInfo = 1;
    },
    update: func {
        me.caretPosition = radar_system.apy1Radar.getCaretLinePosition();
        me.caretLine.setRotation(me.caretPosition[0]*D2R);#print(me.caretPosition[0]);
        me.elapsed = radar_system.elapsedProp.getValue();

        me.rangeInfo.setText(sprintf("RANGE: %3d NM", radar_system.apy1Radar.getRange()));

        me.desig_new = nil;
        me.ijk = 0;
        me.intercept = nil;
        me.showDLT = 0;
        me.prio = radar_system.apy1Radar.getPriorityTarget();
        me.tracks = [];
        me.selectShow = 0;
        me.showLockInfo = 0;
        me.i = 0;
        me.ii = 0;
        me.iii = 0;
        me.iiii = 0;
        me.randoo = rand();
        foreach(var contact; radar_system.apy1Radar.getActiveBleps()) {
            if (contact["randoo"] == me.randoo) continue;

            me.paintRdr(contact);
            contact.randoo = me.randoo;
        }
        me.selection.setVisible(me.selectShow);
        me.selection.update();
        me.lockInfo.setVisible(me.showLockInfo);
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
        if (cursor_screen == 0 and me.desig_new == nil) {
            radar_system.apy1Radar.undesignate();
        } elsif (me.desig_new != nil) {
            radar_system.apy1Radar.designate(me.desig_new);
        }
        if (cursor_screen == 0) cursor_screen = -1;
        return;




















        if (me.noiseup == 10) {
            me.noisebar.setTranslation(0,me.circle_radius_small*0.25);
        } elsif (me.noiseup == 1) {
            me.noisebar.setTranslation(0,0);
        }
        me.noiseup += 1;
        if (me.noiseup > 20) me.noiseup = 1;
#        printf("list %d type %s", size(list), type);
        me.sep = getprop("instrumentation/radar/rwr-separate");
        me.showUnknowns = 1;#getprop("f16/ews/rwr-show-unknowns");
        me.pri5 = 0;#getprop("f16/ews/rwr-show-priority-only");
        me.elapsed = getprop("sim/time/elapsed-sec");
        me.semiCallsign = getprop("payload/armament/MAW-semiactive-callsign");
        me.launchCallsign = "";#getprop("sound/rwr-launch");
        if (me.launchCallsign == "" or me.launchCallsign == nil) {
            me.launchCallsign = "-........-";
        }
        if (me.semiCallsign == "" or me.semiCallsign == nil) {
            me.semiCallsign = "-........-";
        }
        var sorter = func(a, b) {
            if(a[1] > b[1]){
                return -1; # A should before b in the returned vector
            }elsif(a[1] == b[1]){
                return 0; # A is equivalent to b 
            }else{
                return 1; # A should after b in the returned vector
            }
        }
        

        #list ~= test_list;# Uncomment this line to test the RWR display.

        me.sortedlist = sort(list, sorter);

        me.sep_spots = [[0,0,0,0,0,0,0,0],#45 degs  8
                        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],# 20 degs  18
                        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]];# 15 degs  24
        me.sep_angles = [45,20,15];

        me.newList = [];
        me.i = 0;
        me.prio = 0;
        me.newsound = 0;
        me.priCount = 0;
        me.priFlash = 0;# Flash the PRI light
        me.unkFlash = 0;# Flash the UNK light
        foreach(me.contact; me.sortedlist) {
            me.typ=me.lookupType[me.contact[0].getModel()];
            if (me.i > me.max_icons-1) {
                break;
            }
            if (me.typ == nil) {
                me.typ = me.AIRCRAFT_UNKNOWN;
                if (!me.showUnknowns) {
                  me.unkFlash = 1;
                  continue;
                }
            }
            if (me.typ == me.ASSET_AI) {
                if (!me.showUnknowns) {
                  #me.unkFlash = 1; # We don't flash for AI, that would just be distracting
                  continue;
                }
            }
            #print("show "~me.i~" "~me.typ~" "~contact[0].getModel()~"  "~contact[1]);

            if (me.contact[0].get_range() > 150) {
                continue;
            }

            me.threat = me.contact[1];#print(me.threat);

            if (me.threat <= 0) {
                continue;
            }

            if (me.pri5 and me.priCount >= 5) {
                me.priFlash = 1;
                continue;
            }
            me.priCount += 1;

            

            if (!me.sep) {
            
                if (me.threat > 0.5 and me.typ != me.AIRCRAFT_UNKNOWN and me.typ != me.AIRCRAFT_SEARCH) {
                    me.threat = me.inner_radius;# inner circle
                } else {
                    me.threat = me.outer_radius;# outer circle
                }
            
                me.dev = -me.contact[2]+90;
            } else {
                me.dev = -me.contact[2]+90;

                if (me.threat > 0.5 and me.typ != me.AIRCRAFT_UNKNOWN and me.typ != me.AIRCRAFT_SEARCH) {
                    me.threat = 0;
                } elsif (me.threat > 0.25) {
                    me.threat = 1;
                } else {
                    me.threat = 2;
                }
                me.assignSepSpot();
            }




            me.x = math.cos(me.dev*D2R)*me.threat;
            me.y = -math.sin(me.dev*D2R)*me.threat;
            me.texts[me.i].setTranslation(me.x,me.y);
            me.texts[me.i].setText(me.typ);
            me.texts[me.i].show();
            
            if (me.prio == 0 and me.typ != me.ASSET_AI and me.typ != me.AIRCRAFT_UNKNOWN and me.typ != me.AIRCRAFT_SEARCH) {# 
                me.symbol_priority.setTranslation(me.x,me.y);
                me.symbol_priority.show();
                me.prio = 1;
            }
            if (!(me.typ == me.ASSET_GARGOYLE or me.typ == me.ASSET_AAA or me.typ == me.ASSET_VOLGA or me.typ == me.ASSET_2K12 or me.typ == me.ASSET_BUK or me.typ == me.ASSET_PAC2 or me.typ == me.ASSET_FRIGATE) and me.contact[0].get_Speed()>60) {
                #air-borne
                me.symbol_hat[me.i].setTranslation(me.x,me.y);
                me.symbol_hat[me.i].show();
            } else {
                me.symbol_hat[me.i].hide();
            }
            if ((me.contact[0].get_Callsign()==me.launchCallsign or me.contact[0].get_Callsign()==me.semiCallsign) and 5*(me.elapsed-int(me.elapsed))>2.5) {#blink 4Hz
                me.symbol_launch[me.i].setTranslation(me.x,me.y);
                me.symbol_launch[me.i].show();
            } else {
                me.symbol_launch[me.i].hide();
            }
            me.popupNew = me.elapsed;
            foreach(me.old; me.shownList) {
                if(me.contact[0]["test"] == 1 or me.old[0]["test"] == 1) {
                    # this is just to handle the test cases if you uncomment them
                    if (me.old[0].get_Callsign() == me.contact[0].get_Callsign()) {
                      me.popupNew = me.old[1];
                      break;
                    }
                } elsif(me.contact[0].equals(me.old[0])) {
                    me.popupNew = me.old[1];
                    break;
                }
            }
            if (me.popupNew == me.elapsed) {
                me.newsound = 1;
            }
            if (me.popupNew > me.elapsed-me.fadeTime) {
                me.symbol_new[me.i].setTranslation(me.x,me.y);
                me.symbol_new[me.i].show();
                me.symbol_new[me.i].update();
            } else {
                me.symbol_new[me.i].hide();
            }
            #printf("display %s %d",contact[0].get_Callsign(), me.threat);
            append(me.newList, [me.contact[0],me.popupNew]);
            me.i += 1;
        }
        me.shownList = me.newList;
        for (;me.i<me.max_icons;me.i+=1) {
            me.texts[me.i].hide();
            me.symbol_hat[me.i].hide();
            me.symbol_new[me.i].hide();
            me.symbol_launch[me.i].hide();
        }
        if (me.prio == 0) {
            me.symbol_priority.hide();
        }
        if (me.newsound == 1) setprop("sound/rwr-new", !getprop("sound/rwr-new"));
        setprop("f16/ews/rwr-pri", me.pri5 and (!me.priFlash or math.mod(me.noiseup, 5) < 2.5));        # PRI light 
        setprop("f16/ews/rwr-unk", me.showUnknowns or (me.unkFlash and math.mod(me.noiseup, 5) < 2.5)); # UNK light
        
        if (getprop("payload/armament/MAW-active")) {
          me.mawdegs = getprop("payload/armament/MAW-bearing");
          me.dev = -geo.normdeg180(me.mawdegs-getprop("orientation/heading-deg"))+90;
          me.x = math.cos(me.dev*D2R)*(me.inner_radius+me.outer_radius)*0.5;
          me.y = -math.sin(me.dev*D2R)*(me.inner_radius+me.outer_radius)*0.5;
          me.symbol_maw.setRotation(-(me.dev+90)*D2R);
          me.symbol_maw.setTranslation(me.x, me.y);
          me.symbol_maw.show();
        } else {
          me.symbol_maw.hide();
        }
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

var timer = maketimer(0.05, func rdr1.update(););
timer.start();