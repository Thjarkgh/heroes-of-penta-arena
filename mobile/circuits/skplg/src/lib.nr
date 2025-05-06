pub global NOWHERE: u8 = 255;
pub global UNREADABLE_BYTES_PER_FIELD: u32 = 1;
pub comptime global DEBUG: bool = false;
pub comptime fn debug(stmt: Quoted) -> Quoted {
    let debug_result = if DEBUG { stmt } else { quote {} };
    debug_result
}
pub comptime fn debugmsg<T>(msg: T) -> Quoted {
    debug!(quote { println($msg); })
}
pub comptime fn softassert(varname: Quoted, check: Quoted, msg: Quoted) -> Quoted {
    let result = if DEBUG {
        quote {
            $varname &= $check;
            if !($check) {
                println($msg);
            }
        }
    } else {
        quote {
            $varname &= $check;
        }
    };
    result
}

////////////////////

// global WIDTH_MASK: u8 = 31;
// global CLASS_MASK: u8 = 7;
// global WIDTH_BITS: u8 = 5;
// global MAX_CHARACTERS: u32 = 5;
// struct Character {
//     pub x: u8, // 5 bit
//     pub class: u8, // 3 bit
//     pub actions: [[u8; 32]; 7],
// }
// impl Character {
//     fn is_class_valid(class: u8) -> bool {
//         class as u32 <= 5
//     }

//     pub fn is_valid(self) -> bool {
//         let mut valid = true;
//         let x = self.x;
//         let class = self.class;
//         println(x);
//         valid &= Character::is_class_valid(class);
//         valid
//     }

//     fn parse(
//         id: u8,
//         data: Field,
//         actions_data: [Field; 30],
//         wait_action: [u8; 32],
//     ) -> (bool, Character) {
//         let mut is_valid = true;

//         let split: [u8; 32] = data.to_be_bytes::<32>();
//         assert(split.len() == 32);
//         let x_packed = split[2 + id * 6]; // 5 bit x, 3 bit class

//         let x = x_packed & WIDTH_MASK;
//         let mut class = (x_packed >> WIDTH_BITS) & CLASS_MASK;
//         if !Character::is_class_valid(class) {
//             class = 0;
//             is_valid = false;
//         }

//         let c = Character {
//             x: x,
//             class: class,
//             actions: [
//                 wait_action,
//                 actions_data[id * 6 as u8].to_be_bytes::<32>(),
//                 actions_data[id * 6 as u8 + 1].to_be_bytes::<32>(),
//                 actions_data[id * 6 as u8 + 2].to_be_bytes::<32>(),
//                 actions_data[id * 6 as u8 + 3].to_be_bytes::<32>(),
//                 actions_data[id * 6 as u8 + 4].to_be_bytes::<32>(),
//                 actions_data[id * 6 as u8 + 5].to_be_bytes::<32>(),
//             ],
//         };
//         (is_valid, c)
//     }
// }

// fn create_character(x: u8, class: u8) -> Character {
//     let c = Character { x: x, class: class, actions: [[0 as u8; 32]; 7] };
//     assert(c.is_valid());
//     c
// }
// fn parse_characters(data: Field, actions_data: [Field; 30]) -> (bool, [Character; MAX_CHARACTERS]) {
//     let mut is_valid = true;

//     let wait_action = [
//         0 as u8, 0 as u8, 240 as u8, 0 as u8, 63 as u8, 0 as u8, 0 as u8, 1 as u8, 0 as u8,
//         32 as u8, 0 as u8, 0 as u8, 0 as u8, 0 as u8, 32 as u8, 0 as u8, 0 as u8, 0 as u8, 0 as u8,
//         32 as u8, 0 as u8, 0 as u8, 0 as u8, 0 as u8, 32 as u8, 0 as u8, 0 as u8, 0 as u8, 0 as u8,
//         0 as u8, 0 as u8, 0 as u8,
//     ];

//     // no need to optimize, compiler automatically rolls this out
//     let mut result: [Character; MAX_CHARACTERS] = [
//         create_character(0, 0),
//         create_character(0, 0),
//         create_character(0, 0),
//         create_character(0, 0),
//         create_character(0, 0),
//     ];
//     for i in 0..(MAX_CHARACTERS as u8) {
//         let (curr_valid, curr_c) = Character::parse(i, data, actions_data, wait_action);
//         is_valid &= curr_valid;
//         result[i] = curr_c;
//     }

//     // let (curr_valid, curr_c) = Character::parse(0, data, actions_data, wait_action, events, enemy_advance);
//     // is_valid &= curr_valid;
//     // result[0] = curr_c;
//     // let (curr_valid, curr_c) = Character::parse(1, data, actions_data, wait_action, events, enemy_advance);
//     // is_valid &= curr_valid;
//     // result[1] = curr_c;
//     // let (curr_valid, curr_c) = Character::parse(2, data, actions_data, wait_action, events, enemy_advance);
//     // is_valid &= curr_valid;
//     // result[2] = curr_c;
//     // let (curr_valid, curr_c) = Character::parse(3, data, actions_data, wait_action, events, enemy_advance);
//     // is_valid &= curr_valid;
//     // result[3] = curr_c;
//     // let (curr_valid, curr_c) = Character::parse(4, data, actions_data, wait_action, events, enemy_advance);
//     // is_valid &= curr_valid;
//     // result[4] = curr_c;
//     (is_valid, result)
// }

// #[test]
// fn test_parse_character_round0() {
//     let data = 0x2912640000004b03190000006c04142000008a0464000000aa47640b340a;

//     let parsed = parse_characters(
//         data,
//         [
//             0x03f00001300314002000000000100300000020000000002000000000000000,
//             0x02f0000110071020100a000020100a00000020000000002000000000000000,
//             0x02f0000a3b1901002000000000000801000020000000002000000000000000,
//             0x023100081b161118120a010018120a01000020000000002000000000000000,
//             0xf0003f000001002000000000200000000020000000002000000000000000,
//             0xf0003f000001002000000000200000000020000000002000000000000000,
//             0x03f00001300414002000000000100300000020000000002000000000000000,
//             0x02f0000110071008100a000008100a00000020000000002000000000000000,
//             0xf0003f1b1c11002000000000000702000020000000002000000000000000,
//             0xff003f1b1c1100200e013f00000e013f0020000000002000000000000000,
//             0xf0003f000001002000000000200000000020000000002000000000000000,
//             0xf0003f000001002000000000200000000020000000002000000000000000,
//             0x03f00001300314002000000000100300000020000000002000000000000000,
//             0x02f0000110071018100a000018100a00000020000000002000000000000000,
//             0x09f0000130060c002000000000200000000020000000002000000000000000,
//             0xf00001100610001005000100100500010020000000002000000000000000,
//             0xf00001301c0100100d000000100d00000020000000002000000000000000,
//             0x0bf00001100c00002000000000200000000010040a00002000000000000000,
//             0x03f00001300414002000000000100300000020000000002000000000000000,
//             0x02f0000110061028100a000028100a00000020000000002000000000000000,
//             0xf0003f000001002000000000200000000020000000002000000000000000,
//             0xf0003f000001002000000000200000000020000000002000000000000000,
//             0xf0003f000001002000000000200000000020000000002000000000000000,
//             0xf0003f000001002000000000200000000020000000002000000000000000,
//             0x03f00001300414002000000000100300000020000000002000000000000000,
//             0x02f0000110071010100a000010100a00000020000000002000000000000000,
//             0xf000071b1611002000000000000705000020000000002000000000000000,
//             0x6300061b161164150a020164150a02010020000000002000000000000000,
//             0xf0003f000001002000000000200000000020000000002000000000000000,
//             0xf0003f000001002000000000200000000020000000002000000000000000,
//         ],
//     );
//     assert(parsed.0);
// }

// // #[test]
// // fn test_create_character_0() {
// //   let data = 0x2912640000004b03190000006c04142000008a0464000000aa47640b340a;
// //   let enemy_advance = 0x08;
// //   let events = [0 as u8, 0 as u8, 0 as u8, 0 as u8];
// //   println(events);

// //   let actions_data = [
// //     0x03f00001300314002000000000100300000020000000002000000000000000,
// //     0x02f0000110071020100a000020100a00000020000000002000000000000000,
// //     0x02f0000a3b1901002000000000000801000020000000002000000000000000,
// //     0x023100081b161118120a010018120a01000020000000002000000000000000,
// //     0xf0003f000001002000000000200000000020000000002000000000000000,
// //     0xf0003f000001002000000000200000000020000000002000000000000000,
// //     0x03f00001300414002000000000100300000020000000002000000000000000,
// //     0x02f0000110071008100a000008100a00000020000000002000000000000000,
// //     0xf0003f1b1c11002000000000000702000020000000002000000000000000,
// //     0xff003f1b1c1100200e013f00000e013f0020000000002000000000000000,
// //     0xf0003f000001002000000000200000000020000000002000000000000000,
// //     0xf0003f000001002000000000200000000020000000002000000000000000,
// //     0x03f00001300314002000000000100300000020000000002000000000000000,
// //     0x02f0000110071018100a000018100a00000020000000002000000000000000,
// //     0x09f0000130060c002000000000200000000020000000002000000000000000,
// //     0xf00001100610001005000100100500010020000000002000000000000000,
// //     0xf00001301c0100100d000000100d00000020000000002000000000000000,
// //     0x0bf00001100c00002000000000200000000010040a00002000000000000000,
// //     0x03f00001300414002000000000100300000020000000002000000000000000,
// //     0x02f0000110061028100a000028100a00000020000000002000000000000000,
// //     0xf0003f000001002000000000200000000020000000002000000000000000,
// //     0xf0003f000001002000000000200000000020000000002000000000000000,
// //     0xf0003f000001002000000000200000000020000000002000000000000000,
// //     0xf0003f000001002000000000200000000020000000002000000000000000,
// //     0x03f00001300414002000000000100300000020000000002000000000000000,
// //     0x02f0000110071010100a000010100a00000020000000002000000000000000,
// //     0xf000071b1611002000000000000705000020000000002000000000000000,
// //     0x6300061b161164150a020164150a02010020000000002000000000000000,
// //     0xf0003f000001002000000000200000000020000000002000000000000000,
// //     0xf0003f000001002000000000200000000020000000002000000000000000
// // ];
// //   comptime { assert(5 <= 5); }

// //     let enemy_advance = if enemy_advance >= 32 { 0 } else { 32 - enemy_advance - 1 };
// //     let mut is_valid = true;

// //     let wait_action = [0 as u8, 0 as u8, 240 as u8, 0 as u8, 63 as u8, 0 as u8, 0 as u8, 1 as u8, 0 as u8, 32 as u8, 0 as u8, 0 as u8, 0 as u8, 0 as u8, 32 as u8, 0 as u8, 0 as u8, 0 as u8, 0 as u8, 32 as u8, 0 as u8, 0 as u8, 0 as u8, 0 as u8, 32 as u8, 0 as u8, 0 as u8, 0 as u8, 0 as u8, 0 as u8, 0 as u8, 0 as u8];

// // let mut result: [Character; 5] = [create_character(0, 0, 0, 0), create_character(1, 0, 0, 0), create_character(2, 0, 0, 0), create_character(3, 0, 0, 0), create_character(4, 0, 0, 0)];
// //     //for i in 0..(5 as u8) {
// //         let (curr_valid, curr_c) = Character::parse(0, data, actions_data, wait_action, events, enemy_advance);
// //         is_valid &= curr_valid;
// //         result[0] = curr_c;
// //         let (curr_valid, curr_c) = Character::parse(1, data, actions_data, wait_action, events, enemy_advance);
// //         is_valid &= curr_valid;
// //         result[1] = curr_c;
// //         let (curr_valid, curr_c) = Character::parse(2, data, actions_data, wait_action, events, enemy_advance);
// //         is_valid &= curr_valid;
// //         result[2] = curr_c;
// //         let (curr_valid, curr_c) = Character::parse(3, data, actions_data, wait_action, events, enemy_advance);
// //         is_valid &= curr_valid;
// //         result[3] = curr_c;
// //         let (curr_valid, curr_c) = Character::parse(4, data, actions_data, wait_action, events, enemy_advance);
// //         is_valid &= curr_valid;
// //         result[4] = curr_c;
// //    // }
// //     assert(is_valid);
// //     // assert(result[0].x == 0);
// // }
