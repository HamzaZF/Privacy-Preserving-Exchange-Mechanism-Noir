use dep::std;
use dep::std::collections::vec::Vec;

use dep::std::ec::tecurve::affine::{Curve, Point};

struct Record {
    pk : Point,
    T: Field,
    rho: Field,//Field,
    r: Field,
    cm: Field,
}

struct x { //instance
    cm_in: Field, 
    sn_in: Field, 
    C: [Field; 4], 
    g_r: Point,
    g_b: Point,
    g: Point,
}

struct a { //witness
    n_in : Record,
    n_out : Record,
    sk_in: Field,
    b_i: Field,
    g_r_b: Point,
    r: Field,
}
