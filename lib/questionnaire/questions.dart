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

  const Question({
    required this.id,
    required this.title,
    required this.options,
    required this.showIf,
    this.explanation,
    this.feedback,
    this.multi = false,
    this.inputType = 'select',
  });
}

final List<Question> allQuestions = [
  Question(
    id: 'age',
    title: 'בן כמה אתה?',
    options: [],
    showIf: (_) => true,
    explanation: 'מותאם לרמות קושי שונות ומעקב אחרי התקדמות גילאית.',
    inputType: 'number',
  ),
  Question(
    id: 'height',
    title: 'מה הגובה שלך (בס"מ)?',
    options: [],
    showIf: (_) => true,
    explanation: 'יחד עם המשקל, ניתן לחשב טווח יעד סביר.',
    inputType: 'number',
  ),
  Question(
    id: 'weight',
    title: 'כמה אתה שוקל (בק"ג)?',
    options: [],
    showIf: (_) => true,
    explanation: 'כדי לחשב התאמה בין מסת גוף לאופי האימון.',
    inputType: 'number',
  ),
  Question(
    id: 'exercise_break',
    title: 'האם התאמנת בחצי שנה האחרונה?',
    options: [
      'כן, באופן קבוע',
      'כן, לסירוגין',
      'לא, הייתה לי הפסקה',
      'מעולם לא התאמנתי'
    ],
    showIf: (_) => true,
    explanation:
        'המטרה – להבין את נקודת ההתחלה שלך, זה עוזר לנו לבנות עומסים מתאימים.',
    feedback: (answer) {
      if (answer == 'לא, הייתה לי הפסקה' || answer == 'מעולם לא התאמנתי') {
        return 'מעולה שחזרת! נתחיל בהדרגה 💪';
      }
      if (answer == 'כן, באופן קבוע') {
        return 'יפה! זה יעזור לנו לאתגר אותך יותר.';
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
      'חיטוב ועיצוב',
      'שיפור סיבולת/כושר כללי'
    ],
    showIf: (_) => true,
    explanation: 'כדי לבנות לך תוכנית מותאמת בדיוק למה שאתה רוצה להשיג.',
    feedback: (answer) {
      switch (answer) {
        case 'ירידה במשקל':
          return 'נבחרה תוכנית לירידה מבוקרת במשקל!';
        case 'עלייה במסת שריר':
          return 'תוכנית כוח ומסה בדרך אליך!';
        case 'חיטוב ועיצוב':
          return 'נבנה עבורך תוכנית לחיטוב, כולל המלצות תזונה!';
        case 'שיפור סיבולת/כושר כללי':
          return 'תוכנית אירובית ודינמית מוכנה במיוחד בשבילך!';
        default:
          return null;
      }
    },
  ),
  Question(
    id: 'work_type',
    title: 'איזה סוג עבודה אתה עושה ביום־יום?',
    options: [
      'ישיבה מול מחשב',
      'עבודה פיזית',
      'עבודה מגוונת',
      'לימודים',
      'אחר'
    ],
    showIf: (_) => true,
    explanation: 'נבין כמה הגוף שלך פעיל ביומיום וכמה תמיכה צריך דרך האימונים.',
    feedback: (answer) {
      if (answer == 'ישיבה מול מחשב') {
        return 'אימון עקבי יעזור לך לאזן את חוסר תנועה! 💼🏃‍♂️';
      }
      if (answer == 'עבודה פיזית') {
        return 'הגוף שלך כבר בתנועה – נשלב תרגילים שמחזקים ומאזנים.';
      }
      return null;
    },
  ),
  Question(
    id: 'daily_activity',
    title: 'כמה אתה מרגיש שאתה פעיל במהלך היום?',
    options: ['מעט מאוד', 'בינוני', 'פעיל מאוד'],
    showIf: (_) => true,
    explanation: 'זה ישפיע על רמת האינטנסיביות בתוכנית.',
    feedback: (answer) {
      if (answer == 'מעט מאוד') {
        return 'נבנה תוכנית שמעלה את התנועה בהדרגה 🚶‍♂️';
      }
      if (answer == 'פעיל מאוד') {
        return 'נוכל לאתגר אותך ברמות גבוהות יותר! 💥';
      }
      return null;
    },
  ),
  Question(
    id: 'goal_timeline',
    title: 'כמה זמן אתה רוצה להשקיע כדי להגיע למטרה שלך?',
    options: [
      'כמה שיותר מהר, גם אם זה מאתגר',
      'בתהליך הדרגתי ונכון',
      'אין לי לחץ – בקצב שמתאים לי'
    ],
    showIf: (answers) => answers.containsKey('goal'),
    explanation: 'הציפיות קובעות את מבנה התוכנית והקצב שלה.',
    feedback: (answer) {
      switch (answer) {
        case 'כמה שיותר מהר, גם אם זה מאתגר':
          return 'מדהים! נעבוד בעצימות גבוהה לתוצאות מהירות. ⚡';
        case 'בתהליך הדרגתי ונכון':
          return 'בטוח ויציב – כך נשמור אותך לאורך זמן! 🚶‍♀️🏋️‍♂️';
        default:
          return null;
      }
    },
  ),
  Question(
    id: 'equipment',
    title: 'איזה ציוד יש ברשותך?',
    options: ['ללא ציוד', 'גומיות, משקולות קטנות', 'חדר כושר מלא'],
    showIf: (_) => true,
    explanation: 'כך נדע איזה תרגילים ניתן להציע באופן ישיר.',
    feedback: (answer) {
      if (answer == 'חדר כושר מלא') {
        return 'מעולה! המגוון יתרחב משמעותית בתוכנית שלך.';
      }
      return null;
    },
  ),
  Question(
    id: 'frequency',
    title: 'כמה פעמים בשבוע תוכל להתאמן?',
    options: ['פעם-פעמיים', '3-4 פעמים', '5-6 פעמים', 'כל יום'],
    showIf: (answers) => answers['exercise_break'] != 'מעולם לא התאמנתי',
    explanation: 'ההמלצה היא לפחות פעמיים בשבוע לתוצאות.',
    feedback: (answer) {
      if (answer == 'פעם-פעמיים') {
        return 'התחלה נהדרת! אולי נוסיף גם ימי הליכה 🏃';
      }
      if (answer == '3-4 פעמים') {
        return 'קצב מצוין – זה יספיק להתקדמות אמיתית 🚀';
      }
      return null;
    },
  ),
  Question(
    id: 'workout_time',
    title: 'מתי אתה מעדיף להתאמן?',
    options: ['בוקר', 'צהריים', 'ערב', 'לילה'],
    showIf: (_) => true,
    explanation: 'כדי להתאים את התוכנית לשעות שלך.',
  ),
  Question(
    id: 'workout_duration',
    title: 'כמה זמן תוכל להקדיש לאימון?',
    options: ['30 דקות', '45 דקות', '60 דקות', '90 דקות'],
    showIf: (_) => true,
    explanation: 'נבנה אימונים שמתאימים לזמן שלך.',
  ),
  Question(
    id: 'health',
    title: 'האם יש לך מגבלות רפואיות או פציעות?',
    options: ['לא', 'כן, אציין בהמשך'],
    showIf: (_) => true,
    explanation: 'זה חשוב כדי להימנע מתרגילים שאינם מתאימים לך.',
    feedback: (answer) => answer == 'כן, אציין בהמשך'
        ? 'אל תשכח לפרט לנו על הפציעה בהמשך 🩺'
        : null,
  ),
  Question(
    id: 'experience_level',
    title: 'מה רמת הניסיון שלך באימוני כוח?',
    options: ['מתחיל', 'מתקדם', 'מקצועי'],
    showIf: (_) => true,
    explanation: 'כך נוכל להתאים עומס תרגילים בצורה נכונה.',
  ),
  // שאלות מתקדמות עם multi-select:
  Question(
    id: 'main_muscles_focus',
    title: 'על אילו קבוצות שרירים תרצה לשים דגש?',
    options: [
      'חזה',
      'גב',
      'רגליים',
      'כתפיים',
      'יד קדמית',
      'יד אחורית',
      'בטן',
      'שוקיים'
    ],
    showIf: (_) => true,
    explanation: 'בחר עד שלוש – כך התוכנית תהיה יותר מותאמת.',
    feedback: (ans) => (ans != null && (ans as List).isNotEmpty)
        ? 'נכלול את השרירים שבחרת בתוכנית! 💪'
        : null,
    multi: true,
  ),
  Question(
    id: 'equipment_types',
    title: 'איזה ציוד זמין לך?',
    options: [
      'גומיות',
      'משקוליות',
      'מוט',
      'TRX',
      'פולי',
      'כבל',
      'ספסל',
      'מתקן מתח',
      'אין לי ציוד'
    ],
    showIf: (_) => true,
    explanation: 'כדי לנצל את כל הציוד שברשותך.',
    multi: true,
  ),
  Question(
    id: 'avoid_exercises',
    title: 'האם יש תרגילים שלא תרצה לבצע או שאינך אוהב?',
    options: [
      'סקוואט',
      'דדליפט',
      'עליות מתח',
      'שכיבות סמיכה',
      'בטן/קרנצ\'ים',
      'אין מגבלה'
    ],
    showIf: (_) => true,
    explanation: 'נוכל לכלול אלטרנטיבות במקום תרגילים שלא מתאימים לך.',
    feedback: (ans) => (ans != null && (ans as List).contains('אין מגבלה'))
        ? 'מעולה! הכל אפשרי 😊'
        : null,
    multi: true,
  ),
  Question(
    id: 'pain_or_limitations',
    title: 'האם קיימות מגבלות או כאבים כרוניים שצריך לקחת בחשבון?',
    options: ['ברכיים', 'גב תחתון', 'כתף', 'מרפקים/שורש כף יד', 'צוואר', 'לא'],
    showIf: (_) => true,
    explanation: 'נשמח לדלג על תרגילים שעלולים לפגוע. 🛡️',
    feedback: (ans) => (ans != null && (ans as List).contains('לא'))
        ? 'נשמור על מגוון התרגילים! 👍'
        : null,
    multi: true,
  ),
  Question(
    id: 'preferred_training_style',
    title: 'איזה סגנון אימון אתה מעדיף?',
    options: [
      'אימון מחזורי',
      'HIIT',
      'אימון כוח קלאסי',
      'אירובי/משולב',
      'לא משנה'
    ],
    showIf: (_) => true,
    explanation: 'כך התוכנית תתאים לסגנון שמניע אותך.',
  ),
  Question(
    id: 'training_partners',
    title: 'אתה מתאמן לבד או עם אנשים נוספים?',
    options: ['לבד', 'עם בן/בת זוג', 'עם ילדים', 'עם חבר/ה', 'משתנה'],
    showIf: (_) => true,
    explanation: 'אם רוצים – אפשר להוסיף תרגילים קבוצתיים מותאמים.',
  ),
  Question(
    id: 'intensity_preference',
    title: 'מה רמת האינטנסיביות שאתה מעדיף באימון?',
    options: ['נמוכה', 'בינונית', 'גבוהה', 'לא משנה'],
    showIf: (_) => true,
    explanation: 'כך נוכל לכוון את סטים, מנוחות ועומס בצורה מדויקת.',
  ),
];
