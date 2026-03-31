# Windows-11-Gaming-Optimization-Script-By-NOZEED
 
 ![Windows 11](https://img.shields.io/badge/Windows-11-0078D4?style=for-the-badge&logo=windows&logoColor=white)
 ![PowerShell](https://img.shields.io/badge/PowerShell-7.x-blue?style=for-the-badge&logo=powershell&logoColor=white)
 ![Version](https://img.shields.io/badge/Version-v4-green?style=for-the-badge)
 
 สคริปต์ PowerShell สำหรับปรับแต่ง **Windows 11** ให้เหมาะกับการเล่นเกม ลดความหน่วง และทำให้ระบบโดยรวมเบาลงมากขึ้น
 
 โปรเจกต์นี้เน้นเรื่อง:
 
 - ลบแอปที่ติดมากับระบบและส่วนประกอบของ OneDrive ที่ไม่จำเป็น
 - ลดภาระด้านภาพและ animation ของ Explorer
 - ปรับ registry สำหรับการเล่นเกมและลด latency
 - ปิด mouse acceleration
 - ลดภาระจาก services และ process เบื้องหลัง
 - เพิ่มการปรับแต่งที่เกี่ยวกับ `GTA V` และ `FiveM`
 
 ## คุณสมบัติหลัก
 
 - **ลบ OneDrive**
   - ปิด process ของ OneDrive
   - เรียกตัว uninstall ของ OneDrive หากมีอยู่ในระบบ
   - ลบโฟลเดอร์ OneDrive ที่พบบ่อย
   - ตั้ง policy เพื่อปิดการ sync ของ OneDrive
   - ลบค่า namespace tree pinning ที่เกี่ยวข้อง
 
 - **ลบ Bloatware**
   - ลบ Appx ที่ไม่จำเป็นบางส่วน เช่น Xbox, Teams, Clipchamp, Photos, Wallet, Feedback Hub และแอปอื่น ๆ ตามรายการในสคริปต์
 
 - **ปรับแต่งด้านภาพ**
   - ตั้งค่า visual effects ไปทาง best performance
   - ปิด animation และ transparency
   - รีสตาร์ต Explorer อัตโนมัติ
 
 - **ปรับ UI แบบคลาสสิก**
   - คืนค่า classic context menu ของ Windows 11
   - เปิดใช้งาน Windows Photo Viewer สำหรับไฟล์รูปที่รองรับ
 
 - **ปรับแต่งสำหรับเกมและ latency**
   - ปิด Game DVR ผ่าน policy
   - เปิดค่าที่เกี่ยวข้องกับ Game Mode
   - ตั้งค่า GameConfigStore ที่เกี่ยวข้องกับ fullscreen behavior
   - ปรับ multimedia scheduler สำหรับ task `Games`
   - ตั้งค่า `NetworkThrottlingIndex` และ `SystemResponsiveness`
   - ตั้งค่า `TcpAckFrequency` และ `TCPNoDelay`
   - ตั้งค่า `Win32PrioritySeparation`
   - เปิดใช้ power plan แบบประสิทธิภาพสูง หาก GUID นั้นมีอยู่ในระบบ
   - ปิด hibernation
   - ตั้งค่า monitor timeout และ standby timeout ตอนเสียบไฟเป็น `0`
 
 - **ปรับแต่งสำหรับ FiveM / GTA V**
   - เพิ่ม `PerfOptions` ให้กับ:
     - `GTA5.exe`
     - `FiveM_GTAProcess.exe`
 
 - **ปรับแต่งหน่วยความจำและ services**
   - เปิด `DisablePagingExecutive`
   - เปิด `LargeSystemCache`
   - ปรับ `SvcHostSplitThresholdInKB` ตามปริมาณ RAM ที่ติดตั้ง
   - ปิด services บางตัว เช่น `SysMain`, `WSearch`, `DiagTrack` และตัวอื่น ๆ ตามรายการในสคริปต์
 
 - **ปรับแต่ง input**
   - ปิด mouse acceleration
   - ตั้ง `MenuShowDelay` เป็น `0`
   - ตั้ง `ForegroundLockTimeout` เป็น `0`
 
 - **Cleanup**
   - รัน `DISM /online /Cleanup-Image /StartComponentCleanup /ResetBase`
 
 ## คำเตือนสำคัญ
 
 สคริปต์นี้มีการแก้ไข **ระดับระบบ** โดยตรง
 
 - **ต้องรันด้วยสิทธิ์ Administrator เท่านั้น**
 - **ใช้งานด้วยความเข้าใจและความรับผิดชอบของคุณเอง**
 - **ควรสร้าง Restore Point หรือสำรองข้อมูลก่อนใช้งาน**
 - บางค่าที่ปรับอาจไม่เหมาะกับทุกเครื่องหรือทุกลักษณะการใช้งาน
 - services บางตัวที่ถูกปิดอาจกระทบการพิมพ์ การค้นหา การเขียนด้วยปากกา biometrics การบันทึกภาพ หรือการ troubleshoot บางกรณี
 - แนะนำให้รีสตาร์ตเครื่องหลังรันสคริปต์ทุกครั้ง
 
 ## สภาพแวดล้อมที่รองรับ
 
 - **ระบบปฏิบัติการ**: Windows 11
 - **Shell**: PowerShell
 - **เหมาะสำหรับ**: เครื่องที่เน้นเล่นเกม ลด latency และใช้งาน `GTA V / FiveM`
 
 ## วิธีใช้งาน
 
 ### วิธีที่ 1: รันจากไฟล์ในเครื่อง
 
 1. ดาวน์โหลดหรือ clone repository นี้
 2. คลิกขวา PowerShell แล้วเลือก **Run as Administrator**
 3. รันคำสั่งนี้:
 
 ```powershell
 powershell -ExecutionPolicy Bypass -File .\Optimize11-Nozeed-v4.ps1
 ```
 
 ### วิธีที่ 2: รันตรงจาก GitHub
 
 เปิด **PowerShell แบบ Administrator** แล้วรัน:
 
 ```powershell
 irm https://raw.githubusercontent.com/Nozeed/Optimize11-By-NOZEED/main/Optimize11-Nozeed-v4.ps1 | iex
 ```
 
 ## สคริปต์นี้แก้ไขอะไรบ้าง
 
 ตัวอย่างตำแหน่ง registry และส่วนของระบบที่สคริปต์มีการแก้ไข:
 
 - `HKCU:\Software\Microsoft\GameBar`
 - `HKCU:\System\GameConfigStore`
 - `HKCU:\Control Panel\Mouse`
 - `HKCU:\Control Panel\Desktop`
 - `HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR`
 - `HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile`
 - `HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games`
 - `HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\GTA5.exe\PerfOptions`
 - `HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_GTAProcess.exe\PerfOptions`
 - `HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters`
 - `HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl`
 - `HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management`
 
 ## หมายเหตุ
 
 - `DISM /ResetBase` อาจถูก ignore หรือมี warning บน Windows 11 บาง build
 - ค่าบางตัวใน registry อาจมีอยู่แล้ว หรือถูกควบคุมโดย Windows Update, driver หรือโปรแกรมอื่น
 - สคริปต์พยายามซ่อน error ที่ไม่สำคัญด้วย `SilentlyContinue`
 - สคริปต์มีการยกระดับสิทธิ์เป็น Administrator อัตโนมัติหากยังไม่ได้เปิดด้วยสิทธิ์แอดมิน
 
 ## แนะนำหลังใช้งาน
 
 - รีสตาร์ตเครื่อง
 - ตรวจสอบค่า NVIDIA และกราฟิกในเกมอีกครั้ง
 - ทดสอบ latency, ความนิ่ง, และการใช้งานเบื้องหลัง ก่อนใช้งานจริงทุกวัน
 - เปิด services ที่คุณจำเป็นต้องใช้กลับเองตามการใช้งาน
 
 ## โปรเจกต์
 
 - **Repository**: https://github.com/Nozeed/Optimize11-By-NOZEED
 - **ไฟล์หลัก**: `Optimize11-Nozeed-v4.ps1`
 
 ## ข้อจำกัดความรับผิดชอบ
 
 สคริปต์นี้เผยแพร่ในลักษณะ **as is** ไม่มีการรับประกันใด ๆ คุณควรตรวจสอบและทดสอบการเปลี่ยนแปลงทุกจุดก่อนใช้งานบนเครื่องหลักหรือเครื่องที่ใช้งานประจำของคุณ
