// Fume extractor hose connection for an Elegoo Saturn 2 printer

// Output hose connection size (OD) in inches
Hose_OD_In = 2.5;  // [1.18, 1.5, 2.5, 3, 4]

module __Customizer_Limit__ () {}  // Hide following assignments from Customizer.

// Params (defaults for Saturn 2)
size = 80;          // Plate size in mm
height = 5;         // Plate height (thckness) in mm
screw_size = 5;     // Screw size (diameter) in mm
screw_cc_mm = 65;   // Screw center-to-center in mm
hole_id_mm = 75;    // Plate hole ID in mm (standard Saturn 2 port)
hole_height = 20;   // Hose connection height in mm
hose_wall_width = 3;    // Hose connection wall width in mm
inter_fudge = .001; // Inter-layer fudge factor in mm

// Computed values
screw_off_mm = screw_cc_mm / 2;     // Screw offset from center in mm
hole_od_mm = hole_id_mm + hose_wall_width;  // Plate hole OD in mm
hose_od_mm = Hose_OD_In * 25.4;     // Hose OD converted to mmm
hose_id_mm = hose_od_mm - hose_wall_width;  // Hose ID from OD
plate_size_mm = max(size, hose_od_mm);  // Increase plate size for larger hoses

// See https://hydraraptor.blogspot.com/2011/02/polyholes.html
module polyhole(h, d, center = false) {
    n = max(round(2 * d), 3);

    cylinder(h = h, r = (d / 2) / cos (180 / n), $fn = n, center = center);
}

module polycone(h, d1, d2, center = false) {
    n = max(round(2 * d1), 3);
    fudge = cos (180 / n);
    r1 = (d1 / 2) / fudge;
    r2 = (d2 / 2) / fudge;

    cylinder(h = h, r1 = r1, r2 = r2, $fn = n, center = center);
}

// Simple hole (at bottom by default)
module make_hole(x, y, z = 0, h, d) {
    translate([x, y, z])
        polyhole(h = h + 1, d = d, center = true);
}

// Makes a hollow tube, possibly with different OD/ID
module polytube(origin, height, od1, od2, id1, id2) {
    difference() {
        translate([0, 0, fuzz(origin)])
            polycone(h = height, d1 = od1, d2 = od2, center = true);
        translate([0, 0, fuzz(origin)])
            polycone(h = height + 1, d1 = id1, d2 = id2, center = true);
    }
}

// Fuzzes a value to allow for smooth attachment of objects
function fuzz(v) = v - inter_fudge;

// Connection plate
difference() {
    // Overall shape
    cube([plate_size_mm, plate_size_mm, height], center=true);

    // Center hole
    polyhole(h = height + 1, d = hole_id_mm, center = true);

    // Screw holes
    make_hole(x = -screw_off_mm, y = -screw_off_mm, h = height, d = screw_size);
    make_hole(x = screw_off_mm, y = screw_off_mm, h = height, d = screw_size);
    make_hole(x = -screw_off_mm, y = screw_off_mm, h = height, d = screw_size);
    make_hole(x = screw_off_mm, y = -screw_off_mm, h = height, d = screw_size);
}

reducer_origin_z = height / 2 + hole_height / 2;

// Reducer (hole to hose)
polytube(reducer_origin_z, hole_height, hole_od_mm, hose_od_mm, hole_id_mm, hose_id_mm);

hose_origin_z = reducer_origin_z + hole_height;

// Hose connection
polytube(hose_origin_z, hole_height, hose_od_mm, hose_od_mm, hose_id_mm, hose_id_mm);