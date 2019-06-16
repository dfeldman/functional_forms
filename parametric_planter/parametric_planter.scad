/*
    Parametric Planter by Daniel Feldman
    dfeldman.mn@gmail.com
    github.com/dfeldman/functional_forms
    Pull requests welcome!

    Inspired by:
    Vase-wave generator/customizer, Fernando Jerez 2017

    License: CC-NC (Non commercial)
*/


// ------- These variables are great for changing the shape of the object
// How far to rotate the twist at the beginning in degrees
phase          =  40;     // Recommended values 0 - 360

// Radius multiplier
radius         =  40;    // Recommended values 5 - 100

// How fast for the curve to expand (going from bottom to top)
sharpness      =  2;    // Recommended values .1 - 10

// How fast to taper the inside of the object
taper          =  0.2;  // Recommended values 0 - 1

// Number of ripples
ripples        =  3;    // Recommended values 0 - 10

// Twisting factor
twist          =  .8;   // Recommended values 0 - 3

// Distance from the inner to the outer wall of the object at its thickest point
wall_thickness =  5;     // Recommended values 1 - 5

// Distance from the inner to the outer wall of the back at its thickest point
back_thickness =  2;     // Recommended values 1 - 5

// ------- These variables should probably not be changed
// The size of the sharp point on the bottom of the object
epsilon        =  0.01;

// Number of z steps
height         =  100; 

// Size of each z step -- increase for faster rendering
z_step           =  1; 

// Size of each r step -- increase for faster rendering
r_step           =  1; 

// Always set to 360
sides          =  360;

// Distance from the outer bottom to the inner bottom of the object
// Even though it doesn't seem like the two bottoms would intersect because the inner
// wall has 0 radius at the bottom, it can meet in a degenerate
// point which causes rendering problems. 
floor_height   =  5;

// ------- Parameters for the drainage tube
tube_radius       =  5;
tube_thickness    =  1;
tube_floor_height =  35;
tube_hole_spacing =  5;
tube_hole_count   =  3;
tube_hole_radius  =  0.2;
tube_hole_depth   =  5;

// This function defines the radius of the object at each z-step and angle
function wall(z, angle) = let(
                zrad  = pow(sin(z), sharpness) * radius,
                cone  = taper * z,
                wave  = abs(cos(angle*ripples+phase))
)
zrad * wave + cone;

module vase_shape() {
    points = concat([
        // Exterior wall -- points go bottom to top
        for(z = [0:z_step:height])
            for(i = [0:sides-1])
                let(
                    r     =  max(epsilon*2, 
                                (i > 180)? 0 : wall(z, i + twist * z)), 
                    px   = r * cos(i),
                    py   = r * sin(i) - ((i > 180)? back_thickness : 0) 
                )
                [px, py, z] 
    ],
    [
        // Interior wall -- points go bottom to top
        for(z = [0:z_step:height - floor_height])
            for(i = [0:sides-1])
                let(
                    zp = height - z,
                    r     =  max(epsilon, 
                                (i > 180) ? 0 : wall(zp, i + twist * zp) - back_thickness), 
                    px   = r * cos(i),
                    py   = r * sin(i)
                )
                [px, py, zp] 
    ]);
        
    faces = concat(
        // Top left triangle of every ring (both inside and outside walls)
        [
            for(z = [0:z_step:height*2 - floor_height]) 
                for(s = [0:r_step:sides - 1])
                    let(
                        f1 = s + sides*z,
                        f2 = s + sides*(z+1),
                        f3 = ((s+1) % sides) + sides*(z+1)
                    )
                    [f1,f2,f3]
        ],

        // Bottom right triangle of every ring (both inside and outside walls)
        [
            for(z = [0:z_step:height*2 - floor_height]) 
                for(s = [0:r_step:sides - 1])
                    let(
                        f1 = s + sides*z,
                        f3 = ((s+1) % sides) + sides*(z+1),
                        f4 = ((s+1) % sides) + sides*z
                    )
                    [f3,f4,f1]
        ],

        // Interior floor of the object -- note polygon is opposite orientation
        [[ for(s = [sides:-r_step:0]) ((height*2 - floor_height+1) * (sides) + s)]], 

        // Bottom of the object
        [[ for(s = [0:r_step:sides-1]) s]]  
    );

    polyhedron (points=points, faces = faces);
}

module drainage_holes() {
        for ( z = [0 : tube_hole_spacing : height - tube_floor_height - 1 ] )
            for (x = [-tube_hole_count : tube_hole_count ] )
                translate([x, 0, z]) 
                rotate([270, 0, 0]) 
                cylinder(r=tube_hole_radius, h=tube_hole_depth);
}

module drainage_tube() {
    translate([0,0,tube_floor_height]) difference() {
        cylinder(h=height-tube_floor_height, r=tube_radius);
        translate([0,0,tube_thickness]) 
            cylinder(h=(height), 
                r=(tube_radius-tube_thickness));
        translate([-20,-100,0]) cube([100, 100, 100]);
        drainage_holes();
    }
}

module wall_plate() {
    union() {
        difference() {
            translate([-10, -6, 60]) cube([20,3,20]); 
            // Drill a hole in wall plate for a nail
            translate([0,-6,70]) rotate([0,90,90]) cylinder(r=5,h=2);  
        }
        // Box over the hole to form attachment ledge for a hook
        translate([-10, -6, 72]) cube([20,0.5,8]);
    }
}

union() { 
    // The vase itself
    vase_shape();
    // Wall plate
    wall_plate();
    // Drainage tube
    drainage_tube();
};