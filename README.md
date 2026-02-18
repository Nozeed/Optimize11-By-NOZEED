# Windows-11-Gaming-Optimization-Script-By-NOZEED

![Windows 11](https://img.shields.io/badge/Windows-11-0078D4?style=for-the-badge&logo=windows&logoColor=white)
![PowerShell](https://img.shields.io/badge/PowerShell-7.x-blue?style=for-the-badge&logo=powershell&logoColor=white)
![Version](https://img.shields.io/badge/Version-v4.4-green?style=for-the-badge)

**สคริปต์ PowerShell สำหรับ Optimize Windows 11 (24H2 / 25H2 / 26H1+)**  
เน้น **เล่นเกมลื่น / ลด latency** + ลบ bloatware + ปิด animation/visual effects + ลดจำนวน process svchost.exe  

### คุณสมบัติหลัก (v4.4)
- ลบ **OneDrive** ให้หมดจด (process, files, registry, prevent reinstall, sidebar)
- ปิด **Visual Effects & Animations** ทั้งหมด (Best Performance + MinAnimate=0, TaskbarAnimations=0, Transparency=0)
- ลบ Bloatware / Appx ที่ไม่จำเป็น (Xbox, Photos, Clipchamp, Teams ฯลฯ)
- คืนค่า **Classic Context Menu** + **Windows Photo Viewer**
- Tweak **Gaming / Latency** (Game Mode, HAGS, MPO off, NetworkThrottlingIndex=ffffffff, TCPNoDelay, Games priority High)
- Disable **Fullscreen Optimizations** globally (ลด input lag ใน borderless)
- ลด **svchost.exe processes** อัตโนมัติ (ตามขนาด RAM × 1.1)
- Disable Mouse Acceleration + Services ที่ไม่จำเป็น (SysMain, DiagTrack, WSearch ฯลฯ)
- Cleanup Component Store (DISM /StartComponentCleanup)

### คำเตือนสำคัญ
- **ต้องรันด้วยสิทธิ์ Administrator**
- **สำรองข้อมูล + สร้าง System Restore Point** ก่อนรัน
- รีสตาร์ทเครื่องหลังรันทุกครั้งเพื่อให้ tweaks มีผลเต็มที่
- Services บางตัวถูก disable (เช่น PrintSpooler) → ถ้าต้องการพิมพ์ ให้เปิดกลับด้วย Services.msc
- DISM /ResetBase อาจ error หรือ ignore ใน Win11 ล่าสุด → ไม่กระทบ tweaks อื่น

### วิธีใช้งาน (Run Methods)

#### วิธีแนะนำ: รันตรงจาก GitHub (เวอร์ชันล่าสุด v4.4)
เปิด **PowerShell** ด้วย **Run as Administrator** แล้ว paste คำสั่งนี้:

```powershell
irm https://raw.githubusercontent.com/Nozeed/Optimize11-By-NOZEED/main/Optimize11-Nozeed-v4.ps1 | iex
