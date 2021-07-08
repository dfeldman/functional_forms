$fn=200;

WIDTH=100;
HEIGHT=30;
N_HOLDERS=5;
HOLDER_DEPTH=30;
DEPTH=N_HOLDERS*HOLDER_DEPTH;

EXT_THICKNESS=4;
INT_THICKNESS=4;
GAP=1;
BACK_THICKNESS=1;
INT_BACK_THICKNESS=1;
INT_FRONT_THICKNESS=1;
HOLDER_HEIGHT=20;
HOLDER_OFFSET=5;
HOLDER_WIDTH=5;
HOLDER_THICKNESS=10;
HOLDER_NOTCH=4;
HOLDER_NOTCH_HEIGHT=3;
BAR_WIDTH=5;
BAR_HEIGHt=10;
// 1 for outer case, 2 for interior, 3 for both
OBJECT=3;



module shell(w, h, d) {
     union() {
        translate([h/2,0,0]) rotate([90,0,0]) cylinder(h=d,r=h/2);
        translate([h/2,-d,-h/2]) cube([w,d,h]);
        translate([w+h/2,0,0]) rotate([90,0,0]) cylinder(h=d,r=h/2);
    }
}

module exterior() {
    difference() {
        shell(WIDTH,HEIGHT,DEPTH+BACK_THICKNESS);
        translate([EXT_THICKNESS,0,0]) shell(WIDTH-EXT_THICKNESS,HEIGHT-EXT_THICKNESS,DEPTH);
    }
}

module interior_tray() {
    difference() {
       shell(WIDTH-EXT_THICKNESS-GAP,HEIGHT-EXT_THICKNESS-GAP,DEPTH);
       translate([INT_THICKNESS, -INT_FRONT_THICKNESS ,0]) 
           shell(WIDTH-EXT_THICKNESS-INT_THICKNESS-GAP, HEIGHT-EXT_THICKNESS-INT_THICKNESS-GAP, DEPTH-INT_FRONT_THICKNESS-INT_BACK_THICKNESS);
       translate([HEIGHT/2,-DEPTH+INT_BACK_THICKNESS,-HEIGHT/2+INT_THICKNESS]) cube([WIDTH-EXT_THICKNESS-INT_THICKNESS,DEPTH-INT_FRONT_THICKNESS-INT_BACK_THICKNESS,HEIGHT-EXT_THICKNESS]);
    }
}

module interior_holders() {
    for (i = [1:N_HOLDERS]) {
        translate([0,-i*HOLDER_DEPTH+HOLDER_OFFSET,0]) 
            union() {
            difference() {
                cube([HOLDER_WIDTH,HOLDER_THICKNESS,HOLDER_HEIGHT]);
                translate([0,(HOLDER_THICKNESS-HOLDER_NOTCH)/2,HOLDER_HEIGHT-HOLDER_NOTCH_HEIGHT]) cube([HOLDER_WIDTH,HOLDER_NOTCH,HOLDER_NOTCH_HEIGHT]);
            }
        }
    }
}

module interior() {
    full_width=WIDTH-EXT_THICKNESS-GAP+HEIGHT;
    union() {
        interior_tray();
        translate([full_width/2-HOLDER_WIDTH/2, 0,-(HEIGHT-EXT_THICKNESS-GAP)/2]) 
        union() {
            interior_holders();
            translate([-BAR_WIDTH/4,-DEPTH,0]) cube([10,DEPTH,BAR_WIDTH]);
        }
    }
    
}

module glasses_case() {
    if (OBJECT==1) {
        exterior();
    } else if (OBJECT==2) {
        interior();
    } else if (OBJECT==4) {
        interior_holders();
    } else {
        translate([EXT_THICKNESS,0,0]) interior();
        exterior();
    }
}

glasses_case();