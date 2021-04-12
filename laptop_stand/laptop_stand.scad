$fn=100;

// One quadrant of a sphere, which is the overall shape of the object
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

module shell() {
difference() {
    scale([1,1.4,1.2]) spheresec();
    scale([0.7, 1.4, 1]) translate([-10,0,10]) spheresec();
}
}
module upper() {
difference() {
    scale([1,2.3,.7]) shell();
    holders([24, 18.5, 18.5, 16, 9.5, 25],20);
}
}

module holders(lst, y) {
    echo(lst[0]);
    echo(y);
    x=len(lst);
    
    translate([-100,y,3]) cube([100,lst[0],100]);

    if (len(lst)>1) { holders([for (i = [1:(len(lst)-1)]) lst[i]], y+lst[0]+20); }
    //holders(select(lst,[1:(len(lst)-1)]));
}

module lower() {
    difference() {
    translate([-70,0,-31]) cube([70,32,32]);
    translate([-70,3,-28]) cube([100,100,28]);
    translate([0,3,-28]) cylinder(r=2);

    }
}

union(){
   // holders([24, 18.5, 18.5, 16, 9.5, 25],0);
    upper();
  lower();
}
