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

## 📋 دليل الاستخدام خطوة بخطوة

### الخطوة 1: تثبيت المتطلبات

تحتاج 3 أدوات مُثبتة على جهازك:

| الأداة | الإصدار المطلوب | التثبيت |
|--------|----------------|---------|
| **Node.js** | ≥ 22 | [nodejs.org](https://nodejs.org) |
| **pnpm** | ≥ 10 | `npm install -g pnpm` |
| **Python** | ≥ 3.10 | [python.org](https://python.org) |

تحقق من التثبيت:
```bash
node --version    # يجب أن يظهر v22.x.x أو أعلى
pnpm --version    # يجب أن يظهر 10.x.x أو أعلى
python --version  # يجب أن يظهر 3.10.x أو أعلى
```

### الخطوة 2: تثبيت CodeX-Ray (مرة واحدة فقط)

CodeX-Ray تُثبّت في مجلد مخفي ثابت في Home — مستقل عن أي مشروع:

| النظام | مسار التثبيت |
|--------|-------------|
| **Windows** | `C:\Users\<user>\.codex-ray\` |
| **macOS** | `/Users/<user>/.codex-ray/` |
| **Linux** | `/home/<user>/.codex-ray/` |

```bash
# 1. استنسخ الأداة في مجلد ثابت (مرة واحدة)
git clone https://github.com/blackmoon87/CodeX-Ray.git ~/.codex-ray

# 2. ادخل مجلد الأداة
cd ~/.codex-ray/codex-ray-plugin

# 3. ثبّت كل التبعيات (Tree-sitter + محللات اللغات)
pnpm install

# 4. عند ظهور approve-builds — اختر الكل واوافق
pnpm approve-builds
# اضغط 'a' لاختيار الكل، ثم Enter، ثم 'y' للموافقة

# 5. ابنِ محرك التحليل
pnpm --filter @codex-ray/core build
```

> ✅ بعد هذه الخطوة، CodeX-Ray جاهزة للاستخدام. لا تحتاج إعادة التثبيت مرة أخرى.
> الأداة مستقلة تماماً عن مشاريعك — لن تتعطل لو حذفت أي مشروع.

### الخطوة 3: تحليل أي مشروع

#### الطريقة A: عبر Antigravity (الأسهل)

افتح أي محادثة مع Antigravity واطلب:

```
حلل المشروع c:\path\to\my-project
```

أو بالإنجليزية:
```
Analyze the project at c:\path\to\my-project using CodeX-Ray
```

Antigravity سيقوم تلقائياً بتشغيل الأداة عبر 7 مراحل وينتج `knowledge-graph.json`.

#### الطريقة B: يدوياً من سطر الأوامر

```bash
# حدد مسار مشروعك
$PROJECT = "c:\path\to\my-project"
$SKILL   = "$HOME\.codex-ray\codex-ray-plugin\skills\understand"

# المرحلة 1: مسح الملفات
node "$SKILL\scan-project.mjs" "$PROJECT"

# المرحلة 1.5: تقسيم الدفعات
node "$SKILL\compute-batches.mjs" "$PROJECT"

# المرحلة 2: استخراج البنية لكل ملف
node "$SKILL\extract-structure.mjs" "$PROJECT"

# المرحلة 2 (دمج): تجميع النتائج
python "$SKILL\merge-batch-graphs.py" "$PROJECT"

# المرحلة 7: بناء البصمات
node "$SKILL\build-fingerprints.mjs" "$PROJECT\.codex-ray\intermediate\fingerprint-input.json"
```

> ⚠️ المراحل 2-6 تتطلب نموذج LLM لإنتاج الملخصات والتصنيفات. الطريقة A عبر Antigravity تتولى هذا تلقائياً.

---

## 🔄 ماذا يحصل في كل مرحلة؟

```
المشروع المُدخل
    │
    ▼
┌─────────────────────────────────────┐
│ المرحلة 0: التحضير                  │
│ • تحديد مسار المشروع                │
│ • قراءة README + package.json       │
│ • قرار: تحليل كامل أم تدريجي       │
└──────────────┬──────────────────────┘
               ▼
┌─────────────────────────────────────┐
│ المرحلة 1: المسح (scan-project.mjs) │
│ • اكتشاف كل الملفات                │
│ • تحديد اللغة لكل ملف              │
│ • تصنيف: code/config/docs/infra    │
│ • استخراج خريطة الاستيراد           │
│ ← الناتج: scan-result.json         │
└──────────────┬──────────────────────┘
               ▼
┌─────────────────────────────────────┐
│ المرحلة 1.5: التقسيم               │
│ (compute-batches.mjs)               │
│ • تقسيم الملفات لمجموعات 20-30 ملف │
│ • ربط الجيران عبر المجموعات         │
│ ← الناتج: batches.json             │
└──────────────┬──────────────────────┘
               ▼
┌─────────────────────────────────────┐
│ المرحلة 2: التحليل (5 متوازي)      │
│ • Tree-sitter: دوال، كلاسات         │
│ • LLM: ملخص، وسوم، تعقيد           │
│ • إنتاج nodes + edges لكل ملف      │
│ • دمج الكل: merge-batch-graphs.py  │
│ ← الناتج: assembled-graph.json     │
└──────────────┬──────────────────────┘
               ▼
┌─────────────────────────────────────┐
│ المرحلة 3: مراجعة التجميع          │
│ • فحص edges يتيمة                   │
│ • فحص nodes بدون علاقات             │
│ • تطابق مع نتائج المسح             │
└──────────────┬──────────────────────┘
               ▼
┌─────────────────────────────────────┐
│ المرحلة 4: التصنيف المعماري        │
│ • تجميع بالمجلدات                   │
│ • مطابقة أنماط: routes→API          │
│ • تعيين 3-10 طبقات                  │
│ ← الناتج: layers.json              │
└──────────────┬──────────────────────┘
               ▼
┌─────────────────────────────────────┐
│ المرحلة 5: الجولة التعليمية        │
│ • تحديد نقطة الدخول                 │
│ • BFS من Entry Point                │
│ • 5-15 خطوة تعليمية مرتبة           │
│ ← الناتج: tour.json                │
└──────────────┬──────────────────────┘
               ▼
┌─────────────────────────────────────┐
│ المرحلة 6: التحقق النهائي          │
│ • 9 فحوصات جودة                     │
│ • إصلاح تلقائي للمشاكل البسيطة     │
│ • تقرير بالتحذيرات                  │
└──────────────┬──────────────────────┘
               ▼
┌─────────────────────────────────────┐
│ المرحلة 7: الحفظ                    │
│ • كتابة knowledge-graph.json       │
│ • كتابة meta.json (commit hash)    │
│ • بناء بصمات للتحديث التدريجي      │
│ • تنظيف الملفات المؤقتة             │
└─────────────────────────────────────┘
               ▼
    .codex-ray/knowledge-graph.json ✅
```

---

## 📊 الناتج: knowledge-graph.json

ملف JSON واحد في `.codex-ray/knowledge-graph.json` يحتوي 4 أقسام:

### 1. Nodes (العُقد) — كل عنصر في المشروع

```json
{
  "id": "file:src/auth/login.ts",
  "type": "file",
  "name": "login.ts",
  "filePath": "src/auth/login.ts",
  "summary": "Handles user authentication with JWT tokens and session management",
  "tags": ["auth", "security", "api-handler"],
  "complexity": "moderate"
}
```

أنواع العُقد: `file` `function` `class` `config` `document` `service` `table` `endpoint` `pipeline` `schema` `resource` `domain` `flow` `step`

### 2. Edges (الحواف) — كل علاقة بين العناصر

```json
{
  "source": "file:src/app.ts",
  "target": "file:src/auth/login.ts",
  "type": "imports",
  "direction": "forward",
  "weight": 0.7
}
```

أنواع العلاقات: `imports` `exports` `contains` `inherits` `implements` `calls` `depends_on` `tested_by` `configures` `deploys` `documents` `triggers` `defines_schema` `routes` `related`

### 3. Layers (الطبقات) — التصنيف المعماري

```json
{
  "id": "layer:api",
  "name": "API Layer",
  "description": "Route handlers, controllers, and HTTP endpoints",
  "nodeIds": ["file:src/routes/auth.ts", "file:src/routes/users.ts"]
}
```

### 4. Tour (الجولة) — دليل تعليمي مرتب

```json
{
  "order": 1,
  "title": "Project Overview",
  "description": "Start with the README to understand the project's purpose",
  "nodeIds": ["document:README.md"]
}
```

---

## 🎯 ماذا تفعل بعد التحليل؟

بعد إنتاج `knowledge-graph.json`، اطلب من Antigravity:

| الطلب | ماذا يحصل |
|-------|-----------|
| `"اسأل: وين يتم التحقق من المستخدم؟"` | يبحث في nodes بالـ tags والـ summary ويجيب |
| `"لو غيرت auth.ts، شو يتأثر؟"` | يتتبع edges من الملف → كل الملفات المتأثرة |
| `"اشرح ملف database.ts"` | يجمع معلومات الـ node + يقرأ الملف الفعلي → شرح عميق |
| `"أنشئ دليل onboarding"` | يستخدم الـ tour لإنشاء دليل مطور جديد |
| `"حلل منطق الأعمال"` | يستخرج domains وflows من الكود |
| `"حلل تأثير آخر commit"` | يقارن git diff مع الـ graph → تقرير تأثير |
| `"حدّث الـ graph"` | تحديث تدريجي — يحلل الملفات المتغيرة فقط |

---

## 🔄 التحديث التدريجي

عند تغيير الكود، لا تحتاج إعادة تحليل كامل:

```
حدّث الـ knowledge graph
```

CodeX-Ray ستقارن الـ commit الحالي مع آخر تحليل، وتعيد تحليل **الملفات المتغيرة فقط**.

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
