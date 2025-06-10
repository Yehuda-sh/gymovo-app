const { createClient } = require("@supabase/supabase-js");
const { faker } = require("@faker-js/faker");

const supabaseUrl = "https://tueiyvzkhiljaktpcqqs.supabase.co";
const serviceRoleKey =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR1ZWl5dnpraGlsamFrdHBjcXFzIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0ODk1NjU4MSwiZXhwIjoyMDY0NTMyNTgxfQ.ko8RNyQOMyzk3kghldbc2io_q41-s9R3LIH7eThQ6wo";

const supabase = createClient(supabaseUrl, serviceRoleKey);

const PASSWORD = "demoUser123"; // כאן שים את הסיסמה שלך

const genders = ["זכר", "נקבה"];
const goals = [
  "חיטוב",
  "עלייה במסה",
  "ירידה במשקל",
  "שמירה על כושר",
  "שיקום",
  "כושר כללי",
];
const equipmentOptions = [
  ["משקולות", "מוטות"],
  ["מכשירים"],
  ["גומיות התנגדות"],
  ["מוטות"],
  ["משקולות"],
  ["מכשירים"],
];
const injuriesList = [
  [],
  ["ברך"],
  ["כתף"],
  ["גב"],
  ["מרפק"],
  ["קרסול"],
  ["גב", "ברך"],
  [],
];

function getRandomFrom(arr) {
  return arr[Math.floor(Math.random() * arr.length)];
}

(async () => {
  for (let i = 1; i <= 10; i++) {
    const gender = getRandomFrom(genders);
    const firstName = faker.person.firstName(
      gender === "נקבה" ? "female" : "male"
    );
    const lastName = faker.person.lastName();
    const name = `${firstName} ${lastName}`;
    const email = `demo${i}@gymovo.com`;
    const age = faker.number.int({ min: 20, max: 50 });
    const height_cm = faker.number.int({ min: 155, max: 190 });
    const weight_kg = faker.number.int({ min: 50, max: 90 });
    const goal = getRandomFrom(goals);
    const equipment = getRandomFrom(equipmentOptions);
    const injuries = getRandomFrom(injuriesList);

    // צור משתמש ב־AUTH
    const { data: userRes, error: authError } =
      await supabase.auth.admin.createUser({
        email,
        password: PASSWORD,
        email_confirm: true,
      });

    if (authError) {
      console.error(
        `❌ שגיאה ביצירת משתמש AUTH עבור ${email}:`,
        authError.message
      );
      continue;
    } else {
      console.log(`✅ נוצר משתמש AUTH: ${email}`);
    }

    // צור פרופיל ב־users
    const { error: profileError } = await supabase.from("users").insert([
      {
        name,
        email,
        age,
        gender,
        height_cm,
        weight_kg,
        goal,
        equipment,
        injuries,
      },
    ]);

    if (profileError) {
      console.error(
        `❌ שגיאה ביצירת פרופיל DB עבור ${email}:`,
        profileError.message
      );
    } else {
      console.log(`✅ נוצר פרופיל DB: ${email}`);
    }
  }
})();
