---
date: {{date:YYYY-MM-DD}}
tags:
  - 日记
  - todo
status: 进行中
---
# 📅 {{date:YYYY-MM-DD}}


> [!tip] 🎯 今日要事（最多 3 件）
> - ▢
> - ▢
> - ▢

# Day planner

---

## 🔖 短期要做的事情
- [[Study]]
- [[project|pro]]

## 📝 问题记录
- 现象：
- 定位过程：
- 结论 / 关联笔记：

## 🧠 今日收获
- 

## 🌙 晚间回顾
- ✅ 完成情况：
- ⚠️ 遗留事项：
- 🔭 明日计划：

---

## ⏳ 遗留未完成（近 7 天自动汇总）
```dataview
TASK FROM "Note/Daily"
WHERE !completed AND file.day < date(today) AND file.day >= date(today) - dur(7 days)
SORT file.day ASC
```
