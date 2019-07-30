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
phase          = 30;     // Recommended values 0 - 360

// Radius multiplier
radius         =  40;    // Recommended values 5 - 100

// How fast for the curve to expand (going from bottom to top)
sharpness      =  5;    // Recommended values .1 - 10

// How fast to taper the inside of the object
taper          =  .3;  // Recommended values 0 - 1

amp            = 0.75;

// Number of ripples
ripples        =  3;    // Recommended values 0 - 10

// Twisting factor
twist          =  1;   // Recommended values 0 - 3

// Distance from the inner to the outer wall of the object at its thickest point
wall_thickness =  5;     // Recommended values 1 - 5

// Distance from the inner to the outer wall of the back at its thickest point
back_thickness =  5;     // Recommended values 1 - 5

// ------- These variables should probably not be changed
// The size of the sharp point on the bottom of the object
epsilon        =  .1;

// Number of z steps
height         =  100; 

// Size of each z step -- increase for faster rendering
z_step           =  1; 

// Size of each r step -- increase for faster rendering
r_step           =  1; 

// Always set to 360
sides          =  180;

// Distance from the outer bottom to the inner bottom of the object
// Even though it doesn't seem like the two bottoms would intersect because the inner
// wall has 0 radius at the bottom, it can meet in a degenerate
// point which causes rendering problems. 
floor_height   =  20;

// ------- Parameters for the drainage tube
tube_radius       =  5;
tube_thickness    =  1;
tube_floor_height =  35;
tube_hole_spacing =  5;
tube_hole_count   =  3;
tube_hole_radius  =  .5;
tube_hole_depth   =  5;

// This function defines the radius of the object at each z-step and angle
function wall(z, angle) = let(
                zrad  = pow(sin(z), sharpness) * radius,
                cone  = taper * z,
                wave  = abs(cos(angle*ripples+phase))
)
zrad * wave * amp + cone;

function int_pt(z, s) = let(
//    assert(z >= 0),
//    assert(z < height),
//    assert(s >= 0),
//    assert(s <= sides)
    )
    z*(sides+1)+s;

function ext_pt(z, s) = let(
//    assert(z >= 0),
//    assert(z < height),
//    assert(s >= 0),
//    assert(s <= sides)
    )
    height*(sides+1) + z*(sides+1)+s;

module vase_shape() {
    
    vase_shape_exterior_points = [
        for(z = [0:z_step:height-1])
            for(i = [0:sides])
                let(
                    r     =  max(epsilon*2, wall(z, i + twist * z)), 
                    px   = r * cos(i),
                    py   = r * sin(i)
                )
                [px, py, z] 
    ];
            z=echo(len([0:height]));
         x=echo(len(vase_shape_exterior_points));
            
    vase_shape_interior_points =[
        // Interior wall -- points go bottom to top
        for(z = [0:z_step:height-1])
            for(i = [0:sides])
                let(
                  //  zp = height - z,
                    r     =  max(epsilon, 
                                (i > 180) ? 0 : wall(z, i + twist * z) - back_thickness), 
                    px   = r * cos(i),
                    py   = r * sin(i)
                )
                [px, py, z] 
    ];
            
    y=echo(len(vase_shape_interior_points));
    row = height * sides-1;
            
    faces = concat(
        // Top left triangle of every ring (both inside and outside walls)
        [
            for(z = [floor_height:z_step:height-2]) 
                for(s = [0:r_step:sides - 1])
                    let(
                        f1 = int_pt(z, s), //s + sides*z,
                        f2 = int_pt(z+1, s), //s + sides*(z+1),
                        f3 = int_pt(z+1, s+1) // ((s+1) % sides) + sides*(z+1)
                    )
                    [f3,f2,f1]
        ],

        // Bottom right triangle of every ring (both inside and outside walls)
        [
            for(z = [floor_height:z_step:height-2]) 
                for(s = [0:r_step:sides - 1])
                    let(
                        f1 = int_pt(z, s) , //s + sides*z,
                        f3 = int_pt(z+1, s+1), //((s+1) % sides) + sides*(z+1),
                        f4 = int_pt(z, s+1) //((s+1) % sides) + sides*z
                    )
                    [f1,f4,f3]
        ],
//        // Top left triangle of every ring (both inside and outside walls)
        [
            for(z = [0:z_step:height-2]) 
                for(s = [0:r_step:sides - 1])
                    let(
                        f1 = ext_pt(z, s) , // s + sides*z,
                        f2 = ext_pt(z+1, s), // s + sides*(z+1),
                        f3 = ext_pt(z+1, s+1) //((s+1) % sides) + sides*(z+1)
                    )
                    [f1,f2,f3]
        ],

        // Bottom right triangle of every ring (both inside and outside walls)
        [
            for(z = [0:z_step:height-2]) 
                for(s = [0:r_step:sides - 1])
                    let(
                        f1 = ext_pt(z, s), //s + sides*z,
                        f3 = ext_pt(z+1, s+1), //((s+1) % sides) + sides*(z+1),
                        f4 = ext_pt(z, s+1) //((s+1) % sides) + sides*z
                    )
                    [f3,f4,f1] 
        ],
//        // Interior floor of the object -- note polygon is opposite orientation -- degen
      [[ for(s = [sides:-1:0]) int_pt(floor_height, s)]],

     // Bottom of the object -- degen
        [[ for(s = [0:r_step:sides]) ext_pt(0, s)]]  ,
            

        [
           concat( 
                   [for(z=[height-1:-1:floor_height]) int_pt(z,sides)],
                   [for(z = [floor_height:height-1]) int_pt(z, 0)],
                   [for(z = [height-1:-1:0]) ext_pt(z,0)],
                   [for(z = [0:height-1]) ext_pt(z,sides)]
                       )
       ],
        // Top of object
        [
           concat([for(s = [0:sides])    int_pt(height-1,s) ],
                  [for(s = [sides:-1:0]) ext_pt(height-1,s) ]     ) 
       ]
    );
    
    //polyhedron (points=concat(vase_shape_interior_points, vase_shape_exterior_points), 
    //              faces = faces);
   back_faces = concat( 
       [
           concat( 
                   [for(z=[height-1:-1:0]) int_pt(z,0)],
                   [for(z = [0:height-1]) ext_pt(z,sides)]
                 )
       ],
       [
            for(z = [0:z_step:height-2]) 
                    let(
                        p1 = ext_pt(z, 0), //s + sides*z,
                        p2 = ext_pt(z, 1), //((s+1) % sides) + sides*(z+1),
                        p3 = ext_pt(z+1, 1), //((s+1) % sides) + sides*(z+1),
                        p4 = ext_pt(z, 1) //((s+1) % sides) + sides*z
                    )
                    [p1,p2,p3,p4] 
        ]
   ); 
    pts=concat(vase_shape_interior_points, vase_shape_exterior_points);

     l= echo([ for(z = [0:z_step:height-1]) let(pt3 =pts[ext_pt(z, 0)]) [pt3[0], pt3[2]] ]);
     union() {
         polyhedron (points=pts, faces = faces);
         rotate([90, 0, 0]) linear_extrude(height=2) {         
            polygon(points = concat(
                [ for(z = [0:z_step:height-1]) let(pt3 =pts[ext_pt(z, 0)]) [pt3[0], pt3[2]] ],
                [ for(z = [height-1:-1:0]) let(pt3=pts[ext_pt(z, sides)]) [pt3[0], pt3[2]]  ] ));
            }
    }
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
        cylinder(h=height-tube_floor_height-1, r=tube_radius);
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
            translate([0, -1, 70]) rotate([90,0,0]) cylinder(r=15,h=2); 
            // Drill a hole in wall plate for a nail
            translate([0,-6,70]) rotate([0,90,90]) cylinder(r=5,h=5);  
        }
        // Box over the hole to form attachment ledge for a hook
        translate([-10, -3, 72]) cube([20,0.5,8]);
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