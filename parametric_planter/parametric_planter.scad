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
sharpness      =  2;    // Recommended values .1 - 10

// How fast to taper the inside of the object
taper          =  0.4;  // Recommended values 0 - 1

amp            = 0.75;

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
floor_height   =  20;

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
zrad * wave * amp + cone;

function closer(a, b, c) {
    if (norm(a-c) > norm(b-c)) {
        return a} else {return b}
}

module vase_shape() {
    radii = [
        for(z = [0:z_step:height])
            for(i = [0:sides-1])
                let(
                    r     =  max(epsilon*2, 
                                (i< 20 || i > 160)? 0 : wall(z, i + twist * z)), 
                    px   = r * cos(i),
                    py   = r * sin(i) - ((i > 160)? back_thickness : 0) 
                )
                [px, py, z] 
    ];
    exterior_points = [
        // Exterior wall -- points go bottom to top
        for(z = [0:z_step:height])
            for(i = [0:sides-1])
                let(
                    r     =  max(epsilon*2, 
                                (i< 0 || i > 180)? 0 : wall(z, i + twist * z)-20), 
                    px   = r * cos(i),
                    py   = r * sin(i) - ((i > 180)? back_thickness : 0) 
                )
                [px, py, z] 
    ];
    interior_points_OLD=[
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
    ];
            
    normals = [
       // Compute the normal for each exterior point
            for(z = [0:z_step:height-1])
                for(s = [0:sides - 1])
                    let(
                        zp = z,//check
                        f1 = s + sides*zp,
                        f2 = s + sides*min(height, zp+1),
                        f3 = ((s+1) % sides) + sides*min(height, zp+1),
                        f4 = ((s+1) % sides) + sides*zp,

                        pt1= exterior_points[f1],
                        pt2= exterior_points[f2],
                        pt3= exterior_points[f3],
                        pt4 = exterior_points[f4],
                
                        cr1 = cross(pt3-pt1, pt2-pt1),
                        cr1_n = cr1/norm(cr1)+[0,0,0],
                        cr1_p = [cr1_n[0], cr1_n[1], 0],
                        cr2 = cross(pt4-pt2, pt4-pt1),

                        pt_int = (pt1-cr1_n)+[0,0,0]
                    )
                    cr1_n
        ];
        //echo(normals);

    normals_massaged = [
        // At a nonsmooth point in the underlying radius function, the normal points in a 
        // basically random direction. If we used it, we'd get self-intersections in the shape.
        // So we replace it with a fake normal that should produce an OK-looking result in most cases.
            for(z = [0:z_step:height-1])
                // There can't be a discontinuity at the beginning or end (by definition)
                for(s = [0:sides - 1]) 
                    let(
                        normal_diff = norm(normals[z*sides+s+1] - normals[z*sides+s]),
                        normal_diff2 = (s==sides-1)?normals[z*sides+s]:normal_diff,
                       // b1=echo(normals[z*sides+s+1] - normals[z*sides+s], normal_diff),
                        //blank=(normal_diff>.01)?echo("DIRTY"):0,
                        pt=exterior_points[z*sides+s],
                        fake_normal=5 * pt/norm(pt),
                        fake_normal_flat = [fake_normal[0],fake_normal[1],0],
                        normal_clean = (normal_diff>0.25)?fake_normal_flat:(normals[z*sides+s]),
                        normal_clean2 = (s<=8) ?[0,0.01,0]:normal_clean,
                        normal_clean3 = (s > 180)?[0,-1,0]:normal_clean2, 
                    )
                    normal_clean3
    ];
                echo("999",norm([0.995506, -0.0947008, 0]));
                //echo("XXX",normals_massaged);
    interior_points = [
        for(z = [0:z_step:height-1])
            for(i = [0:sides-1])
                    let(                    
                        zp = height - z-1,// imp
                        ip1 = min(i, sides-0),
                        ip2 = max(ip1, 0),
                        ext_point = exterior_points[zp*sides+ip2],
            normal=normals_massaged[zp*sides+ip2],
                       // blacnk=echo(z, zp, i, zp*sides+i, len(normals), normal),
                        pt_int1 = ext_point-normal*3, //+[0,0,100],
                        pt_int2 = closer(pt_int1, ext_point, [0, 0, z]),
                        //x=echo(ext_point, len(exterior_points), z*sides+i)
                    )
                    pt_int
    ];            //echo(len(normals));

         //  echo(interior_points);
            
    faces = concat(
        // Top left triangle of every ring (both inside and outside walls)
        [
            for(z = [each [0:z_step:height], each [height:z_step:height*2-floor_height-1]]) 
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
            for(z = [each [0:z_step:height], each [height:z_step:height*2-floor_height-1]]) 
                for(s = [0:r_step:sides - 1])
                    let(
                        f1 = s + sides*z,
                        f3 = ((s+1) % sides) + sides*(z+1),
                        f4 = ((s+1) % sides) + sides*z
                    )
                    [f3,f4,f1]
        ],

        // Interior floor of the object -- note polygon is opposite orientation
        [[ for(s = [sides:-r_step:0]) ((height*2 - floor_height) * (sides) + s)]],

        // Bottom of the object
        [[ for(s = [0:r_step:sides-1]) s]]  
    );
   // echo(len(interior_points));
   // echo(len(interior_points_OLD));
   //             echo(exterior_points[1]);
    polyhedron (points=concat(exterior_points, interior_points), faces = faces);
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
     //   translate([-20,-100,0]) cube([100, 100, 100]);
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