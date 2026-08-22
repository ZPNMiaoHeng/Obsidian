---
week: <% moment().format('gggg-[W]ww') %>
tags:
  - 周记
  - todo
status: 进行中
---
# 🗓 <% moment().format('gggg-[W]ww') %> 周记

> 📅 日期范围：<% moment().startOf('isoWeek').format('YYYY-MM-DD') %> ~ <% moment().endOf('isoWeek').format('YYYY-MM-DD') %>（周一 ~ 周日）

## 🎯 本周目标
- [ ] 目标 1
- [ ] 目标 2
- [ ] 目标 3

## 📋 本周任务
- [ ] 任务 1
- [ ] 任务 2

## ✅ 完成情况
- 

## 📝 问题记录
- 

## 📌 遗留问题
- 

## 🔭 下周计划
- 

## 💭 反思
- 做得好的：
- 需要改进的：

---

> 📥 本周日记中的未完成任务（自动汇总）

```dataview
TASK FROM "Note/Daily"
WHERE !completed AND dateformat(file.day, "kkkk-'W'ww") = this.week
SORT file.day ASC
```

%% 本模板由 Templater 自动应用：
- 周号、标题、日期范围会根据创建日期自动填充，无需手动修改；
- 底部 Dataview 查询自动汇总本周日记中的未完成任务。
%%
