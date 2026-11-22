$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$testFiles = Get-ChildItem -Filter "test*.html" | Sort-Object Name

if ($testFiles.Count -eq 0) {
    Write-Host "لم يتم العثور على أي ملفات تبدأ بـ test في المجلد الحالي." -ForegroundColor Yellow
    exit
}

$floatingButton = @"
<!-- START_CHOOSE_BTN -->
<a href="choose.html" title="العودة لقائمة التصاميم" style="
  position: fixed;
  bottom: 18px;
  left: 18px;
  z-index: 99999;
  background: rgba(48, 40, 32, 0.88);
  color: #f4eee4;
  border: 1px solid #c59d5f;
  padding: 10px 16px;
  border-radius: 50px;
  font-family: 'IBM Plex Sans Arabic', Tahoma, sans-serif;
  font-size: 14px;
  font-weight: 600;
  text-decoration: none;
  box-shadow: 0 4px 14px rgba(0,0,0,0.25);
  backdrop-filter: blur(6px);
  display: inline-flex;
  align-items: center;
  gap: 6px;
">
  <span>&#9776;</span>
  <span>اختر تصميماً آخر</span>
</a>
<!-- END_CHOOSE_BTN -->
"@

$buttonsHtml = ""
$index = 1
foreach ($file in $testFiles) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8

    $pageTitle = "نموذج الدعوة رقم $index"
    if ($content -match "<title>(.*?)</title>") {
        $extracted = $matches[1].Trim()
        if ($extracted -ne "") { $pageTitle = $extracted }
    }

    $buttonsHtml += @"
      <a class="design-card" href="$($file.Name)">
        <span class="badge">نسخة $index</span>
        <strong class="title">$pageTitle</strong>
        <span class="file-name">$($file.Name)</span>
      </a>

"@

    $cleanContent = [regex]::Replace($content, "(?s)<!-- START_CHOOSE_BTN -->.*?<!-- END_CHOOSE_BTN -->\s*", "")
    if ($cleanContent -match "</body>") {
        $updatedContent = $cleanContent -replace "</body>", "$floatingButton`r`n</body>"
    } else {
        $updatedContent = $cleanContent + "`r`n" + $floatingButton
    }

    [System.IO.File]::WriteAllText($file.FullName, $updatedContent, (New-Object System.Text.UTF8Encoding $false))
    Write-Host "تم تحديث وحقن الزر في: $($file.Name)" -ForegroundColor Green
    $index++
}

$choosePageHtml = @"
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>اختيار تصميم دعوة زواج المهندس حمزة</title>
  <link rel="icon" type="image/png" href="favicon.png">
  <link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans+Arabic:wght@400;500;600;700&family=Reem+Kufi+Ink&display=swap" rel="stylesheet">
  <style>
    * { box-sizing: border-box; }
    body {
      margin: 0;
      min-height: 100vh;
      background: #f4eee4;
      color: #302820;
      font-family: "IBM Plex Sans Arabic", Tahoma, sans-serif;
      padding: 36px 18px 60px;
    }
    .container { max-width: 640px; margin: 0 auto; text-align: center; }
    .header-tag { color: #a64f35; font-size: 13px; font-weight: 700; margin-bottom: 8px; }
    h1 {
      font-family: "Reem Kufi Ink", serif;
      color: #783a2b;
      font-size: clamp(28px, 6vw, 40px);
      font-weight: 400;
      margin: 0 0 10px;
    }
    p.subtitle { color: #76695b; font-size: 16px; margin: 0 0 32px; line-height: 1.7; }
    .grid { display: grid; gap: 14px; }
    .design-card {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 12px;
      background: #fffdf9;
      border: 1.5px solid rgba(120, 58, 43, 0.25);
      border-radius: 14px;
      padding: 18px 20px;
      text-decoration: none;
      color: #302820;
      transition: 0.2s ease;
      box-shadow: 0 4px 12px rgba(48, 40, 32, 0.05);
    }
    .design-card:hover, .design-card:active {
      border-color: #783a2b;
      background: #faf3e8;
      transform: translateY(-2px);
    }
    .badge {
      background: #783a2b;
      color: #f4eee4;
      padding: 6px 14px;
      border-radius: 50px;
      font-size: 14px;
      font-weight: 700;
      white-space: nowrap;
    }
    .title { font-size: 17px; font-weight: 600; color: #302820; text-align: right; flex: 1; }
    .file-name { font-size: 12px; color: #8c7e6f; direction: ltr; }
    .main-link {
      display: inline-block;
      margin-top: 28px;
      padding: 12px 24px;
      border: 1px dashed #69715a;
      border-radius: 10px;
      color: #69715a;
      text-decoration: none;
      font-size: 14px;
      font-weight: 600;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="header-tag">أفراح آل الحميدي</div>
    <h1>نماذج دعوة زواج حمزة</h1>
    <p class="subtitle">اضغط على أي نموذج أدناه لمعاينته، ويمكنك الرجوع لهذه القائمة في أي وقت من الزر أسفل الشاشة</p>
    <div class="grid">
$buttonsHtml
    </div>
    <a class="main-link" href="index.html">الانتقال إلى الصفحة الرئيسية المعتمدة (index.html)</a>
  </div>
</body>
</html>
"@

[System.IO.File]::WriteAllText((Join-Path (Get-Location) "choose.html"), $choosePageHtml, (New-Object System.Text.UTF8Encoding $false))
Write-Host "`nتم إنشاء صفحة choose.html بنجاح وربط $($testFiles.Count) نماذج!" -ForegroundColor Cyan