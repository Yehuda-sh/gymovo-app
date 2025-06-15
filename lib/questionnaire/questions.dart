// lib/questionnaire/questions.dart

class Question {
  final String id;
  final String title;
  final List<String> options;
  final bool Function(Map<String, dynamic> answers) showIf;
  final String? explanation;
  final String? Function(dynamic answer)? feedback;
  final bool multi;
  final String inputType; // 'select' | 'number' | 'text'
  final int? maxSelections; // מגבלת בחירות מרובות

  const Question({
    required this.id,
    required this.title,
    required this.options,
    required this.showIf,
    this.explanation,
    this.feedback,
    this.multi = false,
    this.inputType = 'select',
    this.maxSelections,
  });
}

final List<Question> allQuestions = [
  // קבוצה 1: פרטים בסיסיים
  Question(
      id: 'age',
      title: 'בן/בת כמה את/ה?',
      options: [],
      showIf: (_) => true,
      explanation: 'גילאי 16-90. מותאם לרמות קושי ומעקב התקדמות.',
      inputType: 'number',
      feedback: (answer) {
        if (answer != null && answer < 16) return 'האפליקציה מיועדת לגילאי 16+';
        if (answer != null && answer > 90)
          return 'מומלץ להתייעץ עם רופא לפני תחילת אימונים';
        return null;
      }),

  Question(
    id: 'height',
    title: 'מה הגובה שלך (בס"מ)?',
    options: [],
    showIf: (_) => true,
    explanation: 'לחישוב יחסי גוף ויעדים מותאמים.',
    inputType: 'number',
  ),

  Question(
    id: 'weight',
    title: 'מה המשקל שלך (בק"ג)?',
    options: [],
    showIf: (_) => true,
    explanation: 'לחישוב עצימות והתאמת עומסים.',
    inputType: 'number',
  ),

  // קבוצה 2: רקע ומטרות
  Question(
    id: 'exercise_break',
    title: 'האם התאמנת בחצי שנה האחרונה?',
    options: [
      'כן, באופן קבוע (3+ פעמים בשבוע)',
      'כן, לסירוגין (1-2 פעמים בשבוע)',
      'לא, הייתה לי הפסקה',
      'מעולם לא התאמנתי'
    ],
    showIf: (_) => true,
    explanation: 'להבנת נקודת ההתחלה ובניית עומסים מתאימים.',
    feedback: (answer) {
      if (answer == 'לא, הייתה לי הפסקה' || answer == 'מעולם לא התאמנתי') {
        return 'מצוין שהחלטת להתחיל! נבנה תוכנית הדרגתית 💪';
      }
      if (answer == 'כן, באופן קבוע (3+ פעמים בשבוע)') {
        return 'נהדר! נוכל לאתגר אותך ברמות גבוהות יותר 🚀';
      }
      return null;
    },
  ),

  Question(
    id: 'goal',
    title: 'מה המטרה המרכזית שלך?',
    options: [
      'ירידה במשקל',
      'עלייה במסת שריר',
      'חיטוב ועיצוב הגוף',
      'שיפור כושר גופני כללי',
      'שיפור בריאות וחיוניות'
    ],
    showIf: (_) => true,
    explanation: 'המטרה קובעת את סוג התוכנית והדגשים.',
    feedback: (answer) {
      switch (answer) {
        case 'ירידה במשקל':
          return 'נבנה תוכנית המשלבת אימוני כוח ואירובי 🏃‍♂️';
        case 'עלייה במסת שריר':
          return 'תוכנית כוח פרוגרסיבית בדרך! 💪';
        case 'חיטוב ועיצוב הגוף':
          return 'שילוב מושלם של כוח וסיבולת לחיטוב 🎯';
        default:
          return null;
      }
    },
  ),

  Question(
    id: 'goal_timeline',
    title: 'באיזה קצב תרצה להתקדם?',
    options: [
      'מהיר ואינטנסיבי - תוצאות מהירות',
      'מתון ובטוח - התקדמות הדרגתית',
      'איטי ונינוח - ללא לחץ'
    ],
    showIf: (answers) => answers.containsKey('goal'),
    explanation: 'הקצב משפיע על עצימות ותדירות האימונים.',
    feedback: (answer) {
      if (answer == 'מהיר ואינטנסיבי - תוצאות מהירות') {
        return 'מוכנים לעבוד קשה! זכור - התאוששות חשובה לא פחות ⚡';
      }
      return null;
    },
  ),

  // קבוצה 3: זמינות וציוד
  Question(
    id: 'frequency',
    title: 'כמה פעמים בשבוע תוכל להתאמן?',
    options: ['1-2 פעמים', '3-4 פעמים', '5-6 פעמים', 'כל יום'],
    showIf: (_) => true,
    explanation: 'מינימום 2 פעמים בשבוע לתוצאות משמעותיות.',
    feedback: (answer) {
      if (answer == '1-2 פעמים') {
        return 'נמקסם את היעילות בכל אימון! 🎯';
      }
      if (answer == '3-4 פעמים') {
        return 'תדירות אידיאלית להתקדמות מצוינת! 👏';
      }
      return null;
    },
  ),

  Question(
    id: 'workout_duration',
    title: 'כמה זמן תוכל להקדיש לכל אימון?',
    options: ['עד 30 דקות', '30-45 דקות', '45-60 דקות', 'מעל שעה'],
    showIf: (_) => true,
    explanation: 'נתאים את התוכנית לחלון הזמן שלך.',
  ),

  Question(
    id: 'equipment',
    title: 'איפה תתאמן בדרך כלל?',
    options: [
      'בבית - ללא ציוד',
      'בבית - עם ציוד בסיסי',
      'חדר כושר ביתי מאובזר',
      'מכון כושר מקצועי'
    ],
    showIf: (_) => true,
    explanation: 'נבנה תוכנית המתאימה לסביבת האימון שלך.',
  ),

  // שאלה מותנית - רק אם לא בחרו מכון כושר
  Question(
    id: 'home_equipment',
    title: 'איזה ציוד יש לך בבית?',
    options: [
      'גומיות התנגדות',
      'משקולות/דמבלים',
      'קטלבל',
      'מוט כושר',
      'ספסל אימונים',
      'מתקן מתח',
      'TRX/רצועות',
      'מזרן יוגה'
    ],
    showIf: (answers) =>
        answers['equipment'] == 'בבית - עם ציוד בסיסי' ||
        answers['equipment'] == 'חדר כושר ביתי מאובזר',
    explanation: 'נוודא שכל התרגילים מתאימים לציוד שלך.',
    multi: true,
  ),

  // קבוצה 4: מגבלות ובריאות
  Question(
    id: 'health_limitations',
    title: 'האם יש מגבלות בריאותיות שכדאי לדעת עליהן?',
    options: [
      'אין מגבלות',
      'בעיות גב/עמוד שדרה',
      'בעיות ברכיים',
      'בעיות כתפיים',
      'לחץ דם גבוה',
      'סוכרת',
      'אחר - אפרט בהמשך'
    ],
    showIf: (_) => true,
    explanation: 'חשוב לנו לשמור על הבריאות שלך.',
    multi: true,
    feedback: (answer) {
      if (answer != null && (answer as List).contains('אין מגבלות')) {
        return 'מעולה! נוכל להשתמש במגוון רחב של תרגילים 💪';
      }
      return 'נתאים את התוכנית למגבלות שציינת 🛡️';
    },
  ),

  Question(
    id: 'experience_level',
    title: 'מה רמת הניסיון שלך באימונים?',
    options: [
      'מתחיל מוחלט',
      'מתחיל עם ניסיון בסיסי',
      'מתאמן בינוני',
      'מתקדם',
      'מנוסה מאוד'
    ],
    showIf: (_) => true,
    explanation: 'להתאמת מורכבות התרגילים והטכניקה.',
  ),

  // קבוצה 5: העדפות (אופציונלי)
  Question(
    id: 'body_focus',
    title: 'יש אזורים ספציפיים שתרצה לחזק?',
    options: ['פלג גוף עליון', 'פלג גוף תחתון', 'ליבה ובטן', 'גוף מלא - מאוזן'],
    showIf: (answers) =>
        answers['goal'] == 'חיטוב ועיצוב הגוף' ||
        answers['goal'] == 'עלייה במסת שריר',
    explanation: 'בחר עד 2 אזורי מיקוד.',
    multi: true,
    maxSelections: 2,
  ),

  Question(
    id: 'workout_style_preference',
    title: 'איזה סגנון אימון מדבר אליך?',
    options: [
      'אימוני כוח מסורתיים',
      'אימונים פונקציונליים',
      'HIIT ואינטרוולים',
      'אימוני סיבולת',
      'שילוב מגוון'
    ],
    showIf: (_) => true,
    explanation: 'נשלב את הסגנון המועדף בתוכנית.',
    multi: true,
    maxSelections: 2,
  ),

  Question(
    id: 'avoid_exercises',
    title: 'יש תרגילים שתעדיף להימנע מהם?',
    options: [
      'סקוואט',
      'דדליפט',
      'עליות מתח',
      'לחיצת חזה',
      'תרגילי בטן על הרצפה',
      'ריצה/קפיצות',
      'אין העדפה מיוחדת'
    ],
    showIf: (_) => true,
    explanation: 'נמצא חלופות מתאימות לכל תרגיל.',
    multi: true,
  ),

  // שאלה אחרונה - תזונה
  Question(
    id: 'nutrition_guidance',
    title: 'האם תרצה גם הדרכה תזונתית?',
    options: ['כן, הדרכה מלאה', 'רק טיפים בסיסיים', 'לא, רק אימונים'],
    showIf: (answers) =>
        answers['goal'] == 'ירידה במשקל' ||
        answers['goal'] == 'עלייה במסת שריר' ||
        answers['goal'] == 'חיטוב ועיצוב הגוף',
    explanation: 'תזונה נכונה היא 70% מההצלחה!',
    feedback: (answer) {
      if (answer == 'כן, הדרכה מלאה') {
        return 'נכלול המלצות תזונה מותאמות אישית! 🥗';
      }
      return null;
    },
  ),
];
