<div align="center">
  <img height="250" src="https://pic.4th.in/images/2026/02/07/4B4667B4-770F-437E-95D5-0E94B84C8122.png"  />
</div>
<div align="center">
<h1>Windows-11-Gaming-Optimization-Script-By-NOZEED</h1>
</div>
นี่คือ สคริปต์ PowerShell เวอร์ชันอัปเดต ที่เพิ่ม การตั้งค่ากราฟิกและประสิทธิภาพสำหรับเกม เรียบร้อยแล้ว (จาก tweaks ล่าสุดปี 2025-2026 ที่ safe และ tested จาก community เช่น GitHub, ElevenForum, Reddit)<br>

รวบรวมตามความต้องการของคุณสำหรับ <b>Windows 11</b> โดยเฉพาะเครื่องเล่นเกม (เน้นประสิทธิภาพสูงสุด ลดสิ่งไม่จำเป็น)<br>

<h3>คำเตือนสำคัญมาก</h3>

- สคริปต์นี้ทำการเปลี่ยนแปลงระบบจำนวนมาก (ลบแอป, ปิดฟีเจอร์, ปิดเซอร์วิส, แก้ registry)<br>
- ควร Backup ข้อมูล / สร้างจุดคืนค่า (System Restore Point) ก่อนรัน<br>
- รันด้วย PowerShell แบบ Administrator เท่านั้น<br>
- บางอย่างอาจทำให้ระบบเสียหายถ้าเครื่องคุณใช้งานฟีเจอร์ที่ถูกลบ/ปิด (เช่น ถ้าเคยใช้ Xbox บางส่วน)<br>
- หลังรันเสร็จ แนะนำ รีสตาร์ทเครื่อง ทันที<br><br>

<h3>วิธีใช้งาน</h3>

- เปิด PowerShell ด้วยสิทธิ์ Run as Administrator<br>
- Copy ข้อความในไฟล์ Script v2.0 Nozeed.ps1 ทั้งหมดไปวาง(คลิ๊กขวา)แล้วกด Enter<br>
- รอจนเสร็จ (อาจใช้เวลา 1-15 นาที ขึ้นกับเครื่อง)
- ไฟล์แถม nozeed.nip ใช้ [NVIDIA Profile Inspector](https://github.com/Orbmu2k/nvidiaProfileInspector/releases) ให้ในการ import
<br><br>
<h3>รายละเอียด</h3>
- ลบ ลบ Bloatware ของ Windows 11 และ ปิด Services Disable ที่ไม่จำเป็น<br>
- Hardware-Accelerated GPU Scheduling (HAGS): เปิดเพื่อลด latency (reg: HwSchMode=2)<br>
- Game Mode: เปิดอัตโนมัติ<br>
- Disable Game DVR/Capture: ลด overhead ใน fullscreen<br>
- NVIDIA MPO Disable: ถ้า detect NVIDIA GPU (DisablePreemption=1) เพื่อ low input lag<br>
- Visual Effects to Best Performance: ปิด animations, transparency, menu delay<br>
- Foreground App Priority: CPU prioritize เกม (Win32PrioritySeparation=26)<br>
- Memory Tweaks: DisablePagingExecutive=1, LargeSystemCache=1 (reboot ต้อง)<br>
- Network Latency Tweaks: Disable Nagle (TCPNoDelay=1, TcpAckFrequency=1) สำหรับ online games<br>
- Mouse Precision: ปิด Mouse Acceleration สำหรับ FPS<br>
- Storage Service (storsvc): ปิดตามที่ขอ (เพิ่มใน services)<br>
- High Performance Power Plan: active<br>
- nozeed.nip ตั้งค่า Nvidia Control

