use dep::std;
use dep::std::collections::vec::Vec;
mod structs;

use dep::std::ec::tecurve::affine::{Curve, Point};
use dep::poseidon2;

fn hash_point(point: Point) -> Field{
    let point_0 = point.x;
    let point_1 = point.y;
    poseidon2::bn254::hash_2([point_0, point_1])
}

fn compute_cm(pk: Point, rho: Field, r: Field, T: Field) -> Field{
    
    let cm_0 = std::hash::poseidon::bn254::hash_3([pk.x, pk.y, rho]);
    let cm_1 = std::hash::poseidon::bn254::hash_2([r, cm_0]);
    let cm = std::hash::poseidon::bn254::hash_2([cm_1, T]);
    cm
}

fn compute_sn(rho: Field, a_sk: Field) -> Field{
    std::hash::poseidon::bn254::hash_2([a_sk, rho])
}

fn OTP_field(g_r_b: Point, plain: (Field, Point, Field), op: u8) -> [Field; 4] {

    let sk_in = plain.0;
    let pk_out = plain.1;
    let b_i = plain.2;

    //sk_in XOR H(g_r_b)
    let mut hash_g_r_b_bytes: Field = hash_point(g_r_b);
    let mut sk_in_xor_hash_g_r_b: Field = 0;
    if op==0{
        sk_in_xor_hash_g_r_b = sk_in + hash_g_r_b_bytes;
    }else{
        sk_in_xor_hash_g_r_b = sk_in - hash_g_r_b_bytes;
    }

    //pk_out XOR H(H(g_r_b))
    let mut hash_hash_g_r_b_bytes: Field = poseidon2::bn254::hash_1([hash_point(g_r_b)]);
    let mut hash_hash_hash_g_r_b_bytes: Field = poseidon2::bn254::hash_1([poseidon2::bn254::hash_1([hash_point(g_r_b)])]);
    
    let mut pk_out_x = pk_out.x;
    let mut pk_out_y = pk_out.y;

    let mut pk_out_x_xor_hash_hash_g_r_b: Field = 0;
    let mut pk_out_y_xor_hash_hash_hash_g_r_b: Field = 0;

    if op==0{
        pk_out_x_xor_hash_hash_g_r_b = pk_out_x + hash_hash_g_r_b_bytes;
        pk_out_y_xor_hash_hash_hash_g_r_b = pk_out_y + hash_hash_hash_g_r_b_bytes;
    }else{
        pk_out_x_xor_hash_hash_g_r_b = pk_out_x - hash_hash_g_r_b_bytes;
        pk_out_y_xor_hash_hash_hash_g_r_b = pk_out_y - hash_hash_hash_g_r_b_bytes;
    }

    //b XOR H(H(H(g_r_b)))
    let mut hash_hash_hash_hash_g_r_b_bytes: Field = poseidon2::bn254::hash_1([poseidon2::bn254::hash_1([poseidon2::bn254::hash_1([hash_point(g_r_b)])])]);
    let mut b_i_xor_hash_hash_hash_hash_g_r_b: Field = 0;

    if op==0{
        b_i_xor_hash_hash_hash_hash_g_r_b = b_i + hash_hash_hash_hash_g_r_b_bytes;
    }else{
        b_i_xor_hash_hash_hash_hash_g_r_b = b_i - hash_hash_hash_hash_g_r_b_bytes;
    }

    let mut C_computed : [Field; 4] = [0; 4];
    C_computed[0] = sk_in_xor_hash_g_r_b;
    C_computed[1] = pk_out_x_xor_hash_hash_g_r_b;
    C_computed[2] = pk_out_y_xor_hash_hash_hash_g_r_b;
    C_computed[3] = b_i_xor_hash_hash_hash_hash_g_r_b;

    C_computed
}

fn proof<N>(a: structs::a, x: structs::x){

    let bjj = Curve::new(168700, 168696, Point::new(995203441582195749578291179787384436505546430278305826713579947235728471134,5472060717959818805561601436314318772137091100104008585924551046643952123905));

    //1) C == (sk_in||pk_out||b) XOR (H(g_r_b)||H(H(g_r_b))||H(H(H(g_r_b))))
    
    let mut n_out = a.n_out;
    let mut n_in = a.n_in;

    let C_computed = OTP_field(a.g_r_b, (a.sk_in, n_out.pk, a.b_i), 1);

    assert(C_computed[0] == x.C[0]);
    assert(C_computed[1] == x.C[1]);
    assert(C_computed[2] == x.C[2]);
    assert(C_computed[3] == x.C[3]);

    std::println("passed");

    //2) cm_out == H(n_in.T, n_in.r, n_in.rho, n_in.pk_in)

    let cm_in_computed = compute_cm(n_out.pk, n_out.rho, n_out.r, n_out.T);

    assert(cm_in_computed == n_in.cm);

    std::println("passed");

    //3) pk_in == KeyGen(sk_in)

    let sn_in_computed = compute_sn(n_in.rho, a.sk_in);

    assert(sn_in_computed == x.sn_in);

    std::println("passed");

    //4) g_r == g^r

    let g_r_computed = bjj.mul(a.r, x.g);

    assert(g_r_computed == x.g_r);
    std::println("passed");

    //5) g_r_b == (g^b)^r

    let g_r_b_computed = bjj.mul(a.r, x.g_b);
    assert(g_r_b_computed == a.g_r_b);
    std::println("passed");
}

fn main(witness: structs::a, statement: pub structs::x){
    proof(witness, statement);
}