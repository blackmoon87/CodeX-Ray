# 🔬 CodeX-Ray

> **أداة تحليل أي كودبيس وتحويله لـ Knowledge Graph**
> نسخة مُقلّمة مع دعم كامل لـ Antigravity

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

---

## ما هي CodeX-Ray؟

CodeX-Ray تأخذ أي مشروع برمجي وتنتج **خريطة ذكية** (`knowledge-graph.json`) تحتوي:

- 🧩 **كل ملف/دالة/كلاس** مع ملخص واضح
- 🔗 **كل العلاقات** (imports, calls, contains, inherits, ...)
- 🏗️ **التصنيف المعماري** (API, Service, Data, UI, ...)
- 🎓 **جولة تعليمية مرتبة** للمطورين الجدد

هذه الخريطة تمكّن أي نموذج ذكاء اصطناعي من **فهم كودبيس ضخم** (200K+ سطر) بدون قراءة كل سطر.

---

## الاستخدام مع Antigravity

فقط اطلب في أي محادثة:

```
"حلل المشروع c:\path\to\project"
"افهم هذا الكود"
"/understand"
```

Antigravity سيقوم تلقائياً بـ 7 مراحل:

1. 📂 مسح كل الملفات واكتشاف اللغات والأُطر
2. 🔍 استخراج البنية (دوال، كلاسات، imports) عبر Tree-sitter
3. 🧠 تحليل كل ملف وإنتاج ملخصات ذكية
4. 🏗️ تصنيف الطبقات المعمارية
5. 🎓 بناء جولة تعليمية
6. ✅ التحقق من الجودة والتكامل
7. 💾 حفظ `knowledge-graph.json`

### أوامر إضافية بعد التحليل

| الأمر | الوظيفة |
|-------|---------|
| `اسأل عن الكود` | سؤال وجواب باستخدام الـ Knowledge Graph |
| `حلل تأثير التغييرات` | تتبع الملفات المتأثرة عبر الـ edges |
| `اشرح <ملف>` | شرح عميق لملف أو دالة محددة |
| `أنشئ دليل onboarding` | دليل مطور جديد مبني على الـ tour |
| `حلل منطق الأعمال` | استخراج domains و business flows |

---

## اللغات المدعومة (23 لغة)

`TypeScript` `JavaScript` `Python` `Go` `Rust` `Java` `Kotlin` `C#` `C++` `Swift` `Ruby` `PHP` `SQL` `GraphQL` `Protobuf` `Terraform` `Dockerfile` `Shell` `YAML` `JSON` `HTML` `CSS` `Markdown`

## الأُطر المدعومة (10 أُطر)

`React` `Next.js` `Vue` `Express` `Django` `FastAPI` `Flask` `Rails` `Spring` `Gin`

---

## البنية

```
codex-ray-plugin/
├── agents/           ← 9 عقول متخصصة
│   ├── project-scanner.md
│   ├── file-analyzer.md
│   ├── architecture-analyzer.md
│   ├── tour-builder.md
│   ├── graph-reviewer.md
│   └── ...
├── skills/           ← 8 أوامر + scripts تنفيذية
│   ├── understand/   ← المنسق الرئيسي + 8 scripts
│   ├── understand-chat/
│   ├── understand-diff/
│   ├── understand-explain/
│   ├── understand-onboard/
│   ├── understand-domain/
│   ├── understand-knowledge/
│   └── understand-dashboard/
├── packages/core/    ← محرك التحليل (types, schema, tree-sitter, plugins)
├── src/              ← منطق TypeScript للمهارات
└── hooks/            ← تحديث تلقائي عند الـ commit
```

---

## المتطلبات

- **Node.js** ≥ 22
- **pnpm** ≥ 10

## التثبيت (مرة واحدة)

```bash
cd codex-ray-plugin
pnpm install
pnpm --filter @codex-ray/core build
```

---

## الناتج

ملف `knowledge-graph.json` في مجلد `.codex-ray/` داخل المشروع المُحلل:

```json
{
  "version": "1.0.0",
  "project": {
    "name": "my-project",
    "languages": ["typescript", "python"],
    "frameworks": ["React", "FastAPI"]
  },
  "nodes": [
    {
      "id": "file:src/auth/login.ts",
      "type": "file",
      "summary": "Handles JWT authentication flow",
      "tags": ["auth", "security", "api-handler"],
      "complexity": "moderate"
    }
  ],
  "edges": [
    {
      "source": "file:src/app.ts",
      "target": "file:src/auth/login.ts",
      "type": "imports",
      "weight": 0.7
    }
  ],
  "layers": [
    { "id": "layer:api", "name": "API Layer", "nodeIds": ["..."] }
  ],
  "tour": [
    { "order": 1, "title": "Project Overview", "nodeIds": ["document:README.md"] }
  ]
}
```

---

## النهج التقني

```
Tree-sitter (حتمي 100%) → البنية: imports, functions, classes
LLM (دلالي)             → المعنى: summaries, tags, complexity
```

> الفصل بين التحليل الهيكلي والدلالي هو سر دقة الأداة.

---

## المصدر الأصلي

مبني على [Understand-Anything](https://github.com/Lum1104/Understand-Anything) بواسطة [Lum1104](https://github.com/Lum1104)

MIT License — نسخة مُقلّمة ومُعدّلة بدعم Antigravity بواسطة [blackmoon87](https://github.com/blackmoon87)
