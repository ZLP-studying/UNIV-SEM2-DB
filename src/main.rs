use rand::Rng;

fn main() {
    const DISTRICTS_NR: usize = 4;
    const TYPE_NR: usize = 3;
    const MATERIAL_NR: usize = 2;
    const ADDRESSES: [[&str; 4]; DISTRICTS_NR] = [
        ["Митинская", "Дубравная", "Барышиха", "Пятницкое шоссе"],
        [
            "Осенний бульвар",
            "Крылатские холмы",
            "Рублевское шоссе",
            "Осенняя",
        ],
        ["Фестивальная", "Дыбенко", "Петрозаводская", "Лавочкина"],
        ["Гоголя", "Логвиново", "Панфиловский проспект", "Каменко"],
    ];
    let description1 = [
        "отвратительынй",
        "ужасный",
        "плохой",
        "хороший",
        "отличный",
        "замечательный",
    ];
    let description2 = ["ремнот", "сосед", "парк рядом", "двор", "владелец", "район"];

    let num: u32 = loop {
        let mut num = String::new();
        std::io::stdin()
            .read_line(&mut num)
            .expect("Can't read the line");
        let num = match num.trim().parse() {
            Ok(num) => num,
            Err(_) => {
                println!("Enter a number:");
                continue;
            }
        };
        break num;
    };

    let mut rng: rand::rngs::ThreadRng = rand::thread_rng();
    for _ in 0..num {
        // District id
        let district = rng.gen_range(1..=DISTRICTS_NR);

        // Address
        let address = String::from(
            "\"".to_owned()
                + ADDRESSES[district - 1][rng.gen_range(1..4)]
                + ", "
                + &rng.gen_range(1..=16).to_string()
                + "\"",
        );

        // Rooms count
        let rooms_nr = rng.gen_range(1..=4);

        // Type id
        let type_id = rng.gen_range(1..=TYPE_NR);

        // Status
        let status = match rng.gen_bool(0.5) {
            true => "\"TRUE\"",
            false => "\"FALSE\"",
        };

        // Square
        let square = rng.gen_range(10..=120);

        // Cost
        let cost = (rooms_nr * 2 + 6) * 1000000 * (1 + type_id / 10) * (65 / square)
            + rng.gen_range(1..=100) * 1000;

        // Description
        let description = "\"".to_owned()
            + &description1[rng.gen_range(0..description1.len())].to_string()
            + " "
            + &description2[rng.gen_range(0..description2.len())].to_string()
            + "\"";

        // Material
        let material = rng.gen_range(1..=MATERIAL_NR);

        // Date
        let date = "\"".to_owned()
            + &rng.gen_range(0..=28).to_string()
            + "."
            + &rng.gen_range(0..=12).to_string()
            + "."
            + &(rng.gen_range(10..=22) + 2000).to_string();

        let result = &("(".to_owned()
            + &district.to_string() // District id
            + ", "
            + &address // Address
            + ", "
            + &rng.gen_range(1..=10).to_string() // Floor
            + ", "
            + &rooms_nr.to_string() // Rooms count
            + ", "
            + &type_id.to_string() // Type id
            + ", "
            + &status // Status
            + ", "
            + &cost.to_string() // Cost
            + ", "
            + &description // Description
            + ", "
            + &material.to_string() // Material id
            + ", "
            + &square.to_string() // Square
            + ", "
            + &date // Date
            + ")");
        println!("{}", result);
    }
}
