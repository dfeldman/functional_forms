cube_size=50;
edge_width=5;
sc_x=5.5;
sc_y=5.;

ex=55;
letters=["LETTER1","LETTER2"];

$fn=100;
union() {
    // Exterior box
    difference() {
        cube([cube_size,cube_size,cube_size]);
        translate([edge_width, edge_width, edge_width]) 
            cube([cube_size-edge_width*2,cube_size-edge_width*2, cube_size]);
        translate([edge_width, 0, edge_width]) 
            cube([cube_size-edge_width*2,cube_size, cube_size-edge_width*2]);
        translate([0, edge_width, edge_width]) 
            cube([cube_size,cube_size-edge_width*2, cube_size-edge_width*2]);
    };

    intersection() {    
        cube([cube_size,cube_size,cube_size]);
        translate([25,45,3]) rotate([90,0,0]) scale([sc_x,sc_y,1]) linear_extrude(ex) 
            text(letters[0], halign="center", font = "Liberation Sans:style=Bold");
        translate([0,25,3]) rotate([90,0,90]) scale([sc_x,sc_y,1]) linear_extrude(ex) 
            text(letters[1], halign="center", font = "Liberation Sans:style=Bold");

    }
}
