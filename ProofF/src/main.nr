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

    let mut b_i_xor_hash_hash_hash_hash_g_r_b: Field = b_i + hash_hash_hash_hash_g_r_b_bytes;

    let mut C_computed : [Field; 4] = [0; 4];
    C_computed[0] = sk_in_xor_hash_g_r_b;
    C_computed[1] = pk_out_x_xor_hash_hash_g_r_b;
    C_computed[2] = pk_out_y_xor_hash_hash_hash_g_r_b;
    C_computed[3] = b_i_xor_hash_hash_hash_hash_g_r_b;

    C_computed
}

fn compute_cm(pk: Point, rho: Field, r: Field, tho: Field) -> Field{
    
    let cm_0 = std::hash::poseidon::bn254::hash_3([pk.x, pk.y, rho]);
    let cm_1 = std::hash::poseidon::bn254::hash_2([r, cm_0]);
    let cm = std::hash::poseidon::bn254::hash_2([cm_1, tho]);
    cm
}

fn compute_sn(rho: Field, a_sk: Field) -> Field{
    std::hash::poseidon::bn254::hash_2([a_sk, rho])
}

fn proof<N>(a: structs::a, x: structs::x){

    let bjj = Curve::new(168700, 168696, Point::new(995203441582195749578291179787384436505546430278305826713579947235728471134,5472060717959818805561601436314318772137091100104008585924551046643952123905));

    let g_r_b_list = a.g_r_b_list;
    let n_in_list = a.n_in_list;
    let sn_in_list = x.sn_in_list;
    let cm_out_list = x.cm_out_list;

    let C_list = x.C_list;
    let info = x.info;
    let g_r_list = x.g_r_list;
    let g = x.g;

    //1) get plaintext of each element of C_list
    let mut C_computed : [[Field; 4]; 5] = [[0; 4]; 5];
    for i in 0..g_r_b_list.len(){
        let C = C_list[i];
        C_computed[i] = OTP_field(g_r_b_list[i], (C[0], Point::new(C[1], C[2]), C[2]), 1); // 1 for deciphering
    }
    
    //2) compute sn

    for i in 0..g_r_b_list.len() {
        let C = C_computed[i];
        let sk_i = C[0];
        let sn_computed = compute_sn((n_in_list[i]).rho, sk_i);
        assert(sn_computed == sn_in_list[i]);
    }

    //3) not necessary

    //4) compute cm_out

    for i in 0..g_r_b_list.len() {
        let C = C_computed[i];
        let pk_out = Point::new(C[1], C[2]);
        let mut T = 0;
        if (n_in_list[i]).T[0] == 0{
            T = (n_in_list[i]).T[1];
        }else{
            T = (n_in_list[i]).T[0];
        }
        let cm_computed = compute_cm(pk_out, (n_in_list[i]).rho, (n_in_list[i]).r, T);
        assert(cm_computed == cm_out_list[i]);
    }

    std::println("passed");
}

fn main(witness: structs::a, statement: pub structs::x){
    proof(witness, statement);
}
