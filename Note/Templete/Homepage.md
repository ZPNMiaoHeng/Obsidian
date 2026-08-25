
> 📅 `= dateformat(date(today), "yyyy年MM月dd日 EEEE")`  
> 🕒 `= date(today).year` 年已过 `= (date(today) - date(date(today).year + "-01-01")).days` 天

```contributionGraph
title: 👣 足迹
graphType: default
dateRangeValue: 6
dateRangeType: LATEST_MONTH
startOfWeek: 1
showCellRuleIndicators: true
titleStyle:
  textAlign: center
  fontSize: 15px
  fontWeight: normal
dataSource:
  type: PAGE
  value: ""
  dateField: {}
fillTheScreen: true
enableMainContainerShadow: false
cellStyleRules:
  - id: Ocean_a
    color: "#8dd1e2"
    min: 1
    max: 2
    text:
  - id: Ocean_b
    color: "#63a1be"
    min: 2
    max: 3
    text:
  - id: Ocean_c
    color: "#376d93"
    min: 3
    max: 5
    text:
  - id: Ocean_d
    color: "#012f60"
    min: 5
    max: 9999
    text:

```
# 🏠 工作台

## 🧭 快捷入口
- 📅 [[Daily temp|今日日记模板]] ｜ 🗓 [[Weekly temp|周记模板]] ｜ 🃏 [[QA.md|QA 问题库]] ｜ 🧠 [[PCIe-mindmap|PCIe 导图]]

## ✅ 今日聚焦
```dataview

TASK FROM "Note/Daily" WHERE file.day = date(today) AND !completed SORT text ASC

```
## ⏰ 逾期未完成（近 7 天）
```dataview

TASK FROM "Note/Daily" WHERE !completed AND file.day < date(today) AND file.day >= date(today) - dur(7 days) SORT file.day ASC

```

## 📌 本周周记
```dataview

TABLE WITHOUT ID file.link AS "周记", dateformat(file.mtime, "MM-dd HH:mm") AS "最近更新"
WHERE file.name = dateformat(date(today), "kkkk-'W'WW")

```
```dataviewjs
// 创建 / 打开本周周记（新建时直接调用 Templater 套用 Weekly temp 模板）
const week = window.moment().format("gggg-[W]ww");
const folder = "Note/Weekly";
const path = `${folder}/${week}.md`;
const hasNote = !!app.vault.getAbstractFileByPath(path);
const btn = dv.el("button", hasNote ? `📂 打开本周周记（${week}）` : `➕ 创建本周周记（${week}）`);
btn.style.cssText = "cursor:pointer;padding:4px 14px;border-radius:6px;border:none;font-size:14px;background:var(--interactive-accent);color:var(--text-on-accent);";
btn.addEventListener("click", async () => {
  if (hasNote) {
    app.workspace.openLinkText(path, "", true);
    return;
  }
  const templater = app.plugins.getPlugin("templater-obsidian");
  if (templater) {
    const tpl = app.vault.getAbstractFileByPath("Note/Templete/Weekly temp.md");
    await templater.templater.create_new_note_from_template(tpl, folder, week, true);
  } else {
    await app.vault.create(path, "");
    app.workspace.openLinkText(path, "", true);
  }
});
```

## 🆕 最近更新
```dataview

TABLE WITHOUT ID file.link AS "笔记", dateformat(file.mtime, "MM-dd HH:mm") AS "更新时间"
WHERE !contains(file.folder, "Daily") AND !contains(file.path, "copilot") AND file.name != this.file.name
SORT file.mtime DESC
LIMIT 10

```

## 🃏 最近知识卡片
```dataview

TABLE WITHOUT ID file.link AS "卡片", dateformat(file.ctime, "yyyy-MM-dd") AS "创建时间"
FROM "Note/Card"
SORT file.ctime DESC
LIMIT 8

```

## 🔍 最近 QA 记录
```dataview

TABLE WITHOUT ID file.link AS "问题", dateformat(file.mtime, "yyyy-MM-dd") AS "更新时间"
FROM "Note/QA"
SORT file.mtime DESC
LIMIT 8

```

## 📁 绘图与导图

### ✏️ Excalidraw 绘图
```dataview

TABLE WITHOUT ID file.link AS "绘图", dateformat(file.mtime, "MM-dd HH:mm") AS "修改时间"
FROM "Note/Excalidraw"
SORT file.mtime DESC
LIMIT 8

```

### 🧠 思维导图
```dataview

TABLE WITHOUT ID file.link AS "导图", dateformat(file.mtime, "MM-dd HH:mm") AS "修改时间"
FROM "Note/mindmap"
SORT file.mtime DESC
LIMIT 8

```

## 📊 知识库统计
```dataview

TABLE length(rows) AS "笔记数"
FROM "Note"
WHERE file.name != this.file.name AND !contains(file.folder, "Templete") AND !contains(file.path, "copilot")
GROUP BY file.folder
SORT length(rows) DESC

```

## 🗓 历史上的今天
```dataview

TABLE WITHOUT ID file.link AS "日记", dateformat(file.day, "yyyy") AS "年份"
FROM "Note/Daily"
WHERE dateformat(file.day, "MM-dd") = dateformat(date(today), "MM-dd")
SORT file.day DESC

```
