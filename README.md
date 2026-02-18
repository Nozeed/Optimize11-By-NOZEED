# Windows-11-Gaming-Optimization-Script-By-NOZEED

![Windows 11 Gaming Optimize](https://img.shields.io/badge/Windows-11-0078D4?style=for-the-badge&logo=windows&logoColor=white)
![PowerShell](https://img.shields.io/badge/PowerShell-7.x-blue?style=for-the-badge&logo=powershell&logoColor=white)
![Version](https://img.shields.io/badge/Version-v4-green?style=for-the-badge)

**สคริปต์ PowerShell อัปเดตสำหรับ Windows 11 (รองรับ 24H2 / 25H2 / 26H1 / 26H2)**  
เน้น **ประสิทธิภาพสูงสุดสำหรับเล่นเกม** (ลด latency, ลบ bloatware, ปิด animation/visual effects, tweak GPU/Network/Memory)  
รวบรวม tweaks ล่าสุดปี 2025-2026 ที่ปลอดภัยและ tested จาก community

### คุณสมบัติหลัก (Features v4)
- ลบ **OneDrive** ให้ออกหมดจดจริง (process, uninstaller, folders, registry, prevent reinstall + sidebar)
- ปิด **Visual Effects & Animations** ทั้งหมด → Best Performance mode (MinAnimate=0, TaskbarAnimations=0, Transparency=0, AeroPeek=0)
- ลบ Bloatware / Appx packages ที่ไม่จำเป็น
- คืนค่า **Classic Context Menu** + **Windows Photo Viewer**
- Enable **HAGS**, Game Mode, ปิด Game DVR / MPO
- ตั้ง **CPU Priority** ให้ foreground apps สูงสุด
- Tweak **Memory** (DisablePagingExecutive, LargeSystemCache)
- ลด **Network Latency** (TCPNoDelay, TcpAckFrequency)
- ปิด **Mouse Acceleration** สำหรับ FPS games
- ปิด services ที่ไม่จำเป็น
- Cleanup **WinSXS**

### คำเตือนสำคัญ
- **ต้องรันด้วยสิทธิ์ Administrator**
- **สำรองข้อมูล + สร้าง Restore Point** ก่อนรัน
- รีสตาร์ทเครื่องหลังรันเสร็จทุกครั้ง
- ถ้า OneDrive ยังดื้อ → ลอง `winget uninstall --id Microsoft.OneDrive`

### วิธีรัน (Run Methods)

#### วิธีแนะนำ: รันตรงจาก GitHub (เวอร์ชันล่าสุด v4)
เปิด PowerShell (Admin) แล้ว paste:

```powershell
irm https://raw.githubusercontent.com/Nozeed/Optimize11-By-NOZEED/main/Optimize11-Nozeed-v4.ps1 | iex
