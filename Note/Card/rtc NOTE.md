#card 

## code
### DW_apb_if
- //先读低32b，此时高16b被缓存;
- //对于Match Register，要求先写低32b，然后写高16b，写入高16b以后，match值有效;
- //对于Load Register，要求先写低32b，然后写高16b，写入高16b以后，Load值有效


## Glossary
### Reg

| 缩写    | 全称                             | 功能  |
| ----- | ------------------------------ | --- |
| CDR   | Current Counter Value Register |     |
| MR    | Counter Match Register         |     |
| CLR   | Counter Load Register          |     |
| CR    | Counter Control Register       |     |
| STAT  | Interrupt Status Register      |     |
| RSTAT | interrupt Raw Status Register  |     |
| EOI   | End of Interrupt Register      |     |
| VID   | Component Version Register     |     |
|       |                                |     |
