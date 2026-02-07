# Windows-11-Gaming-Optimization-Script-By-NOZEED
นี่คือ สคริปต์ PowerShell เวอร์ชันอัปเดต ที่เพิ่ม การตั้งค่ากราฟิกและประสิทธิภาพสำหรับเกม เรียบร้อยแล้ว (จาก tweaks ล่าสุดปี 2025-2026 ที่ safe และ tested จาก community เช่น GitHub, ElevenForum, Reddit)<br>

นี่คือ สคริปต์ PowerShell ที่รวบรวมตามความต้องการของคุณสำหรับ Windows 11 โดยเฉพาะเครื่องเล่นเกม (เน้นประสิทธิภาพสูงสุด ลดสิ่งไม่จำเป็น)<br>

<h3>คำเตือนสำคัญมาก</h3>

สคริปต์นี้ทำการเปลี่ยนแปลงระบบจำนวนมาก (ลบแอป, ปิดฟีเจอร์, ปิดเซอร์วิส, แก้ registry)
ควร Backup ข้อมูล / สร้างจุดคืนค่า (System Restore Point) ก่อนรัน
รันด้วย PowerShell แบบ Administrator เท่านั้น
บางอย่างอาจทำให้ระบบเสียหายถ้าเครื่องคุณใช้งานฟีเจอร์ที่ถูกลบ/ปิด (เช่น ถ้าเคยใช้ Xbox บางส่วน)
หลังรันเสร็จ แนะนำ รีสตาร์ทเครื่อง ทันที<br>

<h3>วิธีใช้งาน</h3>

เปิด PowerShell ด้วยสิทธิ์ Run as Administrator<br>
Copy ข้อความในไฟล์ Windows 11 Gaming Optimization Script v2.0 By Nozeed.ps1 ทั้งหมดไปวางแล้วกด Enter<br>
รอจนเสร็จ (อาจใช้เวลา 1-15 นาที ขึ้นกับเครื่อง)<br><br>

ลบ bloatware windows 11 และ ปิด Service ที่ไม่จำเป็นออก<br>
Hardware-Accelerated GPU Scheduling (HAGS): เปิดเพื่อลด latency (reg: HwSchMode=2)<br>
Game Mode: เปิดอัตโนมัติ<br>
Disable Game DVR/Capture: ลด overhead ใน fullscreen<br>
NVIDIA MPO Disable: ถ้า detect NVIDIA GPU (DisablePreemption=1) เพื่อ low input lag<br>
Visual Effects to Best Performance: ปิด animations, transparency, menu delay<br>
Foreground App Priority: CPU prioritize เกม (Win32PrioritySeparation=26)<br>
Memory Tweaks: DisablePagingExecutive=1, LargeSystemCache=1 (reboot ต้อง)<br>
Network Latency Tweaks: Disable Nagle (TCPNoDelay=1, TcpAckFrequency=1) สำหรับ online games<br>
Mouse Precision: ปิด Mouse Acceleration สำหรับ FPS<br>
Storage Service (storsvc): ปิดตามที่ขอ (เพิ่มใน services)<br>
Ultimate/High Performance Power Plan: ยืนยัน active

