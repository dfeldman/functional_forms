/*
    Parametric Planter by Daniel Feldman
    dfeldman.mn@gmail.com
    github.com/dfeldman/functional_forms

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


// ------- These variables should probably not be changed
// The size of the sharp point on the bottom of the object
epsilon   = 0.01;

// Number of z steps
height    = 100; 

// Size of each z step -- increase for faster rendering
step      = 1; 

// Always set to 360
sides     = 360;

// Distance from the outer bottom to the inner bottom of the object
// Even though it doesn't seem like the two bottoms would intersect because the inner
// wall is strictly smaller than the outer wall, it can meet in a degenerate
// point which causes rendering problems. 
// I recommend at least height*.1
floor_height=90;

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
        for(z = [0:step:height])
            for(i = [0:sides-1])
                let(
                    r     =  max(epsilon*2, (i > 180)? 0 : wall(z, i + twist * z)), 
                    px   = r * cos(i),
                    py   = r * sin(i) - ((i > 180)? 5 : 0) 
                )
                [px, py, z] 
    ],
    [
        // Interior wall -- points go bottom to top
        for(z = [0:step:height - floor_height])
            for(i = [0:sides-1])
                let(
                    zp = height - z,
                    r     =  max(epsilon, (i > 180) ? 0 : wall(zp, i + twist * zp) - wall_thickness), 
                    px   = r * cos(i),
                    py   = r * sin(i) - ((i>180)? 3 : 0)
                )
                [px, py, zp] 
    ]);
        
    faces = concat(
        // Top left triangle of every circle (both inside and outside walls)
        [
            for(z = [0:height*2 - floor_height]) 
                for(s = [0:sides - 1])
                    let(
                        // clockwise from left-down corner
                        f1 = s + sides*z,
                        f2 = s + sides*(z+1),
                        f3 = ((s+1) % sides) + sides*(z+1)
                    )
                    [f1,f2,f3]
        ],

        // Bottom right triangle of every circle (both inside and outside walls)
        [
            for(z = [0:height*2 - floor_height]) 
                for(s = [0:sides - 1])
                    let(
                        // clockwise from left-down corner
                        f1 = s + sides*z,
                        f3 = ((s+1) % sides) + sides*(z+1),
                        f4 = ((s+1) % sides) + sides*z
                    )
                    [f3,f4,f1]
        ],

        // Interior floor of the object -- note polygon is opposite orientation
        [[ for(s = [sides-1:-1:0]) ((height*2 - floor_height) * (sides) + s)]], 

        // Bottom of the object
        [[ for(s = [0:sides-1]) s]]  
    );

    polyhedron (points=points, faces = faces);
}


union() { 
    difference() {  
        union() {
            // The vase itself
            vase_shape();
            // Wall plate
            translate([-10, -5.1, 60]) cube([20,3,20]); 
        };
        // Drill a hole in wall plate for a nail
        translate([0,-6,70]) rotate([0,90,90]) cylinder(r=5,h=2);  
    } 
    // Box over the hole to form attachment ledge for a hook
    translate([-10, -5.1, 72]) cube([20,0.5,8]);

};