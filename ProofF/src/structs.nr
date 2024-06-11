use dep::std;
use dep::std::collections::vec::Vec;

use dep::std::ec::tecurve::affine::{Curve, Point};

struct Record {
    pk : Point,
    T: [Field; 2],
    rho: Field,//Field,
    r: Field,
    cm: Field, //Poseidon
}

struct x { //instance
    cm_out_list: [Field; 5], 
    sn_in_list: [Field; 5],
    C_list: [[Field; 4]; 5], 
    info: str<100>,
    g_r_list: [Point; 5],
    g_b: Point,
    g: Point,
}

struct a { //witness
    n_in_list: [Record; 5],
    n_out_list: [Record; 5],
    b: Field,
    g_r_b_list: [Point; 5],
}
