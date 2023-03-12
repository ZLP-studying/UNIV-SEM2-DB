use rand::Rng;

// ---------------------
// Districts & Addresses
// ---------------------
// Districts names
const DISTRICTS_NAMES: [&str; 4] = ["Митино", "Крылатское", "РАЙОН 3", "РАЙОН 4"];
// Addresses names per districts
const ADDRESSES: [[&str; 4]; DISTRICTS_NAMES.len()] = [
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

// -----
// Types
// -----
// Type names
const TYPE_NAMES: [&str; 4] = ["Квартира", "Дом", "Апартаменты", "Трущебы"];

// ---------
// Materials
// ---------
// Number of materials
const MATERIALS_NAMES: [&str; 4] = ["Панель", "Кирпич", "Пена", "Дерево"];

// ----------
// Parameters
// ----------
// Parameters names
const PARAM_NAMES: [&str; 6] = [
    "Экология",
    "Чистота",
    "Соседи",
    "Условия для детей",
    "Магазины",
    "Безопасность",
];

// --------
// Realtors
// --------
const REALTORS: [(&str, &str, &str, &str); 5] = [
    ("Иванов", "Иван", "Петрович", "89608521245"),
    ("Кузнецов", "Антон", "Васильевич", "12234567899"),
    ("Продолговатый", "Петр", "Лисов", "98765432101"),
    ("Меньших", "Афанасий", "Евгеньевич", "65784932013"),
    ("Аккредитованный", "Георгий", "Колобков", "89690137888"),
];

fn main() {
    // Objects count
    println!("Enter how many objects are required:");
    let objects_nr: u32 = loop {
        let mut objects_nr = String::new();
        std::io::stdin()
            .read_line(&mut objects_nr)
            .expect("Can't read the line");
        let num = match objects_nr.trim().parse() {
            Ok(num) => num,
            Err(_) => {
                println!("Enter a number!");
                continue;
            }
        };
        break num;
    };

    // --- Generation ---
    // Tables insert title
    println!("-----------------------\n-- Заполнение таблиц --\n-----------------------");
    // Types
    gen_types();
    print!("\n");
    // Districts
    gen_districts();
    print!("\n");
    // Materials
    gen_materials();
    print!("\n");
    // Objects
    gen_objects(objects_nr);
    print!("\n");
    // Parameters
    gen_parameters();
    print!("\n");
    // Rates
    gen_rates(objects_nr);
    print!("\n");
    // Realtors
    gen_realtors();
    print!("\n");
    // Sales
    gen_sales(objects_nr);
}

fn gen_types() {
    println!("-- «Тип» - types");
    println!("INSERT INTO types (name) VALUES");
    for i in 0..TYPE_NAMES.len() {
        print!("('{}')", TYPE_NAMES[i]);
        if i != TYPE_NAMES.len() - 1 {
            println!(",");
        } else {
            println!(";");
        }
    }
}

fn gen_districts() {
    println!("-- «Районы» - districts");
    println!("INSERT INTO districts (name) VALUES");
    for i in 0..DISTRICTS_NAMES.len() {
        print!("('{}')", DISTRICTS_NAMES[i]);
        if i != DISTRICTS_NAMES.len() - 1 {
            println!(",");
        } else {
            println!(";");
        }
    }
}

fn gen_materials() {
    println!("-- «Материалы зданий» - materials");
    println!("INSERT INTO materials (name) VALUES");
    for i in 0..MATERIALS_NAMES.len() {
        print!("('{}')", MATERIALS_NAMES[i]);
        if i != MATERIALS_NAMES.len() - 1 {
            println!(",");
        } else {
            println!(";");
        }
    }
}

fn gen_objects(iterations: u32) {
    println!("-- «Объекты недвижимости» - objects");
    println!("INSERT INTO objects");
    println!("(district_id, address, floor, rooms, type_id, status, cost, description, material_id, square, date)");
    println!("VALUES");

    // First part of description
    let description1 = [
        "отвратительынй",
        "ужасный",
        "плохой",
        "хороший",
        "отличный",
        "замечательный",
    ];
    // Second part of description
    let description2 = ["ремнот", "сосед", "парк рядом", "двор", "владелец", "район"];

    // Random seed
    let mut rng: rand::rngs::ThreadRng = rand::thread_rng();

    // Gen loop
    for i in 0..iterations {
        // District id
        let district = rng.gen_range(1..=DISTRICTS_NAMES.len());

        // Address
        let address = String::from(
            "'".to_owned()
                + ADDRESSES[district - 1][rng.gen_range(1..4)]
                + ", "
                + "дом "
                + &rng.gen_range(1..=16).to_string()
                + ", "
                + "кв "
                + &rng.gen_range(1..=25).to_string()
                + "'",
        );

        // Rooms count
        let rooms_nr = rng.gen_range(1..=4);

        // Type id
        let type_id = rng.gen_range(1..=TYPE_NAMES.len());

        // Status
        let status = match rng.gen_bool(0.5) {
            true => "TRUE",
            false => "FALSE",
        };

        // Square
        let square = rng.gen_range(10..=120);

        // Cost
        let cost = ((rooms_nr as f32 * 2.0 + 6.0)
            * 1000000.0
            * (1.0 + (type_id as f32 / 10.0))
            * (square as f32 / 65.0)
            + (rng.gen_range(1..=100) * 1000) as f32) as u32;

        // Description
        let description = "'".to_owned()
            + &description1[rng.gen_range(0..description1.len())].to_string()
            + " "
            + &description2[rng.gen_range(0..description2.len())].to_string()
            + "'";

        // Material
        let material = rng.gen_range(1..=MATERIALS_NAMES.len());

        // Date
        let date = "'".to_owned()
            + &rng.gen_range(1..=28).to_string()
            + "."
            + &rng.gen_range(1..=12).to_string()
            + "."
            + &(rng.gen_range(10..=22) + 2000).to_string()
            + "'";

        let result = &mut ("(".to_owned()
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
        if i != iterations - 1 {
            result.push(',');
        } else {
            result.push(';');
        }
        println!("{}", result);
    }
}

fn gen_parameters() {
    println!("-- «Критерии оценки» - parameters");
    println!("INSERT INTO parameters (name) VALUES");
    for i in 0..PARAM_NAMES.len() {
        print!("('{}')", PARAM_NAMES[i]);
        if i != PARAM_NAMES.len() - 1 {
            println!(",");
        } else {
            println!(";");
        }
    }
}

fn gen_rates(objects_nr: u32) {
    println!("-- «Оценки» - rates");
    println!("INSERT INTO rates");
    println!("(object_id, date, parameter_id, rate)");
    println!("VALUES");

    // Random seed
    let mut rng: rand::rngs::ThreadRng = rand::thread_rng();

    let iterations = objects_nr * 5;
    for i in 0..(iterations) {
        // Date
        let date = "'".to_owned()
            + &rng.gen_range(1..=28).to_string()
            + "."
            + &rng.gen_range(1..=12).to_string()
            + "."
            + &(rng.gen_range(10..=22) + 2000).to_string()
            + "'";

        let result = &mut ("(".to_owned()
            + &&rng.gen_range(1..=objects_nr).to_string() // Object id
            + ", "
            + &date // Date
            + ", "
            + &rng.gen_range(1..=PARAM_NAMES.len()).to_string() // Parameter id
            + ", "
            + &rng.gen_range(0..=10).to_string() // Rate
            + ")");
        if i != iterations - 1 {
            result.push(',');
        } else {
            result.push(';');
        }
        println!("{}", result);
    }
}

fn gen_realtors() {
    println!("-- «Риэлторы» - realtors");
    println!("INSERT INTO realtors");
    println!("(s_name, f_name, t_name, contacts)");
    println!("VALUES");
    for i in 0..(REALTORS.len()) {
        let result = &mut ("(".to_owned()
            + &("'".to_owned() + REALTORS[i].0 + "'").to_string() // Second name
            + ", "
            + &("'".to_owned() + REALTORS[i].1 + "'").to_string() // First name
            + ", "
            + &("'".to_owned() + REALTORS[i].2 + "'").to_string() // Last name
            + ", "
            + &("'".to_owned() + REALTORS[i].3 + "'").to_string() // Contacts
            + ")");
        if i != REALTORS.len() - 1 {
            result.push(',');
        } else {
            result.push(';');
        }
        println!("{}", result);
    }
}

fn gen_sales(objects_nr: u32) {
    println!("-- «Продажи» - sales");
    println!("INSERT INTO sales");
    println!("(object_id, date, realtor_id, cost)");
    println!("VALUES");

    // Random seed
    let mut rng: rand::rngs::ThreadRng = rand::thread_rng();

    let iterations = objects_nr * 3;
    for i in 0..iterations {
        let date = "'".to_owned()
            + &rng.gen_range(1..=28).to_string()
            + "."
            + &rng.gen_range(1..=12).to_string()
            + "."
            + &(rng.gen_range(10..=22) + 2000).to_string()
            + "'";

        let result = &mut ("(".to_owned()
            + &rng.gen_range(1..=objects_nr).to_string() // Object id
            + ", "
            + &date.to_string()
            + ", "
            + &rng.gen_range(1..=REALTORS.len()).to_string() // Realtor id
            + ", "
            + &rng.gen_range(1000000..15000000).to_string() // Cost
            + ")");
        if i != iterations - 1 {
            result.push(',');
        } else {
            result.push(';');
        }
        println!("{}", result);
    }
}
