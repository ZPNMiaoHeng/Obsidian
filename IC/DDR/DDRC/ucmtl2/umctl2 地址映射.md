#card 


| 地址  | 数据         |                                                                                              |                                                                 |
| --- | ---------- | -------------------------------------------------------------------------------------------- | --------------------------------------------------------------- |
| 204 | 0x3f1919   | addrmap_bank_b2: 0x3f<br>addrmap_bank_b1: 0x19<br>addrmap_bank_b0: 0x19                      | bank[2]=hif[63]<br>bank[1]=hif[28]<br>bank[0]=hif[27]           |
| 208 | 0          |                                                                                              |                                                                 |
| 20c | 0          |                                                                                              |                                                                 |
| 210 | 0x1f1f     | addrmap_col_b11: 0x1f<br>addrmap_col_b10: 0x1f                                               | col_b11=unused<br>col_b10=unused                                |
| 214 | 0x40f_0404 | addrmap_row_b11: 0x4<br>addrmap_row_b2_10: 0xf<br>addrmap_row_b1: 0x4<br>addrmap_row_b0: 0x4 | b11=hif[21]<br>b2-10在addrmap9、10、11<br>b1=hif[11]<br>b0=hif[10] |
| 218 | 0x404_0404 | addrmap_row_b15: 0x4<br>addrmap_row_b14: 0x4<br>addrmap_row_b13: 0x4<br>addrmap_row_b12: 0x4 | b15=hif[25]<br>b14=hif[24]<br>b13=hif[23]<br>b12=hif[22]        |
| 21c | 0xf04      | addrmap_row_b17: 0xf<br>addrmap_row_b16: 0x4                                                 | b17=0,unused<br>b16=hif[26]                                     |
| 220 | 0x1b1b     | addrmap_bg_b1: 0x1b<br>addrmap_bg_b0: 0x1b                                                   | bg[1]=hif[30]<br>bg[0]=hif[29]                                  |
| 224 | 0x404_0404 | addrmap_row_b5: 0x4<br>addrmap_row_b4: 0x4<br>addrmap_row_b3: 0x4<br>addrmap_row_b2: 0x4     | b5=hif[15]<br>b4=hif[14]<br>b3=hif[13]<br>b2=hif[12]            |
| 228 | 0x404_0404 | addrmap_row_b9: 0x4<br>addrmap_row_b8: 0x4<br>addrmap_row_b7: 0x4<br>addrmap_row_b6: 0x4     | b9=hif[19]<br>b8=hif[18]<br>b7=hif[17]<br>b6=hif[16]            |
| 22c | 0x1f_1f04  | addrmap_cid_b1: 0x1f<br>addrmap_cid_b0: 0x1f<br>addrmap_row_b10: 0x4                         | cid_b1 unused;<br>cid_b0 unused;<br>b10=hif[20]                 |
- col[9:2]=hif[9:2];
- col[11:10] unused;
- row[16:0]=hif[26:10];
- ba[1:0]=hif[28:27];
- bg[1:0]=hif[30:29];