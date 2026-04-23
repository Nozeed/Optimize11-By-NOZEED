# Boost By Nozeed

ไฟล์ในโฟลเดอร์นี้มีไว้สำหรับปรับแต่ง Windows ให้เหมาะกับการเล่น FiveM / GTA V, ใช้ Voice Chat, ทำงานเว็บใน Windsurf, ท่องเว็บ และงานตัดต่อเบื้องต้น

## ไฟล์ที่มี

- **`Optimize-FiveM-By-Nozeed-Ultimate.ps1`**
  สคริปต์ PowerShell สำหรับปรับแต่งระบบแบบรวมชุด

## สิ่งที่สคริปต์ทำ

- **ยกระดับสิทธิ์เป็น Admin อัตโนมัติ**
  ถ้าเปิดแบบปกติ สคริปต์จะเรียกตัวเองใหม่ด้วยสิทธิ์ผู้ดูแลระบบ

- **สำรอง Registry และบันทึก Log**
  สคริปต์จะสร้างโฟลเดอร์ `backup-วันเวลา` เพื่อเก็บไฟล์ `.reg` และ log การทำงาน

- **พยายามสร้าง Restore Point**
  ถ้า Windows อนุญาต จะสร้าง System Restore Point ให้ก่อนปรับแต่ง

- **ลบ Bloatware บางส่วน**
  รวมถึง OneDrive, Copilot, Xbox overlays, Teams, Clipchamp และแอปที่ไม่จำเป็นหลายตัว

- **ปรับ Visual ให้เบาลง**
  ลด animation, transparency และเปิด classic right-click

- **จูน Gaming / Latency**
  ปิด GameDVR บางส่วน, ปรับ `MMCSS`, `NetworkThrottlingIndex`, `SystemResponsiveness`

- **เร่งความสำคัญของโปรเซสเกม**
  โฟกัสไปที่ `FiveM.exe`, `FiveM_GTAProcess.exe`, `GTA5.exe`

- **จูน Memory และ Services**
  ปรับ memory related registry และปิด/ปรับ service ที่ไม่จำเป็นบางส่วน

- **เปิด Ultimate Performance**
  ตั้ง Power Plan ให้เหมาะกับการรีดเฟรมและลดการหน่วง

## วิธีใช้งาน

1. เปิด PowerShell แบบ `Run as Administrator`
2. เข้าไปที่โฟลเดอร์นี้
3. รันคำสั่ง:

```powershell
powershell -ExecutionPolicy Bypass -File ".\Optimize-FiveM-By-Nozeed-Ultimate.ps1"
```

## ตัวเลือกเสริม

- **ข้ามการลบ Bloatware**

```powershell
powershell -ExecutionPolicy Bypass -File ".\Optimize-FiveM-By-Nozeed-Ultimate.ps1" -SkipBloatwareRemoval
```

- **ข้ามการปิด service**

```powershell
powershell -ExecutionPolicy Bypass -File ".\Optimize-FiveM-By-Nozeed-Ultimate.ps1" -SkipServiceTweaks
```

- **ข้ามการสร้าง restore point**

```powershell
powershell -ExecutionPolicy Bypass -File ".\Optimize-FiveM-By-Nozeed-Ultimate.ps1" -SkipRestorePoint
```

- **รันตรงจาก GitHub**
  
```powershell
irm https://raw.githubusercontent.com/Nozeed/Optimize11-By-NOZEED/main/Optimize11-Nozeed.ps1 | iex
```

## สิ่งที่ควรตั้งค่าเพิ่มเองนอกสคริปต์

PowerShell ปรับได้ไม่ทุกอย่าง โดยเฉพาะค่าใน BIOS, GPU driver และบางฟีเจอร์ของ Windows/NVIDIA

- **เปิด XMP / EXPO ใน BIOS**
  ถ้า RAM 32GB ของคุณยังวิ่งไม่เต็มบัส ควรเปิด XMP/EXPO ก่อน

- **เปิด Resizable BAR**
  ถ้าเมนบอร์ดและ BIOS รองรับ ให้เปิดไว้สำหรับ RTX 4060+

- **อัปเดต BIOS / Chipset / Intel ME / NVIDIA Driver**
  ใช้เวอร์ชันเสถียรล่าสุดจากผู้ผลิตเมนบอร์ดและ NVIDIA

- **NVIDIA Control Panel**
  แนะนำสำหรับโปรไฟล์ FiveM / GTA V:
  - Power management mode = `Prefer maximum performance`
  - Low Latency Mode = `On` หรือ `Ultra`
  - Texture filtering - Quality = `High performance`
  - Shader Cache Size = `Driver Default` หรือ `Unlimited`
  - Vertical sync = `Off`
  - Max Frame Rate = ปิด หรือกำหนดตามรีเฟรชเรตจอ

- **Windows Graphics Settings**
  ใส่ `FiveM.exe`, `FiveM_GTAProcess.exe`, `GTA5.exe` เป็น `High performance`

- **เปิด Game Mode ได้ แต่ปิด Xbox overlays**
  โดยทั่วไป Game Mode ยังมีประโยชน์ แต่ Xbox Game Bar / capture overlays มักไม่จำเป็น

- **Hardware-Accelerated GPU Scheduling (HAGS)**
  ให้ลองเปิดแล้วเทสจริงใน FiveM ถ้าดีขึ้นค่อยใช้ต่อ เพราะบางเครื่องดีขึ้น บางเครื่องเฟรมไทม์แกว่ง

- **ปิด startup apps ที่ไม่จำเป็น**
  เช่น launcher, updater, RGB tools ที่ไม่ได้ใช้, auto sync tools

- **Discord / Voice Chat**
  ปิด overlay ถ้าไม่ได้ใช้ และปิด noise/background effects ที่กิน CPU/GPU เกินจำเป็น

- **Browser ที่ใช้ทำงาน**
  ถ้าเปิดแท็บเยอะระหว่างเล่นเกม ให้ปิด extension ที่กิน RAM/CPU มากเกินไป

- **Windsurf / งานเขียนเว็บ**
  ถ้าเครื่องต้องสลับระหว่าง dev กับ gaming บ่อย ให้ปิด dev server หรือ browser tabs ที่ไม่จำเป็นก่อนเข้าเกม จะช่วยให้ `FiveM` ลื่นกว่าเดิม

## หมายเหตุสำคัญ

- **สคริปต์นี้เน้น performance มากกว่า feature completeness**
  บาง service หรือฟีเจอร์ที่ถูกปรับอาจส่งผลกับความสะดวกในการใช้งานบางอย่าง

- **ไม่ควรใช้แบบไม่ดูรายการก่อน ถ้าเครื่องนี้เป็นเครื่องทำงานหลัก**
  แนะนำอ่านรายการ tweak ในไฟล์ `.ps1` ก่อนทุกครั้ง

- **หลังรันเสร็จควรรีสตาร์ตเครื่อง**
  แล้วค่อยทดสอบ FPS, 1% low, frametime และอาการ stutter ใน FiveM/GTA V

## แนะนำการทดสอบหลังปรับแต่ง

- **วัดก่อนและหลัง**
  ใช้ benchmark route เดิม, server เดิม, setting เดิม

- **ดู frametime ไม่ใช่ดูแค่ FPS เฉลี่ย**
  ใช้ MSI Afterburner + RTSS หรือเครื่องมือที่คุณถนัด

- **ถ้าเจอปัญหา**
  ให้ใช้ไฟล์ backup `.reg` ในโฟลเดอร์ `backup-*` เพื่อคืนค่าบางส่วน หรือใช้ System Restore
