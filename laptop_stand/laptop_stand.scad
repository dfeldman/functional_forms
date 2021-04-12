$fn=100;

WIDTH=100;
DEPTH=200;

// The thickness of the side of the object
SIDE_THICKNESS=10;

// The thickness of the bottom of the object. 
BOTTOM_THICKNESS=3;

// The ratio of the outer diameter to the inner diameter (unitless, should be >1)
EDGE_THICKNESS=1.2; 

// Sizes of each of the device slots 
SLOTS=[24, 18.5, 18.5, 16, 9.5, 25];

// Space between each slot 
SLOT_SPACER=20;

// The "table grip" is the part that holds it fast to the table
// If the thickness is correct for your table, it will hold on without any 
// fasteners. There's also a screw hole if needed. 

// Thickness of the table
TABLE_THICKNESS=32;

// Width of the bottom part of the table grip that holds it against the bottom of 
// your table
TABLE_GRIP_WIDTH=30;

// Depth of the table grip
TABLE_GRIP_DEPTH=100;

// Thickness of the bottom and side walls of the table grip
TABLE_GRIP_THICKNESS=3;

// Radius of the screw hole in the bottom of the table grip
SCREW_HOLE_RADIUS=1.5;

// One quadrant of a 100mm diameter sphere, with the front 50mm chopped off, 
// which is the overall shape of the object
module spheresec() {
    difference() {
        sphere(r=100);
        //bottom
        translate([-100,-100,-200]) cube(size=200);
        //left
        translate([-100,-200,0]) cube(size=200);
        //back
        translate([0,0,0]) cube(size=200);
        //right
        translate([-100,50,0]) cube(size=200);
    }
}

// Make the sphere quadrant into a stretched, hollow shell
module shell() {
    difference() {
        scale([1, DEPTH/50,1]) spheresec();
        translate([-SIDE_THICKNESS,0,BOTTOM_THICKNESS]) 
            scale([0.7, DEPTH/50, 1/EDGE_THICKNESS])  spheresec();
    }
}

// Slots for devices
module upper() {
    difference() {
        shell();
        slots(SLOTS,20);
    }
}

// Recursive function that actually creates the slots
// Because the Y position of each slot is actually based on the previous
// slot, this has to be a recursive function. 
module slots(lst, y) {
    translate([-1000,y,BOTTOM_THICKNESS]) cube([2000, lst[0], 2000]);
    if (len(lst)>1) { 
        slots([for (i = [1:(len(lst)-1)]) lst[i]],
            y + lst[0] + SLOT_SPACER); 
    }
}

// Grippy part that holds on to the desk (with screw hole)
module lower() {
    difference() {
        translate([-TABLE_GRIP_DEPTH, 0, -TABLE_THICKNESS]) 
            cube([TABLE_GRIP_DEPTH, TABLE_GRIP_WIDTH, TABLE_THICKNESS]);
        translate([-TABLE_GRIP_DEPTH, 
                    TABLE_GRIP_THICKNESS, 
                   -(TABLE_THICKNESS-TABLE_GRIP_THICKNESS)]) 
            cube([TABLE_GRIP_DEPTH, 
                  TABLE_GRIP_WIDTH, 
                  TABLE_THICKNESS - TABLE_GRIP_THICKNESS]);
    }
}

// Screw hole on the grip if needed
module screw_hole() {
        translate([-TABLE_GRIP_DEPTH/2,
                TABLE_GRIP_WIDTH/2,
                -(TABLE_THICKNESS)]) 
                cylinder(r=SCREW_HOLE_RADIUS, h=TABLE_GRIP_THICKNESS);
}

// Combine the upper and lower parts
union(){
    upper();
    difference() {
        lower();
        screw_hole();
    }
}
